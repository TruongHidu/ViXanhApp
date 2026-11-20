import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/amount_input.dart';

void main() {
  AmountInput type(String keys) {
    var input = const AmountInput();
    for (final k in keys.split(' ')) {
      input = switch (k) {
        '000' => input.thousand(),
        '+' => input.sign(AmountInput.plus),
        '-' => input.sign(AmountInput.minus),
        '<' => input.backspace(),
        _ => input.digit(k),
      };
    }
    return input;
  }

  test('gõ số và 000', () {
    expect(type('4 5 000').total, 45000);
    expect(type('4 5 000').expression, '45000');
  });

  test('000 không có tác dụng khi chưa có số hoặc chỉ có 0', () {
    expect(type('000').isEmpty, isTrue);
    expect(type('0 000').expression, '0');
  });

  test('0 đứng đầu bị thay bởi chữ số sau', () {
    expect(type('0 5').expression, '5');
  });

  test('cộng trừ nhiều khoản', () {
    final input = type('4 5 000 + 2 0 000 - 5 000');
    expect(input.total, 60000);
    expect(input.hasOperator, isTrue);
    expect(input.parts, ['45000', '+', '20000', '−', '5000']);
  });

  test('hai dấu liền nhau: dấu sau thay dấu trước; dấu đầu tiên bị bỏ qua', () {
    expect(type('5 + -').expression, '5−');
    expect(type('+').isEmpty, isTrue);
  });

  test('tổng âm được đưa về 0', () {
    expect(type('5 - 9').total, 0);
  });

  test('xóa lùi', () {
    expect(type('4 5 <').expression, '4');
    expect(const AmountInput().backspace().isEmpty, isTrue);
  });

  test('chip thay số hạng đang gõ', () {
    expect(type('4 5').replaceLastOperand(50000).expression, '50000');
    expect(type('1 0 0 +').replaceLastOperand(20000).total, 20100);
  });

  test('số hạng tối đa 12 chữ số', () {
    final input = type('9 9 9 9 9 9 9 9 9 9 9 9 9');
    expect(input.expression.length, 12);
    expect(input.total, 999999999999);
  });

  test('AmountInput.of khởi tạo từ số có sẵn', () {
    expect(AmountInput.of(45000).total, 45000);
    expect(AmountInput.of(0).isEmpty, isTrue);
  });
}
