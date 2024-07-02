// smoke_test.dart

/// このテストコードは、高頻度の変更を前提とするため、冗長にしておくこと。
/// 各テストケース間で共通部分があっても関数化せずに個別に記述する等、変更の影響範囲を局所化するように注意。

import 'dart:convert';
import 'dart:io';

import 'package:canaspad/core/services/auth_service.dart';
import 'package:canaspad/core/services/secure_storage_service.dart';
import 'package:canaspad/core/services/supabase_service.dart';
import 'package:canaspad/data/mock/environment_sample.dart';
import 'package:canaspad/features/environment/views/environment_view.dart';
import 'package:canaspad/features/image/image_view.dart';
import 'package:canaspad/features/notification/models/notification_model.dart';
import 'package:canaspad/features/notification/viewmodels/notification_viewmodel.dart';
import 'package:canaspad/features/notification/views/notification_view.dart';
import 'package:canaspad/features/numeric/views/numeric_detail_view.dart';
import 'package:canaspad/features/numeric/views/numeric_view.dart';
import 'package:canaspad/features/setting/setting_view.dart';
import 'package:canaspad/main.dart' as app;
import 'package:canaspad/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';

const Duration waitDuration = Duration(seconds: 2);

class _MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MockNotificationViewModel extends StateNotifier<NotificationState> implements NotificationViewModel {
  MockNotificationViewModel() : super(NotificationState(notifications: []));

  @override
  Future<void> loadNotifications() async {
    // モックの実装
  }

  @override
  Future<void> addNotification(NotificationModel notification) async {
    state = NotificationState(notifications: [...state.notifications, notification]);
  }

  @override
  Future<void> deleteNotification(String id) async {
    state = NotificationState(notifications: state.notifications.where((n) => n.id != id).toList());
  }

  @override
  Future<void> deleteAllNotifications() async {
    state = NotificationState(notifications: []);
  }

  @override
  Future<List<NotificationModel>> getNotifications() async {
    return state.notifications;
  }

  @override
  Future<void> updateNotification(NotificationModel notification) async {
    state = NotificationState(
      notifications: state.notifications.map((n) => n.id == notification.id ? notification : n).toList(),
    );
  }
}

