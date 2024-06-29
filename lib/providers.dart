// lib/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/services/auth_service.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/supabase_service.dart';
import 'features/environment/models/environment_model.dart';

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
    return RealSupabaseService(client);
  }
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

// モックのSupabaseサービスプロバイダー
final mockSupabaseServiceProvider = Provider<SupabaseService>((ref) {
  return MockSupabaseService();
});
