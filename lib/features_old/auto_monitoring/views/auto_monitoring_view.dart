import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/auto_monitoring_viewmodel.dart';
import 'monitoring_condition_detail_view.dart';

class AutoMonitoringView extends ConsumerWidget {
  const AutoMonitoringView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conditions = ref.watch(autoMonitoringViewModelProvider);
    final viewModel = ref.read(autoMonitoringViewModelProvider.notifier);

    bool allDisabled = conditions.values.every((condition) => !condition.isEnabled);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Monitoring'),
        actions: [
          IconButton(
            icon: Icon(
              allDisabled ? Icons.notifications_off : Icons.notifications_active,
              color: allDisabled ? Colors.grey : null,
            ),
            onPressed: allDisabled
                ? null
                : () {
                    _showDisableAllConfirmationDialog(context, viewModel);
                  },
            tooltip: allDisabled ? 'All Monitoring Disabled' : 'Disable All Monitoring',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: conditions.length,
        itemBuilder: (context, index) {
          final sensorId = conditions.keys.elementAt(index);
          final condition = conditions[sensorId]!;
          return ListTile(
            title: Text('Sensor: $sensorId'),
            subtitle: Text('Enabled conditions: ${condition.enabledConditions.entries.where((e) => e.value).length}'),
            trailing: IconButton(
              icon: Icon(
                condition.isEnabled ? Icons.notifications_active : Icons.notifications_off,
                color: condition.isEnabled ? null : Colors.grey,
              ),
              onPressed: () {
                viewModel.toggleSensorMonitoring(sensorId);
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MonitoringConditionDetailView(condition: condition),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDisableAllConfirmationDialog(BuildContext context, AutoMonitoringViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Disable All Monitoring'),
          content: Text('Are you sure you want to disable monitoring for all sensors?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Disable All'),
              onPressed: () {
                viewModel.disableAllMonitoring();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
