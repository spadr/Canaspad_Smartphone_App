import 'package:canaspad/core/services/secure_storage_service.dart';
import 'package:canaspad/core/services/supabase_service.dart';
import 'package:canaspad/features/environment/models/environment_model.dart';
import 'package:canaspad/features/environment/views/environment_view.dart';
import 'package:canaspad/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late MockSecureStorageService mockSecureStorageService;
  late MockSupabaseService mockSupabaseService;

  setUp(() {
    mockSecureStorageService = MockSecureStorageService();
    mockSupabaseService = MockSupabaseService();

    reset(mockSecureStorageService);
    reset(mockSupabaseService);
  });

  testWidgets('Changing and saving environment triggers data refresh', (WidgetTester tester) async {
    final environments = [
      EnvironmentModel(envName: "Environment 1", selected: true),
      EnvironmentModel(envName: "Environment 2", selected: false),
    ];

    when(() => mockSecureStorageService.readAllEnvironments()).thenAnswer((_) async => environments);
    when(() => mockSecureStorageService.writeSecureData(any(), any())).thenAnswer((_) async {});
    when(() => mockSupabaseService.fetchAllData()).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageServiceProvider.overrideWithValue(mockSecureStorageService),
          supabaseServiceProvider.overrideWithValue(mockSupabaseService),
        ],
        child: MaterialApp(home: EnvironmentView()),
      ),
    );

    await tester.pumpAndSettle();

    verify(() => mockSecureStorageService.readAllEnvironments()).called(1);

    expect(find.textContaining('Environment 1'), findsOneWidget);
    expect(find.textContaining('Environment 2'), findsOneWidget);

    // Environment 2 を選択
    await tester.tap(find.textContaining('Environment 2'));
    await tester.pumpAndSettle();

    // Environment を編集
    await tester.enterText(find.byKey(Key('EnvironmentNameField')), 'Environment 2 Updated');
    await tester.enterText(find.byKey(Key('SupabaseUrlField')), 'https://supabase.io');
    await tester.enterText(find.byKey(Key('AnonKeyField')), 'anon_key');
    await tester.enterText(find.byKey(Key('PasswordField')), 'password');
    await tester.enterText(find.byKey(Key('EmailAddressField')), 'email@email.jp');
    await tester.tap(find.byKey(Key('SelectEnvironmentSwitch')));

    // SaveEnvironmentButton をタップ
    await tester.tap(find.byKey(Key('SaveEnvironmentButton')));
    await tester.pumpAndSettle();

    // 環境の選択と保存で2回 writeSecureData が呼ばれることを確認
    verify(() => mockSecureStorageService.writeSecureData(any(), any())).called(2);

    // データリフレッシュが1回呼び出されたことを確認
    verify(() => mockSupabaseService.fetchAllData()).called(1);
  });
}
