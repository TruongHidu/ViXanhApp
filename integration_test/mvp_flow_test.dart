import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vi_xanh_app/app.dart';
import 'package:vi_xanh_app/core/result.dart';
import 'package:vi_xanh_app/data/database.dart';
import 'package:vi_xanh_app/data/sql_functions.dart';
import 'package:vi_xanh_app/features/home/presentation/home_screen.dart';
import 'package:vi_xanh_app/features/reports/presentation/reports_screen.dart';
import 'package:vi_xanh_app/features/settings/data/settings_repository.dart';
import 'package:vi_xanh_app/features/settings/presentation/account_screen.dart';
import 'package:vi_xanh_app/features/transactions/presentation/add_transaction_screen.dart';
import 'package:vi_xanh_app/features/transactions/presentation/transactions_screen.dart';
import 'package:vi_xanh_app/features/wallets/presentation/wallet_form_screen.dart';
import 'package:vi_xanh_app/features/wallets/presentation/wallets_screen.dart';
import 'package:vi_xanh_app/native/bank_notification_channel.dart';
import 'package:vi_xanh_app/services/app_info_service.dart';
import 'package:vi_xanh_app/services/auth_service.dart';
import 'package:vi_xanh_app/services/backup_service.dart';
import 'package:vi_xanh_app/services/bank_listener_service.dart';
import 'package:vi_xanh_app/services/key_value_store.dart';
import 'package:vi_xanh_app/services/notification_service.dart';
import 'package:vi_xanh_app/services/share_service.dart';
import 'package:vi_xanh_app/services/sync_service.dart';
import 'package:vi_xanh_app/theme/widgets/amount_keypad.dart';
import 'package:vi_xanh_app/theme/widgets/app_bottom_bar.dart';

/// Bảng chia sẻ thật của hệ điều hành chờ người bấm → test chỉ ghi lại file được chia sẻ.
final class _RecordingShareService implements ShareService {
  final shared = <File>[];

  @override
  Future<Result<bool>> shareFile(File file, {String? subject}) async {
    shared.add(file);
    return const Ok(true);
  }
}

