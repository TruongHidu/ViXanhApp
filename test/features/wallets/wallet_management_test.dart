import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/clock.dart';
import 'package:vi_xanh_app/core/enums.dart';
import 'package:vi_xanh_app/core/failure.dart';
import 'package:vi_xanh_app/core/ids.dart';
import 'package:vi_xanh_app/core/result.dart';
import 'package:vi_xanh_app/data/database.dart';
import 'package:vi_xanh_app/features/transactions/data/transaction_repository.dart';
import 'package:vi_xanh_app/features/transactions/domain/transaction_draft.dart';
import 'package:vi_xanh_app/features/wallets/data/wallet_repository.dart';
import 'package:vi_xanh_app/features/wallets/domain/wallet_summary.dart';

import '../../helpers.dart';

void main() {
  late AppDatabase db;
  late WalletRepository repo;
  late TransactionRepository txns;
  late WalletId cash;
  final today = DateTime(2026, 11, 18, 10);

  CategoryId cat(String key) => CategoryId(stableUuid('category:$key'));

  String? codeOf(Result<Object?> r) => switch (r) {
    Err(:final failure) => failure.code,
    _ => null,
  };

  Future<void> add(
    TransactionType type,
    int amount,
    DateTime at, {
    WalletId? wallet,
    WalletId? to,
  }) => txns.add(
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
  );

  setUp(() async {
    db = inMemoryDatabase(clock: FixedClock(today));
    repo = WalletRepository(db);
    txns = TransactionRepository(db);
    cash = (await repo.create(
      name: 'Tiền mặt',
      type: WalletType.cash,
      initialBalance: 1000000,
    )).valueOrNull!;
  });
  tearDown(() => db.close());

  group('tạo / sửa', () {
    test('số tài khoản lưu dạng "•••• 1234" và đọc lại được', () async {
      final id = (await repo.create(
        name: 'VCB',
        type: WalletType.bank,
        accountLast4: '1234',
      )).valueOrNull!;
      final row = (await repo.watchWallet(id).first)!;
      expect(row.accountMasked, '•••• 1234');
      expect(WalletRepository.unmaskAccount(row.accountMasked), '1234');
    });

    test('số tài khoản không đúng 4 chữ số → wallet_account_invalid', () async {
      expect(
        codeOf(await repo.create(name: 'VCB', type: WalletType.bank, accountLast4: '12a')),
        WalletErrors.accountInvalid,
      );
      expect(
        codeOf(await repo.create(name: 'VCB', type: WalletType.bank, accountLast4: '12345')),
        WalletErrors.accountInvalid,
      );
    });

    test('sửa tên, loại, số dư ban đầu → số dư tính lại; bỏ số tài khoản', () async {
      await add(TransactionType.expense, 200000, today);
      final result = await repo.update(
        cash,
        name: '  Ví chính ',
        type: WalletType.ewallet,
        initialBalance: 500000,
      );
      expect(result.isOk, isTrue);
      final row = (await repo.watchWallet(cash).first)!;
      expect(row.name, 'Ví chính');
      expect(row.type, WalletType.ewallet);
      expect(row.accountMasked, isNull);
      expect((await repo.watchBalances().first)[cash], 300000);
    });

    test('sửa ví không tồn tại → not found; tên rỗng → name invalid', () async {
      expect(
        codeOf(
          await repo.update(
            const WalletId('x'),
            name: 'A',
            type: WalletType.cash,
            initialBalance: 0,
          ),
        ),
        WalletErrors.notFound,
      );
      expect(
        codeOf(await repo.update(cash, name: ' ', type: WalletType.cash, initialBalance: 0)),
        WalletErrors.nameInvalid,
      );
    });
  });

  group('lưu trữ', () {
    test('lưu trữ ví cuối cùng → wallet_last, ví vẫn dùng được', () async {
      final result = await repo.archive(cash);
      expect(codeOf(result), WalletErrors.lastWallet);
      expect((await repo.watchActive().first).single.id, cash);
    });

    test('có ví khác thì lưu trữ được; ví ẩn khỏi danh sách, giao dịch cũ còn', () async {
      final momo = (await repo.create(name: 'MoMo', type: WalletType.ewallet)).valueOrNull!;
      await add(TransactionType.expense, 1000, today, wallet: momo);
      expect((await repo.archive(momo)).isOk, isTrue);
      expect((await repo.watchActive().first).map((w) => w.id), [cash]);
      expect(await txns.watchRecent(walletId: momo).first, hasLength(1));
      expect((await repo.watchWallet(momo).first)!.archived, isTrue);
    });

    test('lưu trữ ví không tồn tại → not found', () async {
      expect((await repo.archive(const WalletId('x'))).isOk, isFalse);
      expect(
        (await repo.archive(const WalletId('x')) as Err<void>).failure,
        isA<NotFoundFailure>(),
      );
    });
  });

  group('lịch sử số dư 30 ngày', () {
    test('30 điểm; ngày không có giao dịch giữ số dư hôm trước; tính số dư đầu kỳ', () async {
      final momo = (await repo.create(name: 'MoMo', type: WalletType.ewallet)).valueOrNull!;
      // Trước kỳ (kỳ bắt đầu 20/10).
      await add(TransactionType.income, 500000, DateTime(2026, 10, 1));
      // Trong kỳ.
      await add(TransactionType.expense, 100000, DateTime(2026, 10, 25, 12));
      await add(TransactionType.transfer, 200000, DateTime(2026, 11, 5, 9), to: momo);
      await add(TransactionType.transfer, 50000, DateTime(2026, 11, 10, 9), wallet: momo, to: cash);
      await add(TransactionType.expense, 999, DateTime(2026, 11, 19)); // sau hôm nay
      final history = await repo.watchBalanceHistory(cash, today: today).first;

      expect(history, hasLength(30));
      expect(history.first.day, DateTime(2026, 10, 20));
      expect(history.last.day, DateTime(2026, 11, 18));
      int at(int month, int day) =>
          history.firstWhere((p) => p.day == DateTime(2026, month, day)).balance;
      expect(at(10, 20), 1500000, reason: 'số dư ban đầu + thu trước kỳ');
      expect(at(10, 24), 1500000);
      expect(at(10, 25), 1400000);
      expect(at(11, 4), 1400000);
      expect(at(11, 5), 1200000, reason: 'chuyển đi');
      expect(at(11, 10), 1250000, reason: 'nhận chuyển đến');
      expect(at(11, 18), 1250000);
    });

    test('giao dịch đã xóa không tính', () async {
      await add(TransactionType.expense, 300000, DateTime(2026, 11, 1));
      final id = (await txns.watchRecent().first).single.id;
      await txns.softDelete(id);
      final history = await repo.watchBalanceHistory(cash, today: today).first;
      expect(history.every((p) => p.balance == 1000000), isTrue);
    });
  });

  test('WalletSummary: tài sản, nợ, tài sản ròng', () {
    final s = WalletSummary.fromBalances([1250000, 15830000, -2000000, 0]);
    expect(s.assets, 17080000);
    expect(s.debt, -2000000);
    expect(s.netWorth, 15080000);
  });
}
