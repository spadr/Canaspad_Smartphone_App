import 'package:canaspad/features/mini_game/services/game_service.dart';
import 'package:canaspad/features/mini_game/utils/navigation_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Navigation to a new screen works', (WidgetTester tester) async {
    final target = Scaffold(body: Text('Target Screen'));

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => navigateTo(context, target),
            child: Text('Navigate'),
          ),
        ),
      ),
    ));

    expect(find.text('Navigate'), findsOneWidget);
    expect(find.text('Target Screen'), findsNothing);

    await tester.tap(find.text('Navigate'));
    await tester.pumpAndSettle();

    expect(find.text('Target Screen'), findsOneWidget);
  });

  testWidgets('Game start message is shown', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showGameStartMessage(context),
              child: Text('Show Message'),
            ),
          ),
        ),
      ),
    ));

    expect(find.text('Show Message'), findsOneWidget);
    expect(find.text('Vanquish the bugs and protect the code!'), findsNothing);

    await tester.tap(find.text('Show Message'));
    await tester.pump();

    expect(find.text('Vanquish the bugs and protect the code!'), findsOneWidget);
  });

  testWidgets('Back button on game over dialog returns to title screen', (WidgetTester tester) async {
    final container = ProviderContainer();
    final gameService = container.read(gameServiceProvider.notifier);

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showGameOver(context, gameService.state),
              child: Text('Show Game Over'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Show Game Over'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Debug Begone!'), findsOneWidget);
  });
}
