import 'package:flutter/material.dart';

import 'game_view.dart';
import 'utils/navigation_utils.dart';
import 'widgets/app_bar.dart';

class TitleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'Debug Vanquisher'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Debug Begone!', style: TextStyle(fontSize: 24)),
            Image.asset(
              'images/BugDaibutsu.png',
              errorBuilder: (context, error, stackTrace) => Text('Image not found'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => navigateTo(context, MiniGameView()),
              child: Text('Game Start'),
            ),
          ],
        ),
      ),
    );
  }
}
