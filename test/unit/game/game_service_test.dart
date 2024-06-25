import 'package:canaspad/features/mini_game/models/beam.dart';
import 'package:canaspad/features/mini_game/models/engineer.dart';
import 'package:canaspad/features/mini_game/models/insect.dart';
import 'package:canaspad/features/mini_game/services/game_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GameService', () {
    late ProviderContainer container;
    late GameService gameService;

    setUp(() {
      container = ProviderContainer();
      gameService = container.read(gameServiceProvider.notifier);
    });

    test('Initial state is correct', () {
      expect(gameService.state.score, 0);
      expect(gameService.state.highScore, 0);
      expect(gameService.state.insects, isEmpty);
      expect(gameService.state.beams, isEmpty);
    });

    test('Engineer movement is clamped within boundaries', () {
      final engineerNotifier = container.read(engineerProvider.notifier);
      engineerNotifier.updatePosition(-1, -1);
      expect(engineerNotifier.state.x, greaterThanOrEqualTo(0.1));
      expect(engineerNotifier.state.y, greaterThanOrEqualTo(0.2));

      engineerNotifier.updatePosition(2, 2);
      expect(engineerNotifier.state.x, lessThanOrEqualTo(0.9));
      expect(engineerNotifier.state.y, lessThanOrEqualTo(0.9));
    });

    test('Insects are spawned correctly', () async {
      gameService.startSpawningInsects();
      await Future.delayed(Duration(milliseconds: 650));
      expect(gameService.state.insects, isNotEmpty);
    });

    test('Beams are shot correctly', () async {
      gameService.startShootingBeams();
      await Future.delayed(Duration(milliseconds: 1100));
      expect(gameService.state.beams, isNotEmpty);
    });

    test('Insect reverses direction when hitting boundary', () {
      var insect = InsectState(x: 1, y: 0.5, dx: 0.1);
      gameService.state = gameService.state.copyWith(insects: [insect]);
      gameService.updateInsects();
      expect(gameService.state.insects[0].dx, -0.1);
    });

    test('Beam and insect collision reduces health and increases score', () {
      var insect = InsectState(x: 0.5, y: 0.5, health: 50);
      var beam = BeamState(x: 0.5, y: 0.5, health: 100);
      gameService.state = gameService.state.copyWith(insects: [insect], beams: [beam]);

      gameService.updateBeams();
      gameService.updateInsects();

      expect(gameService.state.insects.isEmpty, true, reason: "Insect should be removed");
      expect(gameService.state.beams.first.health, lessThan(51), reason: "Beam health should be reduced");
      expect(gameService.state.score, greaterThan(9), reason: "Score should increase");
    });

    test('Score and high score updates correctly', () async {
      await gameService.loadHighScore();
      gameService.state = gameService.state.copyWith(score: 100);
      await gameService.updateHighScore();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('highScore'), 100);
    });

    test('Timers are cancelled correctly', () async {
      gameService.startGame(() {});
      await Future.delayed(Duration(milliseconds: 100)); // Wait for timers to start
      gameService.cancelTimers();

      expect(gameService.state.gameTimer?.isActive, false);
      expect(gameService.state.beamTimer?.isActive, false);
      expect(gameService.state.spawnTimer?.isActive, false);
    });

    test('Score and high score update correctly on game over', () async {
      await gameService.loadHighScore();
      gameService.state = gameService.state.copyWith(score: 100);
      final engineerNotifier = container.read(engineerProvider.notifier);
      engineerNotifier.updateHealth(0);
      await gameService.updateHighScore();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('highScore'), 100);
    });

    test('Engineer health decreases when colliding with multiple insects', () {
      final engineerNotifier = container.read(engineerProvider.notifier);
      var initialHealth = engineerNotifier.state.health;
      var insect1 = InsectState(x: engineerNotifier.state.x, y: engineerNotifier.state.y);
      var insect2 = InsectState(x: engineerNotifier.state.x, y: engineerNotifier.state.y);
      gameService.state = gameService.state.copyWith(insects: [insect1, insect2]);

      gameService.updateInsects();

      expect(engineerNotifier.state.health, lessThan(initialHealth));
    });
  });
}
