// lib/core/utils/error_logger.dart

import 'dart:developer';

class ErrorLogger {
  static void logError(dynamic error, StackTrace stackTrace) {
    log('Error: $error\n$stackTrace');
  }
}
