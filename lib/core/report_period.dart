import 'financial_month.dart';

/// Loại kỳ báo cáo.
enum PeriodKind { week, month, year, custom }

/// Một kỳ báo cáo (giờ địa phương, nửa mở `[start, end)`), đi được tới kỳ trước / sau.
///
/// - Tuần bắt đầu thứ Hai.
/// - Tháng là tháng tài chính theo ngày bắt đầu tháng trong Cài đặt.
/// - Năm là năm dương lịch.
/// - Tùy chọn: khoảng ngày bất kỳ; kỳ trước / sau là khoảng cùng số ngày liền kề.
final class ReportPeriod {
  const ReportPeriod._(this.kind, this.range, {this.month, this.startDay = 1});

  /// Tuần (thứ Hai – Chủ nhật) chứa [at].
  factory ReportPeriod.week(DateTime at) {
    final local = at.toLocal();
    final monday = DateTime(local.year, local.month, local.day - (local.weekday - 1));
    return ReportPeriod._(
      PeriodKind.week,
      DateRange(monday, DateTime(monday.year, monday.month, monday.day + 7)),
    );
  }

  /// Tháng tài chính [month] theo ngày bắt đầu [startDay].
  factory ReportPeriod.month(FinancialMonth month, int startDay) =>
      ReportPeriod._(PeriodKind.month, month.range(startDay), month: month, startDay: startDay);

  /// Tháng tài chính chứa [at].
  factory ReportPeriod.monthOf(DateTime at, int startDay) =>
      ReportPeriod.month(FinancialMonth.containing(at, startDay), startDay);

  factory ReportPeriod.year(int year) =>
      ReportPeriod._(PeriodKind.year, DateRange(DateTime(year), DateTime(year + 1)));

  /// Từ ngày [first] đến hết ngày [last] (cả hai tính theo ngày địa phương).
  factory ReportPeriod.custom(DateTime first, DateTime last) {
    final a = first.toLocal();
    final b = last.toLocal();
    final start = DateTime(a.year, a.month, a.day);
    final end = DateTime(b.year, b.month, b.day + 1);
    return ReportPeriod._(
      PeriodKind.custom,
      end.isAfter(start)
          ? DateRange(start, end)
          : DateRange(start, DateTime(a.year, a.month, a.day + 1)),
    );
  }

  /// Kỳ cùng loại chứa [at] (tùy chọn → giữ nguyên độ dài, bắt đầu từ [at]).
  factory ReportPeriod.containing(PeriodKind kind, DateTime at, {int startDay = 1}) =>
      switch (kind) {
        PeriodKind.week => ReportPeriod.week(at),
        PeriodKind.month => ReportPeriod.monthOf(at, startDay),
        PeriodKind.year => ReportPeriod.year(at.toLocal().year),
        PeriodKind.custom => ReportPeriod.custom(at, at),
      };

  final PeriodKind kind;
  final DateRange range;

  /// Chỉ có với [PeriodKind.month].
  final FinancialMonth? month;
  final int startDay;

  /// Ngày cuối cùng (tính cả) của kỳ.
  DateTime get lastDay => DateTime(range.end.year, range.end.month, range.end.day - 1);

  int get _days => DateTime.utc(
    range.end.year,
    range.end.month,
    range.end.day,
  ).difference(DateTime.utc(range.start.year, range.start.month, range.start.day)).inDays;

  ReportPeriod get previous => _shift(-1);
  ReportPeriod get next => _shift(1);

  ReportPeriod _shift(int step) => switch (kind) {
    PeriodKind.week => ReportPeriod.week(
      DateTime(range.start.year, range.start.month, range.start.day + 7 * step),
    ),
    PeriodKind.month => ReportPeriod.month(step < 0 ? month!.previous : month!.next, startDay),
    PeriodKind.year => ReportPeriod.year(range.start.year + step),
    PeriodKind.custom => ReportPeriod.custom(
      DateTime(range.start.year, range.start.month, range.start.day + _days * step),
      DateTime(range.start.year, range.start.month, range.start.day + _days * step + _days - 1),
    ),
  };

  /// [count] kỳ liên tiếp kết thúc ở kỳ này (cũ nhất trước).
  List<ReportPeriod> lastN(int count) {
    final result = <ReportPeriod>[this];
    while (result.length < count) {
      result.insert(0, result.first.previous);
    }
    return result;
  }

  @override
  bool operator ==(Object other) =>
      other is ReportPeriod && other.kind == kind && other.range == range;

  @override
  int get hashCode => Object.hash(kind, range);

  @override
  String toString() => 'ReportPeriod($kind, $range)';
}
