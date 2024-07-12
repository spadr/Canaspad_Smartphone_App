import 'dart:io';

import 'package:canaspad/core/database/app_database.dart';
import 'package:canaspad/core/database/database_manager.dart';
import 'package:canaspad/core/error/error_handler.dart';
import 'package:canaspad/core/services/connectivity_service.dart';
import 'package:canaspad/core/services/mock_flutter_secure_storage.dart';
import 'package:canaspad/core/services/notification_service.dart';
import 'package:canaspad/core/services/supabase_client_manager.dart';
import 'package:canaspad/core/services/sync_manager/background_sync_manager.dart';
import 'package:canaspad/core/services/sync_manager/full_sync_manager.dart';
import 'package:canaspad/core/services/sync_manager/lightweight_sync_manager.dart';
import 'package:canaspad/core/services/sync_manager/network_aware_sync_manager.dart';
import 'package:canaspad/core/services/sync_manager/offline_operation_manager.dart';
import 'package:canaspad/core/services/sync_manager/realtime_sync_manager.dart';
import 'package:canaspad/core/services/sync_service.dart';
import 'package:canaspad/features/environment/services/environment_service.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core_old/services/auth_service.dart';
import 'core_old/services/secure_storage_service.dart';
import 'core_old/services/supabase_service.dart';
import 'features_old/environment/models/environment_model.dart';
import 'features_old/notification/viewmodels/notification_viewmodel.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final flavor = ref.watch(flavorProvider);
  if (flavor == 'develop') {
    return MockAuthService();
  } else {
    return SupabaseAuthService();
  }
});

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  final flavor = ref.watch(flavorProvider);
  if (flavor == 'develop') {
    return MockSupabaseService();
  } else {
    final client = Supabase.instance.client;
    final notificationViewModel = ref.read(notificationViewModelProvider.notifier);
    return RealSupabaseService(client, notificationViewModel);
  }
});

final mockSupabaseServiceProvider = Provider<SupabaseService>((ref) {
  return MockSupabaseService();
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  final flavor = ref.watch(flavorProvider);
  if (flavor == 'develop') {
    return MockSecureStorageService();
  } else {
    return FlutterSecureStorageService();
  }
});

final flavorProvider = StateProvider<String>((ref) => 'production');
final selectedEnvironmentProvider = StateProvider<EnvironmentModel?>((ref) => null);

class MockFlutterLocalNotificationsPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

final notificationPluginProvider = Provider<FlutterLocalNotificationsPlugin>((ref) {
  final flavor = ref.watch(flavorProvider);
  if (flavor == 'develop') {
    return MockFlutterLocalNotificationsPlugin();
  } else {
    return FlutterLocalNotificationsPlugin();
  }
});

final notificationViewModelProvider = StateNotifierProvider<NotificationViewModel, NotificationState>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);
  final localNotifications = ref.watch(notificationPluginProvider);
  return NotificationViewModel(storage, localNotifications);
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  final flavor = ref.watch(flavorProvider);
  if (flavor == 'develop') {
    return MockFlutterSecureStorage();
  } else {
    return const FlutterSecureStorage();
  }
});

final supabaseClientManagerProvider = Provider<SupabaseClientManager>((ref) {
  final environmentService = ref.watch(environmentServiceProvider);
  return SupabaseClientManager(environmentService);
});

final environmentServiceProvider = Provider<EnvironmentService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final flavor = ref.watch(flavorProvider);
  return EnvironmentService(secureStorage, flavor);
});

final databaseProvider = Provider<AppDatabase>((ref) {
  final lazyDatabase = LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
  return AppDatabase(lazyDatabase);
});

final databaseManagerProvider = Provider<DatabaseManager>((ref) {
  return DatabaseManager(ref.read(databaseProvider as ProviderListenable<LazyDatabase>));
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(FlutterLocalNotificationsPlugin());
});

final realtimeSyncManagerProvider = Provider<RealtimeSyncManager>((ref) {
  final databaseManager = ref.watch(databaseManagerProvider);
  final supabaseClientManager = ref.watch(supabaseClientManagerProvider);
  return RealtimeSyncManager(databaseManager, supabaseClientManager, ref);
});

final offlineOperationManagerProvider = Provider<OfflineOperationManager>((ref) {
  final databaseManager = ref.watch(databaseManagerProvider);
  return OfflineOperationManager(databaseManager, ref);
});

final lightweightSyncManagerProvider = Provider<LightweightSyncManager>((ref) {
  final databaseManager = ref.watch(databaseManagerProvider);
  final supabaseClientManager = ref.watch(supabaseClientManagerProvider);
  return LightweightSyncManager(databaseManager, supabaseClientManager, ref);
});

final fullSyncManagerProvider = Provider<FullSyncManager>((ref) {
  final databaseManager = ref.watch(databaseManagerProvider);
  final supabaseClientManager = ref.watch(supabaseClientManagerProvider);
  return FullSyncManager(databaseManager, supabaseClientManager, ref);
});

final backgroundSyncManagerProvider = Provider<BackgroundSyncManager>((ref) {
  return BackgroundSyncManager();
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  final environmentService = ref.watch(environmentServiceProvider);
  final offlineOperationManager = ref.watch(offlineOperationManagerProvider);
  final realtimeSyncManager = ref.watch(realtimeSyncManagerProvider);
  final lightweightSyncManager = ref.watch(lightweightSyncManagerProvider);
  final fullSyncManager = ref.watch(fullSyncManagerProvider);
  final backgroundSyncManager = ref.watch(backgroundSyncManagerProvider);

  return SyncService(
    connectivityService,
    environmentService,
    offlineOperationManager,
    realtimeSyncManager,
    lightweightSyncManager,
    fullSyncManager,
    backgroundSyncManager,
    ref,
  );
});

final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  final navigatorKey = ref.watch(navigatorKeyProvider);
  return ErrorHandler(navigatorKey);
});

final networkAwareSyncManagerProvider = Provider<NetworkAwareSyncManager>((ref) {
  final databaseManager = ref.watch(databaseManagerProvider);
  final supabaseClientManager = ref.watch(supabaseClientManagerProvider);
  return NetworkAwareSyncManager(databaseManager, supabaseClientManager, ref);
});
