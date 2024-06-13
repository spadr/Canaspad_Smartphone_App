import 'package:flutter/material.dart';

import '../game_title_screen.dart';
import '../utils/navigation_utils.dart';

AppBar buildAppBar(BuildContext context, String title) {
  return AppBar(
    title: Text(title),
    leading: IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => navigateTo(context, TitleScreen()),
    ),
  );
}
