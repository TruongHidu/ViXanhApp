import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/core_providers.dart';
import '../../../core/enums.dart';
import '../../../core/formatting/money_format.dart';
import '../../../core/money.dart';
import '../../../l10n/date_labels.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../routing/routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../theme/typography.dart';
import '../../../theme/widgets/empty_state.dart';
import '../../../theme/widgets/transaction_tile.dart';
import '../../../theme/widgets/wallet_card.dart';
import '../../settings/presentation/settings_notifier.dart';
import '../../transactions/presentation/transaction_ui.dart';
import '../../transactions/domain/transaction_list_item.dart';
import '../../wallets/data/wallet_repository.dart';
import '../../wallets/presentation/wallet_type_ui.dart';
import 'home_providers.dart';
import 'widgets/spending_chart.dart';

/// Tab Tổng quan: lời chào, tổng số dư, thu/chi tháng, ví, chi 7 ngày, giao dịch gần đây.
///
/// Bật "ẩn số dư" thì MỌI số tiền trên màn được che.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => const Scaffold(
    body: SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenGutter,
              AppSpacing.md,
              AppSpacing.screenGutter,
              AppSpacing.xl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                _Header(),
                SizedBox(height: AppSpacing.sm),
                _BalanceCard(),
                SizedBox(height: AppSpacing.xl),
                _WalletsSection(),
                SizedBox(height: AppSpacing.xl),
                _SpendingSection(),
                SizedBox(height: AppSpacing.xl),
                _RecentSection(),
              ]),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Định dạng tiền có tôn trọng "ẩn số dư".
String Function(String formatted) _masker(WidgetRef ref) {
  final hidden = ref.watch(appPreferencesProvider.select((p) => p.hideBalance));
  return (formatted) => hidden ? formatMasked() : formatted;
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider).now().toLocal();
    final name = ref.watch(appPreferencesProvider.select((p) => p.userName));
    final hidden = ref.watch(appPreferencesProvider.select((p) => p.hideBalance));
    final greeting = switch (now.hour) {
      >= 4 && < 11 => l10n.greetingMorning,
      >= 11 && < 18 => l10n.greetingAfternoon,
      _ => l10n.greetingEvening,
    };

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    name == null ? greeting : l10n.greetingWithName(greeting, name),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateLabelsOf(context, ref.watch(clockProvider)).longDate(now),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: hidden ? l10n.showBalance : l10n.hideBalance,
            onPressed: () => ref.read(appPreferencesProvider.notifier).setHideBalance(!hidden),
            icon: Icon(hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends ConsumerWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final mask = _masker(ref);
    final total = ref.watch(totalBalanceProvider).value;
    final month = ref.watch(homeMonthTotalsProvider).value;
    final balanceStyle = theme.extension<AppTextStyles>()!.balanceLarge;
    final divider = colors.divider;

    Widget cell(String label, IconData icon, Color fg, Color bg, String value) => Expanded(
      child: MergeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                    child: Icon(icon, size: 14, color: fg),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: fg),
            ),
          ],
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.all(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MergeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeTotalBalance,
                  style: theme.textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                ),
                Text(
                  total == null ? ' ' : mask(formatMoney(Money(total))),
                  style: balanceStyle.copyWith(
                    color: (total ?? 0) < 0 ? colors.expenseText : balanceStyle.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(color: divider, height: 1),
          const SizedBox(height: AppSpacing.lg),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                cell(
                  l10n.homeIncomeMonth,
                  Icons.arrow_downward_rounded,
                  colors.incomeText,
                  colors.incomeBg,
                  mask(formatSigned(Money(month?.income ?? 0), TransactionType.income)),
                ),
                VerticalDivider(color: divider, width: 33),
                cell(
                  l10n.homeExpenseMonth,
                  Icons.arrow_upward_rounded,
                  colors.expenseText,
                  colors.expenseBg,
                  mask(formatSigned(Money(month?.expense ?? 0), TransactionType.expense)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSizes.minTouch),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
          if (onSeeAll case final onTap?)
            Flexible(
              child: TextButton(
                onPressed: onTap,
                child: Text(l10n.seeAll, textAlign: TextAlign.end),
              ),
            ),
        ],
      ),
    );
  }
}

class _WalletsSection extends ConsumerWidget {
  const _WalletsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mask = _masker(ref);
    final wallets = ref.watch(activeWalletsProvider).value ?? const [];
    final balances = ref.watch(walletBalancesProvider).value ?? const {};
    if (wallets.isEmpty) return const SizedBox.shrink();

    void openWallets() => context.push(Routes.wallets);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: l10n.homeWallets, onSeeAll: openWallets),
        const SizedBox(height: AppSpacing.xs),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, w) in wallets.indexed) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.md),
                  WalletCard(
                    icon: w.type.icon,
                    color: w.type.color,
                    name: w.name,
                    amount: mask(formatMoney(Money(balances[w.id] ?? w.initialBalance))),
                    negative: (balances[w.id] ?? w.initialBalance) < 0,
                    onTap: () => context.push(Routes.walletDetail(w.id.value)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SpendingSection extends ConsumerWidget {
  const _SpendingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final mask = _masker(ref);
    final range = ref.watch(last7DaysRangeProvider);
    final daily = ref.watch(homeDailyExpenseProvider).value ?? const {};
    final labels = dateLabelsOf(context, ref.watch(clockProvider));

    final days = [
      for (var i = 0; i < 7; i++)
        DateTime(range.start.year, range.start.month, range.start.day + i),
    ];
    final total = days.fold<int>(0, (sum, d) => sum + (daily[d] ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: l10n.homeSpending7Days),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.all(AppRadius.card),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.homeSpendingCaption(
                  mask(formatMoney(Money(total))),
                  mask(formatMoney(Money(total ~/ days.length))),
                ),
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              SpendingChart(
                bars: [
                  for (final (i, d) in days.indexed)
                    SpendingBar(
                      label: l10n.weekdayShort('${d.weekday}'),
                      amount: daily[d] ?? 0,
                      amountText: mask(formatMoney(Money(daily[d] ?? 0))),
                      semanticLabel: l10n.homeChartDay(
                        labels.longDate(d),
                        mask(formatMoney(Money(daily[d] ?? 0))),
                      ),
                      highlighted: i == days.length - 1,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentSection extends ConsumerWidget {
  const _RecentSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final mask = _masker(ref);
    final recent = ref.watch(recentTransactionsProvider).value;
    final labels = dateLabelsOf(context, ref.watch(clockProvider));

    if (recent == null) return const SizedBox.shrink();
    if (recent.isEmpty) {
      return EmptyState(
        icon: Icons.savings_outlined,
        message: l10n.emptyOverview,
        actionLabel: l10n.addTransaction,
        onAction: () => context.push(Routes.addTransaction),
      );
    }

    Widget tile(TransactionListItem item) => TransactionTile(
      avatar: TransactionAvatar(item: item),
      title: item.title(l10n),
      subtitle: item.subtitle(l10n),
      amount: mask(item.signedAmount()),
      amountColor: transactionTypeStyle(context, item.type).text,
      trailingCaption: labels.dayLabel(item.occurredAt) == labels.longDate(item.occurredAt)
          ? labels.shortDate(item.occurredAt)
          : labels.timeLabel(item.occurredAt),
      onTap: () => context.push(Routes.transactionDetail(item.id.value)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: l10n.homeRecent, onSeeAll: () => context.go(Routes.transactions)),
        const SizedBox(height: AppSpacing.xs),
        Material(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.all(AppRadius.card),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final (i, item) in recent.indexed) ...[
                if (i > 0) const Divider(indent: 68),
                tile(item),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
