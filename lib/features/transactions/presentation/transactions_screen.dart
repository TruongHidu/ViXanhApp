import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/core_providers.dart';
import '../../../core/enums.dart';
import '../../../core/formatting/date_format.dart';
import '../../../core/formatting/money_format.dart';
import '../../../core/money.dart';
import '../../../l10n/date_labels.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../routing/routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../theme/widgets/amount_text.dart';
import '../../../theme/widgets/empty_state.dart';
import '../../../theme/widgets/swipe_action_tile.dart';
import '../../../theme/widgets/transaction_tile.dart';
import '../../../data/daos/categories_dao.dart';
import '../../categories/data/category_repository.dart';
import '../../categories/presentation/widgets/category_picker_sheet.dart';
import '../../settings/presentation/settings_notifier.dart';
import '../../wallets/data/wallet_repository.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction_list_item.dart';
import 'transaction_ui.dart';
import 'transactions_providers.dart';

/// Tab Giao dịch: chọn tháng, tóm tắt thu/chi, lọc, danh sách nhóm theo ngày, vuốt để sửa/xóa.
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => const Scaffold(
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          _Header(),
          _MonthSwitcher(),
          Expanded(child: _Body()),
        ],
      ),
    ),
  );
}

class _Header extends ConsumerStatefulWidget {
  const _Header();

