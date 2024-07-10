// lib/features/sync/models/numeric_sensor.dart

import 'package:json_annotation/json_annotation.dart';

import 'sensor.dart';
import 'sensor_data.dart';

part 'numeric_sensor.g.dart';

@JsonSerializable()
class NumericSensor extends Sensor {
  final String unit;

  NumericSensor({
    required String id,
    required String groupName,
    required String name,
    required String sensorType,
    String? anomalyDetectionMethod,
    Map<String, dynamic>? anomalyDetectionParams,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<SensorData> data,
    required this.unit,
  }) : super(
          id: id,
          groupName: groupName,
          name: name,
          sensorType: sensorType,
          anomalyDetectionMethod: anomalyDetectionMethod,
          anomalyDetectionParams: anomalyDetectionParams,
          createdAt: createdAt,
          updatedAt: updatedAt,
          data: data,
        );

  factory NumericSensor.fromJson(Map<String, dynamic> json) => _$NumericSensorFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NumericSensorToJson(this);
}

// flutter pub run build_runner build --delete-conflicting-outputs