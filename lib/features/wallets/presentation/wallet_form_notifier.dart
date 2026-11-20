import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums.dart';
import '../../../core/failure.dart';
import '../../../core/ids.dart';
import '../../../core/result.dart';
import '../data/wallet_repository.dart';

/// Trạng thái bất biến của form Thêm / Sửa ví.
@immutable
final class WalletFormState {
  const WalletFormState({
    this.type,
    this.name = '',
    this.nameEdited = false,
    this.amount = 0,
    this.accountLast4 = '',
    this.saving = false,
  });

  final WalletType? type;
  final String name;

  /// Người dùng đã tự sửa tên → đổi loại ví không ghi đè tên gợi ý.
  final bool nameEdited;

  /// Số dư (≥ 0); với thẻ tín dụng là số dư nợ.
  final int amount;
  final String accountLast4;
  final bool saving;

  bool get isNameValid {
    final length = name.trim().length;
    return length >= WalletRepository.minNameLength && length <= WalletRepository.maxNameLength;
  }

  bool get isAccountValid => accountLast4.isEmpty || RegExp(r'^\d{4}$').hasMatch(accountLast4);

  bool get canSave => type != null && isNameValid && isAccountValid && !saving;

  /// Thẻ tín dụng lưu dư nợ thành số âm.
  int get initialBalance => type == WalletType.credit ? -amount : amount;

  WalletFormState copyWith({
    WalletType? type,
    String? name,
    bool? nameEdited,
    int? amount,
    String? accountLast4,
    bool? saving,
  }) => WalletFormState(
    type: type ?? this.type,
    name: name ?? this.name,
    nameEdited: nameEdited ?? this.nameEdited,
    amount: amount ?? this.amount,
    accountLast4: accountLast4 ?? this.accountLast4,
    saving: saving ?? this.saving,
  );
}

/// `null` = thêm ví mới; có id = sửa ví đó.
final walletFormProvider = AsyncNotifierProvider.autoDispose
    .family<WalletFormNotifier, WalletFormState, WalletId?>(WalletFormNotifier.new);

final class WalletFormNotifier extends AsyncNotifier<WalletFormState> {
  WalletFormNotifier(this.walletId);

  final WalletId? walletId;

  @override
  Future<WalletFormState> build() async {
    final id = walletId;
    if (id == null) return const WalletFormState();
    final wallet = await ref.read(walletRepositoryProvider).watchWallet(id).first;
    if (wallet == null) throw const NotFoundFailure('Không tìm thấy ví');
    return WalletFormState(
      type: wallet.type,
      name: wallet.name,
      nameEdited: true,
      amount: wallet.initialBalance.abs(),
      accountLast4: WalletRepository.unmaskAccount(wallet.accountMasked) ?? '',
    );
  }

  void _update(WalletFormState Function(WalletFormState s) change) {
    final current = state.value;
    if (current == null || current.saving) return;
    state = AsyncData(change(current));
  }

  /// [suggestedName] (đã dịch) điền vào tên nếu người dùng chưa tự sửa.
  void pickType(WalletType type, String suggestedName) =>
      _update((s) => s.copyWith(type: type, name: s.nameEdited ? null : suggestedName));

  void setName(String name) => _update((s) => s.copyWith(name: name, nameEdited: true));
  void setAmount(int amount) => _update((s) => s.copyWith(amount: amount < 0 ? 0 : amount));
  void setAccount(String last4) => _update((s) => s.copyWith(accountLast4: last4.trim()));

  Future<Result<void>> save() async {
    final current = state.value;
    if (current == null || !current.canSave) {
      return const Err(ValidationFailure('Form ví chưa hợp lệ', code: WalletErrors.nameInvalid));
    }
    state = AsyncData(current.copyWith(saving: true));
    final repo = ref.read(walletRepositoryProvider);
    final id = walletId;
    final Result<void> result = id == null
        ? await repo.create(
            name: current.name,
            type: current.type!,
            initialBalance: current.initialBalance,
            accountLast4: current.accountLast4,
          )
        : await repo.update(
            id,
            name: current.name,
            type: current.type!,
            initialBalance: current.initialBalance,
            accountLast4: current.accountLast4,
          );
    if (ref.mounted) state = AsyncData(current);
    return result;
  }
}
