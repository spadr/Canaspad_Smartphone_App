import 'package:canaspad/core/error/app_error.dart';
import 'package:canaspad/core/services/notification_service.dart';
import 'package:canaspad/core/utils/error_logger.dart';
import 'package:canaspad/providers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class BackgroundSyncManager {
  static const int maxRetries = 3;
  static const String retryCountKey = 'background_sync_retry_count';
  static const String taskName = 'backgroundSync';

  Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );

    await Workmanager().registerPeriodicTask(
      "backgroundSync",
      taskName,
      frequency: const Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }

  static Future<void> callbackDispatcher() async {
    Workmanager().executeTask((task, inputData) async {
      final container = ProviderContainer();
      final syncService = container.read(syncServiceProvider);
      final errorHandler = container.read(errorHandlerProvider);
      final notificationService = container.read(notificationServiceProvider);

      try {
        final retryCount = await _getRetryCount();
        if (retryCount >= maxRetries) {
          await _resetRetryCount();
          await _notifyUser(notificationService, 'Background sync failed after multiple attempts.');
          return false;
        }

        await syncService.sync();
        await _resetRetryCount();
        return true;
      } catch (e, stackTrace) {
        ErrorLogger.logError(e, stackTrace);
        await _incrementRetryCount();

        errorHandler.handleError(
          AppError(
            'Background sync failed',
            ErrorType.synchronization,
            ErrorSeverity.error,
            originalError: e,
            stackTrace: stackTrace,
          ),
        );

        // Schedule a retry
        await Workmanager().registerOneOffTask(
          'retry_background_sync',
          'backgroundSync',
          initialDelay: const Duration(minutes: 15), // Retry after 15 minutes
        );

        return false;
      }
    });
  }

  static Future<int> _getRetryCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(retryCountKey) ?? 0;
  }

  static Future<void> _incrementRetryCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(retryCountKey) ?? 0;
    await prefs.setInt(retryCountKey, currentCount + 1);
  }

  static Future<void> _resetRetryCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(retryCountKey, 0);
  }

  static Future<void> _notifyUser(NotificationService notificationService, String message) async {
    await notificationService.showNotification(
      'Sync Error',
      message,
      importance: Importance.high,
      priority: Priority.high,
    );
  }
}
