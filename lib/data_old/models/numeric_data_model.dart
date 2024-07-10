import 'data_model.dart';

class NumericData {
  final String? publicId;
  final String? group;
  final String? name;
  final String? dataType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<Data> data;

  NumericData({
    this.publicId,
    this.group,
    this.name,
    this.dataType,
    this.createdAt,
    this.updatedAt,
    required this.data,
  });

  factory NumericData.fromJson(Map<String, dynamic> json) {
    List<Data> dataList = [];
    if (json['DATA'] != null) {
      dataList = (json['DATA'] as List).map((dataJson) => Data.fromJson(dataJson as Map<String, dynamic>)).toList();
    }

    return NumericData(
      publicId: json['public_id'] as String?,
      group: json['group'] as String?,
      name: json['name'] as String?,
      dataType: json['data_type'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      data: dataList,
    );
  }

  @override
  String toString() {
    return 'NumericData(publicId: $publicId, group: $group, name: $name, dataType: $dataType, createdAt: $createdAt, updatedAt: $updatedAt, data: $data)';
  }
}
