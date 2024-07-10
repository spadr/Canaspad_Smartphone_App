// lib/core/services/supabase_client_manager.dart

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/environment/services/environment_service.dart';
import '../models/environment_setting.dart';

class SupabaseClientManager {
  SupabaseClient? _client;
  final EnvironmentService _environmentService;

  SupabaseClientManager(this._environmentService);

  Future<void> initializeClient() async {
    final selectedEnvironment = await _environmentService.getSelectedEnvironmentSetting();
    if (selectedEnvironment == null) {
      throw Exception("No environment selected.");
    }
    await _initializeSupabaseClient(selectedEnvironment);
  }

  SupabaseClient get client {
    if (_client == null) {
      throw Exception("Supabase client is not initialized. Call initializeClient() first.");
    }
    return _client!;
  }

  Future<void> _initializeSupabaseClient(EnvironmentSetting environment) async {
    await Supabase.initialize(
      url: environment.supabaseUrl,
      anonKey: environment.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }
}
