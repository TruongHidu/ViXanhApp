import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/clock.dart';
import 'package:vi_xanh_app/core/enums.dart';
import 'package:vi_xanh_app/core/ids.dart';
import 'package:vi_xanh_app/data/daos/categories_dao.dart';
import 'package:vi_xanh_app/data/database.dart';
import 'package:vi_xanh_app/data/seed/default_categories.dart';

import '../helpers.dart';

/// Đồng hồ chỉnh tay, có mili giây lẻ để kiểm tra độ chính xác khi lưu.
final class MutableClock implements Clock {
  MutableClock(this.current);
  DateTime current;
  @override
  DateTime now() => current;
}

void main() {
  late MutableClock clock;
  late AppDatabase db;

  setUp(() {
    clock = MutableClock(DateTime.utc(2026, 11, 20, 8, 30, 15, 123));
    db = inMemoryDatabase(clock: clock);
  });
  tearDown(() => db.close());

  CategoryId catId(String key) => CategoryId(stableUuid('category:$key'));

  Future<WalletId> addWallet(String name, {int initial = 0}) => db.walletsDao.insertWallet(
    WalletsCompanion(
      name: Value(name),
      type: const Value(WalletType.cash),
      initialBalance: Value(initial),
    ),
  );

  TransactionsCompanion tx(
    WalletId wallet,
    TransactionType type,
    int amount, {
    WalletId? to,
    CategoryId? category,
  }) => TransactionsCompanion(
    walletId: Value(wallet),
    toWalletId: Value(to),
    categoryId: Value(category),
    type: Value(type),
    amount: Value(amount),
    occurredAt: Value(clock.now()),
  );

  group('seed danh mục mặc định', () {
    test('đúng 14 danh mục gốc và 5 danh mục con', () async {
      final expense = await db.categoriesDao.watchByType(CategoryType.expense).first;
      final income = await db.categoriesDao.watchByType(CategoryType.income).first;
      expect(expense.length + income.length, 14);
      expect(income.map((n) => n.category.systemKey), [
        'luong',
        'thuong',
        'ban_hang',
        'lai_tiet_kiem',
        'khac_thu',
      ]);

      final anUong = expense.firstWhere((n) => n.category.systemKey == 'an_uong');
      expect(anUong.children.map((c) => c.systemKey), ['ca_phe', 'di_cho']);
      final hoaDon = expense.firstWhere((n) => n.category.systemKey == 'hoa_don');
      expect(hoaDon.children.map((c) => c.systemKey), ['dien', 'nuoc', 'internet']);

      final total = expense.fold(0, (s, n) => s + 1 + n.children.length) + income.length;
      expect(total, defaultCategories.length);
    });

    test('hai DB khác nhau có cùng id cho cùng danh mục (UUID v5 cố định)', () async {
      final other = inMemoryDatabase();
      addTearDown(other.close);
      Future<List<String>> ids(AppDatabase d) async =>
          (await d.select(d.categories).get()).map((c) => c.id.value).toList()..sort();
      expect(await ids(db), await ids(other));
      expect(await db.categoriesDao.findById(catId('an_uong')), isNotNull);
    });
  });

  group('ràng buộc CHECK', () {
    late WalletId a;
    late WalletId b;
    setUp(() async {
      a = await addWallet('A');
      b = await addWallet('B');
    });

    Matcher rejected() => throwsA(isA<SqliteException>());

    test('amount = 0 bị từ chối', () {
      expect(db.transactionsDao.insertTransaction(tx(a, TransactionType.expense, 0)), rejected());
    });

    test('amount âm bị từ chối', () {
      expect(db.transactionsDao.insertTransaction(tx(a, TransactionType.income, -5)), rejected());
    });

    test('chuyển khoản thiếu to_wallet_id bị từ chối', () {
      expect(
        db.transactionsDao.insertTransaction(tx(a, TransactionType.transfer, 100)),
        rejected(),
      );
    });

    test('thu/chi có to_wallet_id bị từ chối', () {
      expect(
        db.transactionsDao.insertTransaction(tx(a, TransactionType.expense, 100, to: b)),
        rejected(),
      );
    });

    test('chuyển khoản có category_id bị từ chối', () {
      expect(
        db.transactionsDao.insertTransaction(
          tx(a, TransactionType.transfer, 100, to: b, category: catId('khac_chi')),
        ),
        rejected(),
      );
    });

    test('chuyển khoản sang chính ví đó bị từ chối', () {
      expect(
        db.transactionsDao.insertTransaction(tx(a, TransactionType.transfer, 100, to: a)),
        rejected(),
      );
    });

    test('loại ví ngoài danh sách bị từ chối ở tầng SQL', () {
      expect(
        db.customStatement(
          'INSERT INTO wallets (id, name, type, created_at, updated_at) '
          "VALUES ('x', 'X', 'gold', 0, 0)",
        ),
        rejected(),
      );
    });
  });

  test('khóa ngoại đang bật: ví không tồn tại bị từ chối', () async {
    final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.read<int>('foreign_keys'), 1);
    expect(
      db.transactionsDao.insertTransaction(
        tx(const WalletId('khong-ton-tai'), TransactionType.expense, 100),
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  group('số dư ví', () {
    test(
      'initial + thu − chi − chuyển đi + chuyển đến; xóa mềm không tính, khôi phục thì tính',
      () async {
        final a = await addWallet('A', initial: 1000000);
        final b = await addWallet('B', initial: 50000);
        final dao = db.transactionsDao;
        await dao.insertTransaction(
          tx(a, TransactionType.income, 500000, category: catId('luong')),
        );
        final spend = await dao.insertTransaction(
          tx(a, TransactionType.expense, 200000, category: catId('an_uong')),
        );
        await dao.insertTransaction(tx(a, TransactionType.transfer, 100000, to: b));

        expect(await db.walletsDao.watchBalances().first, {a: 1200000, b: 150000});

        expect(await dao.softDelete(spend), isTrue);
        expect((await db.walletsDao.watchBalances().first)[a], 1400000);

        expect(await dao.restore(spend), isTrue);
        expect((await db.walletsDao.watchBalances().first)[a], 1200000);
      },
    );

    test('ví không có giao dịch có số dư = initial_balance', () async {
      final a = await addWallet('A', initial: -300000);
      expect(await db.walletsDao.watchBalances().first, {a: -300000});
    });
  });

  group('thời gian', () {
    test('lưu rồi đọc lại giữ mili giây và là UTC', () async {
      final a = await addWallet('A');
      final at = DateTime.utc(2026, 1, 2, 3, 4, 5, 678);
      final id = await db.transactionsDao.insertTransaction(
        TransactionsCompanion(
          walletId: Value(a),
          type: const Value(TransactionType.expense),
          amount: const Value(1000),
          occurredAt: Value(at.toLocal()),
        ),
      );
      final row = (await db.transactionsDao.findById(id))!;
      expect(row.occurredAt, at);
      expect(row.occurredAt.isUtc, isTrue);
      expect(row.createdAt, clock.current);
      expect(row.deletedAt, isNull);
    });

    test('updated_at lấy từ Clock khi sửa', () async {
      final a = await addWallet('A');
      clock.current = clock.current.add(const Duration(minutes: 5));
      await db.walletsDao.updateWallet(a, const WalletsCompanion(name: Value('Ví mới')));
      final row = (await db.walletsDao.findById(a))!;
      expect(row.name, 'Ví mới');
      expect(row.updatedAt, clock.current);
      expect(row.createdAt, isNot(row.updatedAt));
    });

    test('watchInRange lấy [from, to) và bỏ giao dịch đã xóa', () async {
      final a = await addWallet('A');
      Future<TransactionId> at(DateTime t) => db.transactionsDao.insertTransaction(
        TransactionsCompanion(
          walletId: Value(a),
          type: const Value(TransactionType.expense),
          amount: const Value(1),
          occurredAt: Value(t),
        ),
      );
      final from = DateTime.utc(2026, 11);
      final to = DateTime.utc(2026, 12);
      final inside = await at(from);
      await at(to); // biên trên bị loại
      final deleted = await at(DateTime.utc(2026, 11, 15));
      await db.transactionsDao.softDelete(deleted);
      final rows = await db.transactionsDao.watchInRange(from, to).first;
      expect(rows.map((r) => r.id), [inside]);
    });
  });

  group('cây danh mục', () {
    CategoriesCompanion child(String name, CategoryType type, CategoryId parent) =>
        CategoriesCompanion(
          name: Value(name),
          type: Value(type),
          icon: const Value('more_horiz'),
          color: const Value(0xFFB5B5B5),
          parentId: Value(parent),
        );

    Matcher invalid() => throwsA(isA<InvalidCategoryHierarchy>());

    test('tạo con hợp lệ', () async {
      final id = await db.categoriesDao.insertCategory(
        child('Trà sữa', CategoryType.expense, catId('an_uong')),
      );
      expect((await db.categoriesDao.findById(id))!.parentId, catId('an_uong'));
    });

    test('tạo cấp 3 (cháu) bị từ chối', () {
      expect(
        db.categoriesDao.insertCategory(child('Latte', CategoryType.expense, catId('ca_phe'))),
        invalid(),
      );
    });

    test('con khác loại với cha bị từ chối', () {
      expect(
        db.categoriesDao.insertCategory(child('Hoàn tiền', CategoryType.income, catId('an_uong'))),
        invalid(),
      );
    });

    test('danh mục đang có con không thể trở thành con', () {
      expect(
        db.categoriesDao.updateCategory(
          catId('an_uong'),
          CategoriesCompanion(parentId: Value(catId('mua_sam'))),
        ),
        invalid(),
      );
    });

    test('xóa mềm cha thì ẩn cả con', () async {
      expect(await db.categoriesDao.softDelete(catId('hoa_don')), isTrue);
      expect(await db.categoriesDao.findById(catId('dien')), isNull);
      final roots = await db.categoriesDao.watchByType(CategoryType.expense).first;
      expect(roots.map((n) => n.category.systemKey), isNot(contains('hoa_don')));
    });
  });
}
