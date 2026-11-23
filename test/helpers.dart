import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:vi_xanh_app/app.dart';
import 'package:vi_xanh_app/core/clock.dart';
import 'package:vi_xanh_app/core/core_providers.dart';
import 'package:vi_xanh_app/core/ids.dart';
import 'package:vi_xanh_app/data/database.dart';
import 'package:vi_xanh_app/data/sql_functions.dart';
import 'package:vi_xanh_app/features/settings/data/settings_repository.dart';
import 'package:vi_xanh_app/services/app_info_service.dart';
import 'package:vi_xanh_app/services/auth_service.dart';
import 'package:vi_xanh_app/services/backup_service.dart';
import 'package:vi_xanh_app/services/bank_listener_service.dart';
import 'package:vi_xanh_app/services/key_value_store.dart';
import 'package:vi_xanh_app/services/notification_service.dart';
import 'package:vi_xanh_app/services/share_service.dart';
import 'package:vi_xanh_app/services/sync_service.dart';

import 'fakes/fakes.dart';

AppDatabase inMemoryDatabase({Clock? clock, IdGenerator? ids}) => AppDatabase(
  DatabaseConnection(
    NativeDatabase.memory(setup: registerSqlFunctions),
    closeStreamsSynchronously: true,
  ),
  clock: clock ?? const SystemClock(),
  ids: ids ?? const UuidIdGenerator(),
);

/// Cùng seam DI với bootstrap(): override ĐỦ mọi provider hạ tầng bằng fake/noop,
/// để test không bao giờ chạm platform channel hay file thật.
List<Override> testOverrides({
  required AppDatabase db,
  KeyValueStore? store,
  Clock? clock,
  BackupService? backup,
  ShareService? share,
}) {
  final kv = store ?? FakeKeyValueStore();
  final settings = SettingsRepository(kv)..load();
  return [
    appDatabaseProvider.overrideWithValue(db),
    if (clock != null) clockProvider.overrideWithValue(clock),
    keyValueStoreProvider.overrideWithValue(kv),
    settingsRepositoryProvider.overrideWithValue(settings),
    notificationServiceProvider.overrideWithValue(const NoopNotificationService()),
    backupServiceProvider.overrideWithValue(backup ?? FakeBackupService()),
    bankListenerServiceProvider.overrideWithValue(FakeBankListenerService()),
    authServiceProvider.overrideWithValue(const GuestAuthService()),
    syncServiceProvider.overrideWithValue(const DisabledSyncService()),
    shareServiceProvider.overrideWithValue(share ?? FakeShareService()),
    appInfoServiceProvider.overrideWithValue(const FakeAppInfoService()),
  ];
}

Widget buildTestApp(
  AppDatabase db, {
  KeyValueStore? store,
  Clock? clock,
  BackupService? backup,
  ShareService? share,
}) => ProviderScope(
  overrides: testOverrides(db: db, store: store, clock: clock, backup: backup, share: share),
  child: const App(),
);

/// Giả lập DB hỏng: xóa bảng giao dịch và ví (tắt khóa ngoại để xóa được), mọi lệnh ghi ví
/// sau đó ném SqliteException. Không dùng `db.close()`: drift tự mở lại DB in-memory mới.
Future<void> breakWalletTables(AppDatabase db) async {
  await db.customStatement('PRAGMA foreign_keys = OFF');
  await db.customStatement('DROP TABLE transactions');
  await db.customStatement('DROP TABLE wallets');
}

/// Cho các truy vấn DB thật (drift) chạy xong rồi dựng lại khung hình.
/// testWidgets chạy trong thời gian giả nên I/O của DB cần `runAsync` mới hoàn tất.
Future<void> settleDb(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}
