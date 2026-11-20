import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../../routing/routes.dart';
import '../../../theme/widgets/empty_state.dart';

/// Tab Giao dịch (tạm): tiêu đề + trạng thái trống có nút thêm giao dịch.
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabTransactions)),
      body: EmptyState(
        icon: Icons.receipt_long_outlined,
        message: l10n.emptyTransactions,
        actionLabel: l10n.addTransaction,
        onAction: () => context.push(Routes.addTransaction),
      ),
    );
  }
}
