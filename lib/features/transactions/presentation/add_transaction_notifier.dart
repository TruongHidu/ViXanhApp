import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/amount_input.dart';
import '../../../core/core_providers.dart';
import '../../../core/enums.dart';
import '../../../core/failure.dart';
import '../../../core/ids.dart';
import '../../../core/result.dart';
import '../../wallets/data/wallet_repository.dart';
import '../data/last_wallet_store.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction_draft.dart';

/// Trạng thái bất biến của màn Thêm/Sửa giao dịch.
@immutable
final class AddTransactionState {
  const AddTransactionState({
    required this.type,
    required this.occurredAt,
    this.amount = const AmountInput(),
    this.categories = const {},
    this.walletId,
    this.toWalletId,
    this.note = '',
    this.payee,
    this.saving = false,
  });

  final TransactionType type;
  final AmountInput amount;

  /// Danh mục đã chọn cho từng loại (đổi tab qua lại không mất lựa chọn).
  final Map<TransactionType, CategoryId> categories;
  final WalletId? walletId;
  final WalletId? toWalletId;
  final DateTime occurredAt;
  final String note;

  /// Giữ nguyên khi sửa; màn này chưa có ô nhập (thiết kế không có).
  final String? payee;
  final bool saving;

  CategoryId? get categoryId => categories[type];

  bool get isTransfer => type == TransactionType.transfer;

  static const Object _keep = Object();

  AddTransactionState copyWith({
    TransactionType? type,
    AmountInput? amount,
    Map<TransactionType, CategoryId>? categories,
    Object? walletId = _keep,
    Object? toWalletId = _keep,
    DateTime? occurredAt,
    String? note,
    bool? saving,
  }) => AddTransactionState(
    type: type ?? this.type,
    amount: amount ?? this.amount,
    categories: categories ?? this.categories,
    walletId: identical(walletId, _keep) ? this.walletId : walletId as WalletId?,
    toWalletId: identical(toWalletId, _keep) ? this.toWalletId : toWalletId as WalletId?,
    occurredAt: occurredAt ?? this.occurredAt,
    note: note ?? this.note,
    payee: payee,
    saving: saving ?? this.saving,
  );

  TransactionDraft toDraft() => TransactionDraft(
    type: type,
    amount: amount.total,
    walletId: walletId ?? const WalletId(''),
    toWalletId: isTransfer ? toWalletId : null,
    categoryId: isTransfer ? null : categoryId,
    occurredAt: occurredAt,
    payee: payee,
    note: note,
  );
}

/// Tham số mở màn: [editingId] `null` = thêm mới, có id = sửa giao dịch đó;
/// [initialType] = tab chọn sẵn khi thêm mới (ví dụ "Chuyển tiền giữa các ví").
typedef AddTransactionArgs = ({TransactionId? editingId, TransactionType initialType});

final addTransactionProvider = AsyncNotifierProvider.autoDispose
    .family<AddTransactionNotifier, AddTransactionState, AddTransactionArgs>(
      AddTransactionNotifier.new,
    );

final class AddTransactionNotifier extends AsyncNotifier<AddTransactionState> {
  AddTransactionNotifier(AddTransactionArgs args)
    : editingId = args.editingId,
      initialType = args.initialType;

  final TransactionId? editingId;
  final TransactionType initialType;

  bool get isEditing => editingId != null;

