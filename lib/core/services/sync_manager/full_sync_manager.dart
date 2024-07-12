import 'dart:io';

import 'package:canaspad/core/database/app_database.dart';
import 'package:canaspad/core/database/database_manager.dart';
import 'package:canaspad/core/error/app_error.dart';
import 'package:canaspad/core/models/environment_setting.dart';
import 'package:canaspad/core/services/supabase_client_manager.dart';
import 'package:canaspad/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

class FullSyncManager {
  final DatabaseManager _databaseManager;
  final SupabaseClientManager _supabaseClientManager;
  final Logger _logger = Logger('FullSyncManager');
  final Ref ref;

  FullSyncManager(this._databaseManager, this._supabaseClientManager, this.ref);

  Future<void> performFullSync(EnvironmentSetting environment) async {
    final db = await _databaseManager.database;
    final client = await _supabaseClientManager.getClientForEnvironment(environment);

    await _syncSensors(db, client, environment.id);
    await _syncNumericData(db, client, environment.id);
    await _syncImageData(db, client, environment.id);
  }

  Future<void> _syncSensors(AppDatabase db, SupabaseClient client, String environmentId) async {
    final startSyncTime = DateTime.now();
    final lastSyncTime = await db.getLastSyncTime('sensors');
    final newSensors = await client.from('SENSOR').select().gt('updated_at', lastSyncTime.toIso8601String()).eq('environment_id', environmentId);

    await db.transaction(() async {
      for (final sensor in newSensors) {
        try {
          await db.upsertSensor(sensor);
        } catch (e, stackTrace) {
          _logger.warning('Failed to sync sensor: ${sensor['id']}', e, stackTrace);
          ref.read(errorHandlerProvider).handleError(AppError('Failed to sync sensor: $e', ErrorType.synchronization, ErrorSeverity.error));
          continue;
        }
      }
    });

    final unsyncedSensors = await (db.select(db.sensors)..where((tbl) => tbl.publicId.equals(''))).get();

    for (final sensor in unsyncedSensors) {
      try {
        final result = await client.from('SENSOR').insert({
          'group_name': sensor.groupName,
          'name': sensor.name,
          'sensor_type': sensor.sensorType,
          'created_at': sensor.createdAt.toIso8601String(),
          'updated_at': sensor.updatedAt.toIso8601String(),
          'created_by': sensor.createdBy,
          'environment_id': environmentId,
        });

        if (result.error == null) {
          await db.update(db.sensors).replace(sensor.copyWith(publicId: result.data[0]['id']));
        } else {
          _logger.warning('Failed to insert sensor to Supabase: ${sensor.id}', result.error);
          ref.read(errorHandlerProvider).handleError(AppError('Failed to insert sensor to Supabase: ${result.error}', ErrorType.database, ErrorSeverity.error));
        }
      } catch (e, stackTrace) {
        _logger.warning('Failed to sync sensor: ${sensor.id}', e, stackTrace);
        ref.read(errorHandlerProvider).handleError(AppError('Failed to sync sensor: $e', ErrorType.synchronization, ErrorSeverity.error));
      }
    }

    await db.updateLastSyncTime('sensors', startSyncTime);
  }

