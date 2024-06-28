import 'dart:convert';

import 'package:canaspad/core/services/app_state_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/secure_storage_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../providers.dart';
import '../models/environment_model.dart';

class EnvironmentViewModel extends StateNotifier<List<EnvironmentModel>> {
  final SecureStorageService _secureStorageService;
  final SupabaseService _supabaseService;
  final Ref _ref;

  EnvironmentViewModel(this._secureStorageService, this._supabaseService, this._ref) : super([]) {
    loadEnvironments();
  }

  Future<void> loadEnvironments() async {
    final environments = await _secureStorageService.readAllEnvironments();
    _ensureOneSelectedEnvironment(environments);
    state = environments;
  }

  void addEnvironment() {
    final newEnvironment = EnvironmentModel(
      envName: _generateEnvironmentName(),
      selected: false,
    );
    state = [...state, newEnvironment];
    _ensureOneSelectedEnvironment(state);
    _saveEnvironments();
  }

  Future<void> saveEnvironment(EnvironmentModel environment) async {
    final index = state.indexWhere((e) => e.envName == environment.envName);
    List<EnvironmentModel> updatedEnvironments;
    if (index != -1) {
      updatedEnvironments = [...state];
      updatedEnvironments[index] = environment;
    } else {
      updatedEnvironments = [...state, environment];
    }
    _ensureOneSelectedEnvironment(updatedEnvironments);
    state = updatedEnvironments;
    await _saveEnvironments();

    if (environment.selected == true) {
      await _refreshDataAfterEnvironmentChange(environment);
    }
  }

  Future<bool> deleteEnvironment(EnvironmentModel environment) async {
    if (state.length <= 1) {
      return false; // 最後の環境設定は削除できない
    }

    final wasSelected = environment.selected == true;
    final updatedEnvironments = state.where((e) => e != environment).toList();

    if (wasSelected) {
      updatedEnvironments.first.selected = true;
    }

    state = updatedEnvironments;
    await _saveEnvironments();

    if (wasSelected) {
      await _refreshDataAfterEnvironmentChange(updatedEnvironments.first);
    }

    return true;
  }

  Future<void> selectEnvironment(EnvironmentModel selectedEnvironment) async {
    if (selectedEnvironment.selected == true) {
      return; // 既に選択されている環境の選択を解除することはできない
    }

    final updatedEnvironments = state.map((env) => env.copyWith(selected: env == selectedEnvironment)).toList();

    state = updatedEnvironments;
    await _saveEnvironments();

    // AppStateService を使用して環境を変更し、ログインを行う
    await _ref.read(appStateServiceProvider.notifier).changeEnvironment(selectedEnvironment);
  }

  void _ensureOneSelectedEnvironment(List<EnvironmentModel> environments) {
    if (environments.isEmpty) {
      return;
    }

    final selectedEnvironments = environments.where((e) => e.selected == true).toList();
    if (selectedEnvironments.isEmpty) {
      environments.first.selected = true;
    } else if (selectedEnvironments.length > 1) {
      for (var i = 1; i < selectedEnvironments.length; i++) {
        selectedEnvironments[i] = selectedEnvironments[i].copyWith(selected: false);
      }
    }
  }

  Future<void> _saveEnvironments() async {
    await _secureStorageService.writeSecureData(
      'envSettings',
      jsonEncode(state.map((e) => e.toJson()).toList()),
    );
  }

  String _generateEnvironmentName() {
    int index = 1;
    while (state.any((env) => env.envName == 'Environment $index')) {
      index++;
    }
    return 'Environment $index';
  }

  Future<void> _refreshDataAfterEnvironmentChange(EnvironmentModel environment) async {
    await _supabaseService.fetchAllData();
    await _ref.read(appStateServiceProvider.notifier).changeEnvironment(environment);
  }
}

final environmentViewModelProvider = StateNotifierProvider<EnvironmentViewModel, List<EnvironmentModel>>((ref) {
  final secureStorageService = ref.watch(secureStorageServiceProvider);
  final supabaseService = ref.watch(supabaseServiceProvider);
  return EnvironmentViewModel(secureStorageService, supabaseService, ref);
});
