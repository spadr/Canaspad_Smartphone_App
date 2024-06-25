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
      'publicId': publicId,
      'group': group,
      'name': name,
      'dataType': dataType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create Sensor from JSON
  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      publicId: json['publicId'] ?? '',
      group: json['group'] ?? '',
      name: json['name'] ?? '',
      dataType: json['dataType'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }
}
