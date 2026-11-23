import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/core_providers.dart';
import '../../../core/enums.dart';
import '../../../core/financial_month.dart';
import '../../../core/ids.dart';
import '../../../l10n/date_labels.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../routing/routes.dart';
import '../../../theme/tokens.dart';
import '../../../theme/widgets/transaction_tile.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/domain/transaction_list_item.dart';
import '../../transactions/presentation/transaction_ui.dart';

final _categoryTransactionsProvider = StreamProvider.autoDispose
    .family<List<TransactionListItem>, TransactionQuery>(
      (ref, query) => ref.watch(transactionRepositoryProvider).watchList(query),
    );

/// Giao dịch của một danh mục (gồm mục con) trong một kỳ — mở từ dòng danh mục ở Báo cáo.
class ReportCategoryScreen extends ConsumerWidget {
  const ReportCategoryScreen({
    required this.categoryId,
    required this.range,
    required this.type,
    required this.title,
    super.key,
  });

  final CategoryId categoryId;
  final DateRange range;
  final TransactionType type;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final labels = dateLabelsOf(context, ref.watch(clockProvider));
    final items = ref.watch(
      _categoryTransactionsProvider(
        TransactionQuery(range: range, type: type, categoryId: categoryId),
      ),
    );

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(title, style: theme.textTheme.titleMedium)),
      body: switch (items) {
        AsyncData(:final value) when value.isEmpty => Center(
          child: Text(l10n.reportEmpty(type.name), textAlign: TextAlign.center),
        ),
        AsyncData(:final value) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenGutter,
            AppSpacing.sm,
            AppSpacing.screenGutter,
            AppSpacing.xl,
          ),
          children: [
            Material(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.all(AppRadius.card),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final (i, item) in value.indexed) ...[
                    if (i > 0) const Divider(indent: 68),
                    TransactionTile(
                      avatar: TransactionAvatar(item: item),
                      title: item.title(l10n),
                      subtitle: item.subtitle(l10n),
                      amount: item.signedAmount(),
                      amountColor: transactionTypeStyle(context, item.type).text,
                      trailingCaption: labels.shortDate(item.occurredAt),
                      onTap: () => context.push(Routes.transactionDetail(item.id.value)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        AsyncError() => Center(child: Text(l10n.txnLoadFailed)),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
