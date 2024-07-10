// lib/features/sync/repositories/numeric_data_repository.dart

import 'package:canaspad/core/services/supabase_client_manager.dart';
import 'package:canaspad/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final numericDataRepositoryProvider = Provider<NumericDataRepository>((ref) {
  final supabaseClientManager = ref.watch(supabaseClientManagerProvider);
  final flavor = ref.watch(flavorProvider);
  return NumericDataRepository(supabaseClientManager, flavor);
});

class NumericDataRepository {
  final SupabaseClientManager _supabaseClientManager;
  final String _flavor;

  NumericDataRepository(this._supabaseClientManager, this._flavor);

  // 他のリポジトリメソッド...
}
