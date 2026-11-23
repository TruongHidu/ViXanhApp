import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/core_providers.dart';
import '../../../core/enums.dart';
import '../../../core/formatting/money_format.dart';
import '../../../core/money.dart';
import '../../../core/report_period.dart';
import '../../../l10n/compact_amount.dart';
import '../../../l10n/date_labels.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../routing/routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../theme/widgets/category_avatar.dart';
import '../../../theme/widgets/empty_state.dart';
import '../../categories/domain/category_icons.dart';
import '../../transactions/domain/transaction_list_item.dart';
import '../domain/category_share.dart';
import 'reports_providers.dart';
import 'widgets/donut_chart.dart';
import 'widgets/series_chart.dart';

/// Tab Báo cáo: chọn thu / chi và kỳ; cơ cấu theo danh mục, so với kỳ trước, thu – chi 6 kỳ.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenGutter,
            AppSpacing.md,
            AppSpacing.screenGutter,
            AppSpacing.xxl + AppSpacing.xl,
          ),
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppSizes.minTouch),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Semantics(
                  header: true,
                  child: Text(l10n.tabReports, style: theme.textTheme.headlineMedium),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const _Controls(),
            const SizedBox(height: AppSpacing.sm),
            const _BreakdownCard(),
            const SizedBox(height: AppSpacing.md),
            const _CompareCard(),
            const SizedBox(height: AppSpacing.md),
            const _SeriesCard(),
          ],
        ),
      ),
    );
  }
}

class _Controls extends ConsumerWidget {
  const _Controls();

