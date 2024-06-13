import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/environment_model.dart';
import '../services/secure_storage_service.dart';

/// A view to edit the details of an environment.
class EnvironmentDetailView extends StatefulWidget {
  /// The environment to be edited.
  final EnvironmentModel environment;

  /// The list of all environments.
  final List<EnvironmentModel> environments;

  /// Creates a new [EnvironmentDetailView].
  EnvironmentDetailView({required this.environment, required this.environments});

  @override
  _EnvironmentDetailViewState createState() => _EnvironmentDetailViewState();
}

class _EnvironmentDetailViewState extends State<EnvironmentDetailView> {
  final SecureStorageService _secureStorageService = SecureStorageService();
  final _formKey = GlobalKey<FormState>();
  late EnvironmentModel environment;
  late List<EnvironmentModel> environments;

  @override
  void initState() {
    super.initState();
    environment = widget.environment;
    environments = widget.environments;
  }

  /// Saves the list of environments to secure storage.
  Future<void> _saveEnvironments() async {
    await _secureStorageService.writeSecureData(
      'envSettings',
      jsonEncode(environments.map((e) => e.toJson()).toList()),
    );
  }

  /// Saves the current environment details.
  Future<void> _saveEnvironment() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _saveEnvironments();
      Navigator.pop(context, true);
    }
  }

  /// Deletes the current environment.
  Future<void> _deleteEnvironment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this environment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      environments.remove(environment);
      await _saveEnvironments();
      Navigator.pop(context, true);
    }
  }

  /// Selects the current environment.
  void _selectEnvironment(bool selected) {
    setState(() {
      for (var env in environments) {
        env.selected = env == environment ? selected : false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSingleEnvironment = environments.length == 1;
    return Scaffold(
      appBar: AppBar(title: Text('Edit Environment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextFormField('Environment Name', environment.envName, (value) => environment.envName = value),
              SizedBox(height: 16.0),
              _buildTextFormField('Anon Key', environment.anonKey, (value) => environment.anonKey = value),
              SizedBox(height: 16.0),
              _buildTextFormField('Supabase URL', environment.supabaseUrl, (value) => environment.supabaseUrl = value),
              SizedBox(height: 16.0),
              _buildTextFormField('Password', environment.password, (value) => environment.password = value),
              SizedBox(height: 16.0),
              _buildTextFormField('Email Address', environment.emailAddress, (value) => environment.emailAddress = value),
              SizedBox(height: 16.0),
              SwitchListTile(
                title: Text('Select this environment'),
                subtitle: environment.selected == true
                    ? Text(
                        'Primary Environment',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
                value: environment.selected ?? false,
                onChanged: environment.selected == true ? null : _selectEnvironment,
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _saveEnvironment,
                    icon: Icon(Icons.save),
                    label: Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: isSingleEnvironment ? null : _deleteEnvironment,
                    icon: Icon(Icons.delete),
                    label: Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a text form field with the given label and initial value.
  TextFormField _buildTextFormField(String labelText, String? initialValue, FormFieldSetter<String?> onSaved) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      onSaved: onSaved,
    );
  }
}
