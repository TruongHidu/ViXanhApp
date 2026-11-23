import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core_providers.dart';
import '../../../core/financial_month.dart';
import '../../settings/presentation/settings_notifier.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/domain/transaction_list_item.dart';

/// 7 ngày gần nhất tính cả hôm nay: [0h sáu ngày trước, 0h ngày mai).
final last7DaysRangeProvider = Provider.autoDispose<DateRange>((ref) {
  final now = ref.watch(clockProvider).now().toLocal();
  return DateRange(
    DateTime(now.year, now.month, now.day - 6),
    DateTime(now.year, now.month, now.day + 1),
  );
});

/// Thu / chi của tháng tài chính hiện tại (theo ngày bắt đầu tháng trong Cài đặt).
///
/// Tính khoảng tháng ngay tại đây, không qua một provider trung gian: Tổng quan thường nằm
/// ở tab ẩn (bị Riverpod tạm dừng), và chuỗi phụ thuộc nhiều tầng bị flush giữa lúc build
/// khi đổi ngày bắt đầu tháng từ Tài khoản.
final homeMonthTotalsProvider = StreamProvider.autoDispose<PeriodTotals>((ref) {
  final startDay = ref.watch(appPreferencesProvider.select((p) => p.monthStartDay));
  final range = FinancialMonth.containing(ref.watch(clockProvider).now(), startDay).range(startDay);
  return ref.watch(transactionRepositoryProvider).watchTotals(range);
});

final homeDailyExpenseProvider = StreamProvider.autoDispose<Map<DateTime, int>>(
  (ref) =>
      ref.watch(transactionRepositoryProvider).watchDailyExpense(ref.watch(last7DaysRangeProvider)),
);

final recentTransactionsProvider = StreamProvider.autoDispose<List<TransactionListItem>>(
  (ref) => ref.watch(transactionRepositoryProvider).watchRecent(limit: 5),
);
