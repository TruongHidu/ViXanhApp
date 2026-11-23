import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/clock.dart';
import 'package:vi_xanh_app/core/core_providers.dart';
import 'package:vi_xanh_app/core/enums.dart';
import 'package:vi_xanh_app/core/failure.dart';
import 'package:vi_xanh_app/core/ids.dart';
import 'package:vi_xanh_app/core/result.dart';
import 'package:vi_xanh_app/data/database.dart';
import 'package:vi_xanh_app/features/backup/data/backup_status_store.dart';
import 'package:vi_xanh_app/features/backup/presentation/backup_notifier.dart';
import 'package:vi_xanh_app/features/transactions/data/transaction_repository.dart';
import 'package:vi_xanh_app/features/transactions/domain/transaction_draft.dart';
import 'package:vi_xanh_app/features/wallets/data/wallet_repository.dart';

import '../../fakes/fakes.dart';
import '../../helpers.dart';

void main() {
  final now = DateTime.utc(2026, 11, 20, 2);
  late AppDatabase db;
  late FakeKeyValueStore store;
  late FakeBackupService backup;
  late FakeShareService share;

  ProviderContainer container({Clock? clock}) {
    final c = ProviderContainer(
      overrides: [
        ...testOverrides(db: db, store: store, backup: backup, share: share),
        clockProvider.overrideWithValue(clock ?? FixedClock(now)),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    db = inMemoryDatabase();
    store = FakeKeyValueStore();
    backup = FakeBackupService(result: Ok(File('vi_xanh_backup_1.sqlite')));
    share = FakeShareService();
  });
  tearDown(() => db.close());

  test('thành công → chia sẻ file và lưu last_backup_at = Clock.now()', () async {
    final c = container();
    expect(c.read(backupProvider).lastBackupAt, isNull);

    final result = await c.read(backupProvider.notifier).backupNow();

    expect(result, const Ok(true));
    expect(backup.exports, 1);
    expect(share.shared, ['vi_xanh_backup_1.sqlite']);
    expect(store.getInt(BackupStatusStore.kLastBackupAt), now.millisecondsSinceEpoch);
    expect(c.read(backupProvider).lastBackupAt, now);
    expect(c.read(backupProvider).running, isFalse);
  });

  test('đóng bảng chia sẻ → vẫn tính đã sao lưu (file đã nằm trong máy)', () async {
    share.result = const Ok(false);
    final c = container();
    final result = await c.read(backupProvider.notifier).backupNow();
    expect(result, const Ok(false));
    expect(store.getInt(BackupStatusStore.kLastBackupAt), now.millisecondsSinceEpoch);
  });

  test('xuất thất bại → không chia sẻ, last_backup_at giữ nguyên', () async {
    final earlier = DateTime.utc(2026, 11, 1);
    store = FakeKeyValueStore({BackupStatusStore.kLastBackupAt: earlier.millisecondsSinceEpoch});
    backup.result = const Err(DatabaseFailure('disk full'));
    final c = container();

    final result = await c.read(backupProvider.notifier).backupNow();

    expect(result.isOk, isFalse);
    expect(share.shared, isEmpty);
    expect(store.getInt(BackupStatusStore.kLastBackupAt), earlier.millisecondsSinceEpoch);
    expect(c.read(backupProvider).lastBackupAt, earlier);
    expect(c.read(backupProvider).running, isFalse);
  });

  test('ghi last_backup_at lỗi → Err, trạng thái không đổi', () async {
    store.failWrites = true;
    final c = container();
    final result = await c.read(backupProvider.notifier).backupNow();
    expect(result.isOk, isFalse);
    expect(c.read(backupProvider).lastBackupAt, isNull);
    expect(share.shared, isEmpty);
  });

  group('nhắc sao lưu', () {
    Future<void> seed(int count) async {
      final wallet = (await WalletRepository(
        db,
      ).create(name: 'Tiền mặt', type: WalletType.cash)).valueOrNull!;
      final txns = TransactionRepository(db);
      for (var i = 0; i < count; i++) {
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
    }

    Future<bool> remind(ProviderContainer c) async {
      final sub = c.listen(backupReminderProvider, (_, _) {});
      addTearDown(sub.close);
      expect(await c.read(transactionCountProvider.future), greaterThan(0));
      return c.read(backupReminderProvider);
    }

    test('< 20 giao dịch → không nhắc', () async {
      await seed(19);
      expect(await remind(container()), isFalse);
    });

    test('≥ 20 giao dịch, chưa sao lưu lần nào → nhắc', () async {
      await seed(20);
      expect(await remind(container()), isTrue);
    });

    test('sao lưu 7 ngày trước → chưa nhắc; quá 7 ngày → nhắc', () async {
      await seed(20);
      store = FakeKeyValueStore({
        BackupStatusStore.kLastBackupAt: now
            .subtract(const Duration(days: 7))
            .millisecondsSinceEpoch,
      });
      expect(await remind(container()), isFalse);
      expect(
        await remind(container(clock: FixedClock(now.add(const Duration(minutes: 1))))),
        isTrue,
      );
    });
  });
}
