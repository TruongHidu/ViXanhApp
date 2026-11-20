import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/clock.dart';
import 'package:vi_xanh_app/core/enums.dart';
import 'package:vi_xanh_app/core/ids.dart';
import 'package:vi_xanh_app/features/home/presentation/home_screen.dart';
import 'package:vi_xanh_app/features/transactions/data/transaction_repository.dart';
import 'package:vi_xanh_app/features/transactions/domain/transaction_draft.dart';
import 'package:vi_xanh_app/features/transactions/presentation/add_transaction_screen.dart';
import 'package:vi_xanh_app/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:vi_xanh_app/features/wallets/data/wallet_repository.dart';

import '../../fakes/fakes.dart';
import '../../helpers.dart';

void main() {
  const nbsp = ' ';
  CategoryId cat(String key) => CategoryId(stableUuid('category:$key'));

  Future<FakeKeyValueStore> pumpHome(
    WidgetTester tester, {
    required DateTime now,
    bool withData = true,
    String? userName,
    Size size = const Size(400, 1400),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final db = inMemoryDatabase(clock: FixedClock(now));
    addTearDown(db.close);
    if (withData) {
      await tester.runAsync(() async {
        final walletRepo = WalletRepository(db);
        final cash = (await walletRepo.create(
          name: 'Tiền mặt',
          type: WalletType.cash,
          initialBalance: 1250000,
        )).valueOrNull!;
        await walletRepo.create(
          name: 'Thẻ tín dụng',
          type: WalletType.credit,
          initialBalance: -2000000,
        );
        final repo = TransactionRepository(db);
        Future<void> add(TransactionType t, int amount, DateTime at, String category) => repo.add(
          TransactionDraft(
            type: t,
            amount: amount,
            walletId: cash,
            categoryId: cat(category),
            occurredAt: at,
            payee: t == TransactionType.expense ? 'Highlands Coffee' : null,
          ),
        );
        await add(TransactionType.expense, 45000, DateTime(2026, 11, 18, 8, 15), 'ca_phe');
        await add(TransactionType.income, 18500000, DateTime(2026, 11, 2, 9), 'luong');
        await add(TransactionType.expense, 99000, DateTime(2026, 10, 30), 'an_uong');
      });
    }
    final store = FakeKeyValueStore({
      'locale': 'vi',
      'onboarding_completed': true,
      'user_name': ?userName,
    });
    await tester.pumpWidget(buildTestApp(db, store: store, clock: FixedClock(now)));
    await settleDb(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    return store;
  }

  testWidgets('lời chào theo buổi, kèm tên; dòng ngày đầy đủ', (tester) async {
    await pumpHome(tester, now: DateTime(2026, 11, 18, 8), userName: 'Minh');
    expect(find.text('Chào buổi sáng, Minh'), findsOneWidget);
    expect(find.text('Thứ Tư, 18/11/2026'), findsOneWidget);
  });

  testWidgets('buổi tối, chưa có tên → chào chung', (tester) async {
    await pumpHome(tester, now: DateTime(2026, 11, 18, 20));
    expect(find.text('Chào buổi tối'), findsOneWidget);
  });

  testWidgets('tổng số dư, thu/chi tháng này, ví, chi 7 ngày, giao dịch gần đây', (tester) async {
    await pumpHome(tester, now: DateTime(2026, 11, 18, 14));
    // 1.250.000 + 18.500.000 − 45.000 − 99.000 − 2.000.000
    expect(find.text('17.606.000$nbsp₫'), findsOneWidget);
    expect(find.text('+18.500.000$nbsp₫'), findsWidgets);
    expect(find.text('−45.000$nbsp₫'), findsWidgets, reason: 'chi tháng 11 bỏ khoản tháng 10');
    expect(find.text('Tiền mặt'), findsWidgets);
    expect(find.text('−2.000.000$nbsp₫'), findsOneWidget, reason: 'thẻ tín dụng đang nợ');
    expect(find.text('Tổng 45.000$nbsp₫ · trung bình 6.428$nbsp₫/ngày'), findsOneWidget);
    expect(find.text('T4'), findsOneWidget);
    expect(find.text('Highlands Coffee'), findsWidgets);
  });

  testWidgets('ẩn số dư → không còn số tiền nào trên màn; bật lại thì hiện', (tester) async {
    final store = await pumpHome(tester, now: DateTime(2026, 11, 18, 14));
    await tester.tap(find.byTooltip('Ẩn số dư'));
    await settleDb(tester);
    expect(find.textContaining('₫'), findsNothing);
    expect(find.text('••••••'), findsWidgets);
    expect(store.values['hide_balance'], isTrue);

    await tester.tap(find.byTooltip('Hiện số dư'));
    await settleDb(tester);
    expect(find.text('17.606.000$nbsp₫'), findsOneWidget);
  });

  testWidgets('chạm giao dịch gần đây → chi tiết; chạm cột biểu đồ đổi cột chọn', (tester) async {
    await pumpHome(tester, now: DateTime(2026, 11, 18, 14));
    await tester.tap(find.text('T3'));
    await tester.pump();
    expect(find.text('0$nbsp₫'), findsWidgets, reason: 'thứ Ba không chi');

    await tester.tap(find.text('Highlands Coffee').last);
    await settleDb(tester);
    expect(find.byType(TransactionDetailScreen), findsOneWidget);
  });

  testWidgets('chưa có giao dịch → trạng thái trống có nút thêm', (tester) async {
    await pumpHome(tester, now: DateTime(2026, 11, 18, 14), withData: false);
    await tester.ensureVisible(find.text('Thêm giao dịch').last);
    await tester.tap(find.text('Thêm giao dịch').last);
    await settleDb(tester);
    expect(find.byType(AddTransactionScreen), findsOneWidget);
  });

  for (final locale in ['vi', 'en']) {
    testWidgets('màn 320px, chữ 2x ($locale): không tràn', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpHome(tester, now: DateTime(2026, 11, 18, 14), size: const Size(320, 640));
      if (locale == 'en') {
        // Đổi ngôn ngữ ngay trên app đang chạy.
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
      await tester.fling(find.byType(CustomScrollView).first, const Offset(0, -3000), 3000);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
