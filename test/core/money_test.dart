import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vi_xanh_app/core/money.dart';

void main() {
  setUpAll(() => initializeDateFormatting('vi_VN'));

  test('cộng/trừ cùng loại tiền', () {
    expect(const Money(1000) + const Money(500), const Money(1500));
    expect(const Money(1000) - const Money(1500), const Money(-500));
  });

  test('khác loại tiền thì ném lỗi', () {
    expect(() => const Money(1) + const Money(1, currency: 'USD'), throwsArgumentError);
  });

  test('định dạng VND', () {
    expect(const Money(1250000).format(), contains('1.250.000'));
  });
}
