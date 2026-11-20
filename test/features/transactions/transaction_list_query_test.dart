import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/clock.dart';
import 'package:vi_xanh_app/core/enums.dart';
import 'package:vi_xanh_app/core/financial_month.dart';
import 'package:vi_xanh_app/core/ids.dart';
import 'package:vi_xanh_app/data/database.dart';
import 'package:vi_xanh_app/features/transactions/data/transaction_repository.dart';
import 'package:vi_xanh_app/features/transactions/domain/transaction_draft.dart';
import 'package:vi_xanh_app/features/transactions/domain/transaction_list_item.dart';
import 'package:vi_xanh_app/features/wallets/data/wallet_repository.dart';

import '../../helpers.dart';

void main() {
  late AppDatabase db;
  late TransactionRepository repo;
  late WalletId cash;
  late WalletId momo;
  final november = DateRange(DateTime(2026, 11), DateTime(2026, 12));

  CategoryId cat(String key) => CategoryId(stableUuid('category:$key'));

  Future<TransactionId> add(
    TransactionType type,
    int amount,
    DateTime at, {
    WalletId? wallet,
    WalletId? to,
    String? category,
    String? note,
    String? payee,
  }) async => (await repo.add(
    TransactionDraft(
      type: type,
      amount: amount,
      walletId: wallet ?? cash,
      toWalletId: to,
      categoryId: category == null ? null : cat(category),
      occurredAt: at,
      note: note,
      payee: payee,
    ),
  )).valueOrNull!;

  setUp(() async {
    db = inMemoryDatabase(clock: FixedClock(DateTime.utc(2026, 11, 20)));
    repo = TransactionRepository(db);
    final wallets = WalletRepository(db);
    cash = (await wallets.create(name: 'Tiền mặt', type: WalletType.cash)).valueOrNull!;
    momo = (await wallets.create(name: 'MoMo', type: WalletType.ewallet)).valueOrNull!;

    await add(
      TransactionType.expense,
      45000,
      DateTime(2026, 11, 18, 8, 15),
      category: 'ca_phe',
      note: 'Cà phê sáng với Lan',
      payee: 'Highlands Coffee',
    );
    await add(
      TransactionType.expense,
      62000,
      DateTime(2026, 11, 18, 7, 50),
      wallet: momo,
      category: 'di_chuyen',
      note: 'Grab đi làm',
    );
    await add(
      TransactionType.income,
      18500000,
      DateTime(2026, 11, 17, 9),
      category: 'luong',
      note: 'Lương tháng 11',
    );
    await add(TransactionType.transfer, 500000, DateTime(2026, 11, 15, 9, 40), to: momo);
    // Ngoài kỳ.
    await add(TransactionType.expense, 99000, DateTime(2026, 10, 31, 23, 59), category: 'an_uong');
  });
  tearDown(() => db.close());

  Future<List<TransactionListItem>> list(TransactionQuery q) => repo.watchList(q).first;

  test('lọc theo kỳ, mới nhất trước, kèm tên ví và danh mục', () async {
    final items = await list(TransactionQuery(range: november));
    expect(items.map((i) => i.amount), [45000, 62000, 18500000, 500000]);
    final first = items.first;
    expect(first.walletName, 'Tiền mặt');
    expect(first.categoryName, 'Cà phê');
    expect(first.payee, 'Highlands Coffee');
    final transfer = items.last;
    expect(transfer.toWalletName, 'MoMo');
    expect(transfer.categoryName, isNull);
  });

  test('lọc theo loại', () async {
    final items = await list(TransactionQuery(range: november, type: TransactionType.income));
    expect(items.single.amount, 18500000);
  });

  test('lọc theo ví gồm cả chuyển khoản đến ví đó', () async {
    final items = await list(TransactionQuery(range: november, walletId: momo));
    expect(items.map((i) => i.amount), [62000, 500000]);
  });

  test('lọc theo danh mục cha gồm cả danh mục con', () async {
    final items = await list(TransactionQuery(range: november, categoryId: cat('an_uong')));
    expect(items.single.categoryName, 'Cà phê');
  });

  test('tìm kiếm không phân biệt dấu và hoa thường, trong ghi chú / tên / danh mục', () async {
    Future<List<int>> find(String s) async =>
        (await list(TransactionQuery(range: november, search: s))).map((i) => i.amount).toList();
    expect(await find('ca phe'), [45000]);
    expect(await find('CÀ PHÊ'), [45000]);
    expect(await find('highlands'), [45000]);
    expect(await find('lương'), [18500000]);
    expect(await find('di chuyen'), [62000]);
    expect(await find('không có'), isEmpty);
  });

  test('giao dịch đã xóa không hiện; khôi phục thì hiện lại', () async {
    final items = await list(TransactionQuery(range: november));
    final id = items.first.id;
    expect((await repo.softDelete(id)).isOk, isTrue);
    expect((await list(TransactionQuery(range: november))).map((i) => i.id), isNot(contains(id)));
    expect(await repo.watchItem(id).first, isNull);
    expect((await repo.restore(id)).isOk, isTrue);
    expect((await list(TransactionQuery(range: november))).first.id, id);
  });

  test('xóa giao dịch không tồn tại → Err', () async {
    expect((await repo.softDelete(const TransactionId('x'))).isOk, isFalse);
  });

  test('tổng kỳ bỏ chuyển khoản và giao dịch ngoài kỳ', () async {
    final totals = await repo.watchTotals(november).first;
    expect(totals, const PeriodTotals(income: 18500000, expense: 107000));
    expect(totals.remaining, 18500000 - 107000);
  });

  test('watchItem trả đủ thông tin cho màn chi tiết', () async {
    final id = (await list(TransactionQuery(range: november))).first.id;
    final item = (await repo.watchItem(id).first)!;
    expect(item.note, 'Cà phê sáng với Lan');
    expect(item.source, TransactionSource.manual);
  });
}
