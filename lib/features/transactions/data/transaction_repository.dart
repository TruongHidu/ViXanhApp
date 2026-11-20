import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/amount_parser.dart';
import '../../../core/enums.dart';
import '../../../core/failure.dart';
import '../../../core/financial_month.dart';
import '../../../core/ids.dart';
import '../../../core/result.dart';
import '../../../core/text_fold.dart';
import '../../../data/converters.dart';
import '../../../data/database.dart';
import '../../../data/sql_functions.dart';
import '../domain/transaction_draft.dart';
import '../domain/transaction_list_item.dart';

/// Đường ghi duy nhất cho giao dịch. Kiểm tra nghiệp vụ trước khi ghi; không ném exception.
final class TransactionRepository {
  TransactionRepository(this._db);

  final AppDatabase _db;

  static const maxPayeeLength = 120;
  static const maxNoteLength = 500;

  /// Kiểm tra và ghi trong cùng một transaction DB.
  Future<Result<TransactionId>> add(TransactionDraft draft) => _guard(
    () => _db.transaction(() async {
      await _validate(draft);
      return _db.transactionsDao.insertTransaction(_companion(draft));
    }),
  );

  Future<Result<void>> update(TransactionId id, TransactionDraft draft) => _guard(
    () => _db.transaction(() async {
      await _validate(draft);
      final updated = await _db.transactionsDao.updateTransaction(id, _companion(draft));
      if (!updated) throw const _Invalid(TransactionErrors.notFound, 'Không tìm thấy giao dịch');
    }),
  );

  /// Giao dịch (chưa xóa) dưới dạng draft, để mở màn sửa.
  Future<Result<TransactionDraft>> findDraft(TransactionId id) => _guard(() async {
    final row = await _db.transactionsDao.findById(id);
    if (row == null || row.deletedAt != null) {
      throw const _Invalid(TransactionErrors.notFound, 'Không tìm thấy giao dịch');
    }
    return TransactionDraft(
      type: row.type,
      amount: row.amount,
      walletId: row.walletId,
      toWalletId: row.toWalletId,
      categoryId: row.categoryId,
      occurredAt: row.occurredAt,
      payee: row.payee,
      note: row.note,
    );
  });

  /// Danh mục dùng gần đây cho [type] (mới nhất trước, không trùng, bỏ danh mục đã xóa),
  /// bù bằng danh mục gốc theo `sort_order` cho đủ [limit].
  Future<Result<List<CategoryRow>>> recentCategories(CategoryType type, {int limit = 6}) =>
      _guard(() async {
        final recent = await _db
            .customSelect(
              '''
              SELECT t.category_id AS id, MAX(t.occurred_at) AS last_used
              FROM transactions t
              JOIN categories c ON c.id = t.category_id
              WHERE t.deleted_at IS NULL AND c.deleted_at IS NULL AND c.type = ?
              GROUP BY t.category_id
              ORDER BY last_used DESC
              LIMIT ?
              ''',
              variables: [Variable.withString(type.name), Variable.withInt(limit)],
              readsFrom: {_db.transactions, _db.categories},
            )
            .get();
        final ids = [for (final r in recent) CategoryId(r.read<String>('id'))];
        final byId = {
          for (final c in await (_db.select(
            _db.categories,
          )..where((c) => c.type.equalsValue(type) & c.deletedAt.isNull())).get())
            c.id: c,
        };
        final result = [for (final id in ids) ?byId[id]];
        final roots = byId.values.where((c) => c.parentId == null).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        for (final root in roots) {
          if (result.length >= limit) break;
          if (!result.contains(root)) result.add(root);
        }
        return result;
      });

  static const _listColumns = '''
    t.id, t.type, t.amount, t.occurred_at, t.payee, t.note, t.source,
    t.wallet_id, w.name AS wallet_name, t.to_wallet_id, tw.name AS to_wallet_name,
    t.category_id, c.name AS category_name, c.icon AS category_icon, c.color AS category_color
  ''';

  static const _listJoins = '''
    FROM transactions t
    JOIN wallets w ON w.id = t.wallet_id
    LEFT JOIN wallets tw ON tw.id = t.to_wallet_id
    LEFT JOIN categories c ON c.id = t.category_id
  ''';

