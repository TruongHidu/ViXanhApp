import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/key_value_store.dart';

/// Nhớ thời điểm sao lưu thành công gần nhất (để hiện "Đã sao lưu …" và nhắc sao lưu).
final class BackupStatusStore {
  BackupStatusStore(this._store);

  static const kLastBackupAt = 'last_backup_at';

  /// Key cần có trong allowList của shared_preferences.
  static const keys = {kLastBackupAt};

  final KeyValueStore _store;

  DateTime? read() => switch (_store.getInt(kLastBackupAt)) {
    final ms? when ms > 0 => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true),
    _ => null,
  };

  Future<void> write(DateTime at) =>
      _store.setInt(kLastBackupAt, at.toUtc().millisecondsSinceEpoch);
}

final backupStatusStoreProvider = Provider<BackupStatusStore>(
  (ref) => BackupStatusStore(ref.watch(keyValueStoreProvider)),
);
