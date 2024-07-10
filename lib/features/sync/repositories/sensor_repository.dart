// lib/features/sync/repositories/sensor_repository.dart

import 'package:canaspad/core/services/supabase_client_manager.dart';
import 'package:canaspad/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// SensorRepository を Provider に変更
final sensorRepositoryProvider = Provider<SensorRepository>((ref) {
  final supabaseClientManager = ref.watch(supabaseClientManagerProvider);
  final flavor = ref.watch(flavorProvider);
  return SensorRepository(supabaseClientManager, flavor);
});

class SensorRepository {
  final SupabaseClientManager _supabaseClientManager;
  final String _flavor;

  SensorRepository(this._supabaseClientManager, this._flavor);

  // 他のリポジトリメソッド...
}
