import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/data/database.dart';
import 'package:vi_xanh_app/features/home/presentation/home_screen.dart';
import 'package:vi_xanh_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:vi_xanh_app/features/onboarding/presentation/setup_view.dart';
import 'package:vi_xanh_app/features/wallets/presentation/widgets/wallet_type_picker.dart';

import '../../fakes/fakes.dart';
import '../../helpers.dart';

void main() {
  Future<(AppDatabase, FakeKeyValueStore)> pumpFreshInstall(WidgetTester tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final store = FakeKeyValueStore({'locale': 'vi'});
    await tester.pumpWidget(buildTestApp(db, store: store));
    await tester.pumpAndSettle();
    return (db, store);
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  /// Nhập chữ rồi bỏ focus: con trỏ nhấp nháy là animation lặp vô hạn, ô còn focus thì
  /// pumpAndSettle không bao giờ dừng.
  Future<void> typeInto(WidgetTester tester, Finder field, String text) async {
    await tester.enterText(field, text);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
  }

  Future<void> pressBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  testWidgets('cài mới: trang 1 → Bỏ qua → trang 3 → Bắt đầu → 2 bước → Tổng quan', (tester) async {
    final (db, store) = await pumpFreshInstall(tester);
    expect(find.text('Biết tiền mình đi đâu'), findsOneWidget);

    await tapText(tester, 'Bỏ qua');
    expect(find.text('Chi tiêu có kế hoạch'), findsOneWidget);
    expect(find.text('Bỏ qua'), findsNothing);

    await tapText(tester, 'Bắt đầu');
    expect(find.byType(SetupView), findsOneWidget);
    expect(find.text('Bước 1/2'), findsOneWidget);

    await typeInto(tester, find.byType(TextField), 'Minh');
    await tester.tap(find.byTooltip('Tăng một ngày'));
    await tester.pump();
    expect(find.text('Ngày 2 hằng tháng'), findsOneWidget);
    await tapText(tester, 'Tiếp tục');

    expect(find.text('Bước 2/2'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
      reason: 'chưa chọn loại ví thì chưa được tiếp tục',
    );
    await tapText(tester, 'Tiền mặt');
    await typeInto(tester, find.byType(TextField).first, '1250000');
    await tester.pump();
    expect(find.text('1.250.000'), findsOneWidget);

    // Hoàn tất ghi DB thật (I/O ngoài thời gian giả của testWidgets) rồi mới dựng lại khung hình.
    await tester.ensureVisible(find.text('Tiếp tục'));
    await tester.runAsync(() async {
      await tester.tap(find.text('Tiếp tục'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    final wallets = (await tester.runAsync(() => db.walletsDao.watchActive().first))!;
    expect(wallets.single.name, 'Tiền mặt');
    expect(wallets.single.initialBalance, 1250000);
    expect(store.values['onboarding_completed'], isTrue);
    expect(store.values['user_name'], 'Minh');
    expect(store.values['month_start_day'], 2);
  });

  testWidgets('Back: bước 2 → bước 1 → trang 3 → trang 2; giữ tên đã nhập', (tester) async {
    await pumpFreshInstall(tester);
    await tapText(tester, 'Bỏ qua');
    await tapText(tester, 'Bắt đầu');
    await typeInto(tester, find.byType(TextField), 'Lan');
    await tapText(tester, 'Tiếp tục');

    await pressBack(tester);
    expect(find.text('Bước 1/2'), findsOneWidget);
    expect(find.text('Lan'), findsOneWidget);

    await pressBack(tester);
    expect(find.byType(SetupView), findsNothing);
    expect(find.text('Chi tiêu có kế hoạch'), findsOneWidget);

    await pressBack(tester);
    expect(find.text('Tự động ghi nhận chuyển khoản'), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsOneWidget);

    await tapText(tester, 'Bỏ qua');
    await tapText(tester, 'Bắt đầu');
    expect(find.text('Lan'), findsOneWidget, reason: 'tên đã nhập vẫn còn');
  });

  testWidgets('chọn thẻ tín dụng → nhãn "Dư nợ hiện tại"', (tester) async {
    await pumpFreshInstall(tester);
    await tapText(tester, 'Bỏ qua');
    await tapText(tester, 'Bắt đầu');
    await tapText(tester, 'Tiếp tục');
    await tapText(tester, 'Thẻ tín dụng');
    expect(find.text('Dư nợ hiện tại'), findsOneWidget);
  });

  for (final locale in ['vi', 'en']) {
    testWidgets('màn 320px, chữ 2x ($locale): mọi trang và bước không tràn', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final db = inMemoryDatabase();
      addTearDown(db.close);
      await tester.pumpWidget(buildTestApp(db, store: FakeKeyValueStore({'locale': locale})));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      Future<void> tapPrimary() async {
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await tapPrimary(); // trang 2
      await tapPrimary(); // trang 3
      await tapPrimary(); // bước 1
      await tapPrimary(); // bước 2
      final firstCard = find
          .descendant(of: find.byType(WalletTypePicker), matching: find.byType(InkWell))
          .first;
      await tester.ensureVisible(firstCard);
      await tester.tap(firstCard);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
