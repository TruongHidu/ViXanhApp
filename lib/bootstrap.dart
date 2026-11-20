import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/database.dart';
import 'features/settings/data/settings_repository.dart';
import 'native/bank_notification_channel.dart';
import 'services/auth_service.dart';
import 'services/backup_service.dart';
import 'services/bank_listener_service.dart';
import 'services/crash_log.dart';
import 'services/key_value_store.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';

/// Composition root — nơi DUY NHẤT gọi tên các implementation cụ thể.
/// Thứ tự: bắt lỗi toàn cục → đọc cài đặt → mở DB → ProviderScope overrides → runApp
/// → warm-up DB sau khung hình đầu.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Lưới bắt lỗi TRƯỚC mọi thứ có thể ném.
  final log = await CrashLog.open();
  installErrorHandlers(log);

  // 2. Đọc theme/locale để khung hình đầu tiên đúng giao diện.
  final store = await _openKeyValueStore(log);
  final settings = SettingsRepository(store)..load();

  // 2b. Dữ liệu ngày tháng của intl ("Thứ Hai", "Monday") cho mọi ngôn ngữ app hỗ trợ.
  await Future.wait([initializeDateFormatting('vi'), initializeDateFormatting('en')]);

  // 3. Mở DB. drift mở lười — file thật được mở ở lần truy vấn đầu tiên (warm-up bên dưới).
  final db = openAppDatabase();

  // 4. Gắn implementation thật vào các placeholder provider.
  runApp(
    ProviderScope(
      // Lỗi cục bộ (DB hỏng...) là bug thật — fail ngay, không retry ~38s.
      retry: (retryCount, error) => null,
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
      ],
      child: const App(),
    ),
  );

  // 5. Sau khung hình đầu: chạm DB một lần để mở file và chạy onCreate/seed sớm,
  // không chặn khởi động.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(
      db
          .customSelect('SELECT 1')
          .get()
          .then<void>((_) {})
          .catchError((Object e, StackTrace s) => log.record('Warm-up DB thất bại: $e', s)),
    );
  });
}

/// Không mở được shared_preferences → ghi log và chạy tiếp với kho trong RAM
/// (cài đặt mặc định, không lưu được) thay vì treo app.
Future<KeyValueStore> _openKeyValueStore(CrashLog log) async {
  try {
    return await SharedPrefsKeyValueStore.create(allowList: SettingsRepository.keys);
  } catch (e, s) {
    log.record('Không mở được shared_preferences: $e', s);
    return InMemoryKeyValueStore();
  }
}

/// Đúng HAI handler, không dùng runZonedGuarded.
void installErrorHandlers(CrashLog log) {
  FlutterError.onError = (details) {
    try {
      FlutterError.presentError(details);
      log.record(details.exceptionAsString(), details.stack);
    } catch (_) {
      // Handler lỗi không được phép ném — đừng "sửa" thành đệ quy.
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    try {
      final cause = error is ProviderException ? error.exception : error;
      log.record(cause.toString(), stack);
      if (kDebugMode) debugPrint('$cause\n$stack');
    } catch (_) {
      // Handler lỗi không được phép ném — đừng "sửa" thành đệ quy.
    }
    return true; // LUÔN true: false sẽ chuyển cho embedder, có thể kill tiến trình.
  };
}
