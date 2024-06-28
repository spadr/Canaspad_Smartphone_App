/// A model class representing an environment configuration.
class EnvironmentModel {
  /// The anonymous key used for authentication.
  String? anonKey;

  /// The URL of the Supabase instance.
  String? supabaseUrl;

  /// The name of the environment.
  String? envName;

  /// The password associated with the environment.
  String? password;

  /// The email address associated with the environment.
  String? emailAddress;

  /// Indicates whether this environment is selected as the primary environment.
  bool? selected;

  /// Constructor to create an instance of [EnvironmentModel].
  EnvironmentModel({
    this.anonKey,
    this.supabaseUrl,
    this.envName,
    this.password,
    this.emailAddress,
    this.selected,
  });

  EnvironmentModel copyWith({
    String? anonKey,
    String? supabaseUrl,
    String? envName,
    String? password,
    String? emailAddress,
    bool? selected,
  }) {
    return EnvironmentModel(
      anonKey: anonKey ?? this.anonKey,
      supabaseUrl: supabaseUrl ?? this.supabaseUrl,
      envName: envName ?? this.envName,
      password: password ?? this.password,
      emailAddress: emailAddress ?? this.emailAddress,
      selected: selected ?? this.selected,
    );
  }

  /// Converts an [EnvironmentModel] instance to a JSON map.
  ///
  /// This method is useful for saving the environment configuration
  /// to a secure storage or sending it over the network.
  Map<String, dynamic> toJson() => {
        'anon_key': anonKey,
        'supabase_url': supabaseUrl,
        'env_name': envName,
        'password': password,
        'email_address': emailAddress,
        'selected': selected,
      };

  /// Creates an [EnvironmentModel] instance from a JSON map.
  ///
  /// This factory constructor is useful for creating an environment
  /// configuration instance from data retrieved from secure storage or a network response.
  factory EnvironmentModel.fromJson(Map<String, dynamic> json) => EnvironmentModel(
        anonKey: json['anon_key'],
        supabaseUrl: json['supabase_url'],
        envName: json['env_name'],
        password: json['password'],
        emailAddress: json['email_address'],
        selected: json['selected'],
      );
}