  /// Danh sách giao dịch theo [query], mới nhất trước; tự cập nhật khi DB đổi.
  /// Lọc hoàn toàn bằng SQL (kỳ, loại, ví, danh mục + con, tìm kiếm bỏ dấu).
  Stream<List<TransactionListItem>> watchList(TransactionQuery query) {
    final where = <String>['t.deleted_at IS NULL', 't.occurred_at >= ?', 't.occurred_at < ?'];
    final args = <Variable<Object>>[
      Variable.withInt(query.range.start.toUtc().millisecondsSinceEpoch),
      Variable.withInt(query.range.end.toUtc().millisecondsSinceEpoch),
    ];
    if (query.type case final type?) {
      where.add('t.type = ?');
      args.add(Variable.withString(type.name));
    }
    if (query.walletId case final wallet?) {
      where.add('(t.wallet_id = ? OR t.to_wallet_id = ?)');
      args
        ..add(Variable.withString(wallet.value))
        ..add(Variable.withString(wallet.value));
    }
    if (query.categoryId case final category?) {
      where.add('(t.category_id = ? OR c.parent_id = ?)');
      args
        ..add(Variable.withString(category.value))
        ..add(Variable.withString(category.value));
    }
    final term = foldVietnamese(query.search.trim());
    if (term.isNotEmpty) {
      where.add(
        "instr($foldFunctionName(coalesce(t.note, '') || ' ' || coalesce(t.payee, '') || ' ' "
        "|| coalesce(c.name, '')), ?) > 0",
      );
      args.add(Variable.withString(term));
    }
    return _db
        .customSelect(
          'SELECT $_listColumns $_listJoins WHERE ${where.join(' AND ')} '
          'ORDER BY t.occurred_at DESC, t.created_at DESC',
          variables: args,
          readsFrom: {_db.transactions, _db.wallets, _db.categories},
        )
        .watch()
        .map((rows) => rows.map(_toListItem).toList());
  }

  /// Một giao dịch (chưa xóa) cho màn chi tiết; `null` khi không còn.
  Stream<TransactionListItem?> watchItem(TransactionId id) => _db
      .customSelect(
        'SELECT $_listColumns $_listJoins WHERE t.id = ? AND t.deleted_at IS NULL',
        variables: [Variable.withString(id.value)],
        readsFrom: {_db.transactions, _db.wallets, _db.categories},
      )
      .watch()
      .map((rows) => rows.isEmpty ? null : _toListItem(rows.first));

  /// Tổng thu / chi trong [range] (bỏ chuyển khoản và giao dịch đã xóa).
  Stream<PeriodTotals> watchTotals(DateRange range) => _db
      .customSelect(
        '''
        SELECT
          COALESCE(SUM(CASE WHEN type = 'income' THEN amount END), 0) AS income,
          COALESCE(SUM(CASE WHEN type = 'expense' THEN amount END), 0) AS expense
        FROM transactions
        WHERE deleted_at IS NULL AND occurred_at >= ? AND occurred_at < ?
        ''',
        variables: [
          Variable.withInt(range.start.toUtc().millisecondsSinceEpoch),
          Variable.withInt(range.end.toUtc().millisecondsSinceEpoch),
        ],
        readsFrom: {_db.transactions},
      )
      .watch()
      .map(
        (rows) => PeriodTotals(
          income: rows.single.read<int>('income'),
          expense: rows.single.read<int>('expense'),
        ),
      );

  /// Xóa mềm (có thể [restore] — nút "Hoàn tác").
  Future<Result<void>> softDelete(TransactionId id) => _guard(() async {
    if (!await _db.transactionsDao.softDelete(id)) {
      throw const _Invalid(TransactionErrors.notFound, 'Không tìm thấy giao dịch');
    }
  });

  Future<Result<void>> restore(TransactionId id) => _guard(() async {
    if (!await _db.transactionsDao.restore(id)) {
      throw const _Invalid(TransactionErrors.notFound, 'Không tìm thấy giao dịch');
    }
  });

