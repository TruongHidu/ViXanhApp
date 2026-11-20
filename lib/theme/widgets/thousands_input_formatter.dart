import 'package:flutter/services.dart';

/// Ô nhập số tiền: chỉ nhận chữ số và tự chèn dấu chấm hàng nghìn ("1250000" → "1.250.000").
final class ThousandsInputFormatter extends TextInputFormatter {
  const ThousandsInputFormatter({this.maxDigits = 12});

  /// Số chữ số tối đa (mặc định 12 → tới 999.999.999.999).
  final int maxDigits;

  /// Đọc lại giá trị số từ chuỗi đã định dạng; rỗng → 0.
  static int parse(String text) => int.tryParse(text.replaceAll(RegExp(r'\D'), '')) ?? 0;

  /// "1250000" → "1.250.000".
  static String format(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text
        .replaceAll(RegExp(r'\D'), '')
        .replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (digits.length > maxDigits) return oldValue;
    final text = digits.isEmpty ? '' : format(int.parse(digits));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
