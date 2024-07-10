// lib/core/config/environment_config.dart

class EnvironmentConfig {
  final String environmentName;
  final String supabaseUrl;
  final String supabaseAnonKey;

  EnvironmentConfig({
    required this.environmentName,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
  });

  // 環境設定の名前から設定を取得するメソッド
  static EnvironmentConfig? fromName(String environmentName) {
    // ここでは決め打ちで設定を記述していますが、
    // 将来的には、環境設定をファイルやデータベースから読み込むように変更可能です。
    final environments = {
      '開発環境': EnvironmentConfig(
        environmentName: '開発環境',
        supabaseUrl: 'YOUR_DEV_SUPABASE_URL',
        supabaseAnonKey: 'YOUR_DEV_SUPABASE_ANON_KEY',
      ),
      'ステージング環境': EnvironmentConfig(
        environmentName: 'ステージング環境',
        supabaseUrl: 'YOUR_STAGING_SUPABASE_URL',
        supabaseAnonKey: 'YOUR_STAGING_SUPABASE_ANON_KEY',
      ),
      '本番環境': EnvironmentConfig(
        environmentName: '本番環境',
        supabaseUrl: 'YOUR_PROD_SUPABASE_URL',
        supabaseAnonKey: 'YOUR_PROD_SUPABASE_ANON_KEY',
      ),
    };

    return environments[environmentName];
  }
}
