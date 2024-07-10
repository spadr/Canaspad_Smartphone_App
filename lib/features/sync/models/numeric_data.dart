// lib/features/sync/models/numeric_data.dart

import 'package:json_annotation/json_annotation.dart';

import 'sensor_data.dart';

part 'numeric_data.g.dart';

@JsonSerializable()
class NumericData extends SensorData {
  final double value;

  NumericData({
    required String id,
    required DateTime timestamp,
    required String createdByUserId,
    required this.value,
  }) : super(
          id: id,
          timestamp: timestamp,
          createdByUserId: createdByUserId,
        );

  factory NumericData.fromJson(Map<String, dynamic> json) => _$NumericDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NumericDataToJson(this);
}

// flutter pub run build_runner build --delete-conflicting-outputs