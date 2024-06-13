import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/environment_model.dart';
import '../services/secure_storage_service.dart';

/// ViewModel that manages the state of environments and handles interactions with secure storage.
class EnvironmentViewModel extends ChangeNotifier {
  /// Instance of the SecureStorageService to handle secure data storage.
  SecureStorageService _secureStorageService = SecureStorageService();

  /// List of environments managed by this ViewModel.
  List<EnvironmentModel> environments = [];

  /// Constructor that initializes the ViewModel and loads environments from storage.
  EnvironmentViewModel() {
    loadEnvironments();
  }

  /// Sets the storage service to a new instance. Useful for testing with mock services.
  void setStorageService(SecureStorageService storageService) {
    _secureStorageService = storageService;
  }

  /// Loads environments from secure storage and notifies listeners.
  Future<void> loadEnvironments() async {
    final data = await _secureStorageService.readSecureData('envSettings');
    if (data != null) {
      environments = (jsonDecode(data) as List).map((e) => EnvironmentModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  /// Adds a new environment with a unique name and saves the updated list to storage.
  void addEnvironment() {
    final newEnvironment = EnvironmentModel(
      envName: _generateEnvironmentName(),
      anonKey: null,
      supabaseUrl: null,
      password: null,
      emailAddress: null,
      selected: false,
    );
    environments.add(newEnvironment);
    _saveEnvironments();
  }

  /// Saves the given environment to the list, updating if it already exists, and then saves the list to storage.
  void saveEnvironment(EnvironmentModel environment) {
    final index = environments.indexWhere((e) => e.envName == environment.envName);
    if (index != -1) {
      environments[index] = environment;
    } else {
      environments.add(environment);
    }
    _saveEnvironments();
  }

  /// Deletes the given environment from the list and saves the updated list to storage.
  void deleteEnvironment(EnvironmentModel environment) {
    environments.remove(environment);
    _saveEnvironments();
  }

  /// Selects the given environment as the primary environment, deselecting all others.
  void selectEnvironment(EnvironmentModel selectedEnvironment, bool selected) {
    for (var env in environments) {
      env.selected = env == selectedEnvironment ? selected : false;
    }
    _saveEnvironments();
  }

  /// Saves the current list of environments to secure storage and notifies listeners of changes.
  Future<void> _saveEnvironments() async {
    await _secureStorageService.writeSecureData(
      'envSettings',
      jsonEncode(environments.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  /// Generates a unique name for a new environment by incrementing an index.
  String _generateEnvironmentName() {
    int index = 1;
    while (environments.any((env) => env.envName == 'Environment $index')) {
      index++;
    }
    return 'Environment $index';
  }
}
