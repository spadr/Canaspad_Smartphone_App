import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../../data/models/numeric_data_model.dart';
import '../../../providers.dart';

class NumericDataState {
  final List<NumericData> data;
  final String? error;
  final bool isLoading;

  NumericDataState({
    required this.data,
    this.error,
    this.isLoading = false,
  });

  NumericDataState copyWith({
    List<NumericData>? data,
    String? error,
    bool? isLoading,
  }) {
    return NumericDataState(
      data: data ?? this.data,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NumericDataViewModel extends StateNotifier<NumericDataState> {
  final SupabaseService _supabaseService;

  NumericDataViewModel(this._supabaseService) : super(NumericDataState(data: []));

  Future<void> loadNumericData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final numericData = await _supabaseService.getNumericData();
      state = state.copyWith(data: numericData, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final numericDataViewModelProvider = StateNotifierProvider<NumericDataViewModel, NumericDataState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return NumericDataViewModel(supabaseService);
});
