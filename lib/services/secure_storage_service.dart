import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = FlutterSecureStorage();

  Future<void> saveEnvironmentSettings(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> getEnvironmentSettings(String key) async {
    return await _storage.read(key: key);
  }
}
