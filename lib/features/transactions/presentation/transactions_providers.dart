import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core_providers.dart';
import '../../../core/enums.dart';
import '../../../core/financial_month.dart';
import '../../../core/ids.dart';
import '../../../core/result.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../settings/presentation/settings_notifier.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction_list_item.dart';

/// Trạng thái lọc của tab Giao dịch (bất biến).
@immutable
final class TransactionsFilter {
  const TransactionsFilter({
    required this.month,
    this.type,
    this.walletId,
    this.categoryId,
    this.search = '',
    this.searching = false,
  });

  final FinancialMonth month;

  /// Chip đang chọn: theo loại HOẶC theo ví (thiết kế chỉ chọn một chip); cả hai `null` = "Tất cả".
  final TransactionType? type;
  final WalletId? walletId;
  final CategoryId? categoryId;
  final String search;
  final bool searching;

  bool get isFiltered =>
      type != null || walletId != null || categoryId != null || search.isNotEmpty;

  static const Object _keep = Object();

  TransactionsFilter copyWith({
    FinancialMonth? month,
    Object? type = _keep,
    Object? walletId = _keep,
    Object? categoryId = _keep,
    String? search,
    bool? searching,
  }) => TransactionsFilter(
    month: month ?? this.month,
    type: identical(type, _keep) ? this.type : type as TransactionType?,
    walletId: identical(walletId, _keep) ? this.walletId : walletId as WalletId?,
    categoryId: identical(categoryId, _keep) ? this.categoryId : categoryId as CategoryId?,
    search: search ?? this.search,
    searching: searching ?? this.searching,
  );

  @override
  bool operator ==(Object other) =>
      other is TransactionsFilter &&
      other.month == month &&
      other.type == type &&
      other.walletId == walletId &&
      other.categoryId == categoryId &&
      other.search == search &&
      other.searching == searching;

  @override
  int get hashCode => Object.hash(month, type, walletId, categoryId, search, searching);
}

final transactionsFilterProvider =
    NotifierProvider.autoDispose<TransactionsFilterNotifier, TransactionsFilter>(
      TransactionsFilterNotifier.new,
    );

final class TransactionsFilterNotifier extends Notifier<TransactionsFilter> {
  @override
  TransactionsFilter build() {
    final startDay = ref.read(appPreferencesProvider).monthStartDay;
    return TransactionsFilter(
      month: FinancialMonth.containing(ref.read(clockProvider).now(), startDay),
    );
  }

  void previousMonth() => state = state.copyWith(month: state.month.previous);
  void nextMonth() => state = state.copyWith(month: state.month.next);

  /// Chip "Tất cả".
  void showAll() => state = state.copyWith(type: null, walletId: null);
  void filterType(TransactionType type) => state = state.copyWith(type: type, walletId: null);
  void filterWallet(WalletId id) => state = state.copyWith(walletId: id, type: null);
  void filterCategory(CategoryId? id) => state = state.copyWith(categoryId: id);

  void startSearch() => state = state.copyWith(searching: true);
  void setSearch(String text) => state = state.copyWith(search: text);
  void stopSearch() => state = state.copyWith(searching: false, search: '');
}

/// Khoảng ngày của tháng tài chính đang xem (theo ngày bắt đầu tháng trong Cài đặt).
final selectedRangeProvider = Provider.autoDispose<DateRange>((ref) {
  final month = ref.watch(transactionsFilterProvider.select((f) => f.month));
  final startDay = ref.watch(appPreferencesProvider.select((p) => p.monthStartDay));
  return month.range(startDay);
});

final transactionListProvider = StreamProvider.autoDispose<List<TransactionListItem>>((ref) {
  final f = ref.watch(transactionsFilterProvider);
  return ref
      .watch(transactionRepositoryProvider)
      .watchList(
        TransactionQuery(
          range: ref.watch(selectedRangeProvider),
          type: f.type,
          walletId: f.walletId,
          categoryId: f.categoryId,
          search: f.search,
        ),
      );
});

/// Tổng thu / chi của cả tháng đang xem (không theo bộ lọc chip).
final periodTotalsProvider = StreamProvider.autoDispose<PeriodTotals>(
  (ref) => ref.watch(transactionRepositoryProvider).watchTotals(ref.watch(selectedRangeProvider)),
);

/// Một giao dịch cho màn chi tiết; `null` khi đã bị xóa.
final transactionItemProvider = StreamProvider.autoDispose
    .family<TransactionListItem?, TransactionId>(
      (ref, id) => ref.watch(transactionRepositoryProvider).watchItem(id),
    );

/// Xóa mềm rồi hiện snackbar "Đã xóa giao dịch" có nút "Hoàn tác".
///
/// Dùng ScaffoldMessenger gốc nên snackbar vẫn còn sau khi màn chi tiết đóng lại.
Future<bool> deleteTransactionWithUndo({
  required ScaffoldMessengerState messenger,
  required AppLocalizations l10n,
  required TransactionRepository repository,
  required TransactionId id,
}) async {
  final result = await repository.softDelete(id);
  messenger.hideCurrentSnackBar();
  if (!result.isOk) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.txnDeleteFailed)));
    return false;
  }
  messenger.showSnackBar(
    SnackBar(
      content: Text(l10n.txnDeleted),
      action: SnackBarAction(
        label: l10n.undo,
        onPressed: () async {
          final restored = await repository.restore(id);
          if (restored case Err()) {
            messenger.showSnackBar(SnackBar(content: Text(l10n.txnSaveFailed)));
          }
        },
      ),
    ),
  );
  return true;
}
