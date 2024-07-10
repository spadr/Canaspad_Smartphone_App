import 'dart:async';
import 'dart:convert';

import 'package:canaspad/core_old/services/secure_storage_service.dart';
import 'package:canaspad/core_old/services/supabase_service.dart';
import 'package:canaspad/features_old/auto_monitoring/models/monitoring_condition.dart';
import 'package:canaspad/features_old/notification/models/notification_model.dart';
import 'package:canaspad/features_old/notification/viewmodels/notification_viewmodel.dart';
import 'package:canaspad/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

class AutoMonitoringViewModel extends StateNotifier<Map<String, MonitoringCondition>> {
  final SupabaseService _supabaseService;
  final SecureStorageService _secureStorageService;
  final NotificationViewModel _notificationViewModel;

  AutoMonitoringViewModel(this._supabaseService, this._secureStorageService, this._notificationViewModel) : super({}) {
    _loadMonitoringConditions();
  }

  void toggleSensorMonitoring(String sensorId) {
    state = {
      ...state,
      sensorId: state[sensorId]!.copyWith(isEnabled: !state[sensorId]!.isEnabled),
    };
    _saveConditionsToStorage();
  }

  void disableAllMonitoring() {
    state = state.map((key, condition) {
      return MapEntry(key, condition.copyWith(isEnabled: false));
    });
    _saveConditionsToStorage();
  }

  Future<void> _loadMonitoringConditions() async {
    final savedConditionsJson = await _secureStorageService.readSecureData('monitoringConditions');

    Map<String, MonitoringCondition> savedConditions = {};
    if (savedConditionsJson != null) {
      final savedConditionsMap = json.decode(savedConditionsJson) as Map<String, dynamic>;
      savedConditions = savedConditionsMap.map((key, value) => MapEntry(key, MonitoringCondition.fromJson(value)));
    }

    final sensors = _supabaseService.getSensors();
    Map<String, MonitoringCondition> newConditions = {...savedConditions};
    for (final sensor in sensors) {
      if (!newConditions.containsKey(sensor.publicId)) {
        newConditions[sensor.publicId] = MonitoringCondition(sensorId: sensor.publicId);
      }
    }
    state = newConditions;
  }

  Future<void> updateMonitoringCondition(MonitoringCondition condition) async {
    state = {...state, condition.sensorId: condition};
    await _saveConditionsToStorage();
  }

  Future<void> saveMonitoringCondition(MonitoringCondition condition) async {
    await updateMonitoringCondition(condition);
  }

  Future<void> _saveConditionsToStorage() async {
    final conditionsJson = json.encode(state.map((key, value) => MapEntry(key, value.toJson())));
    await _secureStorageService.writeSecureData('monitoringConditions', conditionsJson);
  }

