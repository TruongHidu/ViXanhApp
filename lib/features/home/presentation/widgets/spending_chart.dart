import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/tokens.dart';

/// Một cột của biểu đồ chi theo ngày.
@immutable
final class SpendingBar {
  const SpendingBar({
    required this.label,
    required this.amount,
    required this.amountText,
    required this.semanticLabel,
    this.highlighted = false,
  });

  /// Nhãn dưới cột ("T4").
  final String label;
  final int amount;

  /// Số tiền đã định dạng (hoặc đã che) hiện trong bong bóng khi chạm.
  final String amountText;

  /// Câu đọc cho trình đọc màn hình ("Thứ Tư, 18/11/2026: chi 45.000 ₫").
  final String semanticLabel;

  /// Cột hôm nay: nhãn đậm.
  final bool highlighted;
}

/// Biểu đồ cột chi 7 ngày theo thiết kế: cột bo tròn 24px, chạm một cột để xem số tiền.
/// Mỗi cột là một nút có nhãn đầy đủ cho trình đọc màn hình.
class SpendingChart extends StatefulWidget {
  const SpendingChart({required this.bars, super.key});

  final List<SpendingBar> bars;

  @override
  State<SpendingChart> createState() => _SpendingChartState();
}

class _SpendingChartState extends State<SpendingChart> {
  /// Mặc định chọn cột cuối (hôm nay).
  int? _selected;

  static const _plotHeight = 120.0;
  static const _minBar = 6.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final bars = widget.bars;
    final selected = _selected ?? bars.length - 1;
    final max = bars.fold<int>(0, (m, b) => b.amount > m ? b.amount : m);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final (i, bar) in bars.indexed)
          Expanded(
            child: Semantics(
              button: true,
              selected: i == selected,
              label: bar.semanticLabel,
              excludeSemantics: true,
              onTap: () => setState(() => _selected = i),
              child: InkWell(
                onTap: () => setState(() => _selected = i),
                borderRadius: const BorderRadius.all(AppRadius.button),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Bong bóng số tiền chỉ hiện ở cột đang chọn; các cột khác giữ chỗ cho thẳng hàng.
                      Visibility(
                        visible: i == selected,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: ShapeDecoration(
                            color: theme.colorScheme.inverseSurface,
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            bar.amountText,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onInverseSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      SizedBox(
                        height: _plotHeight,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 24,
                            height: max == 0
                                ? _minBar
                                : (_minBar + (_plotHeight - _minBar) * bar.amount / max),
                            decoration: BoxDecoration(
                              color: i == selected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primaryContainer,
                              borderRadius: const BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        bar.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: bar.highlighted ? FontWeight.w600 : FontWeight.w400,
                          color: bar.highlighted
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
    );
  }
}
