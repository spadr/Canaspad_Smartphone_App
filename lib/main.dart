import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/services/secure_storage_service.dart';
import 'features/environment/models/environment_model.dart';
import 'features/initialization/views/initialization_view.dart';
import 'providers.dart';

void main() async {
  await initializeApp();
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  final flavor = const String.fromEnvironment('FLAVOR', defaultValue: 'production');
  EnvironmentModel? selectedEnvironment;

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
    }
    if (selectedEnvironment != null) {
      overrides.add(selectedEnvironmentProvider.overrideWithProvider(StateProvider((ref) => selectedEnvironment)));
    }
  } else {
    // 開発用の場合、モックのサービスを使用
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
