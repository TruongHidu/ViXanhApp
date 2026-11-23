import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/features/home/presentation/home_screen.dart';
import 'package:vi_xanh_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:vi_xanh_app/features/categories/presentation/categories_screen.dart';
import 'package:vi_xanh_app/features/reports/presentation/reports_screen.dart';
import 'package:vi_xanh_app/features/settings/presentation/account_screen.dart';
import 'package:vi_xanh_app/features/transactions/presentation/add_transaction_screen.dart';
import 'package:vi_xanh_app/features/transactions/presentation/transactions_screen.dart';
import 'package:vi_xanh_app/features/wallets/presentation/wallets_screen.dart';
import 'package:vi_xanh_app/theme/widgets/app_bottom_bar.dart';

import '../fakes/fakes.dart';
import '../helpers.dart';

void main() {
  Future<FakeKeyValueStore> pumpApp(
    WidgetTester tester, {
    bool onboarded = true,
    String locale = 'vi',
  }) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final store = FakeKeyValueStore({'locale': locale, 'onboarding_completed': onboarded});
    await tester.pumpWidget(buildTestApp(db, store: store));
    await tester.pumpAndSettle();
    return store;
  }

  Finder tab(String label) =>
      find.descendant(of: find.byType(AppBottomBar), matching: find.text(label));

  /// Nút Back của hệ điều hành Android.
  Future<void> pressBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  testWidgets('chưa onboarding → màn chào, không có thanh điều hướng', (tester) async {
    await pumpApp(tester, onboarded: false);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(AppBottomBar), findsNothing);
    // Luồng onboarding đầy đủ: test/features/onboarding/onboarding_flow_test.dart.
  });

  testWidgets('bấm từng tab → đúng màn, tab cũ vẫn giữ trạng thái (IndexedStack)', (tester) async {
    await pumpApp(tester);
    for (final (label, screen) in [
      ('Giao dịch', TransactionsScreen),
      ('Báo cáo', ReportsScreen),
      ('Tài khoản', AccountScreen),
      ('Tổng quan', HomeScreen),
    ]) {
      await tester.tap(tab(label));
      await tester.pumpAndSettle();
      expect(find.byType(screen), findsOneWidget, reason: label);
    }
    // Các tab đã mở vẫn sống (offstage), nên vị trí cuộn và state không mất khi quay lại.
    for (final screen in [TransactionsScreen, ReportsScreen, AccountScreen]) {
      expect(find.byType(screen, skipOffstage: false), findsOneWidget);
    }
  });

  testWidgets('nút + mở Thêm giao dịch che thanh dưới; đóng → về đúng tab cũ', (tester) async {
    await pumpApp(tester);
    await tester.tap(tab('Báo cáo'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Thêm giao dịch'));
    await tester.pumpAndSettle();
    expect(find.byType(AddTransactionScreen), findsOneWidget);
    expect(find.byType(AppBottomBar), findsNothing);

    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    expect(find.byType(ReportsScreen), findsOneWidget);
    expect(find.byType(AppBottomBar), findsOneWidget);
  });

  for (final (label, screen) in [('Ví của tôi', WalletsScreen), ('Danh mục', CategoriesScreen)]) {
    testWidgets('Tài khoản → $label (che thanh dưới) → Back → Tài khoản', (tester) async {
      await pumpApp(tester);
      await tester.tap(tab('Tài khoản'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(find.byType(screen), findsOneWidget);
      expect(find.byType(AppBottomBar), findsNothing);

      await pressBack(tester);
      expect(find.byType(screen), findsNothing);
      expect(find.byType(AccountScreen), findsOneWidget);
      expect(find.byType(AppBottomBar), findsOneWidget);
    });
  }

  testWidgets('không còn route Cài đặt cũ /account/settings', (tester) async {
    await pumpApp(tester);
    await tester.tap(tab('Tài khoản'));
    await tester.pumpAndSettle();
    expect(find.text('Cài đặt'), findsNothing);
  });

  testWidgets('Back ở tab khác → về Tổng quan; Back ở Tổng quan → để hệ thống thoát app', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(tab('Giao dịch'));
    await tester.pumpAndSettle();

    await pressBack(tester);
    expect(find.byType(HomeScreen), findsOneWidget);

    // false = app không tự xử lý → Android đóng activity (thoát app).
    final handled = await tester.binding.handlePopRoute();
    expect(handled, isFalse);
  });

  testWidgets('mục đang chọn có ngữ nghĩa selected', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpApp(tester);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Tổng quan').last),
      matchesSemantics(
        label: 'Tổng quan',
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });

  for (final locale in ['vi', 'en']) {
    testWidgets('màn 320px, chữ 2x ($locale): thanh dưới không tràn, vùng chạm ≥ 48', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpApp(tester, locale: locale);
      expect(tester.takeException(), isNull);
      final fab = tester.getSize(find.byType(FloatingActionButton));
      expect(fab, const Size(60, 60));
      for (final element
          in find
              .descendant(of: find.byType(AppBottomBar), matching: find.byType(InkWell))
              .evaluate()) {
        final size = (element.renderObject! as RenderBox).size;
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }
    });
  }
}
