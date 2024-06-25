import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/environment_model.dart';
import '../providers.dart';
import '../services/secure_storage_service.dart';

class EnvironmentViewModel extends ChangeNotifier {
  final SecureStorageService _secureStorageService;
  List<EnvironmentModel> environments = [];

  EnvironmentViewModel(this._secureStorageService) {
    loadEnvironments();
  }

  Future<void> loadEnvironments() async {
    environments = await _secureStorageService.readAllEnvironments();
    _ensureOneSelectedEnvironment();
    notifyListeners();
  }

  void addEnvironment() {
    final newEnvironment = EnvironmentModel(
      envName: _generateEnvironmentName(),
      selected: false,
    );
    environments.add(newEnvironment);
    _ensureOneSelectedEnvironment();
    _saveEnvironments();
  }

  void saveEnvironment(EnvironmentModel environment) {
    final index = environments.indexWhere((e) => e.envName == environment.envName);
    if (index != -1) {
      environments[index] = environment;
    } else {
      environments.add(environment);
    }
    _ensureOneSelectedEnvironment();
    _saveEnvironments();
  }

  Future<bool> deleteEnvironment(EnvironmentModel environment) async {
    if (environments.length <= 1) {
      return false; // 最後の環境設定は削除できない
    }

    if (environment.selected == true) {
      // 選択されている環境を削除する場合、別の環境を選択する
      final otherEnvironment = environments.firstWhere((e) => e != environment);
      otherEnvironment.selected = true;
    }

    environments.remove(environment);
    _saveEnvironments();
    return true;
  }

  void selectEnvironment(EnvironmentModel selectedEnvironment) {
    if (selectedEnvironment.selected == true) {
      return; // 既に選択されている環境の選択を解除することはできない
    }

    for (var env in environments) {
      env.selected = (env == selectedEnvironment);
    }
    _saveEnvironments();
  }

  void _ensureOneSelectedEnvironment() {
    if (environments.isEmpty) {
      return;
    }

    final selectedEnvironments = environments.where((e) => e.selected == true).toList();
    if (selectedEnvironments.isEmpty) {
      // 選択されている環境がない場合、最初の環境を選択する
      environments.first.selected = true;
    } else if (selectedEnvironments.length > 1) {
      // 複数の環境が選択されている場合、最初の選択環境以外の選択を解除する
      for (var i = 1; i < selectedEnvironments.length; i++) {
        selectedEnvironments[i].selected = false;
      }
    }
  }

  Future<void> _saveEnvironments() async {
    await _secureStorageService.writeSecureData(
      'envSettings',
      jsonEncode(environments.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  String _generateEnvironmentName() {
    int index = 1;
    while (environments.any((env) => env.envName == 'Environment $index')) {
      index++;
    }
    return 'Environment $index';
  }
}

final environmentViewModelProvider = ChangeNotifierProvider((ref) {
  final secureStorageService = ref.watch(secureStorageServiceProvider);
  return EnvironmentViewModel(secureStorageService);
});
