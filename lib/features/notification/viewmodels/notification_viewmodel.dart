import 'dart:convert';

import 'package:canaspad/providers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/secure_storage_service.dart';
import '../models/notification_model.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;

  NotificationState({
    required this.notifications,
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationViewModel extends StateNotifier<NotificationState> {
  final SecureStorageService _storage;
  final FlutterLocalNotificationsPlugin _localNotifications;
  static const String _storageKey = 'notifications';
  static const int _maxNotifications = 100;
  static const int _maxErrorNotifications = 20;

  NotificationViewModel(this._storage, this._localNotifications) : super(NotificationState(notifications: [])) {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    final notifications = await getNotifications();
    state = NotificationState(notifications: notifications);
  }

  Future<List<NotificationModel>> getNotifications() async {
    final jsonString = await _storage.readSecureData(_storageKey);
    if (jsonString == null) return [];
    final jsonList = json.decode(jsonString) as List;
    return jsonList.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<void> addNotification(NotificationModel notification) async {
    state = state.copyWith(isLoading: true);
    final currentNotifications = List<NotificationModel>.from(state.notifications);
    if (notification.type == 'error') {
      final index = currentNotifications.indexWhere((n) => n.type != 'error');
      if (index != -1) {
        currentNotifications.insert(index, notification);
      } else {
        currentNotifications.add(notification);
      }
    } else {
      currentNotifications.add(notification);
    }
    _limitTotalNotifications(currentNotifications);
    _limitErrorNotifications(currentNotifications);
    await _saveNotifications(currentNotifications);
    await _showLocalNotification(notification);
    state = NotificationState(notifications: currentNotifications, isLoading: false);
  }

  Future<void> updateNotification(NotificationModel notification) async {
    state = state.copyWith(isLoading: true);
    final currentNotifications = List<NotificationModel>.from(state.notifications);
    final index = currentNotifications.indexWhere((n) => n.id == notification.id);
    if (index != -1) {
      currentNotifications[index] = notification;
      await _saveNotifications(currentNotifications);
    }
    state = NotificationState(notifications: currentNotifications, isLoading: false);
  }

  Future<void> deleteNotification(String id) async {
    state = state.copyWith(isLoading: true);
    final currentNotifications = List<NotificationModel>.from(state.notifications);
    currentNotifications.removeWhere((n) => n.id == id);
    await _saveNotifications(currentNotifications);
    state = NotificationState(notifications: currentNotifications, isLoading: false);
  }

  Future<void> deleteAllNotifications() async {
    state = state.copyWith(isLoading: true);
    await _storage.deleteSecureData(_storageKey);
    state = NotificationState(notifications: [], isLoading: false);
  }

  void _limitErrorNotifications(List<NotificationModel> notifications) {
    final errorNotifications = notifications.where((n) => n.type == 'error').toList();
    if (errorNotifications.length > _maxErrorNotifications) {
      notifications.removeRange(_maxErrorNotifications, errorNotifications.length);
    }
  }

  void _limitTotalNotifications(List<NotificationModel> notifications) {
    if (notifications.length > _maxNotifications) {
      notifications.removeRange(_maxNotifications, notifications.length);
    }
  }

  Future<void> _saveNotifications(List<NotificationModel> notifications) async {
    final jsonList = notifications.map((n) => n.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await _storage.writeSecureData(_storageKey, jsonString);
  }

  Future<void> _showLocalNotification(NotificationModel notification) async {
    if (_localNotifications is! MockFlutterLocalNotificationsPlugin) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

      final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await _localNotifications.show(
        notificationId,
        notification.title,
        notification.message,
        platformChannelSpecifics,
      );
    }
  }
}
