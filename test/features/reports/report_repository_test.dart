import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/enums.dart';
import 'package:vi_xanh_app/core/financial_month.dart';
import 'package:vi_xanh_app/core/ids.dart';
import 'package:vi_xanh_app/data/database.dart';
import 'package:vi_xanh_app/features/reports/data/report_repository.dart';
import 'package:vi_xanh_app/features/transactions/data/transaction_repository.dart';
import 'package:vi_xanh_app/features/transactions/domain/transaction_draft.dart';
import 'package:vi_xanh_app/features/transactions/domain/transaction_list_item.dart';
import 'package:vi_xanh_app/features/wallets/data/wallet_repository.dart';

import '../../helpers.dart';

void main() {
  late AppDatabase db;
  late ReportRepository reports;
  late TransactionRepository txns;
  late WalletId cash;
  late WalletId momo;
  final november = DateRange(DateTime(2026, 11), DateTime(2026, 12));

  CategoryId cat(String key) => CategoryId(stableUuid('category:$key'));

  Future<TransactionId> add(
    TransactionType type,
    int amount,
    DateTime at, {
    String? category,
    WalletId? to,
  }) async => (await txns.add(
    TransactionDraft(
      type: type,
      amount: amount,
      walletId: cash,
      toWalletId: to,
      categoryId: category == null ? null : cat(category),
      occurredAt: at,
    ),
  )).valueOrNull!;

  setUp(() async {
    db = inMemoryDatabase();
    reports = ReportRepository(db);
    txns = TransactionRepository(db);
    final wallets = WalletRepository(db);
    cash = (await wallets.create(name: 'Tiền mặt', type: WalletType.cash)).valueOrNull!;
    momo = (await wallets.create(name: 'MoMo', type: WalletType.ewallet)).valueOrNull!;
  });
  tearDown(() => db.close());

  test(
    'tổng theo danh mục chính: gộp mục con, bỏ chuyển khoản / khoản thu / đã xóa / ngoài kỳ',
    () async {
      await add(TransactionType.expense, 45000, DateTime(2026, 11, 18), category: 'ca_phe');
      await add(TransactionType.expense, 300000, DateTime(2026, 11, 10), category: 'di_cho');
      await add(TransactionType.expense, 55000, DateTime(2026, 11, 9), category: 'an_uong');
      await add(TransactionType.expense, 780000, DateTime(2026, 11, 17), category: 'dien');
      await add(TransactionType.income, 18500000, DateTime(2026, 11, 2), category: 'luong');
      await add(TransactionType.transfer, 500000, DateTime(2026, 11, 5), to: momo);
      final deleted = await add(
        TransactionType.expense,
        999,
        DateTime(2026, 11, 3),
        category: 'mua_sam',
      );
      await txns.softDelete(deleted);
      await add(TransactionType.expense, 1, DateTime(2026, 10, 31, 23), category: 'giai_tri');

      final totals = await reports.watchByCategory(november, TransactionType.expense).first;
      expect(totals.map((t) => (t.name, t.amount)), [('Hóa đơn', 780000), ('Ăn uống', 400000)]);
      expect(totals.first.categoryId, cat('hoa_don'));

      final income = await reports.watchByCategory(november, TransactionType.income).first;
      expect(income.single.amount, 18500000);
    },
  );

  test('watchSeries: đúng kỳ, kỳ trống = 0, chuyển khoản không tính', () async {
    await add(TransactionType.expense, 100000, DateTime(2026, 10, 15), category: 'an_uong');
    await add(TransactionType.income, 5000000, DateTime(2026, 11, 2), category: 'luong');
    await add(TransactionType.expense, 45000, DateTime(2026, 11, 30, 23, 59), category: 'an_uong');
    await add(TransactionType.transfer, 700000, DateTime(2026, 11, 3), to: momo);

    final ranges = [
      DateRange(DateTime(2026, 9), DateTime(2026, 10)),
      DateRange(DateTime(2026, 10), DateTime(2026, 11)),
      november,
    ];
    final series = await reports.watchSeries(ranges).first;
    expect(series, [
      PeriodTotals.zero,
      const PeriodTotals(income: 0, expense: 100000),
      const PeriodTotals(income: 5000000, expense: 45000),
    ]);
  });
}
