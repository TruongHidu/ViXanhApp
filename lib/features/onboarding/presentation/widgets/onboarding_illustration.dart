import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/tokens.dart';

/// Ba hình minh họa của màn giới thiệu, vẽ lại từ thiết kế (khung 320×320) bằng CustomPainter
/// để không cần thêm package SVG. Thuần trang trí: ẩn khỏi trình đọc màn hình.
enum OnboardingArt { record, autoSync, plan }

class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({required this.art, required this.size, super.key});

  final OnboardingArt art;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    final palette = _ArtPalette(
      blob: scheme.primaryContainer,
      ink: scheme.onPrimaryContainer,
      paper: scheme.surface,
      line: colors.divider,
      chip: colors.transferBg,
      bank: colors.transfer,
      warm: Color.alphaBlend(IllustrationColors.orange.withValues(alpha: 0.18), scheme.surface),
    );
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _OnboardingPainter(art, palette)),
      ),
    );
  }
}

@immutable
final class _ArtPalette {
  const _ArtPalette({
    required this.blob,
    required this.ink,
    required this.paper,
    required this.line,
    required this.chip,
    required this.bank,
    required this.warm,
  });

  final Color blob;
  final Color ink;
  final Color paper;
  final Color line;
  final Color chip;
  final Color bank;
  final Color warm;

  @override
  bool operator ==(Object other) =>
      other is _ArtPalette &&
      other.blob == blob &&
      other.ink == ink &&
      other.paper == paper &&
      other.line == line &&
      other.chip == chip &&
      other.bank == bank &&
      other.warm == warm;

  @override
  int get hashCode => Object.hash(blob, ink, paper, line, chip, bank, warm);
}

class _OnboardingPainter extends CustomPainter {
  _OnboardingPainter(this.art, this.p);

  final OnboardingArt art;
  final _ArtPalette p;

  late Canvas _c;

  Paint _fill(Color color) => Paint()..color = color;

  Paint _stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void _circle(double cx, double cy, double r, Color fill, {double stroke = 0}) {
    _c.drawCircle(Offset(cx, cy), r, _fill(fill));
    if (stroke > 0) _c.drawCircle(Offset(cx, cy), r, _stroke(p.ink, stroke));
  }

  void _rrect(double x, double y, double w, double h, double r, Color fill, {double stroke = 0}) {
    final rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
    _c.drawRRect(rect, _fill(fill));
    if (stroke > 0) _c.drawRRect(rect, _stroke(p.ink, stroke));
  }

  void _shape(Path path, Color fill, double stroke) {
    _c
      ..drawPath(path, _fill(fill))
      ..drawPath(path, _stroke(p.ink, stroke));
  }

  void _line(Path path, {double width = 2.5, Color? color}) =>
      _c.drawPath(path, _stroke(color ?? p.ink, width));

  void _dashed(Path path, double dash, double gap, Paint paint) {
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += dash + gap) {
        _c.drawPath(metric.extractPath(d, math.min(d + dash, metric.length)), paint);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _c = canvas;
    canvas
      ..save()
      ..scale(size.width / 320, size.height / 320);
    _circle(160, 168, 128, p.blob);
    switch (art) {
      case OnboardingArt.record:
        _paintRecord();
      case OnboardingArt.autoSync:
        _paintAutoSync();
      case OnboardingArt.plan:
        _paintPlan();
    }
    canvas.restore();
  }

  /// Trang 1 — "Biết tiền mình đi đâu": chiếc ví có mầm lá và đồng xu.
  void _paintRecord() {
    _circle(56, 84, 6, IllustrationColors.yellow);
    _circle(278, 98, 5, IllustrationColors.blue);
    _circle(40, 214, 4, IllustrationColors.pink);
    _shape(
      Path()
        ..moveTo(150, 132)
        ..cubicTo(122, 104, 126, 64, 166, 44)
        ..cubicTo(182, 84, 176, 112, 150, 132)
        ..close(),
      IllustrationColors.green,
      2.5,
    );
    _line(
      Path()
        ..moveTo(150, 132)
        ..cubicTo(156, 104, 160, 78, 166, 44),
      width: 2,
    );
    _shape(
      Path()
        ..moveTo(160, 134)
        ..cubicTo(190, 126, 216, 102, 224, 70)
        ..cubicTo(190, 70, 168, 94, 160, 134)
        ..close(),
      IllustrationColors.green.withValues(alpha: 0.55),
      2.5,
    );
    _line(
      Path()
        ..moveTo(160, 134)
        ..cubicTo(180, 114, 202, 92, 224, 70),
      width: 2,
    );
    _rrect(86, 106, 132, 70, 12, IllustrationColors.blue.withValues(alpha: 0.45), stroke: 2.5);
    _line(
      Path()
        ..moveTo(102, 124)
        ..lineTo(140, 124),
    );
    _rrect(60, 138, 200, 132, 26, p.warm, stroke: 2.5);
    _dashed(
      Path()
        ..moveTo(78, 156)
        ..lineTo(182, 156),
      2,
      9,
      _stroke(p.ink.withValues(alpha: 0.5), 2),
    );
    _rrect(194, 182, 80, 48, 24, IllustrationColors.orange, stroke: 2.5);
    _circle(218, 206, 7, p.paper, stroke: 2);
    _circle(262, 276, 20, IllustrationColors.yellow, stroke: 2.5);
    _line(
      Path()
        ..moveTo(255, 276)
        ..lineTo(269, 276)
        ..moveTo(262, 269)
        ..lineTo(262, 283),
    );
  }

