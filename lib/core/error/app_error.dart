// lib\core\error\app_error.dart

import 'package:logging/logging.dart';

enum ErrorType {
  network,
  database,
  authentication,
  synchronization,
  storage,
  externalService,
  unknown,
}

enum ErrorSeverity {
  fatal,
  critical,
  error,
  warning,
  info,
}

class AppError implements Exception {
  final String message;
  final ErrorType type;
  final ErrorSeverity severity;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppError(this.message, this.type, this.severity, {this.originalError, this.stackTrace});

  @override
  String toString() => 'AppError: $message (Type: $type, Severity: $severity)';
}

// ErrorSeverity を Level に変換する拡張メソッド
extension ErrorSeverityToLogLevel on ErrorSeverity {
  Level toLogLevel() {
    switch (this) {
      case ErrorSeverity.fatal:
        return Level.SHOUT;
      case ErrorSeverity.critical:
        return Level.SEVERE;
      case ErrorSeverity.error:
        return Level.SEVERE; // error も SEVERE に対応させる
      case ErrorSeverity.warning:
        return Level.WARNING;
      case ErrorSeverity.info:
        return Level.INFO;
    }
  }
}
