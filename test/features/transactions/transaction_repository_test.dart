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

import '../../helpers.dart';

void main() {
  late AppDatabase db;
  late TransactionRepository repo;
  late WalletId cash;
  late WalletId bank;
  final now = DateTime.utc(2026, 11, 20, 8, 15);

  CategoryId cat(String key) => CategoryId(stableUuid('category:$key'));

  setUp(() async {
    db = inMemoryDatabase(clock: FixedClock(now));
    repo = TransactionRepository(db);
    final wallets = WalletRepository(db);
    cash = (await wallets.create(name: 'Tiền mặt', type: WalletType.cash)).valueOrNull!;
    bank = (await wallets.create(name: 'VCB', type: WalletType.bank)).valueOrNull!;
  });
  tearDown(() => db.close());

  TransactionDraft draft({
    TransactionType type = TransactionType.expense,
    int amount = 45000,
    WalletId? wallet,
    WalletId? to,
    CategoryId? category,
    DateTime? at,
    String? note,
  }) => TransactionDraft(
    type: type,
    amount: amount,
    walletId: wallet ?? cash,
    toWalletId: to,
    categoryId: category,
    occurredAt: at ?? now,
    note: note,
  );

  String? codeOf(Result<Object?> r) => switch (r) {
    Err(:final failure) when failure is ValidationFailure => failure.code,
    _ => null,
  };

  group('add', () {
    test('khoản chi hợp lệ được lưu và trừ vào số dư', () async {
      final result = await repo.add(draft(category: cat('an_uong'), note: '  Cà phê  '));
      final row = (await db.transactionsDao.findById(result.valueOrNull!))!;
      expect(row.amount, 45000);
      expect(row.note, 'Cà phê');
      expect((await db.walletsDao.watchBalances().first)[cash], -45000);
    });

    test('ghi chú chỉ có khoảng trắng → null', () async {
      final id = (await repo.add(draft(category: cat('an_uong'), note: '   '))).valueOrNull!;
      expect((await db.transactionsDao.findById(id))!.note, isNull);
    });

    test('số tiền 0 hoặc âm → amount_invalid', () async {
      expect(codeOf(await repo.add(draft(amount: 0, category: cat('an_uong')))), 'amount_invalid');
      expect(codeOf(await repo.add(draft(amount: -1, category: cat('an_uong')))), 'amount_invalid');
    });

    test('thu/chi thiếu danh mục → category_required', () async {
      expect(codeOf(await repo.add(draft())), 'category_required');
    });

    test('danh mục khác loại → category_invalid', () async {
      expect(codeOf(await repo.add(draft(category: cat('luong')))), 'category_invalid');
      expect(
        codeOf(await repo.add(draft(type: TransactionType.income, category: cat('an_uong')))),
        'category_invalid',
      );
    });

    test('danh mục đã xóa → category_invalid', () async {
      await db.categoriesDao.softDelete(cat('giai_tri'));
      expect(codeOf(await repo.add(draft(category: cat('giai_tri')))), 'category_invalid');
    });

    test('thu/chi có ví đến → transfer_wallets', () async {
      expect(codeOf(await repo.add(draft(category: cat('an_uong'), to: bank))), 'transfer_wallets');
    });

    test('ví không tồn tại hoặc đã lưu trữ → wallet_invalid', () async {
      expect(
        codeOf(await repo.add(draft(wallet: const WalletId('x'), category: cat('an_uong')))),
        'wallet_invalid',
      );
      await db.walletsDao.archive(bank);
      expect(
        codeOf(await repo.add(draft(wallet: bank, category: cat('an_uong')))),
        'wallet_invalid',
      );
    });

    test('chuyển khoản: thiếu ví đến, trùng ví, có danh mục → lỗi', () async {
      const t = TransactionType.transfer;
      expect(codeOf(await repo.add(draft(type: t))), 'transfer_wallets');
      expect(codeOf(await repo.add(draft(type: t, to: cash))), 'transfer_wallets');
      expect(
        codeOf(await repo.add(draft(type: t, to: bank, category: cat('an_uong')))),
        'category_invalid',
      );
    });

    test('chuyển khoản hợp lệ chuyển số dư giữa hai ví', () async {
      await repo.add(draft(type: TransactionType.transfer, amount: 100000, to: bank));
      final balances = await db.walletsDao.watchBalances().first;
      expect(balances[cash], -100000);
      expect(balances[bank], 100000);
    });

    test('ghi chú quá dài → text_too_long', () async {
      expect(
        codeOf(await repo.add(draft(category: cat('an_uong'), note: 'a' * 501))),
        'text_too_long',
      );
    });
  });

  group('update + findDraft', () {
    test('sửa số tiền và đổi sang thu nhập', () async {
      final id = (await repo.add(draft(category: cat('an_uong')))).valueOrNull!;
      final loaded = (await repo.findDraft(id)).valueOrNull!;
      expect(loaded.amount, 45000);

      final result = await repo.update(
        id,
        draft(type: TransactionType.income, amount: 500000, category: cat('luong')),
      );
      expect(result.isOk, isTrue);
      expect((await db.walletsDao.watchBalances().first)[cash], 500000);
    });

    test('sửa với dữ liệu sai → lỗi và không đổi gì', () async {
      final id = (await repo.add(draft(category: cat('an_uong')))).valueOrNull!;
      expect(
        codeOf(await repo.update(id, draft(amount: 0, category: cat('an_uong')))),
        'amount_invalid',
      );
      expect((await db.transactionsDao.findById(id))!.amount, 45000);
    });

    test('giao dịch không tồn tại hoặc đã xóa → not_found', () async {
      expect(codeOf(await repo.findDraft(const TransactionId('x'))), 'not_found');
      final id = (await repo.add(draft(category: cat('an_uong')))).valueOrNull!;
      await db.transactionsDao.softDelete(id);
      expect(codeOf(await repo.findDraft(id)), 'not_found');
      expect(
        codeOf(await repo.update(const TransactionId('x'), draft(category: cat('an_uong')))),
        'not_found',
      );
    });
  });

  group('recentCategories', () {
    test('chưa có giao dịch → danh mục gốc theo thứ tự mặc định', () async {
      final result = (await repo.recentCategories(CategoryType.income, limit: 3)).valueOrNull!;
      expect(result.map((c) => c.systemKey), ['luong', 'thuong', 'ban_hang']);
    });

    test('dùng gần nhất lên trước, không trùng, bù bằng danh mục gốc', () async {
      await repo.add(draft(category: cat('di_chuyen'), at: now.subtract(const Duration(days: 2))));
      await repo.add(draft(category: cat('ca_phe'), at: now.subtract(const Duration(days: 1))));
      await repo.add(draft(category: cat('di_chuyen'), at: now));
      final result = (await repo.recentCategories(CategoryType.expense, limit: 4)).valueOrNull!;
      expect(result.map((c) => c.systemKey), ['di_chuyen', 'ca_phe', 'an_uong', 'nha_cua']);
    });

    test('bỏ danh mục đã xóa và giao dịch đã xóa', () async {
      final id = (await repo.add(draft(category: cat('giai_tri')))).valueOrNull!;
      await repo.add(draft(category: cat('suc_khoe')));
      await db.transactionsDao.softDelete(id);
      await db.categoriesDao.softDelete(cat('suc_khoe'));
      final result = (await repo.recentCategories(CategoryType.expense, limit: 2)).valueOrNull!;
      expect(result.map((c) => c.systemKey), ['an_uong', 'di_chuyen']);
    });
  });

  test('lỗi DB → DatabaseFailure', () async {
    await breakWalletTables(db);
    final result = await repo.add(draft(category: cat('an_uong')));
    expect((result as Err<TransactionId>).failure, isA<DatabaseFailure>());
  });

  test('payee được lưu khi có', () async {
    final id = (await repo.add(
      TransactionDraft(
        type: TransactionType.expense,
        amount: 1000,
        walletId: cash,
        categoryId: cat('an_uong'),
        occurredAt: now,
        payee: 'Highlands Coffee',
      ),
    )).valueOrNull!;
    expect((await db.transactionsDao.findById(id))!.payee, 'Highlands Coffee');
  });
}
