// lib/features/environment/services/environment_service.dart

import 'dart:convert';

import 'package:canaspad/core/models/environment_setting.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EnvironmentService {
  final FlutterSecureStorage _secureStorage;
  final String _flavor;
  static const _environmentSettingsKey = 'environmentSettings';

  EnvironmentService(this._secureStorage, this._flavor);

  Future<List<EnvironmentSetting>> getEnvironmentSettings() async {
    if (_flavor == 'develop') {
      return _getMockEnvironmentSettings();
    } else {
      final jsonString = await _secureStorage.read(key: _environmentSettingsKey);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => EnvironmentSetting.fromJson(json)).toList();
    }
  }

  Future<EnvironmentSetting> getSelectedEnvironmentSetting() async {
    final settings = await getEnvironmentSettings();
    final selectedSetting = settings.firstWhere((s) => s.isSelected);
    if (selectedSetting != null) {
      return selectedSetting;
    } else {
      // デフォルトの環境設定を返す (必要に応じて値を変更)
      return EnvironmentSetting(
        id: 'default',
        environmentName: 'デフォルト環境',
        supabaseUrl: 'YOUR_DEFAULT_SUPABASE_URL',
        supabaseAnonKey: 'YOUR_DEFAULT_SUPABASE_ANON_KEY',
        isSelected: true,
      );
    }
  }

  // 疑似環境設定データ
  List<EnvironmentSetting> _getMockEnvironmentSettings() {
    return [
      EnvironmentSetting(
        id: 'dev_env',
        environmentName: '開発環境',
        supabaseUrl: 'YOUR_DEV_SUPABASE_URL',
        supabaseAnonKey: 'YOUR_DEV_SUPABASE_ANON_KEY',
        isSelected: true,
      ),
      EnvironmentSetting(
        id: 'prod_env',
        environmentName: '本番環境',
        supabaseUrl: 'YOUR_PROD_SUPABASE_URL',
        supabaseAnonKey: 'YOUR_PROD_SUPABASE_ANON_KEY',
      ),
    ];
  }

  // ... (他のメソッド: saveEnvironmentSetting, deleteEnvironmentSetting, getSelectedEnvironmentSetting, setSelectedEnvironmentSetting)
}
