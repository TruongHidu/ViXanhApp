import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/clock.dart';
import 'package:vi_xanh_app/core/enums.dart';
import 'package:vi_xanh_app/core/financial_month.dart';
import 'package:vi_xanh_app/core/ids.dart';
import 'package:vi_xanh_app/data/database.dart';
import 'package:vi_xanh_app/features/transactions/data/transaction_repository.dart';
import 'package:vi_xanh_app/features/transactions/domain/transaction_draft.dart';
import 'package:vi_xanh_app/features/wallets/data/wallet_repository.dart';

import '../../helpers.dart';

void main() {
  late AppDatabase db;
  late WalletRepository wallets;
  late TransactionRepository txns;
  late WalletId cash;

  CategoryId cat(String key) => CategoryId(stableUuid('category:$key'));

  Future<TransactionId> add(
    TransactionType type,
    int amount,
    DateTime at, {
    WalletId? wallet,
    WalletId? to,
  }) async => (await txns.add(
    TransactionDraft(
      type: type,
      amount: amount,
      walletId: wallet ?? cash,
      toWalletId: to,
      categoryId: switch (type) {
        TransactionType.expense => cat('an_uong'),
        TransactionType.income => cat('luong'),
        TransactionType.transfer => null,
      },
      occurredAt: at,
    ),
  )).valueOrNull!;

  setUp(() async {
    db = inMemoryDatabase(clock: FixedClock(DateTime(2026, 11, 18, 10)));
    wallets = WalletRepository(db);
    txns = TransactionRepository(db);
    cash = (await wallets.create(
      name: 'Tiền mặt',
      type: WalletType.cash,
      initialBalance: 1000000,
    )).valueOrNull!;
  });
  tearDown(() => db.close());

  group('tổng số dư', () {
    test('cộng các ví đang dùng, thẻ tín dụng nợ làm giảm tổng, ví lưu trữ không tính', () async {
      await wallets.create(name: 'Thẻ', type: WalletType.credit, initialBalance: -300000);
      final saving = (await wallets.create(
        name: 'Tiết kiệm',
        type: WalletType.bank,
        initialBalance: 5000000,
      )).valueOrNull!;
      await add(TransactionType.expense, 200000, DateTime(2026, 11, 18));
      expect(await wallets.watchTotalBalance().first, 1000000 - 300000 + 5000000 - 200000);

      await db.walletsDao.archive(saving);
      expect(await wallets.watchTotalBalance().first, 1000000 - 300000 - 200000);
    });

    test('chuyển khoản giữa hai ví không đổi tổng', () async {
      final momo = (await wallets.create(name: 'MoMo', type: WalletType.ewallet)).valueOrNull!;
      await add(TransactionType.transfer, 400000, DateTime(2026, 11, 18), to: momo);
      expect(await wallets.watchTotalBalance().first, 1000000);
    });

    test('chưa có ví → 0', () async {
      await db.walletsDao.archive(cash);
      expect(await wallets.watchTotalBalance().first, 0);
    });
  });

  group('chi theo ngày', () {
    final week = DateRange(DateTime(2026, 11, 12), DateTime(2026, 11, 19));

    test('gộp theo ngày địa phương, chỉ tính khoản chi chưa xóa trong khoảng', () async {
      await add(TransactionType.expense, 45000, DateTime(2026, 11, 18, 8));
      await add(TransactionType.expense, 5000, DateTime(2026, 11, 18, 23, 59));
      await add(TransactionType.expense, 62000, DateTime(2026, 11, 17, 0, 1));
      await add(TransactionType.income, 999, DateTime(2026, 11, 17, 9));
      final momo = (await wallets.create(name: 'MoMo', type: WalletType.ewallet)).valueOrNull!;
      await add(TransactionType.transfer, 777, DateTime(2026, 11, 16), to: momo);
      final deleted = await add(TransactionType.expense, 123, DateTime(2026, 11, 15));
      await txns.softDelete(deleted);
      await add(TransactionType.expense, 1, DateTime(2026, 11, 11, 23)); // ngoài khoảng
      await add(TransactionType.expense, 1, DateTime(2026, 11, 19)); // ngoài khoảng

      expect(await txns.watchDailyExpense(week).first, {
        DateTime(2026, 11, 18): 50000,
        DateTime(2026, 11, 17): 62000,
      });
    });
  });

  test('giao dịch gần đây: mới nhất trước, đúng giới hạn, bỏ đã xóa', () async {
    for (var i = 1; i <= 7; i++) {
      await add(TransactionType.expense, i * 1000, DateTime(2026, 11, i));
    }
    final latest = (await txns.watchRecent(limit: 5).first).first;
    await txns.softDelete(latest.id);
    final recent = await txns.watchRecent(limit: 5).first;
    expect(recent.map((t) => t.amount), [6000, 5000, 4000, 3000, 2000]);
  });
}