  @override
  Future<AddTransactionState> build() async {
    final now = ref.read(clockProvider).now();
    final repo = ref.read(transactionRepositoryProvider);
    final wallets = (await ref.read(walletRepositoryProvider).watchActive().first)
        .map((w) => w.id)
        .toList();

    final id = editingId;
    if (id != null) {
      final draft = switch (await repo.findDraft(id)) {
        Ok(:final value) => value,
        Err(:final failure) => throw failure,
      };
      return AddTransactionState(
        type: draft.type,
        occurredAt: draft.occurredAt,
        amount: AmountInput.of(draft.amount),
        categories: {if (draft.categoryId case final c?) draft.type: c},
        walletId: draft.walletId,
        toWalletId: draft.toWalletId,
        note: draft.note ?? '',
        payee: draft.payee,
      );
    }

    final last = ref.read(lastWalletStoreProvider).read();
    final walletId = wallets.contains(last) ? last : wallets.firstOrNull;
    final toWalletId = wallets.where((w) => w != walletId).firstOrNull;
    Future<CategoryId?> mostRecent(CategoryType type) async =>
        (await repo.recentCategories(type, limit: 1)).valueOrNull?.firstOrNull?.id;

    return AddTransactionState(
      type: initialType,
      occurredAt: now,
      walletId: walletId,
      toWalletId: toWalletId,
      categories: {
        if (await mostRecent(CategoryType.expense) case final c?) TransactionType.expense: c,
        if (await mostRecent(CategoryType.income) case final c?) TransactionType.income: c,
      },
    );
  }

  void _update(AddTransactionState Function(AddTransactionState s) change) {
    final current = state.value;
    if (current == null || current.saving) return;
    state = AsyncData(change(current));
  }

  void setType(TransactionType type) => _update((s) => s.copyWith(type: type));
  void pressDigit(String digit) => _update((s) => s.copyWith(amount: s.amount.digit(digit)));
  void pressThousand() => _update((s) => s.copyWith(amount: s.amount.thousand()));
  void pressSign(String sign) => _update((s) => s.copyWith(amount: s.amount.sign(sign)));
  void backspace() => _update((s) => s.copyWith(amount: s.amount.backspace()));
  void quickAmount(int value) =>
      _update((s) => s.copyWith(amount: s.amount.replaceLastOperand(value)));
  void setNote(String note) => _update((s) => s.copyWith(note: note));
  void setOccurredAt(DateTime at) => _update((s) => s.copyWith(occurredAt: at));

  void pickCategory(CategoryId id) =>
      _update((s) => s.copyWith(categories: {...s.categories, s.type: id}));

  void pickWallet(WalletId id) => _update(
    (s) => s.copyWith(
      walletId: id,
      // Chọn ví đi trùng ví đến → đổi chỗ, để hai ví luôn khác nhau.
      toWalletId: s.toWalletId == id ? s.walletId : s.toWalletId,
    ),
  );

  void pickToWallet(WalletId id) => _update(
    (s) => s.copyWith(toWalletId: id, walletId: s.walletId == id ? s.toWalletId : s.walletId),
  );

  void swapWallets() => _update((s) => s.copyWith(walletId: s.toWalletId, toWalletId: s.walletId));

  /// Lưu. [keepOpen] = "Lưu & thêm tiếp": giữ loại, ví, danh mục; xóa số tiền và ghi chú.
  Future<Result<TransactionDraft>> save({bool keepOpen = false}) async {
    final current = state.value;
    if (current == null || current.saving) {
      return const Err(UnexpectedFailure('Màn hình chưa sẵn sàng'));
    }
    if (current.amount.total <= 0) {
      return const Err(
        ValidationFailure('Chưa nhập số tiền', code: TransactionErrors.amountInvalid),
      );
    }
    final draft = current.toDraft();
    state = AsyncData(current.copyWith(saving: true));

    final repo = ref.read(transactionRepositoryProvider);
    final id = editingId;
    final Result<void> result = id == null ? await repo.add(draft) : await repo.update(id, draft);
    if (!ref.mounted) return result.map((_) => draft);

    if (result case Err(:final failure)) {
      state = AsyncData(current);
      return Err(failure);
    }
    await ref.read(lastWalletStoreProvider).write(draft.walletId);
    if (!ref.mounted) return Ok(draft);
    state = AsyncData(
      keepOpen
          ? current.copyWith(
              amount: const AmountInput(),
              note: '',
              occurredAt: ref.read(clockProvider).now(),
            )
          : current,
    );
    return Ok(draft);
  }
}
