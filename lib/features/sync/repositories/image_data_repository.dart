// lib/features/sync/repositories/image_data_repository.dart

import 'package:canaspad/core/services/supabase_client_manager.dart';
import 'package:canaspad/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageDataRepositoryProvider = Provider<ImageDataRepository>((ref) {
  final supabaseClientManager = ref.watch(supabaseClientManagerProvider);
  final flavor = ref.watch(flavorProvider);
  return ImageDataRepository(supabaseClientManager, flavor);
});

class ImageDataRepository {
  final SupabaseClientManager _supabaseClientManager;
  final String _flavor;

  ImageDataRepository(this._supabaseClientManager, this._flavor);

  // 他のリポジトリメソッド...
}
