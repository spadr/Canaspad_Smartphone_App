import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/engineer.dart';
import 'services/game_service.dart';
import 'utils/navigation_utils.dart';
import 'widgets/app_bar.dart';
import 'widgets/game_elements.dart';

class MiniGameView extends ConsumerStatefulWidget {
  @override
  _MiniGameViewState createState() => _MiniGameViewState();
}

class _MiniGameViewState extends ConsumerState<MiniGameView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final gameNotifier = ref.read(gameServiceProvider.notifier);
      await gameNotifier.resetGame(); // Ensure game is reset
      gameNotifier.startGame(() => showGameOver(context, ref.read(gameServiceProvider)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameServiceProvider);
    final engineerState = ref.watch(engineerProvider);

    return Scaffold(
      appBar: buildAppBar(context, 'Debug Vanquisher'),
      body: Center(
        child: Column(
          children: [
            Text('Score: ${gameState.score}'),
            Text('High Score: ${gameState.highScore}'),
            Text('Engineer Health: ${engineerState.health}'),
            Expanded(
              child: GestureDetector(
                onPanUpdate: (details) {
                  ref.read(engineerProvider.notifier).updatePosition(
                        engineerState.x + details.delta.dx / MediaQuery.of(context).size.width,
                        engineerState.y + details.delta.dy / MediaQuery.of(context).size.height,
                      );
                },
                child: Builder(
                  builder: (context) {
                    final container = ProviderScope.containerOf(context);
                    return buildGameElements(context, gameState, container);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
