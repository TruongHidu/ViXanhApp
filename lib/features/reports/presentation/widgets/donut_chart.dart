import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../theme/tokens.dart';

/// Một lát của biểu đồ tròn.
typedef DonutSlice = ({double fraction, Color color});

/// Biểu đồ tròn rỗng giữa (theo thiết kế, 232px) với nội dung ở tâm.
/// Thuần đồ họa: nơi dùng gắn câu mô tả cho trình đọc màn hình.
class DonutChart extends StatelessWidget {
  const DonutChart({required this.slices, required this.center, this.size = 232, super.key});

  final List<DonutSlice> slices;
  final Widget center;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: _DonutPainter(slices, Theme.of(context).colorScheme.surface),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl + AppSpacing.md),
          child: center,
        ),
      ),
    ),
  );
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.slices, this.gapColor);

  final List<DonutSlice> slices;
  final Color gapColor;

  static const _stroke = 28.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: size.shortestSide / 2 - _stroke / 2,
    );
    var start = -math.pi / 2;
    for (final s in slices) {
      final sweep = s.fraction * 2 * math.pi;
      if (sweep <= 0) continue;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = s.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = _stroke,
      );
      // Khe nhỏ giữa các lát để phân biệt lát cùng màu gần nhau.
      if (slices.length > 1) {
        canvas.drawArc(
          rect,
          start + sweep - 0.012,
          0.012,
          false,
          Paint()
            ..color = gapColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = _stroke + 1,
        );
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.slices != slices || old.gapColor != gapColor;
}
