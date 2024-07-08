import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/monitoring_condition.dart';
import '../viewmodels/auto_monitoring_viewmodel.dart';

class MonitoringConditionDetailView extends ConsumerStatefulWidget {
  final MonitoringCondition condition;

  const MonitoringConditionDetailView({Key? key, required this.condition}) : super(key: key);

  @override
  ConsumerState<MonitoringConditionDetailView> createState() => _MonitoringConditionDetailViewState();
}

class _MonitoringConditionDetailViewState extends ConsumerState<MonitoringConditionDetailView> {
  late MonitoringCondition _condition;

  @override
  void initState() {
    super.initState();
    _condition = widget.condition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Condition'),
        actions: [
          IconButton(
            icon: Icon(
              _condition.isEnabled ? Icons.notifications_active : Icons.notifications_off,
              color: _condition.isEnabled ? null : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _condition = _condition.copyWith(isEnabled: !_condition.isEnabled);
              });
            },
            tooltip: _condition.isEnabled ? 'Disable Monitoring' : 'Enable Monitoring',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sensor ID: ${_condition.sensorId}'),
            const SizedBox(height: 16),
            ..._buildConditionWidgets(),
            const SizedBox(height: 32),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
                try {
                  await ref.read(autoMonitoringViewModelProvider.notifier).saveMonitoringCondition(_condition);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Condition saved successfully')),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save condition: $e')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildConditionWidgets() {
    return ConditionType.values.map((type) {
      return Column(
        children: [
          SwitchListTile(
            title: Text(
              type.toString().split('.').last,
              style: TextStyle(color: _condition.isEnabled ? null : Colors.grey),
            ),
            value: _condition.enabledConditions[type] ?? false,
            onChanged: (value) {
              setState(() {
                _condition = _condition.copyWith(
                  enabledConditions: {..._condition.enabledConditions, type: value},
                  isEnabled: value ? true : _condition.isEnabled,
                );
              });
            },
          ),
          if (_condition.enabledConditions[type] ?? false) _buildParametersWidget(type),
          const Divider(),
        ],
      );
    }).toList();
  }

  Widget _buildParametersWidget(ConditionType type) {
    Widget widget;
    switch (type) {
      case ConditionType.threshold:
        widget = _buildThresholdParameters();
        break;
      case ConditionType.range:
        widget = _buildRangeParameters();
        break;
      case ConditionType.consecutive:
        widget = _buildConsecutiveParameters();
        break;
      case ConditionType.rapidChange:
        widget = _buildRapidChangeParameters();
        break;
      case ConditionType.trendChange:
        widget = _buildTrendChangeParameters();
        break;
      case ConditionType.dataMissing:
        widget = _buildDataMissingParameters();
        break;
    }
    return Opacity(
      opacity: _condition.isEnabled ? 1.0 : 0.5,
      child: widget,
    );
  }

  Widget _buildThresholdParameters() {
    return Column(
      children: [
        TextFormField(
          initialValue: _condition.parameters[ConditionType.threshold]?['upper']?.toString() ?? '',
          decoration: const InputDecoration(labelText: 'Upper Threshold'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _updateParameter(ConditionType.threshold, 'upper', double.tryParse(value));
          },
        ),
        TextFormField(
          initialValue: _condition.parameters[ConditionType.threshold]?['lower']?.toString() ?? '',
          decoration: const InputDecoration(labelText: 'Lower Threshold'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _updateParameter(ConditionType.threshold, 'lower', double.tryParse(value));
          },
        ),
      ],
    );
  }

  Widget _buildRangeParameters() {
    return Column(
      children: [
        TextFormField(
          initialValue: _condition.parameters[ConditionType.range]?['min']?.toString() ?? '',
          decoration: const InputDecoration(labelText: 'Minimum Value'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _updateParameter(ConditionType.range, 'min', double.tryParse(value));
          },
        ),
        TextFormField(
          initialValue: _condition.parameters[ConditionType.range]?['max']?.toString() ?? '',
          decoration: const InputDecoration(labelText: 'Maximum Value'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _updateParameter(ConditionType.range, 'max', double.tryParse(value));
          },
        ),
        SwitchListTile(
          title: const Text('Inside Range'),
          value: _condition.parameters[ConditionType.range]?['isInside'] ?? true,
          onChanged: (value) {
            _updateParameter(ConditionType.range, 'isInside', value);
          },
        ),
      ],
    );
  }

  Widget _buildConsecutiveParameters() {
    return Column(
      children: [
        TextFormField(
          initialValue: _condition.parameters[ConditionType.consecutive]?['count']?.toString() ?? '',
          decoration: const InputDecoration(labelText: 'Consecutive Count'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _updateParameter(ConditionType.consecutive, 'count', int.tryParse(value));
          },
        ),
        TextFormField(
          initialValue: _condition.parameters[ConditionType.consecutive]?['threshold']?.toString() ?? '',
          decoration: const InputDecoration(labelText: 'Threshold Value'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _updateParameter(ConditionType.consecutive, 'threshold', double.tryParse(value));
          },
        ),
      ],
    );
  }

  Widget _buildRapidChangeParameters() {
    return TextFormField(
      initialValue: _condition.parameters[ConditionType.rapidChange]?['changeThreshold']?.toString() ?? '',
      decoration: const InputDecoration(labelText: 'Change Threshold'),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        _updateParameter(ConditionType.rapidChange, 'changeThreshold', double.tryParse(value));
      },
    );
  }

  Widget _buildTrendChangeParameters() {
    return Column(
      children: [
        TextFormField(
          initialValue: _condition.parameters[ConditionType.trendChange]?['trendPeriod']?.toString() ?? '',
          decoration: const InputDecoration(labelText: 'Trend Period (minutes)'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _updateParameter(ConditionType.trendChange, 'trendPeriod', int.tryParse(value));
          },
        ),
        TextFormField(
          initialValue: _condition.parameters[ConditionType.trendChange]?['trendThreshold']?.toString() ?? '',
          decoration: const InputDecoration(labelText: 'Trend Change Threshold'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _updateParameter(ConditionType.trendChange, 'trendThreshold', double.tryParse(value));
          },
        ),
      ],
    );
  }

  Widget _buildDataMissingParameters() {
    return TextFormField(
      initialValue: _condition.parameters[ConditionType.dataMissing]?['timeThreshold']?.toString() ?? '',
      decoration: const InputDecoration(labelText: 'Time Threshold (minutes)'),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        _updateParameter(ConditionType.dataMissing, 'timeThreshold', int.tryParse(value));
      },
    );
  }

  void _updateParameter(ConditionType type, String key, dynamic value) {
    setState(() {
      _condition = _condition.copyWith(
        parameters: {
          ..._condition.parameters,
          type: {
            ...?_condition.parameters[type],
            key: value,
          },
        },
      );
    });
  }
}
