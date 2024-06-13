import 'package:flutter/material.dart';

import '../game_title_screen.dart';
import '../services/game_service.dart';

void navigateTo(BuildContext context, Widget target) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => target),
  );
}

void showGameStartMessage(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Vanquish the bugs and protect the code!'),
      duration: Duration(seconds: 2),
    ),
  );
}

void showGameOver(BuildContext context, GameState gameState) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text('Game Over'),
      content: Text('Score: ${gameState.score}\nHigh Score: ${gameState.highScore}\n\nMay the bugs be vanquished!'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            navigateTo(context, TitleScreen());
          },
          child: Text('Back'),
        ),
      ],
    ),
  );
}
