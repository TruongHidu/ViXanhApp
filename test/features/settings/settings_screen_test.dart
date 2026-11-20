import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/features/settings/presentation/settings_screen.dart';
import 'package:vi_xanh_app/l10n/gen/app_localizations.dart';

import '../../fakes/fakes.dart';
import '../../helpers.dart';

void main() {
  Future<FakeKeyValueStore> pumpSettings(WidgetTester tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final store = FakeKeyValueStore({'locale': 'vi'});
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(db: db, store: store),
        child: const MaterialApp(
          locale: Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );
    return store;
  }

  testWidgets('chọn English rồi Theo hệ thống → lưu và xóa key locale', (tester) async {
    final store = await pumpSettings(tester);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(store.values['locale'], 'en');

    // Mục "Theo hệ thống" thứ hai thuộc nhóm Ngôn ngữ.
    await tester.tap(find.text('Theo hệ thống').last);
    await tester.pumpAndSettle();
    expect(store.values.containsKey('locale'), isFalse);
  });

  testWidgets('ghi lỗi → hiện snackbar', (tester) async {
    final store = await pumpSettings(tester);
    store.failWrites = true;

    await tester.tap(find.text('Tối'));
    await tester.pumpAndSettle();
    expect(find.text('Không lưu được cài đặt. Vui lòng thử lại.'), findsOneWidget);
  });
}
