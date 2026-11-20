import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/clock.dart';
import 'package:vi_xanh_app/core/enums.dart';
import 'package:vi_xanh_app/core/ids.dart';
import 'package:vi_xanh_app/data/database.dart';
import 'package:vi_xanh_app/features/transactions/data/transaction_repository.dart';
import 'package:vi_xanh_app/features/transactions/domain/transaction_draft.dart';
import 'package:vi_xanh_app/features/transactions/presentation/add_transaction_screen.dart';
import 'package:vi_xanh_app/features/wallets/data/wallet_repository.dart';
import 'package:vi_xanh_app/features/wallets/presentation/wallet_detail_screen.dart';
import 'package:vi_xanh_app/features/wallets/presentation/wallet_form_screen.dart';
import 'package:vi_xanh_app/features/wallets/presentation/wallets_screen.dart';
import 'package:vi_xanh_app/theme/widgets/app_bottom_bar.dart';

import '../../fakes/fakes.dart';
import '../../helpers.dart';

void main() {
  const nbsp = ' ';
  final now = DateTime(2026, 11, 18, 10);

  /// App có ví Tiền mặt (+ thẻ tín dụng nếu [withCredit]), mở màn Ví của tôi từ tab Tài khoản.
  Future<AppDatabase> openWallets(WidgetTester tester, {bool withCredit = true}) async {
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = inMemoryDatabase(clock: FixedClock(now));
    addTearDown(db.close);
    await tester.runAsync(() async {
      final wallets = WalletRepository(db);
      final cash = (await wallets.create(
        name: 'Tiền mặt',
        type: WalletType.cash,
        initialBalance: 1250000,
      )).valueOrNull!;
      if (withCredit) {
        await wallets.create(
          name: 'Thẻ TCB',
          type: WalletType.credit,
          initialBalance: -2000000,
          accountLast4: '4321',
        );
      }
      await TransactionRepository(db).add(
        TransactionDraft(
          type: TransactionType.expense,
          amount: 45000,
          walletId: cash,
          categoryId: CategoryId(stableUuid('category:an_uong')),
          occurredAt: DateTime(2026, 11, 18, 8),
          payee: 'Highlands Coffee',
        ),
      );
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
      find.descendant(of: find.byType(AppBottomBar), matching: find.text('Tài khoản')),
    );
    await settleDb(tester);
    await tester.tap(find.text('Ví của tôi'));
    await settleDb(tester);
    expect(find.byType(WalletsScreen), findsOneWidget);
    return db;
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await settleDb(tester);
  }

  testWidgets('tổng tài sản / nợ / ròng; ví nhóm theo loại; số tài khoản che', (tester) async {
    await openWallets(tester);
    expect(find.text('1.205.000$nbsp₫'), findsWidgets, reason: 'tài sản = tiền mặt sau khoản chi');
    expect(find.text('−2.000.000$nbsp₫'), findsWidgets);
    expect(find.text('−795.000$nbsp₫'), findsOneWidget, reason: 'tài sản ròng');
    expect(find.text('Tiền mặt'), findsWidgets);
    expect(find.text('Thẻ tín dụng'), findsOneWidget, reason: 'tiêu đề nhóm');
    expect(find.text('•••• 4321'), findsOneWidget);
  });

  testWidgets('Thêm ví ngân hàng → xuất hiện trong nhóm Ngân hàng', (tester) async {
    await openWallets(tester);
    await tapVisible(tester, find.text('Thêm ví'));
    expect(find.byType(WalletFormScreen), findsOneWidget);
    await tester.tap(find.text('Ngân hàng'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(0), '5000000');
    await tester.enterText(find.byType(TextField).at(2), '1234');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tapVisible(tester, find.text('Lưu'));

    expect(find.byType(WalletsScreen), findsOneWidget);
    expect(find.text('Tài khoản ngân hàng'), findsOneWidget);
    expect(find.text('•••• 1234'), findsOneWidget);
    expect(find.text('5.000.000$nbsp₫'), findsOneWidget);
  });

  testWidgets('chi tiết ví: số dư, biểu đồ 30 ngày, giao dịch; sửa tên', (tester) async {
    await openWallets(tester);
    await tester.tap(find.text('Tiền mặt').last);
    await settleDb(tester);
    expect(find.byType(WalletDetailScreen), findsOneWidget);
    expect(find.text('Số dư 30 ngày'), findsOneWidget);
    expect(find.text('Highlands Coffee'), findsOneWidget);
    expect(find.text('20/10'), findsOneWidget, reason: 'nhãn ngày đầu kỳ');

    await tester.tap(find.byTooltip('Tùy chọn ví'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sửa ví'));
    await settleDb(tester);
    expect(find.byType(WalletFormScreen), findsOneWidget);
    expect(find.text('1.250.000'), findsOneWidget, reason: 'nạp số dư ban đầu');
    await tester.enterText(find.byType(TextField).at(1), 'Ví trong túi');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tapVisible(tester, find.text('Lưu'));
    expect(find.text('Ví trong túi'), findsOneWidget);
  });

  testWidgets('lưu trữ ví → biến mất khỏi danh sách và khỏi chọn ví khi thêm giao dịch', (
    tester,
  ) async {
    await openWallets(tester);
    await tester.tap(find.text('Thẻ TCB'));
    await settleDb(tester);
    await tester.tap(find.byTooltip('Tùy chọn ví'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu trữ ví'));
    await tester.pumpAndSettle();
    expect(find.text('Lưu trữ ví Thẻ TCB?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Lưu trữ ví'));
    await settleDb(tester);

    expect(find.byType(WalletsScreen), findsOneWidget);
    expect(find.text('Thẻ TCB'), findsNothing);
    expect(find.text('Đã lưu trữ ví'), findsOneWidget);

    await tapVisible(tester, find.text('Chuyển tiền giữa các ví'));
    expect(find.byType(AddTransactionScreen), findsOneWidget);
    expect(find.text('Từ ví'), findsOneWidget, reason: 'mở sẵn tab Chuyển khoản');
    await tester.tap(find.text('Đến ví'));
    await tester.pumpAndSettle();
    expect(find.text('Thẻ TCB'), findsNothing, reason: 'ví đã lưu trữ không còn để chọn');
  });

  testWidgets('lưu trữ ví cuối cùng → báo lỗi, ví vẫn còn', (tester) async {
    await openWallets(tester, withCredit: false);
    await tester.tap(find.text('Tiền mặt').last);
    await settleDb(tester);
    await tester.tap(find.byTooltip('Tùy chọn ví'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu trữ ví'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Lưu trữ ví'));
    await settleDb(tester);
    expect(find.text('Cần giữ ít nhất một ví đang dùng.'), findsOneWidget);
    expect(find.byType(WalletDetailScreen), findsOneWidget);
  });

  testWidgets('Tổng quan: "Xem tất cả" ở mục ví mở Ví của tôi', (tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = inMemoryDatabase(clock: FixedClock(now));
    addTearDown(db.close);
    await tester.runAsync(
      () => WalletRepository(db).create(name: 'Tiền mặt', type: WalletType.cash),
    );
    await tester.pumpWidget(
      buildTestApp(
        db,
        clock: FixedClock(now),
        store: FakeKeyValueStore({'locale': 'vi', 'onboarding_completed': true}),
      ),
    );
    await settleDb(tester);
    await tester.tap(find.text('Xem tất cả').first);
    await settleDb(tester);
    expect(find.byType(WalletsScreen), findsOneWidget);
  });

  testWidgets('màn 320px, chữ 2x: danh sách ví và chi tiết không tràn', (tester) async {
    await openWallets(tester);
    tester.view.physicalSize = const Size(320, 640);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    // ListView dựng lười: cuộn tới dòng chưa được dựng rồi mới chạm.
    await tester.scrollUntilVisible(
      find.text('Thẻ TCB'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tapVisible(tester, find.text('Thẻ TCB'));
    expect(find.byType(WalletDetailScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
