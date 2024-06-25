import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../../data/models/number_data_model.dart';
import '../../../providers.dart';

class NumberDataState {
  final List<NumberData> data;
  final String? error;
  final bool isLoading;

  NumberDataState({
    required this.data,
    this.error,
    this.isLoading = false,
  });

  NumberDataState copyWith({
    List<NumberData>? data,
    String? error,
    bool? isLoading,
  }) {
    return NumberDataState(
      data: data ?? this.data,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NumberDataViewModel extends StateNotifier<NumberDataState> {
  final SupabaseService _supabaseService;

  NumberDataViewModel(this._supabaseService) : super(NumberDataState(data: []));

  Future<void> loadNumberData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final numberData = await _supabaseService.fetchNumberData();
      state = state.copyWith(data: numberData, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final numberDataViewModelProvider = StateNotifierProvider<NumberDataViewModel, NumberDataState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return NumberDataViewModel(supabaseService);
});
