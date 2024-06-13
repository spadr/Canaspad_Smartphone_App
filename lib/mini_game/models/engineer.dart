import 'package:flutter_riverpod/flutter_riverpod.dart';

class Engineer extends StateNotifier<EngineerState> {
  Engineer() : super(EngineerState());

  void updatePosition(double x, double y) {
    // Clamping the position within boundaries
    x = x.clamp(0.1, 0.9);
    y = y.clamp(0.2, 0.9);
    state = state.copyWith(x: x, y: y);
  }

  void updateHealth(int health) {
    state = state.copyWith(health: health);
  }

  void reset() {
    state = EngineerState();
  }
}

class EngineerState {
  final double x;
  final double y;
  int health;

  EngineerState({this.x = 0.5, this.y = 0.7, this.health = 200});

  EngineerState copyWith({double? x, double? y, int? health}) {
    return EngineerState(
      x: x ?? this.x,
      y: y ?? this.y,
      health: health ?? this.health,
    );
  }
}

final engineerProvider = StateNotifierProvider<Engineer, EngineerState>((ref) {
  return Engineer();
});
