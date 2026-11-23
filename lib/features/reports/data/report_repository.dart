import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums.dart';
import '../../../core/financial_month.dart';
import '../../../core/ids.dart';
import '../../../data/database.dart';
import '../../transactions/domain/transaction_list_item.dart';
import '../domain/category_share.dart';

/// Truy vấn tổng hợp cho Báo cáo. Chỉ đọc; mọi phép cộng chạy bằng SQL (SUM / GROUP BY),
/// chuyển khoản không tính là thu hay chi, giao dịch đã xóa bị bỏ qua.
final class ReportRepository {
  ReportRepository(this._db);

  final AppDatabase _db;

  static int _ms(DateTime at) => at.toUtc().millisecondsSinceEpoch;

  /// Tổng theo danh mục CHÍNH (mục con gộp vào cha) của loại [type] trong [range],
  /// lớn nhất trước. Danh mục đã xóa vẫn tính (giao dịch cũ vẫn thuộc về nó).
  Stream<List<CategoryTotal>> watchByCategory(DateRange range, TransactionType type) => _db
      .customSelect(
        '''
        SELECT root.id AS id, root.name AS name, root.icon AS icon, root.color AS color,
               SUM(t.amount) AS total
        FROM transactions t
        JOIN categories c ON c.id = t.category_id
        JOIN categories root ON root.id = COALESCE(c.parent_id, c.id)
        WHERE t.deleted_at IS NULL AND t.type = ? AND t.occurred_at >= ? AND t.occurred_at < ?
        GROUP BY root.id
        ORDER BY total DESC
        ''',
        variables: [
          Variable.withString(type.name),
          Variable.withInt(_ms(range.start)),
          Variable.withInt(_ms(range.end)),
        ],
        readsFrom: {_db.transactions, _db.categories},
      )
      .watch()
      .map(
        (rows) => [
          for (final r in rows)
            CategoryTotal(
              categoryId: CategoryId(r.read<String>('id')),
              name: r.read<String>('name'),
              icon: r.read<String>('icon'),
              color: r.read<int>('color'),
              amount: r.read<int>('total'),
            ),
        ],
      );

  /// Tổng thu / chi cho từng khoảng trong [ranges] (theo đúng thứ tự), một truy vấn duy nhất:
  /// mỗi giao dịch được gán vào khoảng chứa nó bằng biểu thức CASE.
  Stream<List<PeriodTotals>> watchSeries(List<DateRange> ranges) {
    if (ranges.isEmpty) return Stream.value(const []);
    final cases = StringBuffer('CASE');
    final variables = <Variable<Object>>[];
    for (final (i, r) in ranges.indexed) {
      cases.write(' WHEN occurred_at >= ? AND occurred_at < ? THEN $i');
      variables
        ..add(Variable.withInt(_ms(r.start)))
        ..add(Variable.withInt(_ms(r.end)));
    }
    cases.write(' ELSE -1 END');
    final from = ranges.map((r) => r.start).reduce((a, b) => a.isBefore(b) ? a : b);
    final to = ranges.map((r) => r.end).reduce((a, b) => a.isAfter(b) ? a : b);
    variables
      ..add(Variable.withInt(_ms(from)))
      ..add(Variable.withInt(_ms(to)));

    return _db
        .customSelect(
          '''
          SELECT $cases AS bucket,
            COALESCE(SUM(CASE WHEN type = 'income' THEN amount END), 0) AS income,
            COALESCE(SUM(CASE WHEN type = 'expense' THEN amount END), 0) AS expense
          FROM transactions
          WHERE deleted_at IS NULL AND occurred_at >= ? AND occurred_at < ?
          GROUP BY bucket
          ''',
          variables: variables,
          readsFrom: {_db.transactions},
        )
        .watch()
        .map((rows) {
          final byBucket = {
            for (final r in rows)
              r.read<int>('bucket'): PeriodTotals(
                income: r.read<int>('income'),
                expense: r.read<int>('expense'),
              ),
          };
          return [for (var i = 0; i < ranges.length; i++) byBucket[i] ?? PeriodTotals.zero];
        });
  }
}

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => ReportRepository(ref.watch(appDatabaseProvider)),
);
