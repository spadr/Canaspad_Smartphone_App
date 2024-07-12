// lib/core/services/periodic_sync_manager.dart

import 'dart:async';

import 'package:canaspad/core/error/app_error.dart';
import 'package:canaspad/core/models/environment_setting.dart';
import 'package:canaspad/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../database/database_manager.dart';
import '../supabase_client_manager.dart';

class PeriodicSyncManager {
  final DatabaseManager _databaseManager;
  final SupabaseClientManager _supabaseClientManager;
  Timer? _syncTimer;
  final _logger = Logger('PeriodicSyncManager');
  final Ref ref;

  PeriodicSyncManager(this._databaseManager, this._supabaseClientManager, this.ref);

  void startPeriodicSync({Duration period = const Duration(hours: 1), required EnvironmentSetting environment}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(period, (_) => _performSync(environment));
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  Future<void> _performSync(EnvironmentSetting environment) async {
    try {
      final db = await _databaseManager.database;
      final supabase = await _supabaseClientManager.getClientForEnvironment(environment);

      // Sync sensors
      final lastSyncTime = await db.getLastSyncTime('sensors');
      final newSensors = await supabase.from('SENSOR').select().gt('updated_at', lastSyncTime.toIso8601String());

      for (final sensor in newSensors) {
        await db.upsertSensor(sensor);
      }

      // Sync sensor data
      final lastDataSyncTime = await db.getLastSyncTime('sensor_data');
      final newData = await supabase.from('BASE_DATA').select().gt('created_at', lastDataSyncTime.toIso8601String());

      for (final data in newData) {
        await db.insertSensorData(data);
      }

      // Update last sync time
      await db.updateLastSyncTime('sensors', DateTime.now());
      await db.updateLastSyncTime('sensor_data', DateTime.now());

      _logger.info('Periodic sync completed successfully');
    } catch (e, stackTrace) {
      _logger.severe('Periodic sync failed', e, stackTrace);
      // エラーハンドラを使ってエラーを処理
      ref.read(errorHandlerProvider).handleError(AppError('Periodic sync failed: $e', ErrorType.synchronization, ErrorSeverity.error));
    }
  }
}

final periodicSyncManagerProvider = Provider<PeriodicSyncManager>((ref) {
  final databaseManager = ref.watch(databaseManagerProvider);
  final supabaseClientManager = ref.watch(supabaseClientManagerProvider);
  return PeriodicSyncManager(databaseManager, supabaseClientManager, ref);
});
