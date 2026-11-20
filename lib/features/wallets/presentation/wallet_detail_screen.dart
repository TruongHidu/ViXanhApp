import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/core_providers.dart';
import '../../../core/formatting/money_format.dart';
import '../../../core/ids.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';
import '../../../data/database.dart';
import '../../../l10n/compact_amount.dart';
import '../../../l10n/date_labels.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../routing/routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../theme/typography.dart';
import '../../../theme/widgets/transaction_tile.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/domain/transaction_list_item.dart';
import '../../transactions/presentation/transaction_ui.dart';
import '../data/wallet_repository.dart';
import 'wallet_type_ui.dart';
import 'widgets/balance_chart.dart';

final _walletHistoryProvider = StreamProvider.autoDispose
    .family<List<({DateTime day, int balance})>, WalletId>(
      (ref, id) => ref
          .watch(walletRepositoryProvider)
          .watchBalanceHistory(id, today: ref.watch(clockProvider).now()),
    );

final _walletTransactionsProvider = StreamProvider.autoDispose
    .family<List<TransactionListItem>, WalletId>(
      (ref, id) => ref.watch(transactionRepositoryProvider).watchRecent(limit: 50, walletId: id),
    );

enum _MenuAction { edit, archive }

/// Chi tiết ví: số dư, biểu đồ số dư 30 ngày, giao dịch của ví; menu Sửa / Lưu trữ.
class WalletDetailScreen extends ConsumerWidget {
  const WalletDetailScreen({required this.id, super.key});

  final WalletId id;

  Future<void> _archive(BuildContext context, WidgetRef ref, WalletRow wallet) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.walletArchiveConfirmTitle(wallet.name)),
        content: Text(l10n.walletArchiveConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.walletArchive),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await ref.read(walletRepositoryProvider).archive(id);
    messenger.hideCurrentSnackBar();
    switch (result) {
      case Ok():
        messenger.showSnackBar(SnackBar(content: Text(l10n.walletArchived)));
        if (router.canPop()) router.pop();
      case Err(:final failure):
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              failure.code == WalletErrors.lastWallet
                  ? l10n.walletArchiveLast
                  : l10n.walletSaveFailed,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final wallet = ref.watch(walletProvider(id));

    return switch (wallet) {
      AsyncData(:final value?) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(value.name, style: theme.textTheme.titleMedium),
          actions: [
            PopupMenuButton<_MenuAction>(
              tooltip: l10n.walletOptions,
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (action) => switch (action) {
                _MenuAction.edit => context.push(Routes.editWallet(id.value)),
                _MenuAction.archive => _archive(context, ref, value),
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: _MenuAction.edit, child: Text(l10n.walletEditTitle)),
                PopupMenuItem(value: _MenuAction.archive, child: Text(l10n.walletArchive)),
              ],
            ),
          ],
        ),
        body: _Body(wallet: value),
      ),
      AsyncData() || AsyncError() => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.walletNotFound)),
      ),
      _ => Scaffold(appBar: AppBar()),
    };
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.wallet});

  final WalletRow wallet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final labels = dateLabelsOf(context, ref.watch(clockProvider));
    final balance = ref.watch(walletBalancesProvider).value?[wallet.id] ?? wallet.initialBalance;
    final history = ref.watch(_walletHistoryProvider(wallet.id)).value ?? const [];
    final transactions = ref.watch(_walletTransactionsProvider(wallet.id)).value;
    final subtitle = switch (wallet.accountMasked) {
      final masked? => l10n.walletTypeAndAccount(wallet.type.label(l10n), masked),
      null => wallet.type.label(l10n),
    };

    String money(int v) => formatMoney(Money(v));

    String summary() {
      if (history.isEmpty) return l10n.walletBalance30Days;
      final low = history.reduce((a, b) => b.balance < a.balance ? b : a);
      final high = history.reduce((a, b) => b.balance > a.balance ? b : a);
      return l10n.walletChartSummary(
        labels.shortDate(history.first.day),
        labels.shortDate(history.last.day),
        money(low.balance),
        labels.shortDate(low.day),
        money(high.balance),
        labels.shortDate(high.day),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenGutter,
        AppSpacing.xs,
        AppSpacing.screenGutter,
        AppSpacing.xl,
      ),
      children: [
        MergeSemantics(
          child: Column(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: wallet.type.color.withValues(alpha: 0.2),
                child: Icon(wallet.type.icon, color: wallet.type.color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(subtitle, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
              const SizedBox(height: 6),
              Text(
                money(balance),
                textAlign: TextAlign.center,
                style: theme.extension<AppTextStyles>()!.balanceLarge.copyWith(
                  color: balance < 0 ? colors.expenseText : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.all(AppRadius.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(l10n.walletBalance30Days, style: theme.textTheme.titleMedium),
              ),
              const SizedBox(height: AppSpacing.xs),
              BalanceChart(
                points: history,
                formatValue: money,
                formatDay: labels.shortDate,
                formatAxis: (v) => compactAmount(v, l10n),
                semanticSummary: summary(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.sm),
          child: Semantics(
            header: true,
            child: Text(l10n.walletTransactions, style: theme.textTheme.titleMedium),
          ),
        ),
        if (transactions != null && transactions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Text(
              l10n.walletNoTransactions,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
            ),
          )
        else if (transactions != null)
          Material(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.all(AppRadius.card),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (i, item) in transactions.indexed) ...[
                  if (i > 0) const Divider(indent: 68),
                  TransactionTile(
                    avatar: TransactionAvatar(item: item),
                    title: item.title(l10n),
                    subtitle: _subtitle(item, l10n),
                    amount: _signedForWallet(item),
                    amountColor: _colorForWallet(context, item),
                    trailingCaption: labels.shortDate(item.occurredAt),
                    onTap: () => context.push(Routes.transactionDetail(item.id.value)),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  /// Chuyển khoản nhìn từ ví này: "Chuyển sang MoMo" / "Nhận từ Vietcombank".
  String _subtitle(TransactionListItem item, AppLocalizations l10n) {
    if (!item.isTransfer) return item.subtitle(l10n);
    return item.walletId == wallet.id
        ? l10n.walletTransferTo(item.toWalletName ?? '')
        : l10n.walletTransferFrom(item.walletName);
  }

  /// Chuyển khoản đi trừ (−), đến cộng (+) với ví đang xem.
  String _signedForWallet(TransactionListItem item) {
    if (!item.isTransfer) return item.signedAmount();
    final value = formatMoney(Money(item.amount));
    return item.walletId == wallet.id ? '${Money.minusSign}$value' : '+$value';
  }

  Color _colorForWallet(BuildContext context, TransactionListItem item) {
    final colors = context.appColors;
    if (!item.isTransfer) return transactionTypeStyle(context, item.type).text;
    return item.walletId == wallet.id ? colors.expenseText : colors.incomeText;
  }
}
