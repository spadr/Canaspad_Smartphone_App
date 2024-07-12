// lib/core/services/supabase_client_manager.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/environment/services/environment_service.dart';
import '../models/environment_setting.dart';

class SupabaseClientManager {
  final EnvironmentService _environmentService;
  final Map<String, SupabaseClient> _clients = {}; // 環境IDごとに SupabaseClient を保持

  SupabaseClientManager(this._environmentService);

  // 環境設定に基づいて SupabaseClient を取得
  Future<SupabaseClient> getClientForEnvironment(EnvironmentSetting environment) async {
    if (!_clients.containsKey(environment.id)) {
      _clients[environment.id] = await _initializeSupabaseClient(environment);
    }
    return _clients[environment.id]!;
  }

  Future<SupabaseClient> _initializeSupabaseClient(EnvironmentSetting environment) async {
    // Supabase クライアントを初期化
    await Supabase.initialize(
      url: environment.supabaseUrl,
      anonKey: environment.supabaseAnonKey,
    );
    return Supabase.instance.client;
  }
}
