import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/environment_model.dart';
import '../providers.dart';
import '../services/secure_storage_service.dart';

class InitializationViewModel extends ChangeNotifier {
  final SecureStorageService _secureStorageService;

  InitializationViewModel(this._secureStorageService);

  /// Initializes the app by saving sample data if no environment data exists.
  Future<void> initializeApp() async {
    await _loadOrSaveSampleData();
  }

  /// Saves sample environment data if no data exists in secure storage.
  Future<void> _loadOrSaveSampleData() async {
    final environments = await _secureStorageService.readAllEnvironments();
    if (environments.isEmpty) {
      final sampleData = [
        EnvironmentModel(
          anonKey: null,
          supabaseUrl: null,
          envName: "Environment 1",
          password: null,
          emailAddress: null,
          selected: true,
        ),
        EnvironmentModel(
          anonKey: null,
          supabaseUrl: null,
          envName: "Environment 2",
          password: null,
          emailAddress: null,
          selected: false,
        ),
      ];
      await _secureStorageService.writeSecureData(
        'envSettings',
        jsonEncode(sampleData.map((e) => e.toJson()).toList()),
      );
    }
  }

  /// Checks network connectivity.
  Future<bool> checkNetworkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}

final initializationViewModelProvider = ChangeNotifierProvider((ref) {
  final secureStorageService = ref.watch(secureStorageServiceProvider);
  return InitializationViewModel(secureStorageService);
});
