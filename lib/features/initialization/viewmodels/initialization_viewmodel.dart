import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:canaspad/core/services/secure_storage_service.dart';
import 'package:canaspad/core/services/supabase_service.dart';
import 'package:canaspad/data/mock/environment_sample.dart';
import 'package:canaspad/features/environment/models/environment_model.dart';
import 'package:canaspad/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InitializationViewModel extends ChangeNotifier {
  final SecureStorageService _secureStorageService;
  final SupabaseService _supabaseService;

  InitializationViewModel(this._secureStorageService, this._supabaseService) {}

  /// Initializes the app by saving sample data if no environment data exists and fetches all data.
  Future<void> initializeApp() async {
    await _loadOrSaveSampleData();
    await _fetchAllData();
  }

  Future<EnvironmentModel?> getSelectedEnvironment() async {
    return await _secureStorageService.readEnvironment();
  }

  /// Saves sample environment data if no data exists in secure storage.
  Future<void> _loadOrSaveSampleData() async {
    final environments = await _secureStorageService.readAllEnvironments();
    if (environments.isEmpty) {
      final sampleData = sampleEnvironmentData;
      await _secureStorageService.writeSecureData(
        'envSettings',
        jsonEncode(sampleData.map((e) => e.toJson()).toList()),
      );
    }
  }

  /// Fetches all data using the SupabaseService.
  Future<void> _fetchAllData() async {
    try {
      await _supabaseService.fetchAllData();
    } catch (e) {
      // エラーハンドリングをここに追加することができます
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
  final supabaseService = ref.watch(supabaseServiceProvider);
  return InitializationViewModel(secureStorageService, supabaseService);
});
