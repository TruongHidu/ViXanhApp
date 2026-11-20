import 'package:flutter/material.dart';

import '../../../core/enums.dart';
import '../../../core/formatting/money_format.dart';
import '../../../core/money.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../theme/widgets/category_avatar.dart';
import '../../categories/domain/category_icons.dart';
import '../domain/transaction_list_item.dart';

/// Cách hiển thị một giao dịch, dùng chung cho danh sách, chi tiết, Tổng quan.
extension TransactionItemUi on TransactionListItem {
  /// Tên giao dịch nếu có, không thì tên danh mục; chuyển khoản không có tên → "Chuyển khoản".
  String title(AppLocalizations l10n) =>
      payee ?? categoryName ?? (isTransfer ? l10n.txnTypeTransfer : l10n.txnTypeExpense);

  /// "Ăn uống · Tiền mặt"; chuyển khoản "Vietcombank → MoMo".
  String subtitle(AppLocalizations l10n) {
    if (isTransfer) return '$walletName → ${toWalletName ?? ''}';
    final category = payee != null ? categoryName : null;
    return [?category, walletName].join(' · ');
  }

  String signedAmount() => formatSigned(Money(amount), type);

  String sourceLabel(AppLocalizations l10n) => switch (source) {
    TransactionSource.manual => l10n.txnSourceManual,
    TransactionSource.notification => l10n.txnSourceNotification,
    TransactionSource.webhook => l10n.txnSourceWebhook,
    TransactionSource.recurring => l10n.txnSourceRecurring,
    TransactionSource.import => l10n.txnSourceImport,
  };
}

/// Màu chữ (đạt AA), màu nền nhạt và icon mũi tên theo loại giao dịch.
({Color text, Color background, IconData arrow}) transactionTypeStyle(
  BuildContext context,
  TransactionType type,
) {
  final c = context.appColors;
  return switch (type) {
    TransactionType.expense => (
      text: c.expenseText,
      background: c.expenseBg,
      arrow: Icons.arrow_upward_rounded,
    ),
    TransactionType.income => (
      text: c.incomeText,
      background: c.incomeBg,
      arrow: Icons.arrow_downward_rounded,
    ),
    TransactionType.transfer => (
      text: c.transferText,
      background: c.transferBg,
      arrow: Icons.swap_horiz_rounded,
    ),
  };
}

/// Icon danh mục kèm huy hiệu mũi tên nhỏ ở góc (thu/chi không chỉ phân biệt bằng màu).
class TransactionAvatar extends StatelessWidget {
  const TransactionAvatar({required this.item, this.size = AppSizes.categoryIcon, super.key});

  final TransactionListItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final style = transactionTypeStyle(context, item.type);
    final badge = size / 2;
    return SizedBox.square(
      dimension: size + 4,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          item.isTransfer
              ? CategoryAvatar(
                  icon: Icons.swap_horiz_rounded,
                  color: colors.transfer,
                  semanticLabel: l10n.txnTypeTransfer,
                  size: size,
                )
              : CategoryAvatar(
                  icon: categoryIcon(item.categoryIcon ?? ''),
                  color: Color(item.categoryColor ?? CategoryPalette.fallback.toARGB32()),
                  semanticLabel: item.categoryName ?? '',
                  size: size,
                ),
          if (!item.isTransfer)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: badge,
                height: badge,
                decoration: BoxDecoration(
                  color: style.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
                ),
                child: Icon(style.arrow, size: badge * 0.6, color: style.text),
              ),
            ),
        ],
      ),
    );
  }
}
