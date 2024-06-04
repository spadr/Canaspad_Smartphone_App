abstract class AuthService {
  Future<void> signIn(String email, String password);
  Future<void> signOut();
}

class SupabaseAuthService implements AuthService {
  @override
  Future<void> signIn(String email, String password) async {
    // Supabaseのサインイン処理
  }

  @override
  Future<void> signOut() async {
    // Supabaseのサインアウト処理
  }
}

class MockAuthService implements AuthService {
  @override
  Future<void> signIn(String email, String password) async {
    // モックのサインイン処理（デバッグ用）
  }

  @override
  Future<void> signOut() async {
    // モックのサインアウト処理（デバッグ用）
  }
}
