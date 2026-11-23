import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core_providers.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../services/backup_service.dart';
import '../../../services/share_service.dart';
import '../../transactions/data/transaction_repository.dart';
import '../data/backup_status_store.dart';

/// Số giao dịch tối thiểu trước khi bắt đầu nhắc sao lưu.
const kBackupReminderMinTransactions = 20;

/// Quá khoảng này kể từ lần sao lưu gần nhất thì nhắc.
const kBackupReminderMaxAge = Duration(days: 7);

/// Trạng thái sao lưu: thời điểm sao lưu gần nhất (UTC) và có đang chạy không.
final class BackupState {
  const BackupState({this.lastBackupAt, this.running = false});

  final DateTime? lastBackupAt;
  final bool running;
}

final backupProvider = NotifierProvider<BackupNotifier, BackupState>(BackupNotifier.new);

/// Xuất file sao lưu (VACUUM INTO) → ghi `last_backup_at` theo Clock → mở bảng chia sẻ
/// để người dùng lưu file ra Drive/Zalo/máy.
final class BackupNotifier extends Notifier<BackupState> {
  @override
  BackupState build() => BackupState(lastBackupAt: ref.read(backupStatusStoreProvider).read());

  /// `Ok(true)`: đã xuất và chia sẻ. `Ok(false)`: đang chạy dở, hoặc người dùng đóng bảng
  /// chia sẻ (file vẫn nằm trong máy nên vẫn tính là đã sao lưu). `Err`: xuất thất bại,
  /// `last_backup_at` giữ nguyên.
  Future<Result<bool>> backupNow() async {
    if (state.running) return const Ok(false);
    final previous = state.lastBackupAt;
    state = BackupState(lastBackupAt: previous, running: true);

    final exported = await ref.read(backupServiceProvider).exportBackup();
    if (!ref.mounted) return const Ok(false);
    switch (exported) {
      case Err(:final failure):
        state = BackupState(lastBackupAt: previous);
        return Err(failure);
      case Ok(value: final file):
        final now = ref.read(clockProvider).now().toUtc();
        try {
          await ref.read(backupStatusStoreProvider).write(now);
        } catch (e) {
          if (ref.mounted) state = BackupState(lastBackupAt: previous);
          return Err(UnexpectedFailure('Không ghi được thời điểm sao lưu', cause: e));
        }
        if (!ref.mounted) return const Ok(false);
        state = BackupState(lastBackupAt: now, running: true);
        final shared = await ref.read(shareServiceProvider).shareFile(file, subject: 'Ví Xanh');
        if (ref.mounted) state = BackupState(lastBackupAt: now);
        return shared;
    }
  }
}

/// Số giao dịch chưa xóa.
final transactionCountProvider = StreamProvider.autoDispose<int>(
  (ref) => ref.watch(transactionRepositoryProvider).watchCount(),
);

/// Có nên hiện dòng nhắc sao lưu: ≥ [kBackupReminderMinTransactions] giao dịch và chưa sao
/// lưu lần nào hoặc lần gần nhất đã quá [kBackupReminderMaxAge].
final backupReminderProvider = Provider.autoDispose<bool>((ref) {
  final count = ref.watch(transactionCountProvider).value ?? 0;
  if (count < kBackupReminderMinTransactions) return false;
  final last = ref.watch(backupProvider.select((s) => s.lastBackupAt));
  if (last == null) return true;
  return ref.watch(clockProvider).now().difference(last) > kBackupReminderMaxAge;
});
