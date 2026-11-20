import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/clock.dart';
import 'package:vi_xanh_app/core/enums.dart';
import 'package:vi_xanh_app/core/ids.dart';
import 'package:vi_xanh_app/data/database.dart';
import 'package:vi_xanh_app/features/transactions/data/transaction_repository.dart';
import 'package:vi_xanh_app/features/transactions/domain/transaction_draft.dart';
import 'package:vi_xanh_app/features/transactions/presentation/add_transaction_screen.dart';
import 'package:vi_xanh_app/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:vi_xanh_app/features/transactions/presentation/transactions_screen.dart';
import 'package:vi_xanh_app/features/wallets/data/wallet_repository.dart';
import 'package:vi_xanh_app/theme/widgets/amount_keypad.dart';
import 'package:vi_xanh_app/theme/widgets/app_bottom_bar.dart';

import '../../fakes/fakes.dart';
import '../../helpers.dart';

void main() {
  final now = DateTime(2026, 11, 18, 10);
  const nbsp = ' ';

  CategoryId cat(String key) => CategoryId(stableUuid('category:$key'));

  /// Màn dọc như điện thoại để phần dưới không bị che.
  void phoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  /// Seed rồi mở tab Giao dịch.
  Future<AppDatabase> openTransactions(
    WidgetTester tester, {
    bool withData = true,
    Future<void> Function(AppDatabase db, WalletId cash)? seed,
  }) async {
    phoneSize(tester);
    final db = inMemoryDatabase(clock: FixedClock(now));
    addTearDown(db.close);
    await tester.runAsync(() async {
      final cash = (await WalletRepository(
        db,
      ).create(name: 'Tiền mặt', type: WalletType.cash)).valueOrNull!;
      final repo = TransactionRepository(db);
      if (withData) {
        await repo.add(
          TransactionDraft(
            type: TransactionType.expense,
            amount: 45000,
            walletId: cash,
            categoryId: cat('ca_phe'),
            occurredAt: DateTime(2026, 11, 18, 8, 15),
            payee: 'Highlands Coffee',
            note: 'Cà phê sáng với Lan',
          ),
        );
        await repo.add(
          TransactionDraft(
            type: TransactionType.expense,
            amount: 62000,
            walletId: cash,
            categoryId: cat('di_chuyen'),
            occurredAt: DateTime(2026, 11, 17, 7, 50),
          ),
        );
        await repo.add(
          TransactionDraft(
            type: TransactionType.income,
            amount: 18500000,
            walletId: cash,
            categoryId: cat('luong'),
            occurredAt: DateTime(2026, 11, 17, 9),
          ),
        );
      }
      await seed?.call(db, cash);
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
      find.descendant(of: find.byType(AppBottomBar), matching: find.text('Giao dịch')),
    );
    await settleDb(tester);
    expect(find.byType(TransactionsScreen), findsOneWidget);
    return db;
  }

  /// Chạm (bình thường, để snackbar dùng thời gian giả của test) rồi chờ DB.
  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await settleDb(tester);
  }

  testWidgets('nhóm theo ngày, tóm tắt tháng, dòng có tên + danh mục · ví', (tester) async {
    await openTransactions(tester);
    expect(find.text('Tháng 11/2026'), findsOneWidget);
    expect(find.text('Hôm nay · Thứ Tư 18/11'), findsOneWidget);
    expect(find.text('Hôm qua · Thứ Ba 17/11'), findsOneWidget);
    expect(find.text('Highlands Coffee'), findsOneWidget);
    expect(find.text('Cà phê · Tiền mặt'), findsOneWidget);
    expect(find.text('+18.500.000$nbsp₫'), findsWidgets);
    expect(find.text('−107.000$nbsp₫'), findsOneWidget, reason: 'tổng chi của tháng');
  });

  testWidgets('chip Thu nhập chỉ còn khoản thu; tìm "ca phe" không dấu ra Highlands', (
    tester,
  ) async {
    await openTransactions(tester);
    await tapAndSettle(tester, find.widgetWithText(FilterChip, 'Thu nhập'));
    expect(find.text('Highlands Coffee'), findsNothing);
    expect(find.text('Lương'), findsWidgets);

    await tapAndSettle(tester, find.widgetWithText(FilterChip, 'Tất cả'));
    await tester.tap(find.byTooltip('Tìm kiếm giao dịch'));
    await settleDb(tester);
    await tester.enterText(find.byType(TextField), 'ca phe');
    await settleDb(tester);
    expect(find.text('Highlands Coffee'), findsOneWidget);
    expect(find.text('Di chuyển'), findsNothing);

    await tester.enterText(find.byType(TextField), 'không có gì');
    await settleDb(tester);
    expect(find.text('Không có giao dịch phù hợp với bộ lọc này.'), findsOneWidget);
  });

  testWidgets('vuốt trái → Xóa → biến mất → Hoàn tác → hiện lại', (tester) async {
    await openTransactions(tester);
    await tester.drag(find.text('Highlands Coffee'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(find.text('Xóa'), findsWidgets);

    await tapAndSettle(tester, find.text('Xóa').first);
    expect(find.text('Highlands Coffee'), findsNothing);
    expect(find.text('Đã xóa giao dịch'), findsOneWidget);

    await tapAndSettle(tester, find.text('Hoàn tác'));
    expect(find.text('Highlands Coffee'), findsOneWidget);
  });

  testWidgets('mở chi tiết → Chỉnh sửa → đổi số tiền → chi tiết và danh sách cập nhật', (
    tester,
  ) async {
    await openTransactions(tester);
    await tester.tap(find.text('Highlands Coffee'));
    await settleDb(tester);
    expect(find.byType(TransactionDetailScreen), findsOneWidget);
    expect(find.text('Cà phê sáng với Lan'), findsOneWidget);
    expect(find.text('08:15, Thứ Tư 18/11/2026'), findsOneWidget);
    expect(find.text('Nhập tay'), findsOneWidget);

    await tester.tap(find.text('Chỉnh sửa'));
    await settleDb(tester);
    expect(find.byType(AddTransactionScreen), findsOneWidget);
    expect(find.text('45.000'), findsOneWidget, reason: 'nạp đúng số tiền cũ');

    final backspace = find.descendant(
      of: find.byType(AmountKeypad),
      matching: find.byIcon(Icons.backspace_outlined),
    );
    for (var i = 0; i < 5; i++) {
      await tester.tap(backspace);
      await tester.pump();
    }
    for (final k in ['5', '0', '000']) {
      await tester.tap(find.descendant(of: find.byType(AmountKeypad), matching: find.text(k)));
      await tester.pump();
    }
    await tapAndSettle(
      tester,
      find.descendant(of: find.byType(AmountKeypad), matching: find.text('Lưu')),
    );
    expect(find.byType(TransactionDetailScreen), findsOneWidget);
    expect(find.text('−50.000$nbsp₫'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await settleDb(tester);
    expect(find.text('−50.000$nbsp₫'), findsWidgets);
  });

  testWidgets('xóa ở màn chi tiết → về danh sách, có Hoàn tác', (tester) async {
    await openTransactions(tester);
    await tester.tap(find.text('Highlands Coffee'));
    await settleDb(tester);
    await tapAndSettle(tester, find.text('Xóa'));
    expect(find.byType(TransactionDetailScreen), findsNothing);
    expect(find.text('Highlands Coffee'), findsNothing);
    expect(find.text('Đã xóa giao dịch'), findsOneWidget);
  });

  testWidgets('tháng trống → trạng thái trống, nút mở Thêm giao dịch', (tester) async {
    await openTransactions(tester, withData: false);
    expect(find.text('Chưa có giao dịch nào trong tháng này'), findsOneWidget);
    await tester.tap(find.text('Thêm giao dịch đầu tiên'));
    await settleDb(tester);
    expect(find.byType(AddTransactionScreen), findsOneWidget);
  });

  testWidgets('tháng trước không có dữ liệu → trống; quay lại tháng này thấy lại', (tester) async {
    await openTransactions(tester);
    await tester.tap(find.byTooltip('Tháng trước'));
    await settleDb(tester);
    expect(find.text('Tháng 10/2026'), findsOneWidget);
    expect(find.text('Highlands Coffee'), findsNothing);
    await tester.tap(find.byTooltip('Tháng sau'));
    await settleDb(tester);
    expect(find.text('Highlands Coffee'), findsOneWidget);
  });

  testWidgets('1.000 giao dịch: cuộn không lỗi', (tester) async {
    await openTransactions(
      tester,
      withData: false,
      seed: (db, cash) => db.batch((b) {
        for (var i = 0; i < 1000; i++) {
          b.insert(
            db.transactions,
            TransactionsCompanion.insert(
              id: TransactionId('t$i'),
              walletId: cash,
              categoryId: Value(cat('an_uong')),
              type: TransactionType.expense,
              amount: 1000 + i,
              occurredAt: DateTime(2026, 11, 1 + i % 18, 12).subtract(Duration(minutes: i)),
              createdAt: now,
              updatedAt: now,
            ),
          );
        }
      }),
    );
    for (var i = 0; i < 5; i++) {
      await tester.fling(find.byType(CustomScrollView), const Offset(0, -2000), 3000);
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });
}
