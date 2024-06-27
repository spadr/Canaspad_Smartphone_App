import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/secure_storage_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../providers.dart';
import '../models/environment_model.dart';

class EnvironmentViewModel extends ChangeNotifier {
  final SecureStorageService _secureStorageService;
  final SupabaseService _supabaseService;
  List<EnvironmentModel> environments = [];
  bool _disposed = false;

  EnvironmentViewModel(this._secureStorageService, this._supabaseService) {
    loadEnvironments();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
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

  Future<void> saveEnvironment(EnvironmentModel environment) async {
    final index = environments.indexWhere((e) => e.envName == environment.envName);
    if (index != -1) {
      environments[index] = environment;
    } else {
      environments.add(environment);
    }
    _ensureOneSelectedEnvironment();
    await _saveEnvironments();

    // 環境が選択されている場合のみリフレッシュを行う
    if (environment.selected == true) {
      await _refreshDataAfterEnvironmentChange();
    }
  }

  Future<bool> deleteEnvironment(EnvironmentModel environment) async {
    if (environments.length <= 1) {
      return false; // 最後の環境設定は削除できない
    }

    final wasSelected = environment.selected == true;
    environments.remove(environment);

    if (wasSelected) {
      // 選択されていた環境を削除した場合、別の環境を選択する
      environments.first.selected = true;
      await _saveEnvironments();
      await _refreshDataAfterEnvironmentChange();
    } else {
      await _saveEnvironments();
    }

    return true;
  }

  Future<void> selectEnvironment(EnvironmentModel selectedEnvironment) async {
    if (selectedEnvironment.selected == true) {
      return; // 既に選択されている環境の選択を解除することはできない
    }

    for (var env in environments) {
      env.selected = (env == selectedEnvironment);
    }
    await _saveEnvironments();
    // 選択された環境が変更された場合のみリフレッシュを行う
    if (selectedEnvironment != environments.firstWhere((env) => env.selected == true)) {
      await _refreshDataAfterEnvironmentChange();
    }
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

  Future<void> _refreshDataAfterEnvironmentChange() async {
    if (_disposed) return;
    // 環境設定が変更された後のデータ更新処理
    await _supabaseService.fetchAllData();
    // ここで他の必要なデータ更新処理を追加できます
    notifyListeners();
  }
}

final environmentViewModelProvider = ChangeNotifierProvider((ref) {
  final secureStorageService = ref.watch(secureStorageServiceProvider);
  final supabaseService = ref.watch(supabaseServiceProvider);
  return EnvironmentViewModel(secureStorageService, supabaseService);
});
