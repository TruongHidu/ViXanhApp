import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../database.dart';
import '../tables/tables.dart';

part 'wallets_dao.g.dart';

@DriftAccessor(tables: [Wallets, Transactions])
class WalletsDao extends DatabaseAccessor<AppDatabase> with _$WalletsDaoMixin {
  WalletsDao(super.attachedDatabase);

  /// Ví chưa lưu trữ, chưa xóa, theo `sort_order`.
  Stream<List<WalletRow>> watchActive() =>
      (select(wallets)
            ..where((w) => w.archived.equals(false) & w.deletedAt.isNull())
            ..orderBy([(w) => OrderingTerm.asc(w.sortOrder), (w) => OrderingTerm.asc(w.name)]))
          .watch();

  Future<WalletRow?> findById(WalletId id) => (select(
    wallets,
  )..where((w) => w.id.equalsValue(id) & w.deletedAt.isNull())).getSingleOrNull();

  /// Tự sinh `id` (nếu thiếu) và `created_at`/`updated_at`.
  Future<WalletId> insertWallet(WalletsCompanion entry) async {
    final now = attachedDatabase.clock.now();
    final id = entry.id.present ? entry.id.value : WalletId(attachedDatabase.ids.newId());
    await into(
      wallets,
    ).insert(entry.copyWith(id: Value(id), createdAt: Value(now), updatedAt: Value(now)));
    return id;
  }

  /// Trả `false` nếu không có ví (chưa xóa) nào khớp [id].
  Future<bool> updateWallet(WalletId id, WalletsCompanion patch) async {
    final count = await (update(wallets)..where((w) => w.id.equalsValue(id) & w.deletedAt.isNull()))
        .write(
          patch.copyWith(id: const Value.absent(), updatedAt: Value(attachedDatabase.clock.now())),
        );
    return count > 0;
  }

  Future<bool> archive(WalletId id) =>
      updateWallet(id, const WalletsCompanion(archived: Value(true)));

  /// Số dư hiện tại của mọi ví chưa xóa, tính lại từ giao dịch mỗi lần đọc:
  /// `initial_balance + thu − chi − chuyển đi + chuyển đến` (bỏ qua giao dịch đã xóa mềm).
  Stream<Map<WalletId, int>> watchBalances() =>
      customSelect(
        '''
        SELECT w.id AS id,
          w.initial_balance
          + COALESCE((
              SELECT SUM(CASE t.type WHEN 'income' THEN t.amount ELSE -t.amount END)
              FROM transactions t
              WHERE t.wallet_id = w.id AND t.deleted_at IS NULL
            ), 0)
          + COALESCE((
              SELECT SUM(t.amount)
              FROM transactions t
              WHERE t.to_wallet_id = w.id AND t.type = 'transfer' AND t.deleted_at IS NULL
            ), 0) AS balance
        FROM wallets w
        WHERE w.deleted_at IS NULL
        ''',
        readsFrom: {wallets, transactions},
      ).watch().map(
        (rows) => {for (final r in rows) WalletId(r.read<String>('id')): r.read<int>('balance')},
      );
}
