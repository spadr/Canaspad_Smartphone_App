import 'dart:async';

import 'package:canaspad/core/models/environment_setting.dart';
import 'package:canaspad/core/services/connectivity_service.dart';
import 'package:canaspad/core/services/sync_manager/full_sync_manager.dart';
import 'package:canaspad/core/services/sync_manager/lightweight_sync_manager.dart';
import 'package:canaspad/core/services/sync_manager/offline_operation_manager.dart';
import 'package:canaspad/core/services/sync_manager/realtime_sync_manager.dart';
import 'package:canaspad/features/environment/services/environment_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import 'sync_manager/background_sync_manager.dart';

class SyncService {
  final ConnectivityService _connectivityService;
  final EnvironmentService _environmentService;
  final OfflineOperationManager _offlineOperationManager;
  final RealtimeSyncManager _realtimeSyncManager;
  final LightweightSyncManager _lightweightSyncManager;
  final FullSyncManager _fullSyncManager;
  final BackgroundSyncManager _backgroundSyncManager;
  final Logger _logger = Logger('SyncService');
  final Ref ref;

  SyncService(
    this._connectivityService,
    this._environmentService,
    this._offlineOperationManager,
    this._realtimeSyncManager,
    this._lightweightSyncManager,
    this._fullSyncManager,
    this._backgroundSyncManager,
    this.ref,
  );

  Future<void> sync() async {
    if (await _connectivityService.isConnected()) {
      final environments = await _environmentService.getEnvironmentSettings();
      for (final environment in environments) {
        await _fullSyncManager.performFullSync(environment);
      }
    } else {
      await _offlineOperationManager.recordOfflineOperations();
    }
  }

  Future<void> setupRealtimeSync(EnvironmentSetting environment) async {
    await _realtimeSyncManager.initialize(environment);
  }

  Future<void> performLightweightSync(EnvironmentSetting environment) async {
    await _lightweightSyncManager.performLightweightSync(environment);
  }

  Future<void> performManualSync() async {
    _logger.info('Performing manual sync');
    await sync();
  }

  Future<void> setupBackgroundSync() async {
    await _backgroundSyncManager.initialize();
  }

  void dispose() {
    _realtimeSyncManager.dispose();
  }
}
