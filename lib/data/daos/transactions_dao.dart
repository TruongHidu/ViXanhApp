import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../database.dart';
import '../tables/tables.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<AppDatabase> with _$TransactionsDaoMixin {
  TransactionsDao(super.attachedDatabase);

  static List<OrderingTerm Function($TransactionsTable)> get _newestFirst => [
    (t) => OrderingTerm.desc(t.occurredAt),
    (t) => OrderingTerm.desc(t.createdAt),
  ];

  Stream<List<TransactionRow>> watchRecent({int limit = 50}) =>
      (select(transactions)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy(_newestFirst)
            ..limit(limit))
          .watch();

  /// Giao dịch có `occurred_at` trong `[from, to)`, mới nhất trước.
  Stream<List<TransactionRow>> watchInRange(DateTime from, DateTime to) =>
      (select(transactions)
            ..where(
              (t) =>
                  t.deletedAt.isNull() &
                  t.occurredAt.isBiggerOrEqualValue(from.toUtc().millisecondsSinceEpoch) &
                  t.occurredAt.isSmallerThanValue(to.toUtc().millisecondsSinceEpoch),
            )
            ..orderBy(_newestFirst))
          .watch();

  Future<TransactionRow?> findById(TransactionId id) =>
      (select(transactions)..where((t) => t.id.equalsValue(id))).getSingleOrNull();

  /// Tự sinh `id` (nếu thiếu) và `created_at`/`updated_at`.
  Future<TransactionId> insertTransaction(TransactionsCompanion entry) async {
    final now = attachedDatabase.clock.now();
    final id = entry.id.present ? entry.id.value : TransactionId(attachedDatabase.ids.newId());
    await into(
      transactions,
    ).insert(entry.copyWith(id: Value(id), createdAt: Value(now), updatedAt: Value(now)));
    return id;
  }

  Future<bool> updateTransaction(TransactionId id, TransactionsCompanion patch) => _write(
    id,
    patch.copyWith(id: const Value.absent(), deletedAt: const Value.absent()),
    onlyLive: true,
  );

  Future<bool> softDelete(TransactionId id) => _write(
    id,
    TransactionsCompanion(deletedAt: Value(attachedDatabase.clock.now())),
    onlyLive: true,
  );

  /// Hoàn tác xóa mềm (nút "Hoàn tác").
  Future<bool> restore(TransactionId id) =>
      _write(id, const TransactionsCompanion(deletedAt: Value(null)), onlyLive: false);

  Future<bool> _write(
    TransactionId id,
    TransactionsCompanion patch, {
    required bool onlyLive,
  }) async {
    final count =
        await (update(transactions)..where(
              (t) => onlyLive ? t.id.equalsValue(id) & t.deletedAt.isNull() : t.id.equalsValue(id),
            ))
            .write(patch.copyWith(updatedAt: Value(attachedDatabase.clock.now())));
    return count > 0;
  }
}
