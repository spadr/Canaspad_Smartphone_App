import 'dart:convert';

import 'package:canaspad/core/database/app_database.dart';
import 'package:canaspad/core/database/database_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OfflineOperationManager {
  final DatabaseManager _databaseManager;
  final Logger _logger = Logger('OfflineOperationManager');
  final Ref ref;

  OfflineOperationManager(this._databaseManager, this.ref);

  Future<void> recordOfflineOperations() async {
    _logger.info('Recording offline operations');
    final db = await _databaseManager.database;

    await db.transaction(() async {
      await _recordSensorOfflineOperations(db);
      await _recordNumericDataOfflineOperations(db);
      await _recordImageDataOfflineOperations(db);
    });
  }

  Future<void> _recordSensorOfflineOperations(AppDatabase db) async {
    final unsyncedSensors = await (db.select(db.sensors)..where((tbl) => tbl.publicId.equals(''))).get();
    for (final sensor in unsyncedSensors) {
      await db.into(db.offlineOperations).insert(
            OfflineOperationsCompanion.insert(
              table: 'sensors',
              operation: 'INSERT',
              recordId: sensor.id.toString(),
              data: jsonEncode(sensor.toJson()),
              createdAt: DateTime.now(),
            ),
          );
    }
  }

  Future<void> _recordNumericDataOfflineOperations(AppDatabase db) async {
    final unsyncedNumericData = await (db.select(db.numericData)..where((tbl) => tbl.publicId.equals(''))).get();
    for (final numericData in unsyncedNumericData) {
      await db.into(db.offlineOperations).insert(
            OfflineOperationsCompanion.insert(
              table: 'numeric_data',
              operation: 'INSERT',
              recordId: numericData.id.toString(),
              data: jsonEncode(numericData.toJson()),
              createdAt: DateTime.now(),
            ),
          );
    }
  }

  Future<void> _recordImageDataOfflineOperations(AppDatabase db) async {
    final unsyncedImageData = await (db.select(db.imageData)..where((tbl) => tbl.publicId.equals(''))).get();
    for (final imageData in unsyncedImageData) {
      await db.into(db.offlineOperations).insert(
            OfflineOperationsCompanion.insert(
              table: 'image_data',
              operation: 'INSERT',
              recordId: imageData.id.toString(),
              data: jsonEncode(imageData.toJson()),
              createdAt: DateTime.now(),
            ),
          );
    }
  }

  Future<void> applyOfflineOperations(SupabaseClient client) async {
    final db = await _databaseManager.database;
    final offlineOperations = await db.select(db.offlineOperations).get();

    for (final operation in offlineOperations) {
      try {
        await _applyOfflineOperation(operation, client);
        await db.delete(db.offlineOperations).delete(operation);
      } catch (e, stackTrace) {
        _logger.severe('Failed to apply offline operation', e, stackTrace);
        // エラーハンドリング（再試行ロジックやユーザー通知など）
      }
    }
  }

  Future<void> _applyOfflineOperation(OfflineOperation operation, SupabaseClient client) async {
    final db = await _databaseManager.database;
    final data = jsonDecode(operation.data);

    switch (operation.table) {
      case 'sensors':
        await _applySensorOperation(db, operation.operation, data, client);
        break;
      case 'numeric_data':
        await _applyNumericDataOperation(db, operation.operation, data, client);
        break;
      case 'image_data':
        await _applyImageDataOperation(db, operation.operation, data, client);
        break;
      default:
        throw Exception('Unknown table: ${operation.table}');
    }
  }

  Future<void> _applySensorOperation(AppDatabase db, String operation, Map<String, dynamic> data, SupabaseClient client) async {
    switch (operation) {
      case 'INSERT':
        final result = await client.from('SENSOR').insert(data);
        if (result.error == null) {
          final updatedSensor = Sensor.fromJson(data).copyWith(publicId: result.data[0]['id']);
          await db.update(db.sensors).replace(updatedSensor);
        } else {
          throw Exception('Failed to insert sensor: ${result.error}');
        }
        break;
      // UPDATE と DELETE の処理を追加
    }
  }

  Future<void> _applyNumericDataOperation(AppDatabase db, String operation, Map<String, dynamic> data, SupabaseClient client) async {
    switch (operation) {
      case 'INSERT':
        final result = await client.from('NUMERIC_DATA').insert(data);
        if (result.error == null) {
          final updatedNumericData = NumericDataData.fromJson(data).copyWith(publicId: result.data[0]['id']);
          await db.update(db.numericData).replace(updatedNumericData);
        } else {
          throw Exception('Failed to insert numeric data: ${result.error}');
        }
        break;
      // UPDATE と DELETE の処理を追加
    }
  }

  Future<void> _applyImageDataOperation(AppDatabase db, String operation, Map<String, dynamic> data, SupabaseClient client) async {
    switch (operation) {
      case 'INSERT':
        final result = await client.from('IMAGE_DATA').insert(data);
        if (result.error == null) {
          final updatedImageData = ImageDataData.fromJson(data).copyWith(publicId: result.data[0]['id']);
          await db.update(db.imageData).replace(updatedImageData);
        } else {
          throw Exception('Failed to insert image data: ${result.error}');
        }
        break;
      // UPDATE と DELETE の処理を追加
    }
  }
}
