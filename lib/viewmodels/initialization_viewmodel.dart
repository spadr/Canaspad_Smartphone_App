import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/environment_model.dart';

class InitializationViewModel extends ChangeNotifier {
  final _storage = FlutterSecureStorage();

  /// Initializes the app by saving sample data if no environment data exists.
  Future<void> initializeApp() async {
    await _loadOrSaveSampleData();
  }

  /// Saves sample environment data if no data exists in secure storage.
  Future<void> _loadOrSaveSampleData() async {
    final storedData = await _storage.read(key: 'envSettings');
    if (storedData == null) {
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
      await _storage.write(key: 'envSettings', value: jsonEncode(sampleData.map((e) => e.toJson()).toList()));
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
