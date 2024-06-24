import 'data_model.dart';

class SensingData {
  final String publicId;
  final String group;
  final String name;
  final String dataType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Data> data;

  SensingData({
    required this.publicId,
    required this.group,
    required this.name,
    required this.dataType,
    required this.createdAt,
    required this.updatedAt,
    required this.data,
  });

  factory SensingData.fromJson(Map<String, dynamic> json, List<Data> data) {
    return SensingData(
      publicId: json['publicId'] ?? '',
      group: json['group'] ?? '',
      name: json['name'] ?? '',
      dataType: json['dataType'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      data: data,
    );
  }

  @override
  String toString() {
    return 'SensingData(publicId: $publicId, group: $group, name: $name, dataType: $dataType, createdAt: $createdAt, updatedAt: $updatedAt, data: $data)';
  }
}
