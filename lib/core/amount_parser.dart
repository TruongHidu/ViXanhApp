/// Đọc số tiền VND người dùng gõ kiểu tắt: "50k", "1tr2", "1.5tr", "1.250.000".
///
/// Trả số đồng (> 0), hoặc `null` nếu rỗng, bằng 0, âm, sai cú pháp hay vượt [maxAmount].
/// Dấu "." / "," vừa là phân cách hàng nghìn ("1.250.000") vừa là phần thập phân khi đi với
/// đơn vị ("1,5tr"): có đơn vị và đúng một dấu → thập phân; không đơn vị → hàng nghìn.
int? parseAmount(String input) {
  final text = input.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  if (text.isEmpty) return null;

  final match = RegExp(
    r'^(\d+(?:[.,]\d+)*)(k|nghìn|nghin|ng|tr|triệu|trieu|m|tỷ|ty|b)?(\d+)?$',
  ).firstMatch(text);
  if (match == null) return null;
  final number = match.group(1)!;
  final unit = match.group(2);
  final tail = match.group(3);

  final multiplier = switch (unit) {
    null => 1,
    'k' || 'nghìn' || 'nghin' || 'ng' => 1000,
    'tr' || 'triệu' || 'trieu' || 'm' => 1000000,
    _ => 1000000000,
  };

  int? value;
  if (unit == null) {
    // Không đơn vị: "." và "," chỉ là phân cách hàng nghìn, phải đúng nhóm 3 chữ số.
    if (tail != null) return null;
    if (RegExp(r'[.,]').hasMatch(number) && !RegExp(r'^\d{1,3}([.,]\d{3})+$').hasMatch(number)) {
      return null;
    }
    value = int.tryParse(number.replaceAll(RegExp(r'[.,]'), ''));
  } else if (tail != null) {
    // "1tr2" = 1,2 triệu; "2k5" = 2,5 nghìn — phần sau đơn vị là chữ số thập phân.
    if (RegExp(r'[.,]').hasMatch(number)) return null;
    value = _scaled(number, tail, multiplier);
  } else {
    final separators = RegExp(r'[.,]').allMatches(number).length;
    if (separators == 0) {
      value = int.tryParse(number).let((n) => n * multiplier);
    } else if (separators == 1) {
      final parts = number.split(RegExp(r'[.,]'));
      value = _scaled(parts[0], parts[1], multiplier);
    } else {
      return null;
    }
  }

  if (value == null || value <= 0 || value > maxAmount) return null;
  return value;
}

/// Giới hạn trên của một số tiền (đồng).
const maxAmount = 999999999999;

/// `whole,fraction × multiplier`, chỉ nhận kết quả là số nguyên đồng.
int? _scaled(String whole, String fraction, int multiplier) {
  final digits = multiplier.toString().length - 1;
  if (fraction.length > digits) return null;
  final w = int.tryParse(whole);
  final f = int.tryParse(fraction.padRight(digits, '0'));
  if (w == null || f == null) return null;
  return w * multiplier + f;
}

extension on int? {
  int? let(int Function(int) transform) => this == null ? null : transform(this!);
}
