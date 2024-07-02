import 'package:uuid/uuid.dart';

class NotificationModel {
  final String id;
  String title;
  String message;
  String type;
  String status;
  DateTime scheduledTime;
  final DateTime createdAt;
  DateTime updatedAt;

  NotificationModel({
    String? id,
    required this.title,
    required this.message,
    required this.type,
    required this.status,
    required this.scheduledTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      status: json['status'],
      scheduledTime: DateTime.parse(json['scheduled_time']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'status': status,
      'scheduled_time': scheduledTime.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? title,
    String? message,
    String? type,
    String? status,
    DateTime? scheduledTime,
  }) {
    return NotificationModel(
      id: this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      status: status ?? this.status,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
