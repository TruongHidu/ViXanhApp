import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Chuỗi hiển thị phải nằm trong ARB. Bắt lỗi phổ biến nhất: `Text('...tiếng Việt có dấu...')`.
void main() {
  test('không có Text(...) chứa chữ tiếng Việt có dấu viết cứng trong lib/', () {
    const vietnamese = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    final pattern = RegExp(
      '''Text\\(\\s*(?:const\\s+)?['"][^'"]*[$vietnamese]''',
      caseSensitive: false,
      unicode: true,
    );
    final violations = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.replaceAll(r'\', '/').contains('lib/l10n/gen/'));
    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (final (i, line) in lines.indexed) {
        if (pattern.hasMatch(line)) violations.add('${file.path}:${i + 1}: ${line.trim()}');
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