  Future<void> startMonitoring() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );

    await Workmanager().registerPeriodicTask(
      "auto_monitoring",
      "autoMonitoringTask",
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }

  Future<void> checkConditions(String sensorId, double value) async {
    final condition = state[sensorId];
    if (condition != null && condition.isEnabled) {
      if (await _checkCondition(condition, value)) {
        _notifyUser(condition, value);
      }
    }
  }

  Future<bool> _checkCondition(MonitoringCondition condition, double value) async {
    for (var entry in condition.enabledConditions.entries) {
      if (entry.value) {
        switch (entry.key) {
          case ConditionType.threshold:
            if (_checkThreshold(condition, value)) return true;
            break;
          case ConditionType.range:
            if (_checkRange(condition, value)) return true;
            break;
          case ConditionType.consecutive:
            if (await _checkConsecutive(condition, value)) return true;
            break;
          case ConditionType.rapidChange:
            if (await _checkRapidChange(condition, value)) return true;
            break;
          case ConditionType.trendChange:
            if (await _checkTrendChange(condition, value)) return true;
            break;
          case ConditionType.dataMissing:
            if (await _checkDataMissing(condition)) return true;
            break;
        }
      }
    }
    return false;
  }

  bool _checkThreshold(MonitoringCondition condition, double value) {
    final params = condition.parameters[ConditionType.threshold];
    final upper = params?['upper'] as double?;
    final lower = params?['lower'] as double?;
    return (upper != null && value > upper) || (lower != null && value < lower);
  }

  bool _checkRange(MonitoringCondition condition, double value) {
    final params = condition.parameters[ConditionType.range];
    final min = params?['min'] as double? ?? 0;
    final max = params?['max'] as double? ?? 0;
    final isInside = params?['isInside'] as bool? ?? true;
    final inRange = value >= min && value <= max;
    return isInside ? !inRange : inRange;
  }

  Future<bool> _checkConsecutive(MonitoringCondition condition, double value) async {
    final params = condition.parameters[ConditionType.consecutive];
    final count = params?['count'] as int? ?? 0;
    final threshold = params?['threshold'] as double? ?? 0;
    final key = 'consecutive_${condition.sensorId}';
    final storedCount = await _secureStorageService.readSecureData(key);
    int currentCount = storedCount != null ? int.parse(storedCount) : 0;

    if (value > threshold) {
      currentCount++;
    } else {
      currentCount = 0;
    }

    await _secureStorageService.writeSecureData(key, currentCount.toString());
    return currentCount >= count;
  }

  Future<bool> _checkRapidChange(MonitoringCondition condition, double value) async {
    final params = condition.parameters[ConditionType.rapidChange];
    final changeThreshold = params?['changeThreshold'] as double? ?? 0;
    final key = 'last_value_${condition.sensorId}';
    final storedValue = await _secureStorageService.readSecureData(key);
    final lastValue = storedValue != null ? double.parse(storedValue) : null;

    await _secureStorageService.writeSecureData(key, value.toString());

    if (lastValue == null) return false;
    return (value - lastValue).abs() > changeThreshold;
  }

  Future<bool> _checkTrendChange(MonitoringCondition condition, double value) async {
    final params = condition.parameters[ConditionType.trendChange];
    final trendPeriod = params?['trendPeriod'] as int? ?? 0;
    final trendThreshold = params?['trendThreshold'] as double? ?? 0;
    final key = 'trend_values_${condition.sensorId}';
    final storedValues = await _secureStorageService.readSecureData(key);
    List<double> values = storedValues != null ? (json.decode(storedValues) as List).cast<double>() : [];

    values.add(value);
    if (values.length > trendPeriod) {
      values = values.sublist(values.length - trendPeriod);
    }

    await _secureStorageService.writeSecureData(key, json.encode(values));

    if (values.length < trendPeriod) return false;

    final firstHalf = values.sublist(0, trendPeriod ~/ 2);
    final secondHalf = values.sublist(trendPeriod ~/ 2);
    final firstAvg = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.reduce((a, b) => a + b) / secondHalf.length;

    return (secondAvg - firstAvg).abs() > trendThreshold;
  }

  Future<bool> _checkDataMissing(MonitoringCondition condition) async {
    final params = condition.parameters[ConditionType.dataMissing];
    final timeThreshold = params?['timeThreshold'] as int? ?? 0;
    final key = 'last_update_${condition.sensorId}';
    final storedTime = await _secureStorageService.readSecureData(key);
    final lastUpdateTime = storedTime != null ? DateTime.parse(storedTime) : null;

    final currentTime = DateTime.now();
    await _secureStorageService.writeSecureData(key, currentTime.toIso8601String());

    if (lastUpdateTime == null) return false;
    return currentTime.difference(lastUpdateTime).inMinutes > timeThreshold;
  }

  void _notifyUser(MonitoringCondition condition, double value) {
    final notification = NotificationModel(
      title: 'Monitoring Alert',
      message: 'Condition triggered for sensor ${condition.sensorId}',
      type: 'warning',
      status: 'unread',
      scheduledTime: DateTime.now(),
    );
    _notificationViewModel.addNotification(notification);
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final container = ProviderContainer();
    final viewModel = container.read(autoMonitoringViewModelProvider.notifier);

    // Fetch latest data for all sensors
    final supabaseService = container.read(supabaseServiceProvider);
    final latestData = supabaseService.getNumericData();

    for (var data in latestData) {
      if (data.data.isNotEmpty) {
        await viewModel.checkConditions(data.publicId!, data.data.last.value!);
      }
    }

    return Future.value(true);
  });
}

final autoMonitoringViewModelProvider = StateNotifierProvider<AutoMonitoringViewModel, Map<String, MonitoringCondition>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  final secureStorageService = ref.watch(secureStorageServiceProvider);
  final notificationViewModel = ref.watch(notificationViewModelProvider.notifier);
  return AutoMonitoringViewModel(supabaseService, secureStorageService, notificationViewModel);
});