  @override
  ConsumerState<_Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<_Header> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _pickCategory() async {
    final filter = ref.read(transactionsFilterProvider);
    final type = filter.type == TransactionType.income ? CategoryType.income : CategoryType.expense;
    final id = await showCategoryPicker(context, type: type, selected: filter.categoryId);
    if (id != null) ref.read(transactionsFilterProvider.notifier).filterCategory(id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final searching = ref.watch(transactionsFilterProvider.select((f) => f.searching));
    final notifier = ref.read(transactionsFilterProvider.notifier);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenGutter,
          AppSpacing.md,
          AppSpacing.sm,
          0,
        ),
        child: Row(
          children: [
            Expanded(
              child: searching
                  ? TextField(
                      controller: _search,
                      autofocus: true,
                      onChanged: notifier.setSearch,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: l10n.txnSearchHint,
                        prefixIcon: const Icon(Icons.search_rounded),
                      ),
                    )
                  : Semantics(
                      header: true,
                      child: Text(l10n.tabTransactions, style: theme.textTheme.headlineMedium),
                    ),
            ),
            if (searching)
              IconButton(
                tooltip: l10n.txnSearchClose,
                onPressed: () {
                  _search.clear();
                  notifier.stopSearch();
                },
                icon: const Icon(Icons.close_rounded),
              )
            else ...[
              IconButton(
                tooltip: l10n.txnSearchTooltip,
                onPressed: notifier.startSearch,
                icon: const Icon(Icons.search_rounded),
              ),
              IconButton(
                tooltip: l10n.txnFilterTooltip,
                onPressed: _pickCategory,
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MonthSwitcher extends ConsumerWidget {
  const _MonthSwitcher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final month = ref.watch(transactionsFilterProvider.select((f) => f.month));
    final range = ref.watch(selectedRangeProvider);
    final startDay = ref.watch(appPreferencesProvider.select((p) => p.monthStartDay));
    final labels = dateLabelsOf(context, ref.watch(clockProvider));
    final notifier = ref.read(transactionsFilterProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: l10n.previousMonth,
            onPressed: notifier.previousMonth,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 150),
              child: Semantics(
                liveRegion: true,
                child: Column(
                  children: [
                    Text(
                      l10n.monthLabel(month.month, month.year),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                    // Tháng không bắt đầu ngày 1 → ghi rõ khoảng ngày để khỏi hiểu nhầm.
                    if (startDay != 1)
                      Text(
                        l10n.periodRange(
                          labels.shortDate(range.start),
                          labels.shortDate(range.end.subtract(const Duration(days: 1))),
                        ),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.nextMonth,
            onPressed: notifier.nextMonth,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

/// Một phần tử của danh sách phẳng (để dựng lười bằng SliverList cho danh sách dài).
sealed class _Entry {
  const _Entry();
}

final class _DayHeader extends _Entry {
  const _DayHeader(this.day, this.income, this.expense);
  final DateTime day;
  final int income;
  final int expense;
}

final class _Row extends _Entry {
  const _Row(this.item, {required this.first, required this.last});
  final TransactionListItem item;
  final bool first;
  final bool last;
}

class _Body extends ConsumerWidget {
  const _Body();

  static List<_Entry> _entries(List<TransactionListItem> items) {
    final entries = <_Entry>[];
    var i = 0;
    while (i < items.length) {
      final local = items[i].occurredAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      var j = i;
      var income = 0;
      var expense = 0;
      while (j < items.length) {
        final d = items[j].occurredAt.toLocal();
        if (DateTime(d.year, d.month, d.day) != day) break;
        if (items[j].type == TransactionType.income) income += items[j].amount;
        if (items[j].type == TransactionType.expense) expense += items[j].amount;
        j++;
      }
      entries.add(_DayHeader(day, income, expense));
      for (var k = i; k < j; k++) {
        entries.add(_Row(items[k], first: k == i, last: k == j - 1));
      }
      i = j;
    }
    return entries;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final list = ref.watch(transactionListProvider);
    final filter = ref.watch(transactionsFilterProvider);

    return switch (list) {
      AsyncData(:final value) when value.isEmpty && !filter.isFiltered => EmptyState(
        icon: Icons.receipt_long_outlined,
        title: l10n.txnEmptyMonthTitle,
        message: l10n.txnEmptyMonthBody,
        actionLabel: l10n.txnAddFirst,
        onAction: () => context.push(Routes.addTransaction),
      ),
      AsyncData(:final value) => _List(entries: _entries(value), isEmpty: value.isEmpty),
      AsyncError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenGutter),
          child: Text(l10n.txnLoadFailed, textAlign: TextAlign.center),
        ),
      ),
      _ => const _Skeleton(),
    };
  }
}

class _List extends ConsumerWidget {
  const _List({required this.entries, required this.isEmpty});

  final List<_Entry> entries;
  final bool isEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final labels = dateLabelsOf(context, ref.watch(clockProvider));
    const gutter = EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter);

    return CustomScrollView(
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenGutter,
            AppSpacing.xs,
            AppSpacing.screenGutter,
            0,
          ),
          sliver: SliverToBoxAdapter(child: _Summary()),
        ),
        const SliverToBoxAdapter(child: _FilterChips()),
        if (isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenGutter,
              40,
              AppSpacing.screenGutter,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.txnNoMatch,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: context.appColors.textSecondary),
              ),
            ),
          ),
        SliverPadding(
          padding: gutter,
          sliver: SliverList.builder(
            itemCount: entries.length,
            itemBuilder: (context, i) => switch (entries[i]) {
              _DayHeader(:final day, :final income, :final expense) => _DayHeaderView(
                title: labels.groupHeader(day),
                total: expense > 0
                    ? formatSigned(Money(expense), TransactionType.expense)
                    : income > 0
                    ? formatSigned(Money(income), TransactionType.income)
                    : '',
              ),
              _Row(:final item, :final first, :final last) => _TransactionRow(
                item: item,
                first: first,
                last: last,
                labels: labels,
              ),
            },
          ),
        ),
        if (!isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenGutter,
              20,
              AppSpacing.screenGutter,
              AppSpacing.xl,
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.txnSwipeHint,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
      ],
    );
  }
}

class _Summary extends ConsumerWidget {
  const _Summary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final totals = ref.watch(periodTotalsProvider).value ?? PeriodTotals.zero;

