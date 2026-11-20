/// Chuẩn hóa chữ để tìm kiếm không phân biệt hoa thường và dấu tiếng Việt:
/// "Cà Phê Sữa Đá" → "ca phe sua da".
String foldVietnamese(String input) {
  final buffer = StringBuffer();
  for (final rune in input.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_folded[char] ?? char);
  }
  return buffer.toString();
}

/// Bảng bỏ dấu, dựng một lần từ các nhóm nguyên âm có dấu (chữ thường).
final Map<String, String> _folded = () {
  const groups = {
    'a': 'àáạảãâầấậẩẫăằắặẳẵ',
    'e': 'èéẹẻẽêềếệểễ',
    'i': 'ìíịỉĩ',
    'o': 'òóọỏõôồốộổỗơờớợởỡ',
    'u': 'ùúụủũưừứựửữ',
    'y': 'ỳýỵỷỹ',
    'd': 'đ',
  };
  return {
    for (final MapEntry(key: base, value: accented) in groups.entries)
      for (final c in accented.split('')) c: base,
  };
}();
