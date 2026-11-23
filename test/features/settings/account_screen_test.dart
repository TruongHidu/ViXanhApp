import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/clock.dart';
import 'package:vi_xanh_app/core/enums.dart';
import 'package:vi_xanh_app/core/failure.dart';
import 'package:vi_xanh_app/core/formatting/money_format.dart';
import 'package:vi_xanh_app/core/ids.dart';
import 'package:vi_xanh_app/core/result.dart';
import 'package:vi_xanh_app/data/database.dart';
import 'package:vi_xanh_app/features/backup/data/backup_status_store.dart';
import 'package:vi_xanh_app/features/home/presentation/home_screen.dart';
import 'package:vi_xanh_app/features/settings/data/settings_repository.dart';
import 'package:vi_xanh_app/features/settings/presentation/account_screen.dart';
import 'package:vi_xanh_app/features/transactions/data/transaction_repository.dart';
import 'package:vi_xanh_app/features/transactions/domain/transaction_draft.dart';
import 'package:vi_xanh_app/features/wallets/data/wallet_repository.dart';
import 'package:vi_xanh_app/theme/widgets/app_bottom_bar.dart';

import '../../fakes/fakes.dart';
import '../../helpers.dart';

void main() {
  final now = DateTime(2026, 11, 20, 9);
  late AppDatabase db;
  late FakeKeyValueStore store;
  late FakeBackupService backup;
  late FakeShareService share;

  setUp(() {
    store = FakeKeyValueStore({'locale': 'vi', 'onboarding_completed': true});
    backup = FakeBackupService(result: Ok(File('vi_xanh_backup_1.sqlite')));
    share = FakeShareService();
  });

  Finder tab(String label) =>
      find.descendant(of: find.byType(AppBottomBar), matching: find.text(label));

  /// Dựng app (giữ nguyên [store] → giống mở lại app) và mở tab Tài khoản.
  Future<void> openAccount(
    WidgetTester tester, {
    Size size = const Size(400, 1600),
    bool freshDb = true,
    String accountLabel = 'Tài khoản',
    int transactions = 0,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    if (freshDb) {
      db = inMemoryDatabase();
      addTearDown(() => db.close());
      // Ghi dữ liệu TRƯỚC khi dựng app: transaction của drift trong runAsync sẽ chờ
      // khóa mà truy vấn của cây widget (chạy trong thời gian giả) đang giữ.
      await tester.runAsync(() async {
        final wallet = (await WalletRepository(
          db,
        ).create(name: 'Tiền mặt', type: WalletType.cash)).valueOrNull!;
        final txns = TransactionRepository(db);
        for (var i = 0; i < transactions; i++) {
          await txns.add(
            TransactionDraft(
              type: TransactionType.income,
              amount: 1000,
              walletId: wallet,
              categoryId: CategoryId(stableUuid('category:luong')),
              occurredAt: now.subtract(Duration(hours: i)),
            ),
          );
        }
      });
    }
    await tester.pumpWidget(
      buildTestApp(db, store: store, clock: FixedClock(now), backup: backup, share: share),
    );
    await settleDb(tester);
    await tester.tap(tab(accountLabel));
    await settleDb(tester);
    expect(find.byType(AccountScreen), findsOneWidget);
  }

  /// Dựng lại toàn bộ app với cùng kho cài đặt.
  Future<void> restartApp(WidgetTester tester, {String accountLabel = 'Tài khoản'}) async {
    await tester.pumpWidget(const SizedBox());
    await openAccount(tester, freshDb: false, accountLabel: accountLabel);
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    // Chạm mép trái: nút "+" nổi giữa đáy màn có thể che phần giữa dòng.
    await tester.tapAt(tester.getTopLeft(finder) + const Offset(4, 8));
    await settleDb(tester);
  }

  testWidgets('hồ sơ mặc định, chỉ các nhóm đã chạy được, phiên bản', (tester) async {
    await openAccount(tester);
    expect(find.text('Bạn'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('Chưa sao lưu'), findsOneWidget);
    expect(find.text('1 ví'), findsOneWidget);
    for (final title in ['Quản lý', 'Giao diện', 'Dữ liệu', 'Khác']) {
      expect(find.text(title), findsOneWidget, reason: title);
    }
    for (final hidden in [
      'Ngân sách',
      'Giao dịch định kỳ',
      'Kết nối ngân hàng',
      'Bảo mật',
      'Thông báo',
      'Xuất Excel/CSV',
      'Nhập từ file',
      'Xóa toàn bộ dữ liệu',
      'Góp ý',
    ]) {
      expect(find.text(hidden), findsNothing, reason: hidden);
    }
    expect(find.text('1.0.0 (1)'), findsOneWidget);
  });

  testWidgets('sửa tên → thẻ hồ sơ và lời chào ở Tổng quan đổi theo', (tester) async {
    await openAccount(tester);
    await tester.tap(find.byTooltip('Sửa tên'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Minh');
    await tester.tap(find.text('Lưu'));
    await settleDb(tester);

    expect(find.text('Minh'), findsOneWidget);
    expect(find.text('M'), findsOneWidget);
    expect(store.getString(SettingsRepository.kUserName), 'Minh');

    await tester.tap(tab('Tổng quan'));
    await settleDb(tester);
    expect(find.textContaining('Minh'), findsOneWidget);
  });

  testWidgets('sao lưu thành công → chia sẻ file, lưu giờ theo Clock, snackbar', (tester) async {
    await openAccount(tester);
    await tapVisible(tester, find.text('Sao lưu'));

    expect(backup.exports, 1);
    expect(share.shared, ['vi_xanh_backup_1.sqlite']);
    expect(store.getInt(BackupStatusStore.kLastBackupAt), now.toUtc().millisecondsSinceEpoch);
    expect(find.text('Đã tạo bản sao lưu'), findsOneWidget);
    expect(find.text('Đã sao lưu lúc 09:00'), findsOneWidget);
    expect(find.text('Chưa sao lưu'), findsNothing);
  });

  testWidgets('sao lưu lỗi → snackbar, không đổi trạng thái', (tester) async {
    backup.result = const Err(DatabaseFailure('disk full'));
    await openAccount(tester);
    await tapVisible(tester, find.text('Sao lưu'));

    expect(find.text('Không sao lưu được. Vui lòng thử lại.'), findsOneWidget);
    expect(store.getInt(BackupStatusStore.kLastBackupAt), isNull);
    expect(share.shared, isEmpty);
    expect(find.text('Chưa sao lưu'), findsOneWidget);
  });

  testWidgets('chế độ tối có hiệu lực ngay và còn sau khi mở lại app', (tester) async {
    await openAccount(tester);
    await tapVisible(tester, find.text('Chế độ tối'));
    await tester.tap(find.text('Tối').last);
    await settleDb(tester);

    Brightness brightness() => Theme.of(tester.element(find.byType(AccountScreen))).brightness;
    expect(brightness(), Brightness.dark);
    expect(store.getString(SettingsRepository.kThemeMode), 'dark');

    await restartApp(tester);
    expect(brightness(), Brightness.dark);
    expect(find.text('Tối'), findsOneWidget, reason: 'giá trị trên dòng Chế độ tối');
  });

  testWidgets('đổi ngôn ngữ sang English có hiệu lực ngay và còn sau khi mở lại', (tester) async {
    await openAccount(tester);
    await tapVisible(tester, find.text('Ngôn ngữ'));
    await tester.tap(find.text('English'));
    await settleDb(tester);

    expect(find.text('Account'), findsWidgets);
    expect(find.text('Appearance'), findsOneWidget);

    await restartApp(tester, accountLabel: 'Account');
    expect(find.text('Appearance'), findsOneWidget);
    expect(store.getString(SettingsRepository.kLocale), 'en');
  });

  testWidgets('ngày bắt đầu tháng: chọn ngày 5 → lưu, Tổng quan không lỗi', (tester) async {
    await openAccount(tester);
    expect(find.text('Ngày 1'), findsOneWidget);
    await tapVisible(tester, find.text('Ngày bắt đầu tháng'));
    await tester.tap(find.text('Ngày 5'));
    await settleDb(tester);

    expect(find.text('Ngày 5'), findsOneWidget);
    expect(store.getInt(SettingsRepository.kMonthStartDay), 5);

    await tester.tap(tab('Tổng quan'));
    await settleDb(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mở app với ngày bắt đầu tháng đã lưu = 5 → hiện "Ngày 5"', (tester) async {
    store = FakeKeyValueStore({
      'locale': 'vi',
      'onboarding_completed': true,
      SettingsRepository.kMonthStartDay: 5,
    });
    await openAccount(tester);
    expect(find.text('Ngày 5'), findsOneWidget);
  });

  testWidgets('công tắc ẩn số dư → Tổng quan hiện số đã che', (tester) async {
    await openAccount(tester);
    expect(find.text(formatMasked()), findsNothing);
    await tapVisible(tester, find.text('Ẩn số dư khi mở app'));
    expect(store.getBool(SettingsRepository.kHideBalance), isTrue);

    await tester.tap(tab('Tổng quan'));
    await settleDb(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text(formatMasked()), findsWidgets);
  });

  testWidgets('nhắc sao lưu khi có ≥ 20 giao dịch và chưa sao lưu; sao lưu xong → hết nhắc', (
    tester,
  ) async {
    await openAccount(tester, transactions: 20);
    expect(find.textContaining('Đã lâu chưa sao lưu'), findsOneWidget);

    await tapVisible(tester, find.text('Sao lưu'));
    expect(find.textContaining('Đã lâu chưa sao lưu'), findsNothing);
  });

  testWidgets('ít hơn 20 giao dịch → không nhắc', (tester) async {
    await openAccount(tester, transactions: 19);
    expect(find.textContaining('Đã lâu chưa sao lưu'), findsNothing);
  });

  for (final locale in ['vi', 'en']) {
    testWidgets('màn 320px, chữ 2x ($locale): không tràn', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      store = FakeKeyValueStore({'locale': locale, 'onboarding_completed': true});
      await openAccount(
        tester,
        size: const Size(320, 640),
        accountLabel: locale == 'vi' ? 'Tài khoản' : 'Account',
      );
      expect(tester.takeException(), isNull);
      await tester.fling(find.byType(ListView).first, const Offset(0, -3000), 3000);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
