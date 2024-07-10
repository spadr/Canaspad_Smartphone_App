// lib/features/sync/models/sensor.dart

import 'package:json_annotation/json_annotation.dart';

import 'image_sensor.dart';
import 'numeric_sensor.dart';
import 'sensor_data.dart';

part 'sensor.g.dart';

@JsonSerializable(createFactory: false)
abstract class Sensor {
  final String id;
  final String groupName;
  final String name;
  final String sensorType;
  final String? anomalyDetectionMethod;
  final Map<String, dynamic>? anomalyDetectionParams;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SensorData> data;

  Sensor({
    required this.id,
    required this.groupName,
    required this.name,
    required this.sensorType,
    this.anomalyDetectionMethod,
    this.anomalyDetectionParams,
    required this.createdAt,
    required this.updatedAt,
    required this.data,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    switch (json['sensorType']) {
      case 'numeric':
        return NumericSensor.fromJson(json);
      case 'image':
        return ImageSensor.fromJson(json);
      default:
        throw Exception('Unknown sensor type: ${json['sensorType']}');
    }
  }

  Map<String, dynamic> toJson();
}
