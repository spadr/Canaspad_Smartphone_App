import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final flavor = ref.watch(flavorProvider);
  if (flavor == 'develop') {
    return MockAuthService();
  } else {
    return SupabaseAuthService();
  }
});

final modeProvider = Provider<String>((ref) => 'release');
final flavorProvider = Provider<String>((ref) => 'production');
