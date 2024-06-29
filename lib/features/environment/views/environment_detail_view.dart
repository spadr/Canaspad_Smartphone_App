import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/environment_text_field.dart';
import '../models/environment_model.dart';
import '../viewmodels/environment_viewmodel.dart';

class EnvironmentDetailView extends ConsumerStatefulWidget {
  final EnvironmentModel environment;

  EnvironmentDetailView({Key? key, required this.environment}) : super(key: key);

  @override
  _EnvironmentDetailViewState createState() => _EnvironmentDetailViewState();
}

class _EnvironmentDetailViewState extends ConsumerState<EnvironmentDetailView> {
  final _formKey = GlobalKey<FormState>();
  late EnvironmentModel environment;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    environment = widget.environment;
  }

  Future<void> _saveEnvironment() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      try {
        await ref.read(environmentViewModelProvider.notifier).saveEnvironment(environment);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _deleteEnvironment() async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this environment?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        final result = await ref.read(environmentViewModelProvider.notifier).deleteEnvironment(environment);
        if (mounted) {
          if (result) {
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cannot delete the last environment')),
            );
          }
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Key('EnvironmentDetailView'),
      appBar: AppBar(title: Text('Edit Environment')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    EnvironmentTextField(
                      key: Key('EnvironmentNameField'),
                      labelText: 'Environment Name',
                      initialValue: environment.envName,
                      onSaved: (value) => environment = environment.copyWith(envName: value),
                    ),
                    SizedBox(height: 16.0),
                    EnvironmentTextField(
                      key: Key('AnonKeyField'),
                      labelText: 'Anon Key',
                      initialValue: environment.anonKey,
                      onSaved: (value) => environment = environment.copyWith(anonKey: value),
                    ),
                    SizedBox(height: 16.0),
                    EnvironmentTextField(
                      key: Key('SupabaseUrlField'),
                      labelText: 'Supabase URL',
                      initialValue: environment.supabaseUrl,
                      onSaved: (value) => environment = environment.copyWith(supabaseUrl: value),
                    ),
                    SizedBox(height: 16.0),
                    EnvironmentTextField(
                      key: Key('PasswordField'),
                      labelText: 'Password',
                      initialValue: environment.password,
                      onSaved: (value) => environment = environment.copyWith(password: value),
                      obscureText: true,
                    ),
                    SizedBox(height: 16.0),
                    EnvironmentTextField(
                      key: Key('EmailAddressField'),
                      labelText: 'Email Address',
                      initialValue: environment.emailAddress,
                      onSaved: (value) => environment = environment.copyWith(emailAddress: value),
                    ),
                    SizedBox(height: 16.0),
                    SwitchListTile(
                      key: Key('SelectEnvironmentSwitch'),
                      title: Text('Select this environment'),
                      value: environment.selected ?? false,
                      onChanged: (value) {
                        setState(() {
                          environment = environment.copyWith(selected: value);
                        });
                      },
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          key: Key('SaveEnvironmentButton'),
                          onPressed: _saveEnvironment,
                          icon: Icon(Icons.save),
                          label: Text('Save'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          key: Key('DeleteEnvironmentButton'),
                          onPressed: _deleteEnvironment,
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
}
