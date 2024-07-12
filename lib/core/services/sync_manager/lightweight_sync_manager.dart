import 'package:canaspad/core/database/app_database.dart';
import 'package:canaspad/core/database/database_manager.dart';
import 'package:canaspad/core/error/app_error.dart';
import 'package:canaspad/core/models/environment_setting.dart';
import 'package:canaspad/core/services/supabase_client_manager.dart';
import 'package:canaspad/providers.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LightweightSyncManager {
  final DatabaseManager _databaseManager;
  final SupabaseClientManager _supabaseClientManager;
  final Logger _logger = Logger('LightweightSyncManager');
  final Ref ref;

  LightweightSyncManager(this._databaseManager, this._supabaseClientManager, this.ref);

  Future<void> performLightweightSync(EnvironmentSetting environment) async {
    _logger.info('Performing lightweight sync');
    final db = await _databaseManager.database;
    final supabase = await _supabaseClientManager.getClientForEnvironment(environment);

    try {
      await _syncSensorsMetadata(db, supabase, environment.id);
      await _syncNumericDataMetadata(db, supabase, environment.id);
      await _syncImageDataMetadata(db, supabase, environment.id);

      _logger.info('Lightweight sync completed successfully');
    } catch (e, stackTrace) {
      _logger.severe('Lightweight sync failed', e, stackTrace);
      ref.read(errorHandlerProvider).handleError(
            AppError('Lightweight sync failed: $e', ErrorType.synchronization, ErrorSeverity.error, originalError: e, stackTrace: stackTrace),
          );
    }
  }

  Future<void> _syncSensorsMetadata(AppDatabase db, SupabaseClient supabase, String environmentId) async {
    final lastSyncTime = await db.getLastSyncTime('sensors');
    final response =
        await supabase.from('SENSOR').select('id, updated_at').gt('updated_at', lastSyncTime.toIso8601String()).eq('environment_id', environmentId);

    for (final sensorMetadata in response) {
      await db.updateSyncMetadata(
        SyncMetadataCompanion.insert(
          table: 'sensors',
          lastSyncedAt: DateTime.parse(sensorMetadata['updated_at']),
          lastSyncedId: Value(sensorMetadata['id']),
        ),
      );
    }
  }

  Future<void> _syncNumericDataMetadata(AppDatabase db, SupabaseClient supabase, String environmentId) async {
    final lastSyncTime = await db.getLastSyncTime('numeric_data');
    final response = await supabase
        .from('NUMERIC_DATA')
        .select('id, created_at')
        .gt('created_at', lastSyncTime.toIso8601String())
        .eq('environment_id', environmentId)
        .order('created_at', ascending: false)
        .limit(1);

    if (response.isNotEmpty) {
      final latestData = response.first;
      await db.updateSyncMetadata(
        SyncMetadataCompanion.insert(
          table: 'numeric_data',
          lastSyncedAt: DateTime.parse(latestData['created_at']),
          lastSyncedId: Value(latestData['id']),
        ),
      );
    }
  }

  Future<void> _syncImageDataMetadata(AppDatabase db, SupabaseClient supabase, String environmentId) async {
    final lastSyncTime = await db.getLastSyncTime('image_data');
    final response = await supabase
        .from('IMAGE_DATA')
        .select('id, created_at')
        .gt('created_at', lastSyncTime.toIso8601String())
        .eq('environment_id', environmentId)
        .order('created_at', ascending: false)
        .limit(1);

    if (response.isNotEmpty) {
      final latestData = response.first;
      await db.updateSyncMetadata(
        SyncMetadataCompanion.insert(
          table: 'image_data',
          lastSyncedAt: DateTime.parse(latestData['created_at']),
          lastSyncedId: Value(latestData['id']),
        ),
      );
    }
  }
}
