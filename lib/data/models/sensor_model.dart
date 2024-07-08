class Sensor {
  final String publicId;
  final String group;
  final String name;
  final String dataType;
  final DateTime createdAt;
  final DateTime updatedAt;

  Sensor({
    required this.publicId,
    required this.group,
    required this.name,
    required this.dataType,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Sensor to JSON
  Map<String, dynamic> toJson() {
    return {
      'public_id': publicId,
      'group': group,
      'name': name,
      'data_type': dataType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create Sensor from JSON
  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      publicId: json['public_id'] ?? '',
      group: json['group'] ?? '',
      name: json['name'] ?? '',
      dataType: json['data_type'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }
}
