import 'package:canaspad/features_old/initialization/views/initialization_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:sentry/sentry.dart';

import 'core/error/error_handler.dart';
import 'providers.dart';

Future<void> main() async {
  // Flutter バインディングを確実に初期化
  WidgetsFlutterBinding.ensureInitialized();

  // .env ファイルを読み込む
  await dotenv.load(fileName: ".env");

  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'production');

  final navigatorKey = GlobalKey<NavigatorState>();

  // ロギングの設定
  await _setupLogging(flavor);

  // Sentry の初期化
  await Sentry.init(
    (options) {
      options.dsn = dotenv.env['SENTRY_URL'] ?? '';
      options.tracesSampleRate = 1.0;
    },
  );

  // グローバルエラーハンドリング
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    Logger('GlobalErrorHandler').severe('Flutter error', details.exception, details.stack);
    Sentry.captureException(details.exception, stackTrace: details.stack);
  };

  runApp(
    ProviderScope(
      overrides: [
        flavorProvider.overrideWith((ref) => flavor),
        errorHandlerProvider.overrideWithValue(ErrorHandler(navigatorKey)),
      ],
      child: MyApp(flavor: flavor),
    ),
  );
}

Future<void> _setupLogging(String flavor) async {
  // final directory = await getApplicationDocumentsDirectory();
  // final logFile = File('${directory.path}/app_logs.txt');

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    final logMessage = '${record.time}: ${record.level.name}: ${record.message}';
    print(logMessage);
    // logFile.writeAsStringSync('$logMessage\n', mode: FileMode.append);
  });

  Logger('AppInitialization').info('App started in $flavor flavor');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.flavor});

  final String flavor; //リファクタリリファクタリング中につき仮置き

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canaspad IoT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InitializationView(flavor: 'develop'),
    );
  }
}