  /// Trang 2 — "Tự động ghi nhận chuyển khoản": điện thoại nhận thông báo ngân hàng.
  void _paintAutoSync() {
    _circle(46, 230, 6, IllustrationColors.yellow);
    _circle(284, 236, 5, IllustrationColors.pink);
    _circle(62, 70, 4, IllustrationColors.green);
    _rrect(104, 40, 132, 250, 28, p.paper, stroke: 2.5);
    _rrect(146, 54, 48, 8, 4, p.line);
    _rrect(122, 196, 96, 10, 5, p.line);
    _rrect(122, 216, 68, 10, 5, p.line);
    _rrect(122, 242, 96, 28, 14, p.chip);
    _circle(138, 256, 6, IllustrationColors.blue);
    _rrect(150, 252, 52, 8, 4, p.ink.withValues(alpha: 0.45));
    _rrect(52, 94, 232, 80, 18, p.paper, stroke: 2.5);
    _circle(88, 134, 20, IllustrationColors.blue.withValues(alpha: 0.45));
    _line(
      Path()
        ..moveTo(78, 130)
        ..lineTo(88, 123)
        ..lineTo(98, 130)
        ..moveTo(81, 133)
        ..lineTo(81, 141)
        ..moveTo(88, 133)
        ..lineTo(88, 141)
        ..moveTo(95, 133)
        ..lineTo(95, 141)
        ..moveTo(78, 145)
        ..lineTo(98, 145),
      color: p.bank,
    );
    _rrect(120, 114, 84, 10, 5, p.ink.withValues(alpha: 0.55));
    _rrect(120, 132, 140, 9, 4.5, p.line);
    _rrect(120, 149, 62, 10, 5, IllustrationColors.coral);
    _line(
      Path()
        ..moveTo(262, 72)
        ..cubicTo(270, 66, 276, 58, 278, 48)
        ..moveTo(276, 86)
        ..cubicTo(286, 84, 296, 78, 302, 68),
    );
    _circle(248, 200, 18, IllustrationColors.green, stroke: 2.5);
    _line(
      Path()
        ..moveTo(240, 200)
        ..lineTo(246, 206)
        ..lineTo(257, 194),
    );
  }

  /// Trang 3 — "Chi tiêu có kế hoạch": biểu đồ tròn có mầm cây và lá cờ mục tiêu.
  void _paintPlan() {
    _circle(58, 76, 5, IllustrationColors.blue);
    _circle(290, 196, 5, IllustrationColors.pink);
    _circle(44, 250, 6, IllustrationColors.yellow);
    _circle(140, 176, 86, p.paper.withValues(alpha: 0.7));

    const radius = 72.0;
    const circumference = 2 * math.pi * radius;
    final ring = Rect.fromCircle(center: const Offset(140, 176), radius: radius);
    for (final (length, offset, color) in [
      (150.0, 0.0, IllustrationColors.orange),
      (100.0, 154.88, IllustrationColors.pink),
      (80.0, 259.76, IllustrationColors.teal),
      (60.0, 344.64, IllustrationColors.blue),
      (38.0, 409.52, IllustrationColors.yellow),
    ]) {
      _c.drawArc(
        ring,
        -math.pi / 2 + offset / circumference * 2 * math.pi,
        length / circumference * 2 * math.pi,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 28,
      );
    }

    _circle(140, 176, 30, p.paper, stroke: 2.5);
    _line(
      Path()
        ..moveTo(140, 190)
        ..lineTo(140, 166),
    );
    _shape(
      Path()
        ..moveTo(140, 174)
        ..cubicTo(130, 174, 126, 166, 126, 160)
        ..cubicTo(134, 160, 140, 166, 140, 174)
        ..close(),
      IllustrationColors.green,
      2,
    );
    _shape(
      Path()
        ..moveTo(140, 170)
        ..cubicTo(150, 170, 155, 162, 155, 155)
        ..cubicTo(146, 155, 140, 162, 140, 170)
        ..close(),
      IllustrationColors.green,
      2,
    );
    _c.drawOval(
      Rect.fromCenter(center: const Offset(248, 262), width: 60, height: 18),
      _fill(IllustrationColors.green.withValues(alpha: 0.55)),
    );
    _line(
      Path()
        ..moveTo(248, 262)
        ..lineTo(248, 92),
      width: 3,
    );
    _shape(
      Path()
        ..moveTo(248, 94)
        ..lineTo(296, 94)
        ..lineTo(284, 114)
        ..lineTo(296, 134)
        ..lineTo(248, 134)
        ..close(),
      IllustrationColors.yellow,
      2.5,
    );
    _circle(248, 88, 5, p.ink);
    _dashed(
      Path()
        ..moveTo(196, 252)
        ..cubicTo(212, 262, 226, 266, 240, 264),
      2,
      8,
      _stroke(p.ink.withValues(alpha: 0.6), 2),
    );
  }

  @override
  bool shouldRepaint(_OnboardingPainter old) => old.art != art || old.p != p;
}
