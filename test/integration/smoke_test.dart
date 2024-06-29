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
import 'package:canaspad/features/notification/notification_view.dart';
import 'package:canaspad/features/number/views/number_detail_view.dart';
import 'package:canaspad/features/number/views/number_view.dart';
import 'package:canaspad/features/setting/setting_view.dart';
import 'package:canaspad/main.dart' as app;
import 'package:canaspad/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Duration waitDuration = Duration(seconds: 2);

class _MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    HttpOverrides.global = _MyHttpOverrides();
  });

  // MockSecureStorageServiceの初期データを設定
  final mockSecureStorageService = MockSecureStorageService()
    ..writeSecureData('envSettings', jsonEncode(sampleEnvironmentData.map((e) => e.toJson()).toList()));

  const waitDuration = Duration(seconds: 5);

  group('Smoke Tests', () {
    testWidgets('Application launches successfully', (WidgetTester tester) async {
      const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'develop');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(mockSecureStorageService),
            supabaseServiceProvider.overrideWithValue(MockSupabaseService()),
            authServiceProvider.overrideWithValue(MockAuthService()),
          ],
          child: app.MyApp(flavor: flavor),
        ),
      );
      await tester.pumpAndSettle(waitDuration);
      // InitializationViewは一瞬なのでNumericViewをチェック
      expect(find.byType(NumericView), findsOneWidget);
    });

    testWidgets('Navigation test', (WidgetTester tester) async {
      const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'develop');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(mockSecureStorageService),
            supabaseServiceProvider.overrideWithValue(MockSupabaseService()),
            authServiceProvider.overrideWithValue(MockAuthService()),
          ],
          child: app.MyApp(flavor: flavor),
        ),
      );
      await tester.pumpAndSettle(waitDuration);

      // アプリの初期化を待つ
      await tester.pumpAndSettle(waitDuration);
      expect(find.byType(NumericView), findsOneWidget);

      // ナビゲーションのテスト
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
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(mockSecureStorageService),
            supabaseServiceProvider.overrideWithValue(MockSupabaseService()),
            authServiceProvider.overrideWithValue(MockAuthService()),
          ],
          child: app.MyApp(flavor: flavor),
        ),
      );
      await tester.pumpAndSettle(waitDuration);

      // EnvironmentTab をタップ
      await tester.tap(find.byKey(Key('EnvironmentTab')));
      await tester.pumpAndSettle();

      // AddEnvironmentButton をタップ
      await tester.tap(find.byKey(Key('AddEnvironmentButton')));
      await tester.pumpAndSettle();

      // Environment 3 をタップ
      await tester.tap(find.text('Environment 3'));
      await tester.pumpAndSettle();

      // Environment を編集
      await tester.enterText(find.byKey(Key('EnvironmentNameField')), 'Environment 3 Updated');
      await tester.enterText(find.byKey(Key('SupabaseUrlField')), 'https://supabase.io');
      await tester.enterText(find.byKey(Key('AnonKeyField')), 'anon_key');
      await tester.enterText(find.byKey(Key('PasswordField')), 'password');
      await tester.enterText(find.byKey(Key('EmailAddressField')), 'email@email.jp');
      await tester.tap(find.byKey(Key('SelectEnvironmentSwitch')));

      // SaveEnvironmentButton をタップ
      await tester.tap(find.byKey(Key('SaveEnvironmentButton')));
      await tester.pumpAndSettle();

      // 保存されたことを確認
      expect(find.text('Environment 3 Updated'), findsOneWidget);

      // 削除のテスト
      await tester.tap(find.text('Environment 3 Updated'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('DeleteEnvironmentButton')));
      await tester.pumpAndSettle();

      // AlertDialog内のCancelボタンを特定してタップ
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Environment 3 Updated'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('DeleteEnvironmentButton')));
      await tester.pumpAndSettle();

      // AlertDialog内のDeleteボタンを特定してタップ
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();
    });

    testWidgets('Number data display test', (WidgetTester tester) async {
      const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'develop');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(mockSecureStorageService),
            supabaseServiceProvider.overrideWithValue(MockSupabaseService()),
            authServiceProvider.overrideWithValue(MockAuthService()),
          ],
          child: app.MyApp(flavor: flavor),
        ),
      );
      await tester.pumpAndSettle(waitDuration);

      // アプリの初期化を待つ
      await tester.pumpAndSettle(waitDuration);

      // NumberTab をタップ
      await tester.tap(find.byKey(const Key('NumberTab')));
      await tester.pumpAndSettle();

      // データが表示されるまで待つ
      await tester.pumpAndSettle();

      // リストビューの最初の要素をタップ
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      // NumberDetailView が表示されるまで待つ
      expect(find.byType(NumberDetailView), findsOneWidget);

      // 戻るボタンをタップ
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // NumericView が表示されるまで待つ
      expect(find.byType(NumericView), findsOneWidget);
    });
  });

  group('View Tests', () {
    testWidgets('Image view test', (WidgetTester tester) async {
      const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'develop');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(mockSecureStorageService),
            supabaseServiceProvider.overrideWithValue(MockSupabaseService()),
            authServiceProvider.overrideWithValue(MockAuthService()),
          ],
          child: app.MyApp(flavor: flavor),
        ),
      );
      await tester.pumpAndSettle(waitDuration);

      await tester.tap(find.byKey(const Key('ImageTab')));
      await tester.pumpAndSettle();
      expect(find.text('Image View Content'), findsOneWidget);
    });

    testWidgets('Notification view test', (WidgetTester tester) async {
      const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'develop');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(mockSecureStorageService),
            supabaseServiceProvider.overrideWithValue(MockSupabaseService()),
            authServiceProvider.overrideWithValue(MockAuthService()),
          ],
          child: app.MyApp(flavor: flavor),
        ),
      );
      await tester.pumpAndSettle(waitDuration);

      await tester.tap(find.byKey(const Key('NotificationTab')));
      await tester.pumpAndSettle();
      expect(find.text('Notification View Content'), findsOneWidget);
    });

    testWidgets('Setting view test', (WidgetTester tester) async {
      const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'develop');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(mockSecureStorageService),
            supabaseServiceProvider.overrideWithValue(MockSupabaseService()),
            authServiceProvider.overrideWithValue(MockAuthService()),
          ],
          child: app.MyApp(flavor: flavor),
        ),
      );
      await tester.pumpAndSettle(waitDuration);

      await tester.tap(find.byKey(const Key('SettingTab')));
      await tester.pumpAndSettle();
      expect(find.text('Setting View Content'), findsOneWidget);
    });
  });
}
