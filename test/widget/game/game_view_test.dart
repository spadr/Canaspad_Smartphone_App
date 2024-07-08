import 'package:canaspad/features/mini_game/game_view.dart';
import 'package:canaspad/features/mini_game/models/beam.dart';
import 'package:canaspad/features/mini_game/models/engineer.dart';
import 'package:canaspad/features/mini_game/models/insect.dart';
import 'package:canaspad/features/mini_game/services/game_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {});

  testWidgets('Game view displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: MiniGameView(),
      ),
    ));

    expect(find.text('Debug Vanquisher'), findsOneWidget);
  });

  testWidgets('Engineer moves on pan update', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: MiniGameView(),
      ),
    ));

    final initialEngineerPosition = tester.getTopLeft(find.byIcon(Icons.engineering));
    await tester.dragFrom(initialEngineerPosition, Offset(50, 0));
    await tester.pumpAndSettle();

    final newEngineerPosition = tester.getTopLeft(find.byIcon(Icons.engineering));
    expect(newEngineerPosition.dx, greaterThan(initialEngineerPosition.dx));
  });

  testWidgets('Game elements are displayed', (WidgetTester tester) async {
    final container = ProviderContainer();

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: MiniGameView(),
      ),
    ));

    // Initial state should have no insects or beams
    expect(find.byIcon(Icons.bug_report), findsNothing);
    expect(find.byIcon(Icons.build), findsNothing);

    // Simulate game running for a bit
    final gameService = container.read(gameServiceProvider.notifier);
    gameService.state = gameService.state.copyWith(
      insects: [InsectState(x: 0.5, y: 0.5)],
      beams: [BeamState(x: 0.5, y: 0.5)],
    );

    await tester.pump(Duration(seconds: 2));

    // After some time, insects and beams should be present
    expect(find.byIcon(Icons.bug_report), findsWidgets);
    expect(find.byIcon(Icons.build), findsWidgets);

    // Ensure timers are cancelled after the test
    container.read(gameServiceProvider.notifier).cancelTimers();
  });

  testWidgets('Game over is shown when engineer health reaches zero', (WidgetTester tester) async {
    final container = ProviderContainer();
    final engineerNotifier = container.read(engineerProvider.notifier);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: MiniGameView(),
      ),
    ));

    engineerNotifier.updateHealth(0);
    await tester.pump(Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Game Over'), findsOneWidget);

    // Cancel timers after the test
    container.read(gameServiceProvider.notifier).cancelTimers();
  });

  testWidgets('Back button on game over returns to title screen', (WidgetTester tester) async {
    final container = ProviderContainer();
    final engineerNotifier = container.read(engineerProvider.notifier);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: MiniGameView(),
      ),
    ));

    // Simulate game over
    engineerNotifier.updateHealth(0);
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Debug Begone!'), findsOneWidget);

    // Cancel timers after the test
    container.read(gameServiceProvider.notifier).cancelTimers();
  });

  testWidgets('Snackbar message is shown on game start', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: MiniGameView(),
      ),
    ));

    // Trigger the snackbar
    final context = tester.element(find.byType(MiniGameView));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vanquish the bugs and protect the code!'),
      ),
    );

    await tester.pump(); // Start the frame
    await tester.pump(Duration(seconds: 2)); // Wait for the snackbar to be visible

    expect(find.text('Vanquish the bugs and protect the code!'), findsOneWidget);

    // Cancel timers after the test
    final container = ProviderContainer();
    final gameService = container.read(gameServiceProvider.notifier);
    gameService.cancelTimers();
  });

  testWidgets('Engineer movement is restricted within screen boundaries', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: MiniGameView(),
      ),
    ));

    final engineerFinder = find.byIcon(Icons.engineering);
    final initialPosition = tester.getCenter(engineerFinder);

    await tester.dragFrom(initialPosition, Offset(-1000, -1000));
    await tester.pumpAndSettle();
    expect(tester.getCenter(engineerFinder), isNot(equals(Offset.zero)));

    await tester.dragFrom(initialPosition, Offset(1000, 1000));
    await tester.pumpAndSettle();
    expect(tester.getCenter(engineerFinder), isNot(equals(Offset(1000, 1000))));
  });
}
