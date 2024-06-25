import 'package:canaspad/features/mini_game/models/beam.dart';
import 'package:canaspad/features/mini_game/models/engineer.dart';
import 'package:canaspad/features/mini_game/models/insect.dart';
import 'package:canaspad/features/mini_game/services/game_service.dart';
import 'package:canaspad/features/mini_game/widgets/game_elements.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Game Elements', () {
    testWidgets('Game elements are displayed correctly', (WidgetTester tester) async {
      final container = ProviderContainer();
      container.read(engineerProvider.notifier).updatePosition(0.4, 0.4);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return buildGameElements(
                    context,
                    GameState(
                      insects: [InsectState(x: 0.5, y: 0.5)],
                      beams: [BeamState(x: 0.3, y: 0.3)],
                      score: 0,
                      highScore: 0,
                    ),
                    container,
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(Icon), findsNWidgets(3));
      expect(find.byIcon(Icons.engineering), findsOneWidget);
      expect(find.byIcon(Icons.bug_report), findsOneWidget);
      expect(find.byIcon(Icons.build), findsOneWidget);
    });

    testWidgets('Game elements positions are updated correctly', (WidgetTester tester) async {
      final container = ProviderContainer();
      final engineerNotifier = container.read(engineerProvider.notifier);
      final gameService = container.read(gameServiceProvider.notifier);

      // Initial positions
      engineerNotifier.updatePosition(0.6, 0.6);
      gameService.state = gameService.state.copyWith(
        insects: [InsectState(x: 0.5, y: 0.5)],
        beams: [BeamState(x: 0.4, y: 0.4)],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return buildGameElements(context, gameService.state, container);
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Get initial positions after rendering
      final initialEngineerPosition = tester.getTopLeft(find.byIcon(Icons.engineering));
      final initialInsectPosition = tester.getTopLeft(find.byIcon(Icons.bug_report));
      final initialBeamPosition = tester.getTopLeft(find.byIcon(Icons.build));

      // Update positions
      engineerNotifier.updatePosition(0.7, 0.7);
      gameService.state = gameService.state.copyWith(
        insects: [InsectState(x: 0.6, y: 0.6)],
        beams: [BeamState(x: 0.5, y: 0.5)],
      );

      // Pump the widget tree to apply updates
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return buildGameElements(context, gameService.state, container);
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Get updated positions after rendering
      final updatedEngineerPosition = tester.getTopLeft(find.byIcon(Icons.engineering));
      final updatedInsectPosition = tester.getTopLeft(find.byIcon(Icons.bug_report));
      final updatedBeamPosition = tester.getTopLeft(find.byIcon(Icons.build));

      // Ensure positions have been updated
      expect(updatedEngineerPosition, isNot(equals(initialEngineerPosition)));
      expect(updatedInsectPosition, isNot(equals(initialInsectPosition)));
      expect(updatedBeamPosition, isNot(equals(initialBeamPosition)));
    });

    testWidgets('Insect and beam collision reduces health 1', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(child: Container()));
      final container = ProviderScope.containerOf(tester.element(find.byType(Container)));
      final gameService = container.read(gameServiceProvider.notifier);

      gameService.state = gameService.state.copyWith(
        insects: [InsectState(x: 0.5, y: 0.5, health: 100)],
        beams: [BeamState(x: 0.5, y: 0.5, health: 200)],
      );

      gameService.updateInsects();
      gameService.updateBeams();

      expect(gameService.state.beams.first.health, lessThan(200));
      expect(gameService.state.insects.isEmpty, true);
    });

    testWidgets('Insect and beam collision reduces health 2', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(child: Container()));
      final container = ProviderScope.containerOf(tester.element(find.byType(Container)));
      final gameService = container.read(gameServiceProvider.notifier);

      gameService.state = gameService.state.copyWith(
        insects: [InsectState(x: 0.5, y: 0.5, health: 200)],
        beams: [BeamState(x: 0.5, y: 0.5, health: 100)],
      );

      gameService.updateInsects();
      gameService.updateBeams();

      expect(gameService.state.beams.isEmpty, true);
      expect(gameService.state.insects.first.health, lessThan(200));
    });

    testWidgets('Insect and engineer collision reduces health', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(child: Container()));
      final container = ProviderScope.containerOf(tester.element(find.byType(Container)));
      final gameService = container.read(gameServiceProvider.notifier);
      final engineerNotifier = container.read(engineerProvider.notifier);

      engineerNotifier.updatePosition(0.5, 0.5);
      gameService.state = gameService.state.copyWith(
        insects: [InsectState(x: 0.5, y: 0.5, health: 100)],
      );

      gameService.updateInsects();

      expect(engineerNotifier.state.health, lessThan(200));
      expect(gameService.state.insects.isEmpty, true);
    });

    testWidgets('Insects reverse direction on collision', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(child: Container()));
      final container = ProviderScope.containerOf(tester.element(find.byType(Container)));
      final gameService = container.read(gameServiceProvider.notifier);

      gameService.state = gameService.state.copyWith(
        insects: [
          InsectState(x: 0.1, y: 0.5, dx: -0.01),
          InsectState(x: 0.9, y: 0.5, dx: 0.01),
        ],
      );

      gameService.updateInsects();

      expect(gameService.state.insects.first.dx, greaterThan(0));
      expect(gameService.state.insects.last.dx, lessThan(0));
    });

    testWidgets('Beam and insect collision increases score', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(child: Container()));
      final container = ProviderScope.containerOf(tester.element(find.byType(Container)));
      final gameService = container.read(gameServiceProvider.notifier);

      gameService.state = gameService.state.copyWith(
        insects: [InsectState(x: 0.5, y: 0.5, health: 50)],
        beams: [BeamState(x: 0.5, y: 0.5, health: 200)],
        score: 0,
      );

      gameService.updateBeams();

      expect(gameService.state.score, greaterThan(0));
    });
  });
}
