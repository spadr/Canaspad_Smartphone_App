import 'package:uuid/uuid.dart';

/// A model class representing an environment configuration.
class EnvironmentModel {
  final String id;
  String? anonKey;
  String? supabaseUrl;
  String? envName;
  String? password;
  String? emailAddress;
  bool? selected;

  /// Constructor to create an instance of [EnvironmentModel].
  EnvironmentModel({
    String? id,
    this.anonKey,
    this.supabaseUrl,
    this.envName,
    this.password,
    this.emailAddress,
    this.selected,
  }) : id = id ?? Uuid().v4();

  EnvironmentModel copyWith({
    String? id,
    String? anonKey,
    String? supabaseUrl,
    String? envName,
    String? password,
    String? emailAddress,
    bool? selected,
  }) {
    return EnvironmentModel(
      id: id ?? this.id,
      anonKey: anonKey ?? this.anonKey,
      supabaseUrl: supabaseUrl ?? this.supabaseUrl,
      envName: envName ?? this.envName,
      password: password ?? this.password,
      emailAddress: emailAddress ?? this.emailAddress,
      selected: selected ?? this.selected,
    );
  }

  /// Converts an [EnvironmentModel] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'anon_key': anonKey,
        'supabase_url': supabaseUrl,
        'env_name': envName,
        'password': password,
        'email_address': emailAddress,
        'selected': selected,
      };

  /// Creates an [EnvironmentModel] instance from a JSON map.
  factory EnvironmentModel.fromJson(Map<String, dynamic> json) => EnvironmentModel(
        id: json['id'],
        anonKey: json['anon_key'],
        supabaseUrl: json['supabase_url'],
        envName: json['env_name'],
        password: json['password'],
        emailAddress: json['email_address'],
        selected: json['selected'],
      );
}
