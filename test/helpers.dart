import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:vi_xanh_app/app.dart';
import 'package:vi_xanh_app/core/clock.dart';
import 'package:vi_xanh_app/core/ids.dart';
import 'package:vi_xanh_app/data/database.dart';
import 'package:vi_xanh_app/features/settings/data/settings_repository.dart';
import 'package:vi_xanh_app/services/auth_service.dart';
import 'package:vi_xanh_app/services/backup_service.dart';
import 'package:vi_xanh_app/services/bank_listener_service.dart';
import 'package:vi_xanh_app/services/key_value_store.dart';
import 'package:vi_xanh_app/services/notification_service.dart';
import 'package:vi_xanh_app/services/sync_service.dart';

import 'fakes/fakes.dart';

AppDatabase inMemoryDatabase({Clock? clock, IdGenerator? ids}) => AppDatabase(
  NativeDatabase.memory(),
  clock: clock ?? const SystemClock(),
  ids: ids ?? const UuidIdGenerator(),
);

/// Cùng seam DI với bootstrap(): override ĐỦ mọi provider hạ tầng bằng fake/noop,
/// để test không bao giờ chạm platform channel hay file thật.
List<Override> testOverrides({required AppDatabase db, KeyValueStore? store}) {
  final kv = store ?? FakeKeyValueStore();
  final settings = SettingsRepository(kv)..load();
  return [
    appDatabaseProvider.overrideWithValue(db),
    keyValueStoreProvider.overrideWithValue(kv),
    settingsRepositoryProvider.overrideWithValue(settings),
    notificationServiceProvider.overrideWithValue(const NoopNotificationService()),
    backupServiceProvider.overrideWithValue(FakeBackupService()),
    bankListenerServiceProvider.overrideWithValue(FakeBankListenerService()),
    authServiceProvider.overrideWithValue(const GuestAuthService()),
    syncServiceProvider.overrideWithValue(const DisabledSyncService()),
  ];
}

Widget buildTestApp(AppDatabase db, {KeyValueStore? store}) => ProviderScope(
  overrides: testOverrides(db: db, store: store),
  child: const App(),
);
