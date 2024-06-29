import 'dart:convert';

import 'package:canaspad/core/services/app_state_service.dart';
import 'package:canaspad/core/services/data_refresh_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/secure_storage_service.dart';
import '../../../providers.dart';
import '../models/environment_model.dart';

class EnvironmentViewModel extends StateNotifier<List<EnvironmentModel>> {
  final SecureStorageService _secureStorageService;
  final DataRefreshService _dataRefreshService;
  final Ref _ref;

  EnvironmentViewModel(this._secureStorageService, this._dataRefreshService, this._ref) : super([]) {
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
    _saveEnvironments();
  }

  Future<void> saveEnvironment(EnvironmentModel editedEnvironment) async {
    final updatedEnvironments = state.map((env) {
      if (env.id == editedEnvironment.id) {
        return editedEnvironment;
      } else if (editedEnvironment.selected == true) {
        return env.copyWith(selected: false);
      }
      return env;
    }).toList();

    // 選択された環境が1つだけであることを確認
    final selectedEnvironments = updatedEnvironments.where((env) => env.selected == true).toList();
    if (selectedEnvironments.isEmpty) {
      // 選択された環境がない場合、最初の環境を選択
      updatedEnvironments[0] = updatedEnvironments[0].copyWith(selected: true);
    } else if (selectedEnvironments.length > 1) {
      // 複数の環境が選択されている場合、最後に編集された環境以外の選択を解除
      for (var i = 0; i < updatedEnvironments.length; i++) {
        if (updatedEnvironments[i] != editedEnvironment) {
          updatedEnvironments[i] = updatedEnvironments[i].copyWith(selected: false);
        }
      }
    }

    state = updatedEnvironments;
    await _saveEnvironments();

    final selectedEnvironment = updatedEnvironments.firstWhere((env) => env.selected == true);
    await _refreshDataAfterEnvironmentChange(selectedEnvironment);
  }

  Future<bool> deleteEnvironment(EnvironmentModel environment) async {
    if (state.length <= 1) {
      return false; // 最後の環境設定は削除できない
    }

    final updatedEnvironments = state.where((e) => e.id != environment.id).toList();
    if (environment.selected == true && updatedEnvironments.isNotEmpty) {
      updatedEnvironments[0] = updatedEnvironments[0].copyWith(selected: true);
    }

    state = updatedEnvironments;
    await _saveEnvironments();

    if (environment.selected == true && updatedEnvironments.isNotEmpty) {
      await _refreshDataAfterEnvironmentChange(updatedEnvironments[0]);
    }

    return true;
  }

  void _ensureOneSelectedEnvironment(List<EnvironmentModel> environments) {
    if (environments.isEmpty) return;

    final selectedEnvironments = environments.where((e) => e.selected == true).toList();
    if (selectedEnvironments.isEmpty) {
      environments[0] = environments[0].copyWith(selected: true);
    } else if (selectedEnvironments.length > 1) {
      for (var i = 1; i < selectedEnvironments.length; i++) {
        environments[i] = environments[i].copyWith(selected: false);
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
    await _dataRefreshService.onEnvironmentChanged(environment);
    await _ref.read(appStateServiceProvider.notifier).changeEnvironment(environment);
  }
}

final environmentViewModelProvider = StateNotifierProvider<EnvironmentViewModel, List<EnvironmentModel>>((ref) {
  final secureStorageService = ref.watch(secureStorageServiceProvider);
  final dataRefreshService = ref.watch(dataRefreshServiceProvider.notifier);
  return EnvironmentViewModel(secureStorageService, dataRefreshService, ref);
});