    Widget cell(String label, String value, Color color) => Expanded(
      child: Column(
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 2),
          AmountText(
            value,
            textAlign: TextAlign.center,
            alignment: Alignment.center,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
    final divider = Container(width: 1, height: 32, color: colors.divider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.all(AppRadius.card),
      ),
      child: Row(
        children: [
          cell(
            l10n.summaryIncome,
            formatSigned(Money(totals.income), TransactionType.income),
            colors.incomeText,
          ),
          divider,
          cell(
            l10n.summaryExpense,
            formatSigned(Money(totals.expense), TransactionType.expense),
            colors.expenseText,
          ),
          divider,
          cell(
            l10n.summaryRemaining,
            formatMoney(Money(totals.remaining)),
            totals.remaining < 0 ? colors.expenseText : theme.colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends ConsumerWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(transactionsFilterProvider);
    final notifier = ref.read(transactionsFilterProvider.notifier);
    final wallets = ref.watch(activeWalletsProvider).value ?? const [];
    final categoryName = _categoryName(ref, filter);

    Widget chip(String label, {required bool selected, required VoidCallback onTap}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: FilterChip(label: Text(label), selected: selected, onSelected: (_) => onTap()),
    );

    return Semantics(
      label: l10n.txnFilterGroupLabel,
      container: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        child: Row(
          children: [
            if (categoryName != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: InputChip(
                  label: Text(categoryName),
                  selected: true,
                  onPressed: () => notifier.filterCategory(null),
                  onDeleted: () => notifier.filterCategory(null),
                  deleteButtonTooltipMessage: l10n.txnFilterClearCategory(categoryName),
                ),
              ),
            chip(
              l10n.filterAll,
              selected: filter.type == null && filter.walletId == null,
              onTap: notifier.showAll,
            ),
            for (final (type, label) in [
              (TransactionType.expense, l10n.txnTypeExpense),
              (TransactionType.income, l10n.txnTypeIncome),
              (TransactionType.transfer, l10n.txnTypeTransfer),
            ])
              chip(label, selected: filter.type == type, onTap: () => notifier.filterType(type)),
            for (final w in wallets)
              chip(
                w.name,
                selected: filter.walletId == w.id,
                onTap: () => notifier.filterWallet(w.id),
              ),
          ],
        ),
      ),
    );
  }

  static String? _categoryName(WidgetRef ref, TransactionsFilter filter) {
    final id = filter.categoryId;
    if (id == null) return null;
    for (final type in CategoryType.values) {
      for (final node in ref.watch(categoryTreeProvider(type)).value ?? const <CategoryNode>[]) {
        for (final c in [node.category, ...node.children]) {
          if (c.id == id) return c.name;
        }
      }
    }
    return null;
  }
}

class _DayHeaderView extends StatelessWidget {
  const _DayHeaderView({required this.title, required this.total});

  final String title;
  final String total;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: context.appColors.textSecondary,
    );
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xs,
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(child: Text(title, style: style)),
            Text(total, style: style),
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends ConsumerWidget {
  const _TransactionRow({
    required this.item,
    required this.first,
    required this.last,
    required this.labels,
  });

  final TransactionListItem item;
  final bool first;
  final bool last;
  final DateLabelFormatter labels;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final style = transactionTypeStyle(context, item.type);
    final radius = BorderRadius.vertical(
      top: first ? AppRadius.card : Radius.zero,
      bottom: last ? AppRadius.card : Radius.zero,
    );

    return Column(
      children: [
        ClipRRect(
          borderRadius: radius,
          child: SwipeActionTile(
            actions: [
              SwipeAction(
                label: l10n.txnEdit,
                icon: Icons.edit_outlined,
                background: scheme.primary,
                foreground: scheme.onPrimary,
                onPressed: () => context.push(Routes.editTransaction(item.id.value)),
              ),
              SwipeAction(
                label: l10n.txnDelete,
                icon: Icons.delete_outline_rounded,
                background: scheme.error,
                foreground: scheme.onError,
                onPressed: () => deleteTransactionWithUndo(
                  messenger: ScaffoldMessenger.of(context),
                  l10n: l10n,
                  repository: ref.read(transactionRepositoryProvider),
                  id: item.id,
                ),
              ),
            ],
            child: TransactionTile(
              avatar: TransactionAvatar(item: item),
              title: item.title(l10n),
              subtitle: item.subtitle(l10n),
              amount: item.signedAmount(),
              amountColor: style.text,
              trailingCaption: labels.timeLabel(item.occurredAt),
              onTap: () => context.push(Routes.transactionDetail(item.id.value)),
            ),
          ),
        ),
        if (!last) ColoredBox(color: scheme.surface, child: const Divider(indent: 68)),
      ],
    );
  }
}

/// Khung xương lúc đang tải: khối màu bề mặt phụ, không dùng vòng xoay.
class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = context.appColors.surfaceAlt;
    Widget block(double height) => Container(
      height: height,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.all(AppRadius.card)),
    );
    return Semantics(
      label: l10n.txnLoadingLabel,
      child: ExcludeSemantics(
        // ListView không cuộn: màn thấp thì các khối thừa bị cắt gọn thay vì tràn.
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.screenGutter),
          children: [block(64), block(48), block(160), block(160)],
        ),
      ),
    );
  }
}
