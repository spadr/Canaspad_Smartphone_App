import 'package:canaspad/mini_game/models/beam.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Beam', () {
    late ProviderContainer container;
    late Beam beamNotifier;

    setUp(() {
      container = ProviderContainer();
      beamNotifier = container.read(beamProvider.notifier);
    });

    test('Initial state is correct', () {
      expect(beamNotifier.state.x, 0);
      expect(beamNotifier.state.y, 0);
      expect(beamNotifier.state.health, 200);
    });

    test('Beam health can be reduced', () {
      beamNotifier.updateHealth(beamNotifier.state.health - 50);
      expect(beamNotifier.state.health, 150);
    });

    test('Beam is removed when it goes off-screen', () {
      final beams = <Beam>[];

      final beamNotifier = Beam();
      beamNotifier.updatePosition(0.5, -0.1);
      beams.add(beamNotifier);

      beams.removeWhere((beam) => beam.state.y < 0);

      expect(beams, isEmpty);
    });
  });
}
