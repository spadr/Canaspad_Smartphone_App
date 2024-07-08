import 'package:canaspad/core/services/supabase_service.dart';
import 'package:canaspad/features/image/models/image_model.dart';
import 'package:canaspad/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageState {
  final List<ImageSensor> sensors;
  final bool isLoading;
  final String? error;

  ImageState({required this.sensors, this.isLoading = false, this.error});

  ImageState copyWith({List<ImageSensor>? sensors, bool? isLoading, String? error}) {
    return ImageState(
      sensors: sensors ?? this.sensors,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ImageViewModel extends StateNotifier<ImageState> {
  final SupabaseService _supabaseService;

  ImageViewModel(this._supabaseService) : super(ImageState(sensors: []));

  Future<void> loadImageSensors() async {
    state = state.copyWith(isLoading: true);
    try {
      if (_supabaseService is MockSupabaseService) {
        while (!(_supabaseService as MockSupabaseService).isInitialized) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
      final sensors = await _supabaseService.getImageSensors();
      state = state.copyWith(sensors: sensors, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final imageViewModelProvider = StateNotifierProvider<ImageViewModel, ImageState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return ImageViewModel(supabaseService);
});
