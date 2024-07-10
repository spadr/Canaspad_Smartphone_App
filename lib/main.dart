import 'package:canaspad/features_old/initialization/views/initialization_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/supabase_client_manager.dart';
import 'features/environment/services/environment_service.dart';
import 'providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'production');

  runApp(
    ProviderScope(
      overrides: [
        flavorProvider.overrideWith((ref) => flavor),
        supabaseClientManagerProvider.overrideWith(
          (ref) => SupabaseClientManager(ref.read(environmentServiceProvider)),
        ),
        environmentServiceProvider.overrideWith(
          (ref) => EnvironmentService(ref.read(secureStorageProvider), ref.read(flavorProvider)),
        ),
      ],
      child: const MyApp(flavor: flavor),
    ),
  );
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
