import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/services/auth_service.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/supabase_service.dart';
import 'features/environment/models/environment_model.dart';
import 'features/notification/viewmodels/notification_viewmodel.dart';

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

// モックの SupabaseService プロバイダーを追加
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
