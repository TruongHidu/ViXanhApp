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

/// Thanh điều hướng dưới 5 vị trí: 2 mục, nút "+" tròn 60px ở giữa, 2 mục.
///
/// Không dùng NavigationBar mặc định vì cần nút giữa. Chữ hệ thống phóng to thì thanh cao lên
/// (nhãn xuống dòng), không cắt chữ, không ellipsis, không FittedBox.
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    required this.items,
    required this.currentIndex,
    required this.onSelect,
    required this.onAdd,
    required this.addLabel,
    super.key,
  }) : assert(items.length == 4, 'Thanh điều hướng cần đúng 4 mục');

  final List<AppBottomBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;

  /// Nhãn trợ năng của nút "+".
  final String addLabel;

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: FloatingActionButton(
                    heroTag: null,
                    tooltip: addLabel,
                    onPressed: onAdd,
                    child: const Icon(Icons.add_rounded, size: 30),
                  ),
                ),
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
