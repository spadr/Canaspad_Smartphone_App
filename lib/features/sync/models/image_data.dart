// lib/features/sync/models/image_data.dart

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'sensor_data.dart';

part 'image_data.g.dart';

@JsonSerializable()
class ImageData extends SensorData {
  final String filePath;
  @JsonKey(ignore: true)
  final Image? image;

  ImageData({
    required String id,
    required DateTime timestamp,
    required String createdByUserId,
    required this.filePath,
    this.image,
  }) : super(
          id: id,
          timestamp: timestamp,
          createdByUserId: createdByUserId,
        );

  factory ImageData.fromJson(Map<String, dynamic> json) => _$ImageDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ImageDataToJson(this);
}

// flutter pub run build_runner build --delete-conflicting-outputs