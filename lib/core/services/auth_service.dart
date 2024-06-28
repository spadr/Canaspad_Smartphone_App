import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthService {
  Future<void> signIn(String email, String password);
  Future<void> signOut();
}

class SupabaseAuthService implements AuthService {
  final SupabaseClient _client;

  SupabaseAuthService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  Future<void> signIn(String email, String password) async {
    try {
      print('Signing in with email: $email');
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
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
