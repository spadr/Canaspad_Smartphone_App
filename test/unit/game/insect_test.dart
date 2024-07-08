import 'package:canaspad/features/mini_game/models/insect.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Insect', () {
    late ProviderContainer container;
    late Insect insectNotifier;

    setUp(() {
      container = ProviderContainer();
      insectNotifier = container.read(insectProvider.notifier);
    });

    test('Initial state is correct', () {
      expect(insectNotifier.state.x, 0.5);
      expect(insectNotifier.state.y, 0.0);
      expect(insectNotifier.state.health, 50);
      expect(insectNotifier.state.dx, 0.01);
    });

    test('Reverse direction works', () {
      insectNotifier.reverseXDirection();
      expect(insectNotifier.state.dx, -0.01);

      insectNotifier.reverseXDirection();
      expect(insectNotifier.state.dx, 0.01);
    });
  });
}
