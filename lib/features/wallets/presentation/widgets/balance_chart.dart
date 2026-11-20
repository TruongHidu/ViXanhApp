import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/tokens.dart';

/// Biểu đồ đường số dư theo ngày (theo thiết kế "Số dư 30 ngày"): chạm hoặc rê ngang để xem
/// số dư từng ngày; mặc định chọn ngày cuối. Vẽ bằng CustomPainter, không cần package.
class BalanceChart extends StatefulWidget {
  const BalanceChart({
    required this.points,
    required this.formatValue,
    required this.formatDay,
    required this.formatAxis,
    required this.semanticSummary,
    super.key,
  });

  final List<({DateTime day, int balance})> points;

  /// Số tiền đầy đủ cho dòng giá trị đang chọn ("15.830.000 ₫").
  final String Function(int value) formatValue;

  /// Nhãn ngày ("18/11").
  final String Function(DateTime day) formatDay;

  /// Nhãn rút gọn trên trục ("16 tr").
  final String Function(int value) formatAxis;

  /// Câu tóm tắt cho trình đọc màn hình (khoảng ngày, thấp nhất, cao nhất).
  final String semanticSummary;

  @override
  State<BalanceChart> createState() => _BalanceChartState();
}

class _BalanceChartState extends State<BalanceChart> {
  int? _selected;

  static const _plotHeight = 140.0;

  void _select(double dx, double width) {
    final n = widget.points.length;
    if (n == 0 || width <= 0) return;
    final i = (dx / width * (n - 1)).round().clamp(0, n - 1);
    if (i != _selected) setState(() => _selected = i);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final points = widget.points;
    if (points.isEmpty) return const SizedBox(height: _plotHeight);
    final selected = (_selected ?? points.length - 1).clamp(0, points.length - 1);
    final values = points.map((p) => p.balance);
    final maxV = values.reduce(math.max);
    final minV = math.min(values.reduce(math.min), 0);
    final point = points[selected];
    final middle = points[points.length ~/ 2];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  widget.formatValue(point.balance),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: point.balance < 0 ? colors.expenseText : null,
                  ),
                ),
              ),
              Text(widget.formatDay(point.day), style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          label: widget.semanticSummary,
          image: true,
          excludeSemantics: true,
          child: LayoutBuilder(
            builder: (context, constraints) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) => _select(d.localPosition.dx, constraints.maxWidth),
              onHorizontalDragUpdate: (d) => _select(d.localPosition.dx, constraints.maxWidth),
              child: SizedBox(
                height: _plotHeight,
                width: constraints.maxWidth,
                child: CustomPaint(
                  painter: _BalancePainter(
                    values: values.toList(),
                    min: minV,
                    max: maxV,
                    selected: selected,
                    line: theme.colorScheme.primary,
                    grid: colors.divider,
                    fill: theme.colorScheme.primary.withValues(alpha: 0.12),
                    dotBorder: theme.colorScheme.surface,
                  ),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Text(widget.formatAxis(maxV), style: theme.textTheme.labelSmall),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ExcludeSemantics(
          // Ba ô co giãn (đầu – giữa – cuối) để chữ phóng to không tràn ngang.
          child: Row(
            children: [
              for (final (day, align) in [
                (points.first.day, TextAlign.start),
                (middle.day, TextAlign.center),
                (points.last.day, TextAlign.end),
              ])
                Expanded(
                  child: Text(
                    widget.formatDay(day),
                    textAlign: align,
                    style: theme.textTheme.labelSmall,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BalancePainter extends CustomPainter {
  _BalancePainter({
    required this.values,
    required this.min,
    required this.max,
    required this.selected,
    required this.line,
    required this.grid,
    required this.fill,
    required this.dotBorder,
  });

  final List<int> values;
  final int min;
  final int max;
  final int selected;
  final Color line;
  final Color grid;
  final Color fill;
  final Color dotBorder;

  /// Chừa phía trên cho nhãn trục, phía dưới cho chấm.
  static const _top = 20.0;
  static const _bottom = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height - _top - _bottom;
    final span = (max - min) == 0 ? 1 : (max - min);
    Offset at(int i) => Offset(
      values.length == 1 ? size.width / 2 : size.width * i / (values.length - 1),
      _top + height * (1 - (values[i] - min) / span),
    );

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (final y in [_top, _top + height / 2, _top + height]) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(at(i).dx, at(i).dy);
    }
    final area = Path.from(path)
      ..lineTo(at(values.length - 1).dx, _top + height)
      ..lineTo(at(0).dx, _top + height)
      ..close();
    canvas
      ..drawPath(area, Paint()..color = fill)
      ..drawPath(
        path,
        Paint()
          ..color = line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );

    final p = at(selected);
    canvas
      ..drawLine(
        Offset(p.dx, _top),
        Offset(p.dx, _top + height),
        gridPaint..color = line.withValues(alpha: 0.4),
      )
      ..drawCircle(p, 6, Paint()..color = dotBorder)
      ..drawCircle(p, 4, Paint()..color = line);
  }

  @override
  bool shouldRepaint(_BalancePainter old) =>
      old.values != values ||
      old.selected != selected ||
      old.line != line ||
      old.grid != grid ||
      old.fill != fill;
}
