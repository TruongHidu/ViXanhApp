import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../tokens.dart';

/// Một mục của [AppBottomBar].
@immutable
final class AppBottomBarItem {
  const AppBottomBarItem({required this.label, required this.icon, required this.selectedIcon});

  final String label;

  /// Icon nét (outlined) khi chưa chọn.
  final IconData icon;

  /// Icon đặc (filled) khi đang chọn — trạng thái không chỉ phân biệt bằng màu.
  final IconData selectedIcon;
}

/// Thanh điều hướng dưới 5 vị trí: 2 mục, khoảng trống giữa cho [AppAddButton], 2 mục.
///
/// Không dùng NavigationBar mặc định vì cần nút giữa. Chữ hệ thống phóng to thì thanh cao lên
/// (nhãn xuống dòng), không cắt chữ, không ellipsis, không FittedBox.
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    required this.items,
    required this.currentIndex,
    required this.onSelect,
    super.key,
  }) : assert(items.length == 4, 'Thanh điều hướng cần đúng 4 mục');

  final List<AppBottomBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  /// Bề rộng chừa ở giữa cho nút "+" nổi (đặt bằng [AppAddButton.location]).
  static const centerGap = AppAddButton.outerSize + AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    Widget item(int i) => Expanded(
      child: _BarItem(item: items[i], selected: i == currentIndex, onTap: () => onSelect(i)),
    );

    return Material(
      color: theme.colorScheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.divider)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                item(0),
                item(1),
                const SizedBox(width: centerGap),
                item(2),
                item(3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({required this.item, required this.selected, required this.onTap});

  final AppBottomBarItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final color = selected ? colors.primaryText : colors.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      // excludeSemantics bỏ cả hành động chạm của InkWell bên trong, nên khai báo lại ở đây.
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.button),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSizes.minTouch,
            minWidth: AppSizes.minTouch,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 2),
                  decoration: ShapeDecoration(
                    shape: AppRadius.pill,
                    color: selected ? theme.colorScheme.primaryContainer : Colors.transparent,
                  ),
                  child: Icon(
                    selected ? item.selectedIcon : item.icon,
                    color: selected ? theme.colorScheme.onPrimaryContainer : color,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Nút "+" tròn 60px nổi lên khỏi thanh điều hướng (theo thiết kế: lệch lên 22px,
/// viền 4px màu nền, bóng nhẹ). Đặt qua `Scaffold.floatingActionButton` với [location]
/// để cả phần nổi lên vẫn nhận chạm.
class AppAddButton extends StatelessWidget {
  const AppAddButton({required this.onPressed, required this.label, super.key});

  final VoidCallback onPressed;

  /// Nhãn trợ năng / tooltip.
  final String label;

  static const ring = 4.0;
  static const outerSize = AppSizes.fab + 2 * ring;

  /// Phần nút nhô lên trên mép thanh điều hướng.
  static const rise = 22.0;

  static const FloatingActionButtonLocation location = _RaisedCenterLocation();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: outerSize,
      height: outerSize,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(ring),
      child: FloatingActionButton(
        heroTag: null,
        tooltip: label,
        onPressed: onPressed,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
    );
  }
}

/// Giữa theo chiều ngang; mép trên của nút cao hơn mép trên thanh điều hướng [AppAddButton.rise]
/// (cộng viền).
final class _RaisedCenterLocation extends FloatingActionButtonLocation {
  const _RaisedCenterLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) {
    final size = geometry.floatingActionButtonSize;
    final x = (geometry.scaffoldSize.width - size.width) / 2;
    final y = geometry.contentBottom - AppAddButton.rise - AppAddButton.ring;
    return Offset(x, y);
  }
}
