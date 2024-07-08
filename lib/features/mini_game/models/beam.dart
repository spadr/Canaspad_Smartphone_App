import 'package:flutter_riverpod/flutter_riverpod.dart';

class Beam extends StateNotifier<BeamState> {
  Beam() : super(BeamState());

  void updatePosition(double x, double y) {
    state = state.copyWith(x: x, y: y);
  }

  void updateHealth(int health) {
    state = state.copyWith(health: health);
  }
}

class BeamState {
  final double x;
  final double y;
  int health;
  final int interval;

  BeamState({
    this.x = 0,
    this.y = 0,
    this.health = 200,
    this.interval = 300,
  });

  BeamState copyWith({
    double? x,
    double? y,
    int? health,
    int? interval,
  }) {
    return BeamState(
      x: x ?? this.x,
      y: y ?? this.y,
      health: health ?? this.health,
      interval: interval ?? this.interval,
    );
  }
}

final beamProvider = StateNotifierProvider<Beam, BeamState>((ref) {
  return Beam();
});