  Future<void> _syncNumericData(AppDatabase db, SupabaseClient client, String environmentId) async {
    final startSyncTime = DateTime.now();
    final lastSyncTime = await db.getLastSyncTime('numeric_data');
    final newNumericData = await client.from('NUMERIC_DATA').select().gt('created_at', lastSyncTime.toIso8601String()).eq('environment_id', environmentId);

    await db.transaction(() async {
      for (final data in newNumericData) {
        try {
          await db.upsertNumericData(data);
        } catch (e, stackTrace) {
          _logger.warning('Failed to sync numeric data: ${data['id']}', e, stackTrace);
          ref.read(errorHandlerProvider).handleError(AppError('Failed to sync numeric data: $e', ErrorType.synchronization, ErrorSeverity.error));
          continue;
        }
      }
    });

    final unsyncedNumericData = await (db.select(db.numericData)..where((tbl) => tbl.publicId.equals(''))).get();

    for (final numericData in unsyncedNumericData) {
      try {
        final sensorData = await (db.select(db.sensorData)..where((tbl) => tbl.id.equals(numericData.id))).getSingle();
        final result = await client.from('NUMERIC_DATA').insert({
          'sensor_id': sensorData.sensorPublicId,
          'value': numericData.value,
          'created_at': sensorData.timestamp.toIso8601String(),
          'created_by': sensorData.createdByUserId,
          'environment_id': environmentId,
        });

        if (result.error == null) {
          await db.update(db.numericData).replace(numericData.copyWith(publicId: result.data[0]['id']));
        } else {
          _logger.warning('Failed to insert numeric data to Supabase: ${numericData.id}', result.error);
          ref
              .read(errorHandlerProvider)
              .handleError(AppError('Failed to insert numeric data to Supabase: ${result.error}', ErrorType.database, ErrorSeverity.error));
        }
      } catch (e, stackTrace) {
        _logger.warning('Failed to sync numeric data: ${numericData.id}', e, stackTrace);
        ref.read(errorHandlerProvider).handleError(AppError('Failed to sync numeric data: $e', ErrorType.synchronization, ErrorSeverity.error));
      }
    }

    await db.updateLastSyncTime('numeric_data', startSyncTime);
  }

  Future<void> _syncImageData(AppDatabase db, SupabaseClient client, String environmentId) async {
    final startSyncTime = DateTime.now();
    final lastSyncTime = await db.getLastSyncTime('image_data');
    final newImageData = await client.from('IMAGE_DATA').select().gt('created_at', lastSyncTime.toIso8601String()).eq('environment_id', environmentId);

    await db.transaction(() async {
      for (final data in newImageData) {
        try {
          await db.upsertImageData(data);
        } catch (e, stackTrace) {
          _logger.warning('Failed to sync image data: ${data['id']}', e, stackTrace);
          ref.read(errorHandlerProvider).handleError(AppError('Failed to sync image data: $e', ErrorType.synchronization, ErrorSeverity.error));
          continue;
        }
      }
    });

    final unsyncedImageData = await (db.select(db.imageData)..where((tbl) => tbl.publicId.equals(''))).get();

    for (final imageData in unsyncedImageData) {
      try {
        final sensorData = await (db.select(db.sensorData)..where((tbl) => tbl.id.equals(imageData.id))).getSingle();
        final file = File(imageData.filePath);
        final fileName = p.basename(imageData.filePath);
        final uploadResult = await client.storage.from('sensor-images').upload(fileName, file);

        if (uploadResult == null) {
          final publicUrl = client.storage.from('sensor-images').getPublicUrl(fileName);
          final result = await client.from('IMAGE_DATA').insert({
            'sensor_id': sensorData.sensorPublicId,
            'file_path': publicUrl,
            'created_at': sensorData.timestamp.toIso8601String(),
            'created_by': sensorData.createdByUserId,
            'environment_id': environmentId,
          });

          if (result.error == null) {
            await db.update(db.imageData).replace(imageData.copyWith(publicId: result.data[0]['id']));
          } else {
            _logger.warning('Failed to insert image data to Supabase: ${imageData.id}', result.error);
            ref
                .read(errorHandlerProvider)
                .handleError(AppError('Failed to insert image data to Supabase: ${result.error}', ErrorType.database, ErrorSeverity.error));
          }
        } else {
          _logger.warning('Failed to upload image to Supabase Storage: ${imageData.id}', uploadResult);
          ref
              .read(errorHandlerProvider)
              .handleError(AppError('Failed to upload image to Supabase Storage: ${uploadResult}', ErrorType.storage, ErrorSeverity.error));
        }
      } catch (e, stackTrace) {
        _logger.warning('Failed to sync image data: ${imageData.id}', e, stackTrace);
        ref.read(errorHandlerProvider).handleError(AppError('Failed to sync image data: $e', ErrorType.synchronization, ErrorSeverity.error));
      }
    }

    await db.updateLastSyncTime('image_data', startSyncTime);
  }
}
