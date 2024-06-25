class Data {
  final String sensorId;
  final String publicId;
  late final DateTime createdAt;
  final double value;
  final String filePath;

  Data({
    required this.sensorId,
    required this.publicId,
    required this.createdAt,
    required this.value,
    required this.filePath,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      sensorId: json['sensor_id'],
      publicId: json['publicId'],
      createdAt: DateTime.parse(json['createdAt']),
      value: json['value'],
      filePath: json['file_path'],
    );
  }
}
