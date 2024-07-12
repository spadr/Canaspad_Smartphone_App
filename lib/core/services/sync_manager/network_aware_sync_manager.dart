import 'dart:io';

import 'package:canaspad/core/error/app_error.dart';
import 'package:canaspad/core/models/environment_setting.dart';
import 'package:canaspad/providers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

import '../../database/database_manager.dart';
import '../supabase_client_manager.dart';

class NetworkAwareSyncManager {
  final DatabaseManager _databaseManager;
  final SupabaseClientManager _supabaseClientManager;
  final _logger = Logger('NetworkAwareSyncManager');
  final Ref ref;

  NetworkAwareSyncManager(
    this._databaseManager,
    this._supabaseClientManager,
    this.ref,
  );

  Future<void> syncImageData(EnvironmentSetting environment) async {
    if (await _isWifiConnected()) {
      await _syncLargeData(environment);
    } else {
      _logger.info('Skipping large data sync due to no WiFi connection');
    }
  }

  Future<bool> _isWifiConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult == ConnectivityResult.wifi;
  }

  Future<void> _syncLargeData(EnvironmentSetting environment) async {
    try {
      final db = await _databaseManager.database;
      final supabase = await _supabaseClientManager.getClientForEnvironment(environment);

      final lastImageSyncTime = await db.getLastSyncTime('image_data');
      final newImageData = await supabase.from('IMAGE_DATA').select().gt('created_at', lastImageSyncTime.toIso8601String());

      for (final imageData in newImageData) {
        // Download image file
        final imageUrl = imageData['file_path'];
        final response = await supabase.storage.from('sensor-images').download(imageUrl);

        // Save image file locally
        final localPath = await _saveImageLocally(response, imageData['id']);

        // Update local database
        await db.upsertImageData({
          ...imageData,
          'local_file_path': localPath,
        });
      }

      await db.updateLastSyncTime('image_data', DateTime.now());
    } catch (e, stackTrace) {
      _logger.severe('Large data sync failed', e, stackTrace);
      // エラーハンドラを使ってエラーを処理
      ref.read(errorHandlerProvider).handleError(AppError('Large data sync failed: $e', ErrorType.synchronization, ErrorSeverity.error));
    }
  }

  Future<String> _saveImageLocally(List<int> bytes, String imageId) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/images/$imageId.jpg');
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
