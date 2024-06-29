import 'package:canaspad/core/services/secure_storage_service.dart';
import 'package:canaspad/core/widgets/number_data_list_item.dart';
import 'package:canaspad/main.dart';
import 'package:canaspad/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('Data Refresh Tests', () {
    testWidgets('Data refresh when environment is changed', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            flavorProvider.overrideWithProvider(StateProvider((ref) => 'develop')),
            secureStorageServiceProvider.overrideWithProvider(Provider((ref) => MockSecureStorageService())),
            supabaseServiceProvider.overrideWithProvider(mockSupabaseServiceProvider),
          ],
          child: MyApp(flavor: 'develop'),
        ),
      );

      // Initialization完了を待つ
      await tester.pumpAndSettle();

      // NumericViewに移動
      await tester.tap(find.byKey(Key('NumberTab')));
      await tester.pumpAndSettle();

      // 最初のNumericDataを取得
      final initialNumericData = tester.widget<NumericDataListItem>(find.byType(NumericDataListItem).first).numericData;

      // EnvironmentViewに移動
      await tester.tap(find.byKey(Key('EnvironmentTab')));
      await tester.pumpAndSettle();

      // 2番目の環境を選択
      await tester.tap(find.byKey(Key('EnvironmentTile_1')));
      await tester.pumpAndSettle();

      // Saveボタンを押下
      await tester.tap(find.byKey(Key('SaveEnvironmentButton')));
      await tester.pumpAndSettle();

      // NumericViewに戻る
      await tester.tap(find.byKey(Key('NumberTab')));
      await tester.pumpAndSettle();

      // 更新されたNumericDataを取得
      final updatedNumericData = tester.widget<NumericDataListItem>(find.byType(NumericDataListItem).first).numericData;

      // データがリフレッシュされたことを確認
      expect(initialNumericData != updatedNumericData, true);
    });

    testWidgets('Data refresh when environment content is changed', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            flavorProvider.overrideWithProvider(StateProvider((ref) => 'develop')),
            secureStorageServiceProvider.overrideWithProvider(Provider((ref) => MockSecureStorageService())),
            supabaseServiceProvider.overrideWithProvider(mockSupabaseServiceProvider),
          ],
          child: MyApp(flavor: 'develop'),
        ),
      );

      await tester.pumpAndSettle();

      // NumericViewに移動
      await tester.tap(find.byKey(Key('NumberTab')));
      await tester.pumpAndSettle();

      // 最初のNumericDataを取得
      final initialNumericData = tester.widget<NumericDataListItem>(find.byType(NumericDataListItem).first).numericData;

      // EnvironmentViewに移動
      await tester.tap(find.byKey(Key('EnvironmentTab')));
      await tester.pumpAndSettle();

      // 最初の環境を編集
      await tester.tap(find.byKey(Key('EnvironmentTile_0')));
      await tester.pumpAndSettle();

      // 環境名を入力
      await tester.enterText(find.byKey(Key('EnvironmentNameField')), 'Updated Environment');
      await tester.pumpAndSettle();

      // Saveボタンを押下
      await tester.tap(find.byKey(Key('SaveEnvironmentButton')));
      await tester.pumpAndSettle();

      // NumericViewに戻る
      await tester.tap(find.byKey(Key('NumberTab')));
      await tester.pumpAndSettle();

      // 更新されたNumericDataを取得
      final updatedNumericData = tester.widget<NumericDataListItem>(find.byType(NumericDataListItem).first).numericData;

      // データがリフレッシュされたことを確認
      expect(initialNumericData != updatedNumericData, true);
    });

    testWidgets('Data refresh when both environment selection and content are changed', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            flavorProvider.overrideWithProvider(StateProvider((ref) => 'develop')),
            secureStorageServiceProvider.overrideWithProvider(Provider((ref) => MockSecureStorageService())),
            supabaseServiceProvider.overrideWithProvider(mockSupabaseServiceProvider),
          ],
          child: MyApp(flavor: 'develop'),
        ),
      );

      await tester.pumpAndSettle();

      // NumericViewに移動
      await tester.tap(find.byKey(Key('NumberTab')));
      await tester.pumpAndSettle();

      // 最初のNumericDataを取得
      final initialNumericData = tester.widget<NumericDataListItem>(find.byType(NumericDataListItem).first).numericData;

      // EnvironmentViewに移動
      await tester.tap(find.byKey(Key('EnvironmentTab')));
      await tester.pumpAndSettle();

      // 2番目の環境を選択 & 編集
      await tester.tap(find.byKey(Key('EnvironmentTile_1')));
      await tester.pumpAndSettle();

      // 環境名を入力
      await tester.enterText(find.byKey(Key('EnvironmentNameField')), 'Updated Environment');
      await tester.pumpAndSettle();

      // Saveボタンを押下
      await tester.tap(find.byKey(Key('SaveEnvironmentButton')));
      await tester.pumpAndSettle();

      // NumericViewに戻る
      await tester.tap(find.byKey(Key('NumberTab')));
      await tester.pumpAndSettle();

      // 更新されたNumericDataを取得
      final updatedNumericData = tester.widget<NumericDataListItem>(find.byType(NumericDataListItem).first).numericData;

      // データがリフレッシュされたことを確認
      expect(initialNumericData != updatedNumericData, true);
    });
  });
}
