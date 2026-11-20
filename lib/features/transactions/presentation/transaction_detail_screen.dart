import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/core_providers.dart';
import '../../../core/ids.dart';
import '../../../l10n/date_labels.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../routing/routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction_list_item.dart';
import 'transaction_ui.dart';
import 'transactions_providers.dart';

/// Chi tiết một giao dịch: số tiền, danh mục, ví, thời gian, ghi chú, nguồn; Xóa / Chỉnh sửa.
class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({required this.id, super.key});

  final TransactionId id;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final router = GoRouter.of(context);
    final deleted = await deleteTransactionWithUndo(
      messenger: ScaffoldMessenger.of(context),
      l10n: AppLocalizations.of(context),
      repository: ref.read(transactionRepositoryProvider),
      id: id,
    );
    if (deleted && router.canPop()) router.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final item = ref.watch(transactionItemProvider(id));

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.txnDetailTitle, style: theme.textTheme.titleMedium),
      ),
      body: switch (item) {
        AsyncData(:final value?) => Column(
          children: [
            Expanded(child: _Details(item: value)),
            _Actions(
              onDelete: () => _delete(context, ref),
              onEdit: () => context.push(Routes.editTransaction(id.value)),
            ),
          ],
        ),
        AsyncData() || AsyncError() => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenGutter),
            child: Text(l10n.txnNotFound, textAlign: TextAlign.center),
          ),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _Details extends ConsumerWidget {
  const _Details({required this.item});

  final TransactionListItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final style = transactionTypeStyle(context, item.type);
    final labels = dateLabelsOf(context, ref.watch(clockProvider));
    final heading = item.isTransfer ? l10n.txnTypeTransfer : (item.categoryName ?? '');

    final rows = <(String, String)>[
      (
        l10n.txnFieldWallet,
        item.isTransfer ? '${item.walletName} → ${item.toWalletName ?? ''}' : item.walletName,
      ),
      (l10n.txnFieldTime, labels.fullDateTime(item.occurredAt)),
      if (item.note case final note?) (l10n.txnNoteLabel, note),
      (l10n.txnFieldSource, item.sourceLabel(l10n)),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenGutter,
        AppSpacing.md,
        AppSpacing.screenGutter,
        AppSpacing.xl,
      ),
      children: [
        Semantics(
          container: true,
          label: '${item.signedAmount()}, $heading',
          excludeSemantics: true,
          child: Column(
            children: [
              TransactionAvatar(item: item, size: 64),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(style.arrow, color: style.text, size: 24),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      item.signedAmount(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall?.copyWith(color: style.text),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(heading, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
              if (item.payee case final payee?)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    payee,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.all(AppRadius.card),
          ),
          child: Column(
            children: [
              for (final (i, (label, value)) in rows.indexed) ...[
                if (i > 0) const Divider(),
                MergeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Text(
                            value,
                            textAlign: TextAlign.end,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.onDelete, required this.onEdit});

  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenGutter,
            AppSpacing.md,
            AppSpacing.screenGutter,
            AppSpacing.lg,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 10,
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.expenseText,
                    side: BorderSide(color: colors.expense, width: 1.5),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(l10n.txnDelete),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 16,
                child: FilledButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l10n.txnEditAction),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
