/// Khoảng thời gian nửa mở `[start, end)` theo giờ địa phương.
final class DateRange {
  const DateRange(this.start, this.end);

  final DateTime start;

  /// Không bao gồm.
  final DateTime end;

  bool contains(DateTime at) {
    final local = at.toLocal();
    return !local.isBefore(start) && local.isBefore(end);
  }

  @override
  bool operator ==(Object other) => other is DateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'DateRange($start – $end)';
}

/// "Tháng tài chính" theo ngày bắt đầu tháng người dùng chọn (1..28).
///
/// Tháng mang nhãn M/Y là kỳ KẾT THÚC trong tháng M: ngày bắt đầu 25 → "Tháng 11" là
/// 25/10 – 24/11 (lương nhận 25/10 dùng cho tháng 11). Ngày bắt đầu 1 → đúng tháng dương lịch.
final class FinancialMonth implements Comparable<FinancialMonth> {
  const FinancialMonth(this.year, this.month) : assert(month >= 1 && month <= 12, 'tháng 1..12');

  /// Tháng tài chính chứa thời điểm [at] (giờ địa phương).
  factory FinancialMonth.containing(DateTime at, int startDay) {
    final local = at.toLocal();
    if (startDay <= 1 || local.day < startDay) return FinancialMonth(local.year, local.month);
    final next = DateTime(local.year, local.month + 1);
    return FinancialMonth(next.year, next.month);
  }

  final int year;
  final int month;

  DateRange range(int startDay) {
    if (startDay <= 1) return DateRange(DateTime(year, month), DateTime(year, month + 1));
    // DateTime tự chuẩn hóa tháng 0 → tháng 12 năm trước.
    return DateRange(DateTime(year, month - 1, startDay), DateTime(year, month, startDay));
  }

  FinancialMonth get previous {
    final d = DateTime(year, month - 1);
    return FinancialMonth(d.year, d.month);
  }

  FinancialMonth get next {
    final d = DateTime(year, month + 1);
    return FinancialMonth(d.year, d.month);
  }

  @override
  int compareTo(FinancialMonth other) =>
      year != other.year ? year.compareTo(other.year) : month.compareTo(other.month);

  @override
  bool operator ==(Object other) =>
      other is FinancialMonth && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => 'FinancialMonth($month/$year)';
}
