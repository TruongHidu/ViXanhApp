import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/theme/tokens.dart';

/// Tỉ lệ tương phản WCAG 2.x giữa hai màu đặc.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  test('contrastRatio đúng với cặp chuẩn', () {
    expect(contrastRatio(Colors.black, Colors.white), closeTo(21, 0.01));
    expect(contrastRatio(Colors.white, Colors.white), closeTo(1, 0.001));
  });

  for (final (name, p) in [('sáng', AppPalette.light), ('tối', AppPalette.dark)]) {
    group('chế độ $name', () {
      // Chữ thường (< 18,66px đậm) cần ≥ 4,5:1 trên mọi nền nó thực sự nằm trên.
      final textPairs = <String, (Color, List<Color>)>{
        'textPrimary': (p.textPrimary, [p.background, p.card, p.surfaceAlt]),
        'textSecondary': (p.textSecondary, [p.background, p.card, p.surfaceAlt]),
        'primaryText': (p.primaryText, [p.background, p.card]),
        'incomeText': (p.incomeText, [p.background, p.card, p.incomeBg]),
        'expenseText': (p.expenseText, [p.background, p.card, p.expenseBg]),
        'warningText': (p.warningText, [p.background, p.card, p.warningBg]),
        'transferText': (p.transferText, [p.background, p.card, p.transferBg]),
        'onPrimary': (p.onPrimary, [p.primary]),
        'onPrimaryContainer': (p.onPrimaryContainer, [p.primaryContainer]),
        'onExpense (nút lỗi)': (p.onExpense, [p.expenseText]),
        'snackbar': (p.background, [p.textPrimary]),
      };

      for (final MapEntry(key: label, value: (fg, bgs)) in textPairs.entries) {
        test('$label ≥ 4,5:1', () {
          for (final bg in bgs) {
            final ratio = contrastRatio(fg, bg);
            expect(ratio, greaterThanOrEqualTo(4.5), reason: '$label trên $bg = $ratio');
          }
        });
      }

      // Thành phần đồ họa quan trọng (FAB, viền ô nhập khi focus) cần ≥ 3:1.
      test('primary (FAB, viền focus) ≥ 3:1 so với nền', () {
        for (final bg in [p.background, p.card, p.surfaceAlt]) {
          expect(contrastRatio(p.primary, bg), greaterThanOrEqualTo(3));
        }
      });
    });
  }
}
