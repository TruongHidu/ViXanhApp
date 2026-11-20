import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../tokens.dart';

/// Dòng giao dịch dùng chung (danh sách, Tổng quan, chi tiết ví):
/// [avatar] | tiêu đề đậm + dòng phụ | số tiền căn phải + giờ.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.avatar,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    required this.trailingCaption,
    required this.onTap,
    this.semanticLabel,
    super.key,
  });

  final Widget avatar;
  final String title;
  final String subtitle;

  /// Đã định dạng kèm dấu ("−45.000 ₫").
  final String amount;
  final Color amountColor;

  /// Thường là giờ ("08:15").
  final String trailingCaption;
  final VoidCallback onTap;

  /// Câu đọc cho trình đọc màn hình; mặc định ghép các phần hiển thị.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    return Semantics(
      button: true,
      label: semanticLabel ?? '$title, $subtitle, $amount, $trailingCaption',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Row(
              children: [
                avatar,
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amount,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: amountColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(trailingCaption, style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
