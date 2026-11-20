import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/enums.dart';
import 'package:vi_xanh_app/data/database.dart';
import 'package:vi_xanh_app/features/transactions/presentation/add_transaction_screen.dart';
import 'package:vi_xanh_app/features/wallets/data/wallet_repository.dart';
import 'package:vi_xanh_app/theme/widgets/amount_keypad.dart';

import '../../fakes/fakes.dart';
import '../../helpers.dart';

void main() {
  /// App đã qua onboarding với [walletNames] ví tiền mặt, đang ở Tổng quan.
  Future<AppDatabase> pumpApp(
    WidgetTester tester, {
    List<String> walletNames = const ['Tiền mặt'],
  }) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await tester.runAsync(() async {
      for (final name in walletNames) {
        await WalletRepository(db).create(name: name, type: WalletType.cash);
      }
    });
    await tester.pumpWidget(
      buildTestApp(db, store: FakeKeyValueStore({'locale': 'vi', 'onboarding_completed': true})),
    );
    await settleDb(tester);
    return db;
  }

  Future<void> openAdd(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Thêm giao dịch'));
    await settleDb(tester);
    expect(find.byType(AddTransactionScreen), findsOneWidget);
  }

  /// Màn test thấp: phần trên có thể bị bàn phím che → cuộn tới rồi mới chạm.
  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
  }

  Finder key(String label) =>
      find.descendant(of: find.byType(AmountKeypad), matching: find.text(label));

  Future<void> typeKeys(WidgetTester tester, List<String> labels) async {
    for (final label in labels) {
      await tester.tap(key(label));
      await tester.pump();
    }
  }

  /// Lưu chạm DB thật → bấm trong runAsync rồi chờ DB.
  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.runAsync(() async {
      await tester.tap(finder);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await settleDb(tester);
  }

  Future<List<TransactionRow>> transactions(WidgetTester tester, AppDatabase db) async =>
      (await tester.runAsync(() => db.transactionsDao.watchRecent().first))!;

  testWidgets('gõ 4 5 000 trên bàn phím riêng → chọn Ăn uống → Lưu → có khoản chi 45.000', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await openAdd(tester);

    await typeKeys(tester, ['4', '5', '000']);
    expect(find.text('45.000'), findsOneWidget);
    await tapVisible(tester, find.text('Ăn uống'));

    await tapAndSettle(tester, key('Lưu'));
    expect(find.byType(AddTransactionScreen), findsNothing, reason: 'Lưu xong thì đóng màn');

    final rows = await transactions(tester, db);
    expect(rows.single.amount, 45000);
    expect(rows.single.type, TransactionType.expense);
  });

  testWidgets('phím + / − cộng dồn và hiện biểu thức', (tester) async {
    await pumpApp(tester);
    await openAdd(tester);
    await typeKeys(tester, ['5', '000', '+', '2', '0', '000']);
    expect(find.text('25.000'), findsOneWidget);
    expect(find.text('5.000 + 20.000 ='), findsOneWidget);
  });

  testWidgets('chip 50k thay số đang gõ', (tester) async {
    await pumpApp(tester);
    await openAdd(tester);
    await typeKeys(tester, ['7']);
    await tapVisible(tester, find.text('50k'));
    expect(find.text('50.000'), findsOneWidget);
  });

  testWidgets('"Lưu & thêm tiếp" giữ màn mở, báo đã lưu, xóa số tiền', (tester) async {
    final db = await pumpApp(tester);
    await openAdd(tester);
    await typeKeys(tester, ['4', '5', '000']);
    await tapVisible(tester, find.text('Ăn uống'));

    await tapAndSettle(tester, find.text('Lưu & thêm tiếp'));
    expect(find.byType(AddTransactionScreen), findsOneWidget);
    // Giữa số và ₫ là khoảng trắng không ngắt (U+00A0).
    expect(find.text('Đã lưu −45.000 ₫ · Ăn uống'), findsOneWidget);
    expect(find.text('45.000'), findsNothing);
    expect(await transactions(tester, db), hasLength(1));
  });

  testWidgets('chưa nhập số tiền → báo lỗi, không lưu', (tester) async {
    final db = await pumpApp(tester);
    await openAdd(tester);
    await tapAndSettle(tester, key('Lưu'));
    expect(find.text('Nhập số tiền trước nhé'), findsOneWidget);
    expect(find.byType(AddTransactionScreen), findsOneWidget);
    expect(await transactions(tester, db), isEmpty);
  });

  testWidgets('chuyển khoản khi chỉ có một ví → báo cần hai ví khác nhau', (tester) async {
    final db = await pumpApp(tester);
    await openAdd(tester);
    await tapVisible(tester, find.text('Chuyển khoản'));
    expect(find.text('Từ ví'), findsOneWidget);

    await typeKeys(tester, ['1', '000']);
    await tapAndSettle(tester, key('Lưu'));
    expect(find.text('Chọn hai ví khác nhau để chuyển khoản'), findsOneWidget);
    expect(await transactions(tester, db), isEmpty);
  });

  testWidgets('chuyển khoản giữa hai ví được lưu', (tester) async {
    final db = await pumpApp(tester, walletNames: ['Tiền mặt', 'MoMo']);
    await openAdd(tester);
    await tapVisible(tester, find.text('Chuyển khoản'));
    await typeKeys(tester, ['5', '0', '0', '000']);
    await tapAndSettle(tester, key('Lưu'));

    final row = (await transactions(tester, db)).single;
    expect(row.type, TransactionType.transfer);
    expect(row.amount, 500000);
    expect(row.toWalletId, isNotNull);
    expect(row.toWalletId, isNot(row.walletId));
  });

  for (final locale in ['vi', 'en']) {
    testWidgets('màn 320px, chữ 2x ($locale): không tràn', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final db = inMemoryDatabase();
      addTearDown(db.close);
      await tester.runAsync(
        () => WalletRepository(db).create(name: 'Tiền mặt', type: WalletType.cash),
      );
      await tester.pumpWidget(
        buildTestApp(
          db,
          store: FakeKeyValueStore({'locale': locale, 'onboarding_completed': true}),
        ),
      );
      await settleDb(tester);
      await tester.tap(find.byType(FloatingActionButton));
      await settleDb(tester);
      expect(tester.takeException(), isNull);
      expect(find.byType(AmountKeypad), findsOneWidget);
    });
  }
}
