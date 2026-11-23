import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/clock.dart';
import 'package:vi_xanh_app/core/enums.dart';
import 'package:vi_xanh_app/core/ids.dart';
import 'package:vi_xanh_app/features/reports/presentation/report_category_screen.dart';
import 'package:vi_xanh_app/features/reports/presentation/reports_screen.dart';
import 'package:vi_xanh_app/features/transactions/data/transaction_repository.dart';
import 'package:vi_xanh_app/features/transactions/domain/transaction_draft.dart';
import 'package:vi_xanh_app/features/wallets/data/wallet_repository.dart';
import 'package:vi_xanh_app/theme/widgets/app_bottom_bar.dart';

import '../../fakes/fakes.dart';
import '../../helpers.dart';

void main() {
  const nbsp = ' ';
  final now = DateTime(2026, 11, 18, 10);
  CategoryId cat(String key) => CategoryId(stableUuid('category:$key'));

  Future<void> openReports(
    WidgetTester tester, {
    bool withData = true,
    Size size = const Size(400, 2000),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = inMemoryDatabase(clock: FixedClock(now));
    addTearDown(db.close);
    await tester.runAsync(() async {
      final cash = (await WalletRepository(
        db,
      ).create(name: 'Tiền mặt', type: WalletType.cash)).valueOrNull!;
      if (!withData) return;
      final repo = TransactionRepository(db);
      Future<void> add(TransactionType t, int amount, DateTime at, String c) => repo.add(
        TransactionDraft(
          type: t,
          amount: amount,
          walletId: cash,
          categoryId: cat(c),
          occurredAt: at,
          payee: c == 'ca_phe' ? 'Highlands Coffee' : null,
        ),
      );
      await add(TransactionType.expense, 45000, DateTime(2026, 11, 18, 8), 'ca_phe');
      await add(TransactionType.expense, 300000, DateTime(2026, 11, 10), 'di_cho');
      await add(TransactionType.expense, 780000, DateTime(2026, 11, 17), 'dien');
      await add(TransactionType.income, 18500000, DateTime(2026, 11, 2), 'luong');
      // Tháng trước: chi 1.250.000 → tháng này chi 1.125.000 ít hơn 10%.
      await add(TransactionType.expense, 1250000, DateTime(2026, 10, 12), 'an_uong');
    });
    await tester.pumpWidget(
      buildTestApp(
        db,
        clock: FixedClock(now),
        store: FakeKeyValueStore({'locale': 'vi', 'onboarding_completed': true}),
      ),
    );
    await settleDb(tester);
    await tester.tap(
      find.descendant(of: find.byType(AppBottomBar), matching: find.text('Báo cáo')),
    );
    await settleDb(tester);
    expect(find.byType(ReportsScreen), findsOneWidget);
  }

  testWidgets('tháng này: tổng chi, danh mục chính gộp mục con, so với tháng trước, 6 tháng', (
    tester,
  ) async {
    await openReports(tester);
    expect(find.text('Tháng 11/2026'), findsOneWidget);
    expect(find.text('Tổng chi'), findsOneWidget);
    expect(find.text('1.125.000$nbsp₫'), findsOneWidget);
    expect(find.text('Hóa đơn'), findsOneWidget);
    expect(find.text('Ăn uống'), findsOneWidget);
    expect(find.text('345.000$nbsp₫'), findsOneWidget, reason: 'Cà phê + Đi chợ gộp vào Ăn uống');
    expect(find.text('69%'), findsOneWidget);
    expect(find.text('So với tháng trước'), findsOneWidget);
    expect(find.text('Chi ít hơn 10% so với tháng 10'), findsOneWidget);
    expect(find.text('Thu – chi 6 tháng'), findsOneWidget);
    expect(find.text('T11'), findsOneWidget);
    expect(find.textContaining('👏'), findsNothing);
  });

  testWidgets('đổi ngày bắt đầu tháng ở Tài khoản → Báo cáo tính lại kỳ đang xem', (tester) async {
    await openReports(tester);
    expect(find.text('1.125.000$nbsp₫'), findsOneWidget);

    Finder tab(String label) =>
        find.descendant(of: find.byType(AppBottomBar), matching: find.text(label));
    await tester.tap(tab('Tài khoản'));
    await settleDb(tester);
    await tester.ensureVisible(find.text('Ngày bắt đầu tháng'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ngày bắt đầu tháng'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Ngày 15'),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Ngày 15'));
    await settleDb(tester);

    await tester.tap(tab('Báo cáo'));
    await settleDb(tester);
    // Hôm nay 18/11 ≥ ngày 15 → kỳ hiện tại là 15/11 – 14/12, mang tên tháng kết thúc (12):
    // chi 45.000 (18/11) + 780.000 (17/11).
    expect(find.text('Tháng 12/2026'), findsOneWidget);
    expect(find.text('825.000$nbsp₫'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tab Thu nhập → Tổng thu và Lương', (tester) async {
    await openReports(tester);
    await tester.tap(find.text('Thu nhập'));
    await settleDb(tester);
    expect(find.text('Tổng thu'), findsOneWidget);
    expect(find.text('Lương'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('đổi kỳ: Tuần, Năm, mũi tên kỳ trước', (tester) async {
    await openReports(tester);
    await tester.tap(find.text('Tuần'));
    await settleDb(tester);
    expect(find.text('16/11 – 22/11/2026'), findsOneWidget);
    expect(find.text('45.000$nbsp₫'), findsWidgets);

    await tester.tap(find.text('Năm'));
    await settleDb(tester);
    expect(find.text('Năm 2026'), findsOneWidget);
    expect(find.text('2.375.000$nbsp₫'), findsOneWidget);

    await tester.tap(find.byTooltip('Kỳ trước'));
    await settleDb(tester);
    expect(find.text('Năm 2025'), findsOneWidget);
    expect(find.text('Chưa có khoản chi nào trong kỳ này.'), findsOneWidget);
  });

  testWidgets('chạm danh mục → danh sách giao dịch của danh mục trong kỳ', (tester) async {
    await openReports(tester);
    await tester.tap(find.text('Ăn uống'));
    await settleDb(tester);
    expect(find.byType(ReportCategoryScreen), findsOneWidget);
    expect(find.text('Ăn uống · Tháng 11/2026'), findsOneWidget);
    expect(find.text('Highlands Coffee'), findsOneWidget);
    expect(find.text('−300.000$nbsp₫'), findsOneWidget, reason: 'mục con Đi chợ cũng hiện');
    expect(find.text('−1.250.000$nbsp₫'), findsNothing, reason: 'tháng trước không hiện');
  });

  testWidgets('chưa có giao dịch → trạng thái trống, không có thẻ so sánh', (tester) async {
    await openReports(tester, withData: false);
    expect(find.text('Chưa có khoản chi nào trong kỳ này.'), findsOneWidget);
    expect(find.text('So với tháng trước'), findsNothing);
  });

  testWidgets('màn 320px, chữ 2x: không tràn', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openReports(tester, size: const Size(320, 640));
    expect(tester.takeException(), isNull);
    await tester.fling(find.byType(ListView).first, const Offset(0, -3000), 3000);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
