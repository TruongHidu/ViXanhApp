import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums.dart';
import '../../../core/formatting/money_format.dart';
import '../../../core/money.dart';
import '../../../data/database.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../routing/routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../theme/widgets/amount_text.dart';
import '../data/wallet_repository.dart';
import '../domain/wallet_summary.dart';
import 'wallet_type_ui.dart';

/// Ví của tôi: tổng tài sản / nợ / tài sản ròng, ví nhóm theo loại, thêm ví, chuyển tiền.
class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final wallets = ref.watch(activeWalletsProvider).value ?? const <WalletRow>[];
    final balances = ref.watch(walletBalancesProvider).value ?? const {};
    int balanceOf(WalletRow w) => balances[w.id] ?? w.initialBalance;

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenGutter,
          0,
          AppSpacing.screenGutter,
          AppSpacing.xl,
        ),
        children: [
          Semantics(
            header: true,
            child: Text(l10n.walletsTitle, style: theme.textTheme.headlineMedium),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SummaryCard(summary: WalletSummary.fromBalances(wallets.map(balanceOf))),
          for (final type in WalletType.values)
            if (wallets.where((w) => w.type == type).toList() case final group
                when group.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xs, 20, AppSpacing.xs, AppSpacing.sm),
                child: Semantics(
                  header: true,
                  child: Text(
                    type.label(l10n),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ),
              ),
              Material(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.all(AppRadius.card),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final (i, w) in group.indexed) ...[
                      if (i > 0) const Divider(indent: 68),
                      _WalletRowTile(wallet: w, balance: balanceOf(w)),
                    ],
                  ],
                ),
              ),
            ],
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: () => context.push(Routes.newWallet),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.walletAdd),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => context.push(Routes.addTransfer),
            icon: const Icon(Icons.swap_horiz_rounded),
            label: Text(l10n.walletTransferBetween),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final WalletSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;

    Widget row(
      String label,
      String value, {
      TextStyle? labelStyle,
      TextStyle? valueStyle,
    }) => MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          // Số tiền được phần rộng hơn (thu nhỏ khi vẫn thiếu chỗ), nhãn xuống dòng nếu cần.
          Expanded(
            flex: 2,
            child: Text(
              label,
              style:
                  labelStyle ?? theme.textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            flex: 3,
            child: AmountText(
              value,
              textAlign: TextAlign.end,
              alignment: AlignmentDirectional.centerEnd,
              style: valueStyle ?? theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.all(AppRadius.card),
      ),
      child: Column(
        children: [
          row(l10n.walletsTotalAssets, formatMoney(Money(summary.assets))),
          const SizedBox(height: AppSpacing.sm),
          row(
            l10n.walletsDebt,
            formatMoney(Money(summary.debt)),
            valueStyle: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: summary.debt < 0 ? colors.expenseText : null,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Divider(color: colors.divider),
          const SizedBox(height: AppSpacing.sm),
          row(
            l10n.walletsNetWorth,
            formatMoney(Money(summary.netWorth)),
            labelStyle: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            valueStyle: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: summary.netWorth < 0 ? colors.expenseText : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletRowTile extends StatelessWidget {
  const _WalletRowTile({required this.wallet, required this.balance});

  final WalletRow wallet;
  final int balance;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final amount = formatMoney(Money(balance));
    final subtitle = wallet.accountMasked ?? wallet.type.hint(l10n);

    return Semantics(
      button: true,
      label: '${wallet.name}, $subtitle, $amount',
      excludeSemantics: true,
      onTap: () => context.push(Routes.walletDetail(wallet.id.value)),
      child: InkWell(
        onTap: () => context.push(Routes.walletDetail(wallet.id.value)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: wallet.type.color.withValues(alpha: 0.2),
                  child: Icon(wallet.type.icon, color: wallet.type.color, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallet.name,
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(subtitle, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: AmountText(
                    amount,
                    textAlign: TextAlign.end,
                    alignment: AlignmentDirectional.centerEnd,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: balance < 0 ? colors.expenseText : null,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
