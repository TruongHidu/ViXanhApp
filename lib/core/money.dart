import 'package:intl/intl.dart';

/// Số tiền bất biến, lưu dưới dạng số nguyên đơn vị nhỏ nhất (VND không có
/// đơn vị lẻ nên `minor` = đồng). Không bao giờ dùng `double` cho tiền.
final class Money implements Comparable<Money> {
  const Money(this.minor, {this.currency = 'VND'});

  const Money.zero({this.currency = 'VND'}) : minor = 0;

  final int minor;
  final String currency;

  bool get isNegative => minor < 0;
  bool get isZero => minor == 0;

  Money operator +(Money other) => Money(minor + _same(other).minor, currency: currency);
  Money operator -(Money other) => Money(minor - _same(other).minor, currency: currency);
  Money operator -() => Money(-minor, currency: currency);
  Money abs() => Money(minor.abs(), currency: currency);

  Money _same(Money other) {
    if (other.currency != currency) {
      throw ArgumentError('Không thể cộng $currency với ${other.currency}');
    }
    return other;
  }

  /// "1.250.000 ₫" (khoảng trắng không ngắt U+00A0 trước ₫). Số âm dùng dấu trừ U+2212:
  /// "−5.000 ₫". Định dạng VND giữ kiểu Việt Nam kể cả khi giao diện là tiếng Anh.
  String format({String locale = 'vi_VN'}) {
    final digits = NumberFormat.currency(
      locale: locale,
      symbol: _symbol,
      decimalDigits: 0,
    ).format(minor.abs());
    return minor < 0 ? '$minusSign$digits' : digits;
  }

  /// Dấu trừ toán học (U+2212), không phải gạch nối.
  static const minusSign = '−';

  String get _symbol => switch (currency) {
    'VND' => '₫',
    'USD' => r'$',
    _ => currency,
  };

  @override
  int compareTo(Money other) => minor.compareTo(_same(other).minor);

  @override
  bool operator ==(Object other) =>
      other is Money && other.minor == minor && other.currency == currency;

  @override
  int get hashCode => Object.hash(minor, currency);

  @override
  String toString() => 'Money($minor $currency)';
}
