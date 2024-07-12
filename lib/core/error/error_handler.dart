import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry/sentry.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/error_messages.dart';
import '../utils/error_dialog.dart';
import 'app_error.dart';

class ErrorHandler {
  final Logger _logger;
  final GlobalKey<NavigatorState> _navigatorKey;
  late File _logFile;
  final List<AppError> _errorQueue = [];
  bool _isOfflineMode = false;

  ErrorHandler(this._navigatorKey, {Logger? logger}) : _logger = logger ?? Logger('ErrorHandler') {
    _initializeLogger();
  }

  Future<void> _initializeLogger() async {
    final directory = await getApplicationDocumentsDirectory();
    _logFile = File('${directory.path}/error_logs.txt');
    if (!await _logFile.exists()) {
      await _logFile.create();
    }
  }

  void handleError(AppError error) {
    queueError(error);
  }

  void queueError(AppError error) {
    _errorQueue.add(error);
    _errorQueue.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    _processErrorQueue();
  }

  Future<void> _processErrorQueue() async {
    while (_errorQueue.isNotEmpty) {
      final error = _errorQueue.removeAt(0);
      await handleErrorAsync(error);
    }
  }

  Future<void> handleErrorAsync(AppError error) async {
    await Future.microtask(() => _logError(error));

    switch (error.severity) {
      case ErrorSeverity.fatal:
      case ErrorSeverity.critical:
        await persistErrorState(error);
        await _recoverFromError(error);
        _showErrorDialog(error);
        break;
      case ErrorSeverity.error:
        await _recoverFromError(error);
        _showErrorSnackBar(error);
        break;
      case ErrorSeverity.warning:
      case ErrorSeverity.info:
        // 警告と情報はログ出力のみ
        break;
    }
  }

  Future<void> _logError(AppError error) async {
    _logger.log(error.severity.toLogLevel(), error.message, error.originalError, error.stackTrace);

    final logEntry = '${DateTime.now()}: ${error.severity}: ${error.message}\n'
        'Error Type: ${error.type}\n'
        'Original Error: ${error.originalError}\n'
        'Stack Trace: ${error.stackTrace}\n\n';

    await _logFile.writeAsString(logEntry, mode: FileMode.append);

    await Sentry.captureException(
      error.originalError,
      stackTrace: error.stackTrace,
    );
  }

  Future<void> _recoverFromError(AppError error) async {
    switch (error.type) {
      case ErrorType.network:
        await _switchToOfflineMode();
        break;
      case ErrorType.authentication:
        await _refreshAuthToken();
        break;
      case ErrorType.synchronization:
        await _handleSyncError();
        break;
      case ErrorType.storage:
        await _handleStorageError();
        break;
      case ErrorType.database:
        await _handleDatabaseError();
        break;
      default:
        await _handleGenericError();
        break;
    }
  }

  Future<void> _switchToOfflineMode() async {
    _logger.info('Switching to offline mode');
    _isOfflineMode = true;
    // オフラインモードの実装
    // 例: ローカルストレージの使用を優先し、同期を一時停止
    // TODO: アプリの他の部分に通知して、オフラインモードに適応させる
  }

  Future<void> _refreshAuthToken() async {
    _logger.info('Refreshing auth token');
    // トークンリフレッシュの実装
    // TODO: 認証サービスを使用して新しいトークンを取得し、保存する
  }

  Future<void> _handleSyncError() async {
    _logger.info('Handling synchronization error');
    // 同期エラーの処理
    // TODO: 同期プロセスをリセットし、次回の同期を予約する
  }

  Future<void> _handleStorageError() async {
    _logger.info('Handling storage error');
    // ストレージエラーの処理
    // TODO: 利用可能なストレージ容量を確認し、必要に応じてクリーンアップを行う
  }

  Future<void> _handleDatabaseError() async {
    _logger.info('Handling database error');
    // データベースエラーの処理
    // TODO: データベース接続を再確立し、必要に応じてマイグレーションを実行する
  }

  Future<void> _handleGenericError() async {
    _logger.info('Handling generic error');
    // 一般的なエラーの処理
    // TODO: アプリの状態をリセットし、ユーザーに再起動を促す
  }

  void _showErrorDialog(AppError error) {
    showDialog(
      context: _navigatorKey.currentContext!,
      builder: (context) => ErrorDialog(
        title: AppLocalizations.of(context)!.error,
        message: ErrorMessages.getLocalizedErrorMessage(context, error),
        onRetry: () {
          Navigator.of(context).pop();
          _retryOperation(error);
        },
      ),
    );
  }

  void _showErrorSnackBar(AppError error) {
    final context = _navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorMessages.getLocalizedErrorMessage(context, error)),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _retryOperation(error),
          ),
        ),
      );
    } else {
      _logger.warning('Cannot show snackbar: context is null.');
    }
  }

  void _retryOperation(AppError error) {
    // エラーが発生した操作を再試行
    // TODO: エラーのタイプに基づいて適切な再試行ロジックを実装
  }

  Future<void> persistErrorState(AppError error) async {
    final prefs = await SharedPreferences.getInstance();
    final errorState = {
      'message': error.message,
      'severity': error.severity.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    await prefs.setString('last_error_state', json.encode(errorState));
  }

  Future<AppError?> recoverErrorState() async {
    final prefs = await SharedPreferences.getInstance();
    final errorStateJson = prefs.getString('last_error_state');
    if (errorStateJson != null) {
      final errorState = json.decode(errorStateJson);
      return AppError(
        errorState['message'],
        ErrorType.unknown,
        ErrorSeverity.values.firstWhere((e) => e.toString() == errorState['severity']),
      );
    }
    return null;
  }

  Future<T> executeWithRetry<T>(Future<T> Function() operation, String operationName) async {
    int retryCount = 0;
    const maxRetries = 3;
    Duration delay = const Duration(seconds: 1);

    while (retryCount < maxRetries) {
      try {
        return await operation();
      } catch (e, stackTrace) {
        retryCount++;
        _logger.warning('$operationName failed (attempt $retryCount). Retrying in $delay...');
        if (retryCount < maxRetries) {
          await Future.delayed(delay);
          delay *= 2; // 指数バックオフ
        } else {
          _logger.severe('$operationName failed after $maxRetries attempts.');
          rethrow;
        }
      }
    }
    throw Exception('$operationName failed after $maxRetries attempts.');
  }

  Future<bool> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  void setOfflineMode(bool isOffline) {
    _isOfflineMode = isOffline;
  }

  bool get isOfflineMode => _isOfflineMode;
}
