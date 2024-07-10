import 'dart:ui' as ui;

import 'package:canaspad/data_old/models/sensor_model.dart';

class ImageData {
  final String? sensorId;
  final String? publicId;
  final DateTime? createdAt;
  final ui.Image? image;
  final String? filePath; // Added filePath property

  ImageData({
    this.sensorId,
    this.publicId,
    this.createdAt,
    this.image,
    this.filePath, // Added filePath to constructor
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      sensorId: json['sensor_id'] as String?,
      publicId: json['public_id'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      image: null,
      filePath: json['file_path'] as String?, // Added filePath to fromJson
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sensor_id': sensorId,
      'public_id': publicId,
      'created_at': createdAt?.toIso8601String(),
      'file_path': filePath,
    };
  }
}

class ImageSensor extends Sensor {
  final List<ImageData> data;

  ImageSensor({
    required super.publicId,
    required super.group,
    required super.name,
    required super.dataType,
    required super.createdAt,
    required super.updatedAt,
    required this.data,
  });

  factory ImageSensor.fromJson(Map<String, dynamic> json) {
    final sensor = Sensor.fromJson(json);
    final dataList = (json['data'] as List<dynamic>?)?.map((e) => ImageData.fromJson(e as Map<String, dynamic>)).toList() ?? [];

    return ImageSensor(
      publicId: sensor.publicId,
      group: sensor.group,
      name: sensor.name,
      dataType: sensor.dataType,
      createdAt: sensor.createdAt,
      updatedAt: sensor.updatedAt,
      data: dataList,
    );
  }
}
