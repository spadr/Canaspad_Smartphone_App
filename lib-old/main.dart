import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/environment_model.dart';
import 'providers.dart';
import 'services/secure_storage_service.dart';
import 'views/initialization_view.dart';

void main() async {
  await initializeApp();
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  final flavor = const String.fromEnvironment('FLAVOR', defaultValue: 'production');
  EnvironmentModel? selectedEnvironment;

  // フレーバーに応じてプロバイダーを上書き
  final overrides = [
    flavorProvider.overrideWithProvider(StateProvider((ref) => flavor)),
  ];

  if (flavor != 'develop') {
    final secureStorageService = FlutterSecureStorageService();
    selectedEnvironment = await secureStorageService.readEnvironment();
    if (selectedEnvironment != null) {
      await Supabase.initialize(
        url: selectedEnvironment.supabaseUrl ?? 'YOUR_DEFAULT_SUPABASE_URL',
        anonKey: selectedEnvironment.anonKey ?? 'YOUR_DEFAULT_SUPABASE_ANON_KEY',
      );
    } else {
      print('No environment settings found. Using default values.');
      await Supabase.initialize(
        url: 'YOUR_DEFAULT_SUPABASE_URL',
        anonKey: 'YOUR_DEFAULT_SUPABASE_ANON_KEY',
      );
    }
    if (selectedEnvironment != null) {
      overrides.add(selectedEnvironmentProvider.overrideWithProvider(StateProvider((ref) => selectedEnvironment)));
    }
  } else {
    // 開発用の場合、モックのサービスを使用
    print('Running in develop mode');
    overrides.add(supabaseServiceProvider.overrideWithProvider(mockSupabaseServiceProvider));
    overrides.add(secureStorageServiceProvider.overrideWithProvider(Provider((ref) => MockSecureStorageService())));
  }

  runApp(
    ProviderScope(
      overrides: overrides,
      child: MyApp(flavor: flavor),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String flavor;

  const MyApp({Key? key, required this.flavor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canaspad_IoT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InitializationView(flavor: flavor),
    );
  }
}