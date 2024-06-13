import 'package:flutter_riverpod/flutter_riverpod.dart';

class Insect extends StateNotifier<InsectState> {
  Insect() : super(InsectState());

  void updatePosition(double x, double y) {
    state = state.copyWith(x: x, y: y);
  }

  void updateHealth(int health) {
    state = state.copyWith(health: health);
  }

  void reverseXDirection() {
    state = state.copyWith(dx: -state.dx);
  }
}

class InsectState {
  int health;
  final double x;
  final double y;
  final double dx;
  final int interval;

  InsectState({
    this.health = 50,
    this.x = 0.5,
    this.y = 0,
    this.dx = 0.01,
    this.interval = 600,
  });

  InsectState copyWith({
    int? health,
    double? x,
    double? y,
    double? dx,
    int? interval,
  }) {
    return InsectState(
      health: health ?? this.health,
      x: x ?? this.x,
      y: y ?? this.y,
      dx: dx ?? this.dx,
      interval: interval ?? this.interval,
    );
  }
}

final insectProvider = StateNotifierProvider<Insect, InsectState>((ref) {
  return Insect();
});