/// Luồng chính của MVP trên thiết bị thật, như một lần cài mới: onboarding → ví thứ hai →
/// 3 giao dịch → Tổng quan → xóa + hoàn tác → Báo cáo → Sao lưu.
///
/// Dùng DB và kho cài đặt TRONG RAM để không đụng dữ liệu thật trên máy, nhưng mọi plugin
/// khác là thật (path_provider + VACUUM INTO của sao lưu, package_info, intl).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const nbsp = ' ';

  testWidgets('MVP: cài mới → onboarding → ví → chi/thu/chuyển → tổng → xóa/hoàn tác → '
      'báo cáo → sao lưu', (tester) async {
    await Future.wait([initializeDateFormatting('vi'), initializeDateFormatting('en')]);
    final db = AppDatabase(NativeDatabase.memory(setup: registerSqlFunctions));
    addTearDown(db.close);
    final store = InMemoryKeyValueStore({'locale': 'vi'});
    final settings = SettingsRepository(store)..load();
    final share = _RecordingShareService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          keyValueStoreProvider.overrideWithValue(store),
          settingsRepositoryProvider.overrideWithValue(settings),
          notificationServiceProvider.overrideWithValue(const NoopNotificationService()),
          backupServiceProvider.overrideWithValue(FileBackupService(db)),
          bankListenerServiceProvider.overrideWithValue(
            NativeBankListenerService(const BankNotificationChannel()),
          ),
          authServiceProvider.overrideWithValue(const GuestAuthService()),
          syncServiceProvider.overrideWithValue(const DisabledSyncService()),
          shareServiceProvider.overrideWithValue(share),
          appInfoServiceProvider.overrideWithValue(const PackageAppInfoService()),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> tapText(String text) async {
      final finder = find.text(text).last;
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    Future<void> typeInto(Finder field, String text) async {
      await tester.enterText(field, text);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    }

    Finder tab(String label) =>
        find.descendant(of: find.byType(AppBottomBar), matching: find.text(label));

    Future<void> goTab(String label) async {
      await tester.tap(tab(label));
      await tester.pumpAndSettle();
    }

    Finder key(String label) =>
        find.descendant(of: find.byType(AmountKeypad), matching: find.text(label));

    Future<void> typeKeys(List<String> labels) async {
      for (final label in labels) {
        await tester.tap(key(label));
        await tester.pump();
      }
    }

    Future<void> openAdd() async {
      await tester.tap(find.byTooltip('Thêm giao dịch'));
      await tester.pumpAndSettle();
      expect(find.byType(AddTransactionScreen), findsOneWidget);
    }

    Future<void> save() async {
      await tester.tap(key('Lưu'));
      await tester.pumpAndSettle();
      expect(find.byType(AddTransactionScreen), findsNothing, reason: 'Lưu xong thì đóng màn');
    }

    // 1. Onboarding + thiết lập: tên, ví tiền mặt 1.000.000.
    await tapText('Bỏ qua');
    await tapText('Bắt đầu');
    await typeInto(find.byType(TextField), 'Minh');
    await tapText('Tiếp tục');
    await tapText('Tiền mặt');
    await typeInto(find.byType(TextField).first, '1000000');
    await tapText('Tiếp tục');
    expect(find.byType(HomeScreen), findsOneWidget);

    // 2. Ví thứ hai (ngân hàng 5.000.000) qua Tài khoản → Ví của tôi → Thêm ví.
    await goTab('Tài khoản');
    await tapText('Ví của tôi');
    expect(find.byType(WalletsScreen), findsOneWidget);
    await tapText('Thêm ví');
    expect(find.byType(WalletFormScreen), findsOneWidget);
    await tester.tap(find.text('Ngân hàng'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '5000000');
    await typeInto(find.byType(TextField).at(2), '1234');
    await tapText('Lưu');
    expect(find.text('•••• 1234'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await goTab('Tổng quan');

    // 3. Ba giao dịch: chi 45.000 Ăn uống, thu 2.000.000 Lương, chuyển 500.000.
    await openAdd();
    await typeKeys(['4', '5', '000']);
    await tapText('Ăn uống');
    await save();

    await openAdd();
    await tapText('Thu nhập');
    await typeKeys(['2', '000', '000']);
    await tapText('Lương');
    await save();

    await openAdd();
    await tapText('Chuyển khoản');
    await typeKeys(['5', '0', '0', '000']);
    await save();

    // 4. Tổng quan: tổng số dư không đổi khi chuyển khoản; thu/chi tháng này.
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('7.955.000$nbsp₫'), findsWidgets, reason: '1tr + 5tr − 45k + 2tr');
    expect(find.textContaining('2.000.000'), findsWidgets);
    expect(find.textContaining('45.000'), findsWidgets);

    // 5. Giao dịch: vuốt xóa khoản chi → biến mất → Hoàn tác → hiện lại.
    await goTab('Giao dịch');
    expect(find.byType(TransactionsScreen), findsOneWidget);
    final expenseRow = find.text('Ăn uống').first;
    // Kéo có thời lượng như ngón tay thật (drag tức thời không mở được dòng trên máy thật).
    await tester.timedDrag(expenseRow, const Offset(-240, 0), const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    // Dòng nào cũng có nút Xóa nằm dưới nội dung; chỉ nút của dòng vừa vuốt là chạm được.
    await tester.tap(find.text('Xóa').hitTestable());
    await tester.pumpAndSettle();
    expect(find.text('Đã xóa giao dịch'), findsOneWidget);
    expect(find.text('Ăn uống'), findsNothing);
    await tester.tap(find.text('Hoàn tác'));
    await tester.pumpAndSettle();
    expect(find.text('Ăn uống'), findsWidgets);

    // 6. Báo cáo: tổng chi tháng này = 45.000 (bỏ chuyển khoản).
    await goTab('Báo cáo');
    expect(find.byType(ReportsScreen), findsOneWidget);
    expect(find.text('Tổng chi'), findsOneWidget);
    expect(find.textContaining('45.000'), findsWidgets);

    // 7. Tài khoản → Sao lưu: file .sqlite thật được tạo và chuyển cho bảng chia sẻ.
    await goTab('Tài khoản');
    expect(find.byType(AccountScreen), findsOneWidget);
    // Lần trước đã cuộn xuống tới "Ví của tôi": cuộn về đầu để thấy thẻ hồ sơ.
    await tester.fling(find.byType(ListView).first, const Offset(0, 2000), 3000);
    await tester.pumpAndSettle();
    expect(find.text('Chưa sao lưu'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Sao lưu'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tapText('Sao lưu');
    await tester.pumpAndSettle();
    expect(find.text('Đã tạo bản sao lưu'), findsOneWidget);
    await tester.fling(find.byType(ListView).first, const Offset(0, 2000), 3000);
    await tester.pumpAndSettle();
    expect(find.textContaining('Đã sao lưu lúc'), findsOneWidget);
    expect(share.shared, hasLength(1));
    final file = share.shared.single;
    expect(file.existsSync(), isTrue);
    expect(file.lengthSync(), greaterThan(0));
    expect(file.path, endsWith('.sqlite'));
    addTearDown(() {
      if (file.existsSync()) file.deleteSync();
    });
  });
}
