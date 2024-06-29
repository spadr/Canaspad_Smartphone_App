import 'package:canaspad/core/services/supabase_service.dart';
import 'package:canaspad/features/environment/models/environment_model.dart';
import 'package:canaspad/features/number/viewmodels/number_viewmodel.dart';
import 'package:canaspad/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DataRefreshService extends StateNotifier<void> {
  final SupabaseService _supabaseService;
  final Ref _ref;

  DataRefreshService(this._supabaseService, this._ref) : super(null);

  Future<void> refreshData() async {
    await _supabaseService.fetchAllData();
    // 他の必要なデータ更新処理をここに追加
  }

  Future<void> onEnvironmentChanged(EnvironmentModel newEnvironment) async {
    // 環境設定が変更されたときの処理
    // Supabaseの再初期化などが必要な場合はここで行う

    // データの再取得
    await refreshData();

    // 関連するViewModelの更新
    _ref.read(numericDataViewModelProvider.notifier).loadNumericData();
    // 他の必要なViewModelの更新処理をここに追加
  }
}

final dataRefreshServiceProvider = StateNotifierProvider<DataRefreshService, void>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return DataRefreshService(supabaseService, ref);
});
