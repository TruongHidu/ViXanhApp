import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../tokens.dart';

/// Thẻ ví nhỏ trong dãy cuộn ngang (Tổng quan): icon + tên ví, số dư bên dưới.
class WalletCard extends StatelessWidget {
  const WalletCard({
    required this.icon,
    required this.color,
    required this.name,
    required this.amount,
    required this.negative,
    required this.onTap,
    super.key,
  });

  final IconData icon;

  /// Màu nhận diện của loại ví.
  final Color color;
  final String name;

  /// Đã định dạng (hoặc đã che khi ẩn số dư).
  final String amount;

  /// Số dư âm (thẻ tín dụng đang nợ) → chữ màu chi.
  final bool negative;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    return Semantics(
      button: true,
      label: '$name, $amount',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.all(AppRadius.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.all(AppRadius.card),
          child: Container(
            width: 140,
            constraints: const BoxConstraints(minHeight: 90),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 16, color: color),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  amount,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: negative ? colors.expenseText : theme.colorScheme.onSurface,
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
