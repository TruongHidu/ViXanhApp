import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vi_xanh_app/app.dart';
import 'package:vi_xanh_app/core/clock.dart';
import 'package:vi_xanh_app/core/enums.dart';
import 'package:vi_xanh_app/data/database.dart';
import 'package:vi_xanh_app/data/sql_functions.dart';
import 'package:vi_xanh_app/debug/demo_seed.dart';
import 'package:vi_xanh_app/features/settings/data/settings_repository.dart';
import 'package:vi_xanh_app/features/transactions/presentation/transactions_screen.dart';
import 'package:vi_xanh_app/features/wallets/data/wallet_repository.dart';
import 'package:vi_xanh_app/services/app_info_service.dart';
import 'package:vi_xanh_app/services/auth_service.dart';
import 'package:vi_xanh_app/services/backup_service.dart';
import 'package:vi_xanh_app/services/bank_listener_service.dart';
import 'package:vi_xanh_app/services/key_value_store.dart';
import 'package:vi_xanh_app/services/notification_service.dart';
import 'package:vi_xanh_app/services/share_service.dart';
import 'package:vi_xanh_app/services/sync_service.dart';
import 'package:vi_xanh_app/native/bank_notification_channel.dart';
import 'package:vi_xanh_app/theme/widgets/app_bottom_bar.dart';

/// 10.000 giao dịch giả → cuộn danh sách Giao dịch, đo thời gian dựng khung hình.
/// Ý nghĩa ở profile mode (xem test_driver/perf_driver.dart); chạy debug chỉ kiểm tra không lỗi.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('10.000 giao dịch: mở tab Giao dịch và cuộn', (tester) async {
    await Future.wait([initializeDateFormatting('vi'), initializeDateFormatting('en')]);
    final db = AppDatabase(NativeDatabase.memory(setup: registerSqlFunctions));
    addTearDown(db.close);
    final wallet = (await WalletRepository(
      db,
    ).create(name: 'Tiền mặt', type: WalletType.cash, initialBalance: 50000000)).valueOrNull!;
    final seedWatch = Stopwatch()..start();
    await seedDemoTransactions(db, walletId: wallet, clock: const SystemClock());
    seedWatch.stop();

    final store = InMemoryKeyValueStore({'locale': 'vi', 'onboarding_completed': true});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          keyValueStoreProvider.overrideWithValue(store),
          settingsRepositoryProvider.overrideWithValue(SettingsRepository(store)..load()),
          notificationServiceProvider.overrideWithValue(const NoopNotificationService()),
          backupServiceProvider.overrideWithValue(FileBackupService(db)),
          bankListenerServiceProvider.overrideWithValue(
            NativeBankListenerService(const BankNotificationChannel()),
          ),
          authServiceProvider.overrideWithValue(const GuestAuthService()),
          syncServiceProvider.overrideWithValue(const DisabledSyncService()),
          shareServiceProvider.overrideWithValue(const SharePlusShareService()),
          appInfoServiceProvider.overrideWithValue(const PackageAppInfoService()),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    final openWatch = Stopwatch()..start();
    await tester.tap(
      find.descendant(of: find.byType(AppBottomBar), matching: find.text('Giao dịch')),
    );
    await tester.pumpAndSettle();
    openWatch.stop();
    expect(find.byType(TransactionsScreen), findsOneWidget);

    final list = find.byType(CustomScrollView).first;
    await binding.watchPerformance(() async {
      for (var i = 0; i < 10; i++) {
        await tester.fling(list, const Offset(0, -1500), 4000);
        await tester.pumpAndSettle();
      }
      for (var i = 0; i < 5; i++) {
        await tester.fling(list, const Offset(0, 1500), 4000);
        await tester.pumpAndSettle();
      }
    }, reportKey: 'transactions_scroll');

    binding.reportData = {
      ...?binding.reportData,
      'seed_10k_ms': seedWatch.elapsedMilliseconds,
      'open_transactions_tab_ms': openWatch.elapsedMilliseconds,
    };
    expect(tester.takeException(), isNull);
  });
}
