import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/environment_viewmodel.dart';
import 'environment_detail_view.dart';

class EnvironmentView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(environmentViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Environments'),
      ),
      body: Padding(
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
                key: Key('EnvironmentTile_$index'),
                title: Text(env.envName ?? 'No Name'),
                subtitle: Text('Supabase URL: ${env.supabaseUrl ?? "N/A"}'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EnvironmentDetailView(
                        key: Key('EnvironmentDetailView'),
                        environment: env,
                      ),
                    ),
                  );
                  if (result == true) {
                    viewModel.loadEnvironments();
                  }
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: Key('AddEnvironmentButton'),
        onPressed: () => viewModel.addEnvironment(),
        tooltip: 'Add Environment',
        child: Icon(Icons.add),
      ),
    );
  }
}
