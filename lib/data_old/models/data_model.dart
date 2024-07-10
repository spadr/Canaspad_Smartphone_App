class Data {
  final String? sensorId;
  final String? publicId;
  final DateTime? createdAt;
  final double? value;
  final String? filePath;

  Data({
    this.sensorId,
    this.publicId,
    this.createdAt,
    this.value,
    this.filePath,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      sensorId: json['sensor_id'] as String?,
      publicId: json['public_id'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      value: json['value'] != null ? (json['value'] as num).toDouble() : null,
      filePath: json['file_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sensor_id': sensorId,
      'public_id': publicId,
      'created_at': createdAt?.toIso8601String(),
      'value': value,
      'file_path': filePath,
    };
  }

  @override
  String toString() {
    return 'Data(sensorId: $sensorId, publicId: $publicId, createdAt: $createdAt, value: $value, filePath: $filePath)';
  }
}
