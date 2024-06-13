import 'package:canaspad/mini_game/models/engineer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Engineer', () {
    late ProviderContainer container;
    late Engineer engineerNotifier;

    setUp(() {
      container = ProviderContainer();
      engineerNotifier = container.read(engineerProvider.notifier);
    });

    test('Initial state is correct', () {
      expect(engineerNotifier.state.x, 0.5);
      expect(engineerNotifier.state.y, 0.7);
      expect(engineerNotifier.state.health, 200);
    });

    test('Engineer health can be reduced', () {
      engineerNotifier.updateHealth(150);
      expect(engineerNotifier.state.health, 150);
    });
  });
}
