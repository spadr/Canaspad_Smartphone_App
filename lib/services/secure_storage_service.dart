// lib/services/secure_storage_service.dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/environment_model.dart';

abstract class SecureStorageService {
  Future<void> writeSecureData(String key, String value);
  Future<String?> readSecureData(String key);
  Future<void> deleteSecureData(String key);
  Future<EnvironmentModel?> readEnvironment();
  Future<List<EnvironmentModel>> readAllEnvironments();
}

class FlutterSecureStorageService implements SecureStorageService {
  final _storage = FlutterSecureStorage();

  @override
  Future<void> writeSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> readSecureData(String key) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<EnvironmentModel?> readEnvironment() async {
    final data = await _storage.read(key: 'envSettings');
    if (data != null) {
      final environments = (jsonDecode(data) as List).map((e) => EnvironmentModel.fromJson(e)).toList();
      return environments.firstWhere((env) => env.selected == true, orElse: () => environments.first);
    }
    return null;
  }

  @override
  Future<List<EnvironmentModel>> readAllEnvironments() async {
    final data = await _storage.read(key: 'envSettings');
    if (data != null) {
      return (jsonDecode(data) as List).map((e) => EnvironmentModel.fromJson(e)).toList();
    }
    return [];
  }
}

class MockSecureStorageService implements SecureStorageService {
  final Map<String, String> _storage = {};

  @override
  Future<void> writeSecureData(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<String?> readSecureData(String key) async {
    return _storage[key];
  }

  @override
  Future<void> deleteSecureData(String key) async {
    _storage.remove(key);
  }

  @override
  Future<EnvironmentModel?> readEnvironment() async {
    final data = _storage['envSettings'];
    if (data != null) {
      final environments = (jsonDecode(data) as List).map((e) => EnvironmentModel.fromJson(e)).toList();
      return environments.firstWhere((env) => env.selected == true, orElse: () => environments.first);
    }
    return null;
  }

  @override
  Future<List<EnvironmentModel>> readAllEnvironments() async {
    final data = _storage['envSettings'];
    if (data != null) {
      return (jsonDecode(data) as List).map((e) => EnvironmentModel.fromJson(e)).toList();
    }
    return [];
  }
}
