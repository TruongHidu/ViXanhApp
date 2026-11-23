import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/tokens.dart';

/// Một nhóm cột (thu + chi) của một kỳ.
@immutable
final class SeriesGroup {
  const SeriesGroup({
    required this.label,
    required this.income,
    required this.expense,
    required this.detail,
  });

  /// Nhãn dưới nhóm ("T11").
  final String label;
  final int income;
  final int expense;

  /// Câu đầy đủ hiện khi chọn và đọc cho trình đọc màn hình.
  final String detail;
}

/// Biểu đồ cột đôi thu – chi nhiều kỳ (theo thiết kế "Thu – chi 6 tháng").
/// Chạm một nhóm để xem số liệu; mặc định chọn kỳ cuối.
class SeriesChart extends StatefulWidget {
  const SeriesChart({
    required this.groups,
    required this.formatAxis,
    required this.incomeLabel,
    required this.expenseLabel,
    super.key,
  });

  final List<SeriesGroup> groups;

  /// Nhãn trục rút gọn ("20 tr").
  final String Function(int value) formatAxis;
  final String incomeLabel;
  final String expenseLabel;

  @override
  State<SeriesChart> createState() => _SeriesChartState();
}

class _SeriesChartState extends State<SeriesChart> {
  int? _selected;

  static const _plotHeight = 120.0;
  static const _barWidth = 14.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final groups = widget.groups;
    if (groups.isEmpty) return const SizedBox.shrink();
    final selected = (_selected ?? groups.length - 1).clamp(0, groups.length - 1);
    final max = groups.fold<int>(
      0,
      (m, g) => [m, g.income, g.expense].reduce((a, b) => a > b ? a : b),
    );
    double height(int v) => max == 0 ? 0 : _plotHeight * v / max;

    Widget legend(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: Wrap(
            spacing: AppSpacing.md,
            children: [
              legend(colors.income, widget.incomeLabel),
              legend(colors.expense, widget.expenseLabel),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          liveRegion: true,
          child: Text(
            groups[selected].detail,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ExcludeSemantics(child: Text(widget.formatAxis(max), style: theme.textTheme.labelSmall)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final (i, g) in groups.indexed)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: i == selected,
                  label: g.detail,
                  onTap: () => setState(() => _selected = i),
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: () => setState(() => _selected = i),
                    borderRadius: const BorderRadius.all(AppRadius.button),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: Column(
                        children: [
                          SizedBox(
                            height: _plotHeight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _Bar(
                                  height: height(g.income),
                                  color: colors.income,
                                  dim: i != selected,
                                ),
                                const SizedBox(width: 3),
                                _Bar(
                                  height: height(g.expense),
                                  color: colors.expense,
                                  dim: i != selected,
                                ),
                              ],
                            ),
                          ),
                          Divider(color: colors.divider, height: 1),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            g.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: i == selected ? FontWeight.w600 : FontWeight.w400,
                              color: i == selected
                                  ? theme.colorScheme.onSurface
                                  : colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.height, required this.color, required this.dim});

  final double height;
  final Color color;

  /// Cột không được chọn nhạt đi để nhóm đang chọn nổi bật.
  final bool dim;

  @override
  Widget build(BuildContext context) => Container(
    width: _SeriesChartState._barWidth,
    height: height < 2 && height > 0 ? 2 : height,
    decoration: BoxDecoration(
      color: dim ? color.withValues(alpha: 0.45) : color,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
    ),
  );
}
