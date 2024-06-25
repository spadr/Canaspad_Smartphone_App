import '../../features/environment/models/environment_model.dart';

final sampleEnvironmentData = [
  EnvironmentModel(
    anonKey: 'dummy_anon_key',
    supabaseUrl: 'https://dummy.supabase.co',
    envName: "Environment 1",
    password: 'dummy_password',
    emailAddress: 'dummy@example.com',
    selected: true, // 初回設定で選択されるようにする
  ),
  EnvironmentModel(
    anonKey: 'dummy_anon_key',
    supabaseUrl: 'https://dummy.supabase.co',
    envName: "Environment 2",
    password: 'dummy_password',
    emailAddress: 'dummy@example.com',
    selected: false,
  ),
];
