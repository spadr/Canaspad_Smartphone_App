import 'package:canaspad/core/services/auth_service.dart';
import 'package:canaspad/core/services/secure_storage_service.dart';
import 'package:canaspad/core/services/supabase_service.dart';
import 'package:canaspad/features/environment/models/environment_model.dart';
import 'package:canaspad/features/initialization/viewmodels/initialization_viewmodel.dart';
import 'package:canaspad/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppStateService extends StateNotifier<AsyncValue<EnvironmentModel?>> {
  final AuthService _authService;
  final SecureStorageService _secureStorageService;
  final SupabaseService _supabaseService;
  final Ref _ref;

  AppStateService(this._authService, this._secureStorageService, this._supabaseService, this._ref) : super(const AsyncValue.loading()) {
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
        // ここで環境が設定されていない場合の処理を行う
        final initializationViewModel = _ref.read(initializationViewModelProvider);
        await initializationViewModel.initializeApp();
        // 再度環境を読み込む
        final updatedEnvironment = await _secureStorageService.readEnvironment();
        if (updatedEnvironment != null) {
          await login(updatedEnvironment);
        } else {
          state = const AsyncValue.data(null);
        }
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
    await login(newEnvironment);
  }
}

final appStateServiceProvider = StateNotifierProvider<AppStateService, AsyncValue<EnvironmentModel?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final secureStorageService = ref.watch(secureStorageServiceProvider);
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AppStateService(authService, secureStorageService, supabaseService, ref);
});
