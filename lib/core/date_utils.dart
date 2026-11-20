/// Tiện ích ngày tháng thuần Dart.
extension DateOnly on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get startOfMonth => DateTime(year, month);
  DateTime get endOfMonth => DateTime(year, month + 1).subtract(const Duration(microseconds: 1));
}