  Future<void> _pickCustom(BuildContext context, WidgetRef ref) async {
    final selection = ref.read(reportSelectionProvider);
    final now = ref.read(clockProvider).now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: DateTimeRange(
        start: selection.period.range.start,
        end: selection.period.lastDay,
      ),
    );
    if (picked != null) {
      ref.read(reportSelectionProvider.notifier).setCustom(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final selection = ref.watch(reportSelectionProvider);
    final notifier = ref.read(reportSelectionProvider.notifier);
    final labels = dateLabelsOf(context, ref.watch(clockProvider));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: l10n.reportTypeGroup,
          container: true,
          child: SegmentedButton<TransactionType>(
            segments: [
              ButtonSegment(value: TransactionType.expense, label: Text(l10n.txnTypeExpense)),
              ButtonSegment(value: TransactionType.income, label: Text(l10n.txnTypeIncome)),
            ],
            selected: {selection.type},
            onSelectionChanged: (s) => notifier.setType(s.single),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Semantics(
          label: l10n.reportPeriodGroup,
          container: true,
          child: Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final (kind, label) in [
                (PeriodKind.week, l10n.reportPeriodWeek),
                (PeriodKind.month, l10n.reportPeriodMonth),
                (PeriodKind.year, l10n.reportPeriodYear),
                (PeriodKind.custom, l10n.reportPeriodCustom),
              ])
                ChoiceChip(
                  label: Text(label),
                  selected: selection.period.kind == kind,
                  onSelected: (_) => kind == PeriodKind.custom
                      ? _pickCustom(context, ref)
                      : notifier.setKind(kind),
                ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: l10n.previousPeriod,
              onPressed: notifier.previous,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Flexible(
              child: Semantics(
                liveRegion: true,
                child: Text(
                  periodLabel(selection.period, l10n, labels),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.nextPeriod,
              onPressed: notifier.next,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.all(AppRadius.card),
    ),
    child: child,
  );
}

class _BreakdownCard extends ConsumerWidget {
  const _BreakdownCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final selection = ref.watch(reportSelectionProvider);
    final totals = ref.watch(reportCategoryTotalsProvider).value;
    final labels = dateLabelsOf(context, ref.watch(clockProvider));
    if (totals == null) return const _Card(child: SizedBox(height: 232));

    final shares = toShares(totals);
    final sum = totals.fold<int>(0, (s, t) => s + t.amount);
    if (shares.isEmpty) {
      return _Card(
        child: EmptyState(
          icon: Icons.pie_chart_outline_rounded,
          message: l10n.reportEmpty(selection.type.name),
        ),
      );
    }

    final totalText = formatMoney(Money(sum));
    final titleLabel = l10n.reportTotal(selection.type.name);
    final period = periodLabel(selection.period, l10n, labels);
    Color colorOf(CategoryShare s) => s.isOther ? CategoryPalette.fallback : Color(s.color!);
    String nameOf(CategoryShare s) => s.isOther ? l10n.reportOther : s.name!;
    final largeText = MediaQuery.textScalerOf(context).scale(16) >= 24;
    final total = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(titleLabel, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(
          totalText,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            label: l10n.reportDonutSummary(
              '$titleLabel $totalText',
              '${nameOf(shares.first)} ${shares.first.percent}%',
            ),
            image: true,
            excludeSemantics: true,
            child: Column(
              children: [
                DonutChart(
                  slices: [for (final s in shares) (fraction: s.fraction, color: colorOf(s))],
                  // Chữ hệ thống lớn: tổng xuống dưới biểu đồ vì tâm vòng tròn không đủ chỗ.
                  center: largeText ? const SizedBox.shrink() : total,
                ),
                if (largeText) ...[const SizedBox(height: AppSpacing.md), total],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final s in shares)
            _ShareRow(
              share: s,
              name: nameOf(s),
              color: colorOf(s),
              barColor: colors.surfaceAlt,
              onTap: s.isOther
                  ? null
                  : () => context.push(
                      Routes.reportCategory(
                        s.categoryId!.value,
                        from: selection.period.range.start,
                        to: selection.period.range.end,
                        type: selection.type.name,
                        title: l10n.reportCategoryTitle(nameOf(s), period),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

class _ShareRow extends StatelessWidget {
  const _ShareRow({
    required this.share,
    required this.name,
    required this.color,
    required this.barColor,
    required this.onTap,
  });

  final CategoryShare share;
  final String name;
  final Color color;
  final Color barColor;

  /// `null` với lát "Khác" (gộp nhiều danh mục, không mở được).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final amount = formatMoney(Money(share.amount));
    // Chữ hệ thống lớn: số tiền và % xuống dưới thanh thay vì tranh chỗ bên phải.
    final stacked = MediaQuery.textScalerOf(context).scale(16) >= 24;
    final figures = [
      Text(amount, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      Text('${share.percent}%', style: theme.textTheme.bodySmall),
    ];
    return Semantics(
      button: onTap != null,
      label: l10n.reportCategoryRow(name, amount, share.percent),
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(AppRadius.button),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                CategoryAvatar(
                  icon: share.isOther ? Icons.more_horiz_rounded : categoryIcon(share.icon!),
                  color: color,
                  semanticLabel: name,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(3)),
                        child: LinearProgressIndicator(
                          value: share.fraction,
                          minHeight: 6,
                          color: color,
                          backgroundColor: barColor,
                        ),
                      ),
                      if (stacked) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(spacing: AppSpacing.sm, children: figures),
                      ],
                    ],
                  ),
                ),
                if (!stacked) ...[
                  const SizedBox(width: AppSpacing.md),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: figures),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompareCard extends ConsumerWidget {
  const _CompareCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final selection = ref.watch(reportSelectionProvider);
    final series = ref.watch(reportSeriesProvider).value;
    if (series == null || series.length < 2) return const SizedBox.shrink();

    int pick(PeriodTotals t) => selection.type == TransactionType.income ? t.income : t.expense;
    final change = percentChange(pick(series.last), pick(series[series.length - 2]));
    // Kỳ trước không có dữ liệu → không có gì để so sánh.
    if (change == null) return const SizedBox.shrink();

    final prev = selection.period.previous;
    final prevName = l10n.reportPreviousName(
      prev.kind.name,
      '${prev.month?.month ?? ''}',
      '${prev.range.start.year}',
    );
    final type = selection.type.name;
    final sentence = change > 0
        ? l10n.reportCompareMore(type, change, prevName)
        : change < 0
        ? l10n.reportCompareLess(type, -change, prevName)
        : l10n.reportCompareSame(type, prevName);
    // Chi giảm / thu tăng là tốt → màu thu; ngược lại màu chi. Luôn kèm mũi tên lên / xuống.
    final good = selection.type == TransactionType.income ? change >= 0 : change <= 0;
    final color = good ? colors.incomeText : colors.expenseText;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.reportCompareTitle(selection.period.kind.name),
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Icon(
                  change > 0
                      ? Icons.trending_up_rounded
                      : change < 0
                      ? Icons.trending_down_rounded
                      : Icons.trending_flat_rounded,
                  color: color,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  sentence,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SeriesCard extends ConsumerWidget {
  const _SeriesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final period = ref.watch(reportSelectionProvider.select((s) => s.period));
    final series = ref.watch(reportSeriesProvider).value;
    final labels = dateLabelsOf(context, ref.watch(clockProvider));
    if (series == null) return const SizedBox.shrink();
    final periods = period.lastN(series.length);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.reportSeriesTitle(period.kind.name),
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SeriesChart(
            incomeLabel: l10n.summaryIncome,
            expenseLabel: l10n.summaryExpense,
            formatAxis: (v) => compactAmount(v, l10n),
            groups: [
              for (final (i, totals) in series.indexed)
                SeriesGroup(
                  label: periodShortLabel(periods[i], labels),
                  income: totals.income,
                  expense: totals.expense,
                  detail: l10n.reportSeriesDetail(
                    periodLabel(periods[i], l10n, labels),
                    formatMoney(Money(totals.income)),
                    formatMoney(Money(totals.expense)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
