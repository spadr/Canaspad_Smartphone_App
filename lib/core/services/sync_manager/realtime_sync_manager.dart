import 'dart:async';

import 'package:canaspad/core/database/app_database.dart';
import 'package:canaspad/core/database/database_manager.dart';
import 'package:canaspad/core/error/app_error.dart';
import 'package:canaspad/core/models/environment_setting.dart';
import 'package:canaspad/providers.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../supabase_client_manager.dart';

class RealtimeSyncManager {
  final DatabaseManager _databaseManager;
  final SupabaseClientManager _supabaseClientManager;
  final _logger = Logger('RealtimeSyncManager');
  final Ref ref;

  List<StreamSubscription> _subscriptions = [];

  RealtimeSyncManager(this._databaseManager, this._supabaseClientManager, this.ref);

  Future<void> initialize(EnvironmentSetting environment) async {
    final supabase = await _supabaseClientManager.getClientForEnvironment(environment);
    final db = await _databaseManager.database;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      _logger.warning('User is not logged in, skipping realtime sync');
      return;
    }

    try {
      supabase.from('SENSOR').stream(primaryKey: ['id']).eq('created_by', userId).listen((event) {
            _handleSensorUpdate(db, event, environment.id);
          });

      supabase.from('BASE_DATA').stream(primaryKey: ['id']).eq('created_by', userId).listen((event) {
            _handleBaseDataUpdate(db, event, environment.id);
          });

      supabase.from('NUMERIC_DATA').stream(primaryKey: ['id']).eq('created_by', userId).listen((event) {
            _handleNumericDataUpdate(db, event, environment.id);
          });

      supabase.from('IMAGE_DATA').stream(primaryKey: ['id']).eq('created_by', userId).listen((event) {
            _handleImageDataUpdate(db, event, environment.id);
          });
    } catch (e, stackTrace) {
      _logger.severe('Failed to setup realtime sync', e, stackTrace);
      // エラーハンドラを使ってエラーを処理
      ref.read(errorHandlerProvider).handleError(AppError('Failed to setup realtime sync: $e', ErrorType.synchronization, ErrorSeverity.error));
    }
  }

  void _handleSensorUpdate(AppDatabase db, List<Map<String, dynamic>> event, String environmentId) {
    for (var sensorData in event) {
      final sensor = SensorsCompanion.insert(
        id: Value(sensorData['id']),
        publicId: sensorData['id'],
        groupName: sensorData['group_name'],
        name: sensorData['name'],
        sensorType: sensorData['sensor_type'],
        createdAt: DateTime.parse(sensorData['created_at']),
        updatedAt: DateTime.parse(sensorData['updated_at']),
        createdBy: Value(sensorData['created_by']),
        environmentId: environmentId,
      );
      db.into(db.sensors).insertOnConflictUpdate(sensor);

      if (sensorData['sensor_type'] == 'numeric') {
        final numericSensor = NumericSensorsCompanion.insert(
          id: Value(sensorData['id']),
          publicId: sensorData['id'],
          unit: sensorData['unit'],
          environmentId: environmentId,
        );
        db.into(db.numericSensors).insertOnConflictUpdate(numericSensor);
      } else if (sensorData['sensor_type'] == 'image') {
        final imageSensor = ImageSensorsCompanion.insert(
          id: Value(sensorData['id']),
          publicId: sensorData['id'],
          resolution: sensorData['resolution'],
          environmentId: environmentId,
        );
        db.into(db.imageSensors).insertOnConflictUpdate(imageSensor);
      }
    }
  }

  void _handleBaseDataUpdate(AppDatabase db, List<Map<String, dynamic>> event, String environmentId) {
    for (var baseData in event) {
      final data = SensorDataCompanion.insert(
        id: Value(baseData['id']),
        publicId: baseData['id'],
        sensorPublicId: baseData['sensor_id'],
        timestamp: DateTime.parse(baseData['timestamp']),
        createdByUserId: Value(baseData['created_by']),
        environmentId: environmentId,
      );
      db.into(db.sensorData).insertOnConflictUpdate(data);
    }
  }

  void _handleNumericDataUpdate(AppDatabase db, List<Map<String, dynamic>> event, String environmentId) {
    for (var numericData in event) {
      final data = NumericDataCompanion.insert(
        id: Value(numericData['id']),
        publicId: numericData['id'],
        value: numericData['value'],
        environmentId: environmentId,
      );
      db.into(db.numericData).insertOnConflictUpdate(data);
    }
  }

  void _handleImageDataUpdate(AppDatabase db, List<Map<String, dynamic>> event, String environmentId) {
    for (var imageData in event) {
      final data = ImageDataCompanion.insert(
        id: Value(imageData['id']),
        publicId: imageData['id'],
        filePath: imageData['file_path'],
        environmentId: environmentId,
      );
      db.into(db.imageData).insertOnConflictUpdate(data);
    }
  }

  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _logger.info('RealtimeSyncManager disposed');
  }
}
