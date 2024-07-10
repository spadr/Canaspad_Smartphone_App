// lib/features/sync/models/image_sensor.dart

import 'package:json_annotation/json_annotation.dart';

import 'sensor.dart';
import 'sensor_data.dart';

part 'image_sensor.g.dart';

@JsonSerializable()
class ImageSensor extends Sensor {
  final String resolution;

  ImageSensor({
    required String id,
    required String groupName,
    required String name,
    String? anomalyDetectionMethod,
    Map<String, dynamic>? anomalyDetectionParams,
    required DateTime createdAt,
    required DateTime updatedAt,
    required List<SensorData> data,
    required this.resolution,
  }) : super(
          id: id,
          groupName: groupName,
          name: name,
          sensorType: 'image',
          anomalyDetectionMethod: anomalyDetectionMethod,
          anomalyDetectionParams: anomalyDetectionParams,
          createdAt: createdAt,
          updatedAt: updatedAt,
          data: data,
        );

  factory ImageSensor.fromJson(Map<String, dynamic> json) => _$ImageSensorFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ImageSensorToJson(this);
}
