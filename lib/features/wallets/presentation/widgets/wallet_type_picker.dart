import 'package:flutter/material.dart';

import '../../../../core/enums.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/tokens.dart';
import '../wallet_type_ui.dart';

/// Lưới 2×2 chọn loại ví (Tiền mặt / Ngân hàng / Ví điện tử / Thẻ tín dụng).
/// Dùng ở Thiết lập ban đầu và form thêm ví.
class WalletTypePicker extends StatelessWidget {
  const WalletTypePicker({required this.selected, required this.onPick, super.key});

  final WalletType? selected;
  final ValueChanged<WalletType> onPick;

  @override
  Widget build(BuildContext context) {
    Widget row(WalletType a, WalletType b) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _TypeCard(type: a, selected: selected == a, onTap: () => onPick(a)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _TypeCard(type: b, selected: selected == b, onTap: () => onPick(b)),
          ),
        ],
      ),
    );

    return Column(
      children: [
        row(WalletType.cash, WalletType.bank),
        const SizedBox(height: AppSpacing.md),
        row(WalletType.ewallet, WalletType.credit),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({required this.type, required this.selected, required this.onTap});

  final WalletType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final label = type.label(l10n);
    final hint = type.hint(l10n);
    const radius = BorderRadius.all(AppRadius.card);
    final background = selected
        ? Color.alphaBlend(scheme.primaryContainer.withValues(alpha: 0.4), scheme.surface)
        : scheme.surface;

    return Semantics(
      button: true,
      selected: selected,
      label: '$label, $hint',
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: selected ? scheme.primary : Colors.transparent, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 120),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: type.color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(type.icon, color: type.color, size: 24),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        label,
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
                      child: Icon(Icons.check_rounded, size: 16, color: scheme.onPrimary),
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
