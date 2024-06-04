import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';
import 'views/splash_view.dart';

void main(List<String> args) {
  // 引数を解析してモードとフレーバーを設定
  String mode = 'release'; // デフォルトはrelease
  String flavor = 'production'; // デフォルトはproduction

  if (args.contains('--mode')) {
    int modeIndex = args.indexOf('--mode');
    if (modeIndex != -1 && modeIndex + 1 < args.length) {
      mode = args[modeIndex + 1];
    }
  }

  if (args.contains('--flavor')) {
    int flavorIndex = args.indexOf('--flavor');
    if (flavorIndex != -1 && flavorIndex + 1 < args.length) {
      flavor = args[flavorIndex + 1];
    }
  }

  runApp(ProviderScope(
    overrides: [
      modeProvider.overrideWithValue(mode),
      flavorProvider.overrideWithValue(flavor),
    ],
    child: MyApp(mode: mode, flavor: flavor),
  ));
}

class MyApp extends StatelessWidget {
  final String mode;
  final String flavor;

  MyApp({required this.mode, required this.flavor});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _getAppTitle(),
      theme: _getAppTheme(),
      home: SplashView(flavor: flavor),
    );
  }

  String _getAppTitle() {
    return 'Time Series Data App ($flavor - $mode)';
  }

  ThemeData _getAppTheme() {
    switch (flavor) {
      case 'develop':
        return ThemeData(
          primarySwatch: Colors.blue,
        );
      case 'staging':
        return ThemeData(
          primarySwatch: Colors.orange,
        );
      case 'production':
      default:
        return ThemeData(
          primarySwatch: Colors.green,
        );
    }
  }
}
