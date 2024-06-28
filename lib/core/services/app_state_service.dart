import 'dart:convert';

import 'package:canaspad/core/services/auth_service.dart';
import 'package:canaspad/core/services/secure_storage_service.dart';
import 'package:canaspad/core/services/supabase_service.dart';
import 'package:canaspad/features/environment/models/environment_model.dart';
import 'package:canaspad/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppStateService extends StateNotifier<AsyncValue<EnvironmentModel?>> {
  final AuthService _authService;
  final SecureStorageService _secureStorageService;
  final SupabaseService _supabaseService;

  AppStateService(this._authService, this._secureStorageService, this._supabaseService) : super(const AsyncValue.loading()) {
    initializeApp();
  }

  Future<void> initializeApp() async {
    state = const AsyncValue.loading();
    try {
      await _supabaseService.fetchAllData();
      final environment = await _secureStorageService.readEnvironment();
      if (environment != null) {
        await login(environment);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> login(EnvironmentModel environment) async {
    try {
      await _authService.signIn(
        environment.emailAddress ?? '',
        environment.password ?? '',
      );
      state = AsyncValue.data(environment);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> changeEnvironment(EnvironmentModel newEnvironment) async {
    await _secureStorageService.writeSecureData(
      'envSettings',
      jsonEncode([newEnvironment.toJson()]),
    );
    await login(newEnvironment);
  }
}

final appStateServiceProvider = StateNotifierProvider<AppStateService, AsyncValue<EnvironmentModel?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final secureStorageService = ref.watch(secureStorageServiceProvider);
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AppStateService(authService, secureStorageService, supabaseService);
});
