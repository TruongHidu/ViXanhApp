import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core_providers.dart';
import '../../../core/enums.dart';
import '../../../core/formatting/date_format.dart';
import '../../../core/report_period.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../settings/presentation/settings_notifier.dart';
import '../../transactions/domain/transaction_list_item.dart';
import '../data/report_repository.dart';
import '../domain/category_share.dart';

/// Lựa chọn trên màn Báo cáo: loại (thu / chi) và kỳ.
@immutable
final class ReportSelection {
  const ReportSelection({required this.type, required this.period});

  /// [TransactionType.expense] hoặc [TransactionType.income].
  final TransactionType type;
  final ReportPeriod period;

  ReportSelection copyWith({TransactionType? type, ReportPeriod? period}) =>
      ReportSelection(type: type ?? this.type, period: period ?? this.period);

  @override
  bool operator ==(Object other) =>
      other is ReportSelection && other.type == type && other.period == period;

  @override
  int get hashCode => Object.hash(type, period);
}

final reportSelectionProvider =
    NotifierProvider.autoDispose<ReportSelectionNotifier, ReportSelection>(
      ReportSelectionNotifier.new,
    );

final class ReportSelectionNotifier extends Notifier<ReportSelection> {
  int get _startDay => ref.read(appPreferencesProvider).monthStartDay;

  /// Theo dõi ngày bắt đầu tháng: đổi ở Tài khoản thì kỳ đang xem tính lại theo ngày mới
  /// (về tháng hiện tại), thay vì giữ khoảng ngày cũ.
  @override
  ReportSelection build() {
    final startDay = ref.watch(appPreferencesProvider.select((p) => p.monthStartDay));
    return ReportSelection(
      type: TransactionType.expense,
      period: ReportPeriod.monthOf(ref.read(clockProvider).now(), startDay),
    );
  }

  void setType(TransactionType type) => state = state.copyWith(type: type);

  /// Đổi loại kỳ: lấy kỳ chứa hôm nay (tùy chọn dùng [setCustom]).
  void setKind(PeriodKind kind) => state = state.copyWith(
    period: ReportPeriod.containing(kind, ref.read(clockProvider).now(), startDay: _startDay),
  );

  void setCustom(DateTime first, DateTime last) =>
      state = state.copyWith(period: ReportPeriod.custom(first, last));

  void previous() => state = state.copyWith(period: state.period.previous);
  void next() => state = state.copyWith(period: state.period.next);
}

/// Tổng theo danh mục chính của kỳ đang xem.
final reportCategoryTotalsProvider = StreamProvider.autoDispose<List<CategoryTotal>>((ref) {
  final s = ref.watch(reportSelectionProvider);
  return ref.watch(reportRepositoryProvider).watchByCategory(s.period.range, s.type);
});

/// Thu / chi của 6 kỳ gần nhất, kỳ đang xem ở cuối (kỳ trước nằm ở vị trí áp chót).
final reportSeriesProvider = StreamProvider.autoDispose<List<PeriodTotals>>((ref) {
  final period = ref.watch(reportSelectionProvider.select((s) => s.period));
  return ref.watch(reportRepositoryProvider).watchSeries([
    for (final p in period.lastN(6)) p.range,
  ]);
});

/// Nhãn đầy đủ của kỳ: "16/11 – 22/11/2026", "Tháng 11/2026", "Năm 2026".
String periodLabel(ReportPeriod p, AppLocalizations l10n, DateLabelFormatter labels) =>
    switch (p.kind) {
      PeriodKind.month => l10n.monthLabel(p.month!.month, p.month!.year),
      PeriodKind.year => l10n.reportYearLabel(p.range.start.year),
      PeriodKind.week || PeriodKind.custom => l10n.periodRange(
        labels.shortDate(p.range.start),
        labels.numericDate(p.lastDay),
      ),
    };

/// Nhãn ngắn dưới cột biểu đồ: "T11", "16/11", "2026".
String periodShortLabel(ReportPeriod p, DateLabelFormatter labels) => switch (p.kind) {
  PeriodKind.month => labels.shortMonth(DateTime(p.month!.year, p.month!.month)),
  PeriodKind.year => '${p.range.start.year}',
  PeriodKind.week || PeriodKind.custom => labels.shortDate(p.range.start),
};
