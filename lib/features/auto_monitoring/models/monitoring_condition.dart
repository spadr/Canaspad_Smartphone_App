import 'package:uuid/uuid.dart';

enum ConditionType {
  threshold,
  range,
  consecutive,
  rapidChange,
  trendChange,
  dataMissing,
}

class MonitoringCondition {
  final String id;
  final String sensorId;
  final Map<ConditionType, bool> enabledConditions;
  final Map<ConditionType, Map<String, dynamic>> parameters;
  bool isEnabled;

  MonitoringCondition({
    String? id,
    required this.sensorId,
    Map<ConditionType, bool>? enabledConditions,
    Map<ConditionType, Map<String, dynamic>>? parameters,
    this.isEnabled = true,
  })  : id = id ?? Uuid().v4(),
        enabledConditions = enabledConditions ?? {for (var type in ConditionType.values) type: type == ConditionType.dataMissing},
        parameters = parameters ??
            {
              for (var type in ConditionType.values) type: type == ConditionType.dataMissing ? {'timeThreshold': 120} : {}
            };

  factory MonitoringCondition.fromJson(Map<String, dynamic> json) {
    return MonitoringCondition(
      id: json['id'],
      sensorId: json['sensorId'],
      enabledConditions: Map<ConditionType, bool>.from(
          json['enabledConditions'].map((key, value) => MapEntry(ConditionType.values.firstWhere((e) => e.toString() == key), value))),
      parameters: Map<ConditionType, Map<String, dynamic>>.from(
          json['parameters'].map((key, value) => MapEntry(ConditionType.values.firstWhere((e) => e.toString() == key), Map<String, dynamic>.from(value)))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sensorId': sensorId,
      'enabledConditions': enabledConditions.map((key, value) => MapEntry(key.toString(), value)),
      'parameters': parameters.map((key, value) => MapEntry(key.toString(), value)),
    };
  }

  MonitoringCondition copyWith({
    String? id,
    String? sensorId,
    Map<ConditionType, bool>? enabledConditions,
    Map<ConditionType, Map<String, dynamic>>? parameters,
    bool? isEnabled,
  }) {
    return MonitoringCondition(
      id: id ?? this.id,
      sensorId: sensorId ?? this.sensorId,
      enabledConditions: enabledConditions ?? Map.from(this.enabledConditions),
      parameters: parameters ?? Map.from(this.parameters),
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
