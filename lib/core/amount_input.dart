import 'amount_parser.dart';

/// Nội dung đang gõ trên bàn phím số của màn Thêm giao dịch: các số hạng nối bằng + / −
/// ("45000+20000−5000"). Bất biến; mỗi phím trả về một [AmountInput] mới.
final class AmountInput {
  const AmountInput([this.expression = '']);

  /// Khởi tạo từ một số tiền có sẵn (chế độ sửa).
  factory AmountInput.of(int amount) => AmountInput(amount > 0 ? '$amount' : '');

  static const plus = '+';
  static const minus = '−';

  /// Số chữ số tối đa của một số hạng.
  static const maxOperandDigits = 12;

  final String expression;

  bool get isEmpty => expression.isEmpty;

  bool get hasOperator => expression.contains(plus) || expression.contains(minus);

  /// Các phần theo thứ tự: số hạng và dấu ("45000", "+", "20000").
  List<String> get parts =>
      RegExp('[0-9]+|[$plus$minus]').allMatches(expression).map((m) => m.group(0)!).toList();

  String get _lastOperand {
    final match = RegExp(r'[0-9]*$').firstMatch(expression);
    return match?.group(0) ?? '';
  }

  /// Tổng của biểu thức, không âm và không vượt [maxAmount].
  int get total {
    var sum = 0;
    var sign = 1;
    for (final part in parts) {
      if (part == plus) {
        sign = 1;
      } else if (part == minus) {
        sign = -1;
      } else {
        sum += sign * int.parse(part);
      }
    }
    if (sum < 0) return 0;
    return sum > maxAmount ? maxAmount : sum;
  }

  /// Nhấn một chữ số "0"–"9".
  AmountInput digit(String d) {
    assert(RegExp(r'^[0-9]$').hasMatch(d), 'chỉ nhận một chữ số');
    final last = _lastOperand;
    if (last.length >= maxOperandDigits) return this;
    // "0" đứng đầu số hạng bị thay bởi chữ số mới (không có "05").
    final base = last == '0' ? expression.substring(0, expression.length - 1) : expression;
    return AmountInput('$base$d');
  }

  /// Nhấn "000": chỉ khi số hạng hiện tại đã có chữ số khác 0.
  AmountInput thousand() {
    final last = _lastOperand;
    if (last.isEmpty || last == '0' || last.length + 3 > maxOperandDigits) return this;
    return AmountInput('${expression}000');
  }

  /// Nhấn "+" hoặc "−"; bấm hai dấu liền nhau thì dấu sau thay dấu trước.
  AmountInput sign(String op) {
    assert(op == plus || op == minus, 'chỉ nhận + hoặc −');
    if (expression.isEmpty) return this;
    final trimmed = _endsWithOperator ? expression.substring(0, expression.length - 1) : expression;
    return AmountInput('$trimmed$op');
  }

  bool get _endsWithOperator => expression.endsWith(plus) || expression.endsWith(minus);

  AmountInput backspace() =>
      isEmpty ? this : AmountInput(expression.substring(0, expression.length - 1));

  /// Chip số tiền nhanh: thay số hạng đang gõ bằng [amount].
  AmountInput replaceLastOperand(int amount) {
    final last = _lastOperand;
    return AmountInput('${expression.substring(0, expression.length - last.length)}$amount');
  }

  @override
  bool operator ==(Object other) => other is AmountInput && other.expression == expression;

  @override
  int get hashCode => expression.hashCode;

  @override
  String toString() => 'AmountInput($expression)';
}
