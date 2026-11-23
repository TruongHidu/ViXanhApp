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
import 'package:vi_xanh_app/features/wallets/data/wallet_repository.dart';
import 'package:vi_xanh_app/native/bank_notification_channel.dart';
import 'package:vi_xanh_app/services/app_info_service.dart';
import 'package:vi_xanh_app/services/auth_service.dart';
import 'package:vi_xanh_app/services/backup_service.dart';
import 'package:vi_xanh_app/services/bank_listener_service.dart';
import 'package:vi_xanh_app/services/key_value_store.dart';
import 'package:vi_xanh_app/services/notification_service.dart';
import 'package:vi_xanh_app/services/share_service.dart';
import 'package:vi_xanh_app/services/sync_service.dart';
import 'package:vi_xanh_app/theme/widgets/app_bottom_bar.dart';

/// Đi qua các màn chính ở 4 biến thể (sáng/tối, vi/en, chữ 2x) và in mốc `VX_SHOT <tên>`.
/// Máy chủ theo dõi log và chụp màn hình bằng `adb exec-out screencap` khi thấy mốc
/// (xem docs/screenshots/mvp/README.md). Bản thân test không chụp gì.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const variants = [
    (name: 'light-vi', theme: 'light', locale: 'vi', scale: 1.0),
    (name: 'dark-vi', theme: 'dark', locale: 'vi', scale: 1.0),
    (name: 'light-en', theme: 'light', locale: 'en', scale: 1.0),
    (name: 'large-vi', theme: 'light', locale: 'vi', scale: 2.0),
  ];

  testWidgets('chụp màn hình MVP', (tester) async {
    await Future.wait([initializeDateFormatting('vi'), initializeDateFormatting('en')]);

    for (final v in variants) {
      tester.platformDispatcher.textScaleFactorTestValue = v.scale;
      final db = AppDatabase(NativeDatabase.memory(setup: registerSqlFunctions));
      final wallets = WalletRepository(db);
      final cash = (await wallets.create(
        name: v.locale == 'vi' ? 'Tiền mặt' : 'Cash',
        type: WalletType.cash,
        initialBalance: 3200000,
      )).valueOrNull!;
      await wallets.create(
        name: 'Vietcombank',
        type: WalletType.bank,
        initialBalance: 18500000,
        accountLast4: '4321',
      );
      await seedDemoTransactions(
        db,
        walletId: cash,
        clock: const SystemClock(),
        count: 60,
        seed: 7,
        span: const Duration(days: 28),
      );
      final store = InMemoryKeyValueStore({
        'locale': v.locale,
        'onboarding_completed': true,
        SettingsRepository.kThemeMode: v.theme,
        SettingsRepository.kUserName: 'Minh',
      });

      await tester.pumpWidget(
        ProviderScope(
          key: ValueKey(v.name),
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

      Future<void> shot(String screen) async {
        await tester.pumpAndSettle();
        debugPrint('VX_SHOT ${v.name}-$screen');
        await Future<void>.delayed(const Duration(seconds: 4));
      }

      final tabs = find.descendant(of: find.byType(AppBottomBar), matching: find.byType(InkWell));
      Future<void> goTab(int i) async {
        await tester.tap(tabs.at(i));
        await tester.pumpAndSettle();
      }

      await shot('1-overview');
      await goTab(1);
      await shot('2-transactions');
      await goTab(2);
      await shot('3-reports');
      await goTab(3);
      await shot('4-account');

      await tester.tap(find.byType(AppAddButton));
      await tester.pumpAndSettle();
      await shot('5-add');
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();

      Future<void> tapIcon(IconData icon) async {
        final f = find.byIcon(icon).first;
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      await tapIcon(Icons.account_balance_wallet_outlined);
      await shot('6-wallets');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      await tapIcon(Icons.grid_view_rounded);
      await shot('7-categories');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox());
      await db.close();
    }
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}
