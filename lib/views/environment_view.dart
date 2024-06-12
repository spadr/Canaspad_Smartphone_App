import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/environment_viewmodel.dart';
import 'environment_detail_view.dart';

/// A view that displays a list of environments and allows adding, editing, and deleting environments.
class EnvironmentView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Provides the EnvironmentViewModel to the widget tree.
      create: (context) => EnvironmentViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Environments'),
        ),
        body: Consumer<EnvironmentViewModel>(
          // Consumes the EnvironmentViewModel to rebuild the UI when the model changes.
          builder: (context, viewModel, child) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: viewModel.environments.length,
                itemBuilder: (context, index) {
                  final env = viewModel.environments[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      title: Text(env.envName ?? 'No Name'),
                      subtitle: Text('Supabase URL: ${env.supabaseUrl ?? "N/A"}'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        // Navigates to the EnvironmentDetailView when an environment is tapped.
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EnvironmentDetailView(
                              environment: env,
                              environments: viewModel.environments,
                            ),
                          ),
                        );
                        if (result == true) {
                          // Reloads the environments if the detail view indicates changes.
                          viewModel.loadEnvironments();
                        }
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: Consumer<EnvironmentViewModel>(
          // Consumes the EnvironmentViewModel to handle adding a new environment.
          builder: (context, viewModel, child) {
            return FloatingActionButton(
              onPressed: viewModel.addEnvironment,
              tooltip: 'Add Environment',
              child: Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}
