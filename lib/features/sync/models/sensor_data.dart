import 'package:json_annotation/json_annotation.dart';

part 'sensor_data.g.dart';

@JsonSerializable()
class SensorData {
  final String id;
  final DateTime timestamp;
  final String createdByUserId;

  SensorData({
    required this.id,
    required this.timestamp,
    required this.createdByUserId,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) => _$SensorDataFromJson(json);

  Map<String, dynamic> toJson() => _$SensorDataToJson(this);
}
