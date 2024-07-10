// lib/core/models/environment_setting.dart

import 'package:uuid/uuid.dart';

class EnvironmentSetting {
  final String id;
  String environmentName;
  String supabaseUrl;
  String supabaseAnonKey;
  bool isSelected; // isSelected プロパティを追加

  // 認証情報が必要な場合は追加
  String? emailAddress;
  String? password;

  EnvironmentSetting({
    String? id,
    required this.environmentName,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.emailAddress,
    this.password,
    this.isSelected = false, // isSelected プロパティの初期値を設定
  }) : id = id ?? const Uuid().v4();

  // JSONシリアライズ/デシリアライズメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'environmentName': environmentName,
      'supabaseUrl': supabaseUrl,
      'supabaseAnonKey': supabaseAnonKey,
      'emailAddress': emailAddress,
      'password': password,
      'isSelected': isSelected, // isSelected を追加
    };
  }

  factory EnvironmentSetting.fromJson(Map<String, dynamic> json) {
    return EnvironmentSetting(
      id: json['id'],
      environmentName: json['environmentName'],
      supabaseUrl: json['supabaseUrl'],
      supabaseAnonKey: json['supabaseAnonKey'],
      emailAddress: json['emailAddress'],
      password: json['password'],
      isSelected: json['isSelected'] ?? false, // isSelected を追加
    );
  }

  // copyWith メソッドを追加
  EnvironmentSetting copyWith({
    String? id,
    String? environmentName,
    String? supabaseUrl,
    String? supabaseAnonKey,
    String? emailAddress,
    String? password,
    bool? isSelected,
  }) {
    return EnvironmentSetting(
      id: id ?? this.id,
      environmentName: environmentName ?? this.environmentName,
      supabaseUrl: supabaseUrl ?? this.supabaseUrl,
      supabaseAnonKey: supabaseAnonKey ?? this.supabaseAnonKey,
      emailAddress: emailAddress ?? this.emailAddress,
      password: password ?? this.password,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
