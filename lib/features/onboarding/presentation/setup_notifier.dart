import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums.dart';
import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../settings/domain/app_preferences.dart';
import '../../settings/presentation/settings_notifier.dart';
import '../../wallets/data/wallet_repository.dart';

/// Bước của Thiết lập ban đầu. Bước "Bảo vệ dữ liệu" (PIN) làm ở tuần 7–8.
enum SetupStep { profile, wallet }

/// Trạng thái bất biến của luồng Thiết lập.
@immutable
final class SetupState {
  const SetupState({
    this.step = SetupStep.profile,
    this.userName = '',
    this.monthStartDay = AppPreferences.defaultMonthStartDay,
    this.walletType,
    this.walletName = '',
    this.walletNameEdited = false,
    this.balance = 0,
    this.submitting = false,
  });

  final SetupStep step;
  final String userName;
  final int monthStartDay;
  final WalletType? walletType;
  final String walletName;

  /// Người dùng đã tự sửa tên ví → đổi loại ví không ghi đè tên nữa.
  final bool walletNameEdited;

  /// Số dư (hoặc dư nợ với thẻ tín dụng) người dùng nhập, luôn ≥ 0.
  final int balance;
  final bool submitting;

  static const totalSteps = 2;

  int get stepNumber => step.index + 1;

  bool get isWalletNameValid {
    final length = walletName.trim().length;
    return length >= WalletRepository.minNameLength && length <= WalletRepository.maxNameLength;
  }

  bool get canContinue => switch (step) {
    SetupStep.profile => AppPreferences.isValidUserName(userName),
    SetupStep.wallet => walletType != null && isWalletNameValid && !submitting,
  };

  /// Số dư ban đầu lưu vào DB: thẻ tín dụng nhập số nợ nên lưu thành số âm.
  int get initialBalance => walletType == WalletType.credit ? -balance : balance;

  SetupState copyWith({
    SetupStep? step,
    String? userName,
    int? monthStartDay,
    WalletType? walletType,
    String? walletName,
    bool? walletNameEdited,
    int? balance,
    bool? submitting,
  }) => SetupState(
    step: step ?? this.step,
    userName: userName ?? this.userName,
    monthStartDay: monthStartDay ?? this.monthStartDay,
    walletType: walletType ?? this.walletType,
    walletName: walletName ?? this.walletName,
    walletNameEdited: walletNameEdited ?? this.walletNameEdited,
    balance: balance ?? this.balance,
    submitting: submitting ?? this.submitting,
  );
}

final setupNotifierProvider = NotifierProvider.autoDispose<SetupNotifier, SetupState>(
  SetupNotifier.new,
);

final class SetupNotifier extends Notifier<SetupState> {
  @override
  SetupState build() {
    final prefs = ref.read(appPreferencesProvider);
    return SetupState(userName: prefs.userName ?? '', monthStartDay: prefs.monthStartDay);
  }

  void setUserName(String name) => state = state.copyWith(userName: name);

  /// Ngày bắt đầu tháng xoay vòng trong 1..28.
  void increaseDay() => state = state.copyWith(
    monthStartDay: state.monthStartDay >= AppPreferences.maxMonthStartDay
        ? AppPreferences.minMonthStartDay
        : state.monthStartDay + 1,
  );

  void decreaseDay() => state = state.copyWith(
    monthStartDay: state.monthStartDay <= AppPreferences.minMonthStartDay
        ? AppPreferences.maxMonthStartDay
        : state.monthStartDay - 1,
  );

  /// Chọn loại ví; [suggestedName] (đã dịch) điền vào tên nếu người dùng chưa tự sửa.
  void pickWalletType(WalletType type, String suggestedName) => state = state.copyWith(
    walletType: type,
    walletName: state.walletNameEdited ? null : suggestedName,
  );

  void setWalletName(String name) =>
      state = state.copyWith(walletName: name, walletNameEdited: true);

  void setBalance(int amount) => state = state.copyWith(balance: amount < 0 ? 0 : amount);

  /// Bước 1 → bước 2. Trả false nếu chưa đủ điều kiện.
  bool next() {
    if (state.step != SetupStep.profile || !state.canContinue) return false;
    state = state.copyWith(step: SetupStep.wallet);
    return true;
  }

  /// Bước 2 → bước 1. Trả false khi đang ở bước đầu (nơi gọi tự quay về trang giới thiệu).
  bool back() {
    if (state.step == SetupStep.profile || state.submitting) return false;
    state = state.copyWith(step: SetupStep.profile);
    return true;
  }

  /// Tạo ví đầu tiên rồi mới đánh dấu xong onboarding.
  ///
  /// Tạo ví lỗi → không đánh dấu xong. Ghi cài đặt lỗi sau khi đã có ví → lần thử lại
  /// (kể cả sau khi mở lại app) thấy đã có ví nên bỏ qua bước tạo, không tạo trùng.
  Future<Result<void>> submit() async {
    if (state.step != SetupStep.wallet || !state.canContinue) {
      return const Err(ValidationFailure('Thiết lập chưa đủ thông tin'));
    }
    state = state.copyWith(submitting: true);
    final result = await _submit();
    if (ref.mounted) state = state.copyWith(submitting: false);
    return result;
  }

  Future<Result<void>> _submit() async {
    final wallets = ref.read(walletRepositoryProvider);
    final existing = await wallets.hasActiveWallet();
    if (existing case Err(:final failure)) return Err(failure);
    if (existing.valueOrNull != true) {
      final created = await wallets.create(
        name: state.walletName,
        type: state.walletType!,
        initialBalance: state.initialBalance,
      );
      if (created case Err(:final failure)) return Err(failure);
    }
    return ref
        .read(appPreferencesProvider.notifier)
        .completeSetup(userName: state.userName, monthStartDay: state.monthStartDay);
  }
}