class MockFlutterLocalNotificationsPlugin extends Mock implements FlutterLocalNotificationsPlugin {
  @override
  Future<bool?> initialize(
    InitializationSettings initializationSettings, {
    void Function(NotificationResponse)? onDidReceiveBackgroundNotificationResponse,
    void Function(NotificationResponse)? onDidReceiveNotificationResponse,
  }) async {
    return true;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    HttpOverrides.global = _MyHttpOverrides();
  });

  final mockSecureStorageService = MockSecureStorageService()
    ..writeSecureData('envSettings', jsonEncode(sampleEnvironmentData.map((e) => e.toJson()).toList()));

  group('Smoke Tests', () {
    testWidgets('Application launches successfully', (WidgetTester tester) async {
      const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'develop');
      final mockNotificationViewModel = MockNotificationViewModel();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(mockSecureStorageService),
            supabaseServiceProvider.overrideWithValue(MockSupabaseService()),
            authServiceProvider.overrideWithValue(MockAuthService()),
            notificationViewModelProvider
                .overrideWithProvider(StateNotifierProvider<NotificationViewModel, NotificationState>((ref) => mockNotificationViewModel)),
          ],
          child: const app.MyApp(flavor: flavor),
        ),
      );
      await tester.pumpAndSettle(waitDuration);

      await mockNotificationViewModel.loadNotifications();
      await tester.pumpAndSettle();

      expect(find.byType(NumericView), findsOneWidget);
    });

    testWidgets('Navigation test', (WidgetTester tester) async {
      const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'develop');
      final mockNotificationViewModel = MockNotificationViewModel();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(mockSecureStorageService),
            supabaseServiceProvider.overrideWithValue(MockSupabaseService()),
            authServiceProvider.overrideWithValue(MockAuthService()),
            notificationViewModelProvider
                .overrideWithProvider(StateNotifierProvider<NotificationViewModel, NotificationState>((ref) => mockNotificationViewModel)),
          ],
          child: const app.MyApp(flavor: flavor),
        ),
      );
      await tester.pumpAndSettle(waitDuration);

      await mockNotificationViewModel.loadNotifications();
      await tester.pumpAndSettle();

      expect(find.byType(NumericView), findsOneWidget);

      await tester.tap(find.byKey(const Key('NumberTab')));
      await tester.pumpAndSettle();
      expect(find.byType(NumericView), findsOneWidget);

      await tester.tap(find.byKey(const Key('ImageTab')));
      await tester.pumpAndSettle();
      expect(find.byType(ImageView), findsOneWidget);

      await tester.tap(find.byKey(const Key('NotificationTab')));
      await tester.pumpAndSettle();
      expect(find.byType(NotificationView), findsOneWidget);

      await tester.tap(find.byKey(const Key('SettingTab')));
      await tester.pumpAndSettle();
      expect(find.byType(SettingView), findsOneWidget);

      await tester.tap(find.byKey(const Key('EnvironmentTab')));
      await tester.pumpAndSettle();
      expect(find.byType(EnvironmentView), findsOneWidget);
    });

    testWidgets('Environment settings test', (WidgetTester tester) async {
      const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'develop');
      final mockNotificationViewModel = MockNotificationViewModel();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(mockSecureStorageService),
            supabaseServiceProvider.overrideWithValue(MockSupabaseService()),
            authServiceProvider.overrideWithValue(MockAuthService()),
            notificationViewModelProvider
                .overrideWithProvider(StateNotifierProvider<NotificationViewModel, NotificationState>((ref) => mockNotificationViewModel)),
          ],
          child: const app.MyApp(flavor: flavor),
        ),
      );
      await tester.pumpAndSettle(waitDuration);

      await tester.tap(find.byKey(const Key('EnvironmentTab')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('AddEnvironmentButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Environment 3'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('EnvironmentNameField')), 'Environment 3 Updated');
      await tester.enterText(find.byKey(const Key('SupabaseUrlField')), 'https://supabase.io');
      await tester.enterText(find.byKey(const Key('AnonKeyField')), 'anon_key');
      await tester.enterText(find.byKey(const Key('PasswordField')), 'password');
      await tester.enterText(find.byKey(const Key('EmailAddressField')), 'email@email.jp');
      await tester.tap(find.byKey(const Key('SelectEnvironmentSwitch')));

      await tester.tap(find.byKey(const Key('SaveEnvironmentButton')));
      await tester.pumpAndSettle();

      expect(find.text('Environment 3 Updated'), findsOneWidget);

      await tester.tap(find.text('Environment 3 Updated'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('DeleteEnvironmentButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Environment 3 Updated'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('DeleteEnvironmentButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();
    });

    testWidgets('Number data display test', (WidgetTester tester) async {
      const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'develop');
      final mockNotificationViewModel = MockNotificationViewModel();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(mockSecureStorageService),
            supabaseServiceProvider.overrideWithValue(MockSupabaseService()),
            authServiceProvider.overrideWithValue(MockAuthService()),
            notificationViewModelProvider
                .overrideWithProvider(StateNotifierProvider<NotificationViewModel, NotificationState>((ref) => mockNotificationViewModel)),
          ],
          child: const app.MyApp(flavor: flavor),
        ),
      );
      await tester.pumpAndSettle(waitDuration);

      await tester.tap(find.byKey(const Key('NumberTab')));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      expect(find.byType(NumberDetailView), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(NumericView), findsOneWidget);
    });

    testWidgets('Notification view test', (WidgetTester tester) async {
      const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'develop');

      final mockNotificationViewModel = MockNotificationViewModel();

      final container = ProviderContainer(
        overrides: [
          secureStorageServiceProvider.overrideWithValue(mockSecureStorageService),
          supabaseServiceProvider.overrideWithValue(MockSupabaseService()),
          authServiceProvider.overrideWithValue(MockAuthService()),
          notificationViewModelProvider
              .overrideWithProvider(StateNotifierProvider<NotificationViewModel, NotificationState>((ref) => mockNotificationViewModel)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const app.MyApp(flavor: flavor),
        ),
      );
      await tester.pumpAndSettle(waitDuration);

      final testNotification1 = NotificationModel(
        title: 'Test Notification 1',
        message: 'This is a test notification.',
        type: 'info',
        status: 'unread',
        scheduledTime: DateTime.now(),
      );

      final testNotification2 = NotificationModel(
        title: 'Test Notification 2',
        message: 'This is another test notification.',
        type: 'info',
        status: 'unread',
        scheduledTime: DateTime.now(),
      );

      await mockNotificationViewModel.addNotification(testNotification1);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('NotificationTab')));
      await tester.pumpAndSettle();

      expect(find.text('Test Notification 1'), findsOneWidget);
      expect(find.text('This is a test notification.'), findsOneWidget);

      await mockNotificationViewModel.addNotification(testNotification2);
      await tester.pumpAndSettle();

      expect(find.text('Test Notification 2'), findsOneWidget);

      await tester.drag(find.byKey(Key(testNotification1.id)), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      expect(find.text('Test Notification 1'), findsNothing);
      expect(find.text('This is a test notification.'), findsNothing);

      addTearDown(container.dispose);
    });
  });

  group('View Tests', () {
    testWidgets('Image view test', (WidgetTester tester) async {
      const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'develop');
      final mockNotificationViewModel = MockNotificationViewModel();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(mockSecureStorageService),
            supabaseServiceProvider.overrideWithValue(MockSupabaseService()),
            authServiceProvider.overrideWithValue(MockAuthService()),
            notificationViewModelProvider
                .overrideWithProvider(StateNotifierProvider<NotificationViewModel, NotificationState>((ref) => mockNotificationViewModel)),
          ],
          child: const app.MyApp(flavor: flavor),
        ),
      );
      await tester.pumpAndSettle(waitDuration);

      await tester.tap(find.byKey(const Key('ImageTab')));
      await tester.pumpAndSettle();
      expect(find.text('Image View Content'), findsOneWidget);
    });

    testWidgets('Setting view test', (WidgetTester tester) async {
      const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'develop');
      final mockNotificationViewModel = MockNotificationViewModel();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(mockSecureStorageService),
            supabaseServiceProvider.overrideWithValue(MockSupabaseService()),
            authServiceProvider.overrideWithValue(MockAuthService()),
            notificationViewModelProvider
                .overrideWithProvider(StateNotifierProvider<NotificationViewModel, NotificationState>((ref) => mockNotificationViewModel)),
          ],
          child: const app.MyApp(flavor: flavor),
        ),
      );
      await tester.pumpAndSettle(waitDuration);

      await tester.tap(find.byKey(const Key('SettingTab')));
      await tester.pumpAndSettle();
      expect(find.text('Setting View Content'), findsOneWidget);
    });
  });
}
