import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sensing_data_model.dart';
import '../providers.dart';
import '../services/supabase_service.dart';

class SensingDataState {
  final List<SensingData> data;
  final String? error;
  final bool isLoading;

  SensingDataState({
    required this.data,
    this.error,
    this.isLoading = false,
  });

  SensingDataState copyWith({
    List<SensingData>? data,
    String? error,
    bool? isLoading,
  }) {
    return SensingDataState(
      data: data ?? this.data,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SensingDataViewModel extends StateNotifier<SensingDataState> {
  final SupabaseService _supabaseService;

  SensingDataViewModel(this._supabaseService) : super(SensingDataState(data: [])) {}

  Future<void> loadSensingData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final sensingData = await _supabaseService.fetchSensingData();
      state = state.copyWith(data: sensingData, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final sensingDataViewModelProvider = StateNotifierProvider<SensingDataViewModel, SensingDataState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return SensingDataViewModel(supabaseService);
});