  static TransactionListItem _toListItem(QueryRow r) {
    const toUtc = EpochMsConverter();
    return TransactionListItem(
      id: TransactionId(r.read<String>('id')),
      type: TransactionType.values.byName(r.read<String>('type')),
      amount: r.read<int>('amount'),
      occurredAt: toUtc.fromSql(r.read<int>('occurred_at')),
      walletId: WalletId(r.read<String>('wallet_id')),
      walletName: r.read<String>('wallet_name'),
      toWalletId: r.readNullable<String>('to_wallet_id')?.let(WalletId.new),
      toWalletName: r.readNullable<String>('to_wallet_name'),
      categoryId: r.readNullable<String>('category_id')?.let(CategoryId.new),
      categoryName: r.readNullable<String>('category_name'),
      categoryIcon: r.readNullable<String>('category_icon'),
      categoryColor: r.readNullable<int>('category_color'),
      payee: r.readNullable<String>('payee'),
      note: r.readNullable<String>('note'),
      source: TransactionSource.values.byName(r.read<String>('source')),
    );
  }

  Future<void> _validate(TransactionDraft d) async {
    if (d.amount <= 0 || d.amount > maxAmount) {
      throw const _Invalid(TransactionErrors.amountInvalid, 'Số tiền phải lớn hơn 0');
    }
    if ((d.payee?.length ?? 0) > maxPayeeLength || (d.note?.length ?? 0) > maxNoteLength) {
      throw const _Invalid(TransactionErrors.textTooLong, 'Tên hoặc ghi chú quá dài');
    }
    await _requireUsableWallet(d.walletId);

    if (d.type == TransactionType.transfer) {
      final to = d.toWalletId;
      if (to == null || to == d.walletId) {
        throw const _Invalid(TransactionErrors.transferWallets, 'Cần hai ví khác nhau');
      }
      if (d.categoryId != null) {
        throw const _Invalid(TransactionErrors.categoryInvalid, 'Chuyển khoản không có danh mục');
      }
      await _requireUsableWallet(to);
      return;
    }

    if (d.toWalletId != null) {
      throw const _Invalid(TransactionErrors.transferWallets, 'Chỉ chuyển khoản mới có ví đến');
    }
    final categoryId = d.categoryId;
    if (categoryId == null) {
      throw const _Invalid(TransactionErrors.categoryRequired, 'Chưa chọn danh mục');
    }
    final category = await _db.categoriesDao.findById(categoryId);
    final expected = d.type == TransactionType.income ? CategoryType.income : CategoryType.expense;
    if (category == null || category.type != expected) {
      throw const _Invalid(TransactionErrors.categoryInvalid, 'Danh mục không hợp lệ');
    }
  }

  Future<void> _requireUsableWallet(WalletId id) async {
    final wallet = await _db.walletsDao.findById(id);
    if (wallet == null || wallet.archived) {
      throw const _Invalid(TransactionErrors.walletInvalid, 'Ví không tồn tại hoặc đã lưu trữ');
    }
  }

  static TransactionsCompanion _companion(TransactionDraft d) => TransactionsCompanion(
    type: Value(d.type),
    amount: Value(d.amount),
    walletId: Value(d.walletId),
    toWalletId: Value(d.toWalletId),
    categoryId: Value(d.categoryId),
    occurredAt: Value(d.occurredAt),
    payee: Value(_blankToNull(d.payee)),
    note: Value(_blankToNull(d.note)),
  );

  static String? _blankToNull(String? text) {
    final trimmed = text?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  Future<Result<T>> _guard<T>(Future<T> Function() body) => guardAsync(
    body,
    onError: (error) => switch (error) {
      _Invalid(:final code, :final message) => ValidationFailure(message, code: code),
      InvalidDataException() => ValidationFailure('Dữ liệu giao dịch không hợp lệ', cause: error),
      _ => DatabaseFailure('Không ghi được giao dịch', cause: error),
    },
  );
}

/// Lỗi kiểm tra nội bộ, chỉ sống trong repository (được đổi thành [ValidationFailure]).
final class _Invalid implements Exception {
  const _Invalid(this.code, this.message);
  final String code;
  final String message;
}

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(ref.watch(appDatabaseProvider)),
);

extension<T extends Object> on T {
  R let<R>(R Function(T) transform) => transform(this);
}
