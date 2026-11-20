import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../data/settings_repository.dart';
import '../domain/app_preferences.dart';

final appPreferencesProvider = NotifierProvider<AppPreferencesNotifier, AppPreferences>(
  AppPreferencesNotifier.new,
);

/// Cập nhật lạc quan: state đổi ngay, ghi lỗi thì trả lại state cũ.
final class AppPreferencesNotifier extends Notifier<AppPreferences> {
  @override
  AppPreferences build() => ref.read(settingsRepositoryProvider).current;

  Future<Result<void>> setThemeMode(ThemeMode mode) => _update(state.copyWith(themeMode: mode));

  /// `null` = theo ngôn ngữ hệ thống.
  Future<Result<void>> setLocale(String? code) async {
    if (code != null && !AppPreferences.supportedLocaleCodes.contains(code)) {
      return Err(ValidationFailure('Ngôn ngữ không được hỗ trợ: $code'));
    }
    return _update(state.copyWith(localeCode: code));
  }

  Future<Result<void>> setOnboardingCompleted(bool completed) =>
      _update(state.copyWith(onboardingCompleted: completed));

  Future<Result<void>> setMonthStartDay(int day) async {
    if (!AppPreferences.isValidMonthStartDay(day)) {
      return Err(
        ValidationFailure(
          'Ngày bắt đầu tháng phải từ ${AppPreferences.minMonthStartDay} '
          'đến ${AppPreferences.maxMonthStartDay}',
        ),
      );
    }
    return _update(state.copyWith(monthStartDay: day));
  }

  Future<Result<void>> setHideBalance(bool hide) => _update(state.copyWith(hideBalance: hide));

  /// Rỗng / chỉ khoảng trắng → xóa tên (chào chung).
  Future<Result<void>> setUserName(String? name) async {
    if (!AppPreferences.isValidUserName(name)) return Err(_userNameTooLong());
    return _update(state.copyWith(userName: AppPreferences.normalizeUserName(name)));
  }

  /// Lưu kết quả Thiết lập ban đầu trong MỘT lần ghi: tên, ngày bắt đầu tháng và cờ
  /// onboarding — để không bao giờ có trạng thái "đã xong onboarding nhưng thiếu cài đặt".
  Future<Result<void>> completeSetup({String? userName, required int monthStartDay}) async {
    if (!AppPreferences.isValidUserName(userName)) return Err(_userNameTooLong());
    if (!AppPreferences.isValidMonthStartDay(monthStartDay)) {
      return Err(ValidationFailure('Ngày bắt đầu tháng không hợp lệ: $monthStartDay'));
    }
    return _update(
      state.copyWith(
        userName: AppPreferences.normalizeUserName(userName),
        monthStartDay: monthStartDay,
        onboardingCompleted: true,
      ),
    );
  }

  static ValidationFailure _userNameTooLong() =>
      const ValidationFailure('Tên tối đa ${AppPreferences.maxUserNameLength} ký tự');

  Future<Result<void>> _update(AppPreferences next) async {
    final previous = state;
    if (next == previous) return const Ok(null);
    state = next;
    final result = await ref.read(settingsRepositoryProvider).save(next);
    // Chỉ hoàn tác nếu chưa có thay đổi nào khác chen vào trong lúc chờ ghi.
    if (!result.isOk && ref.mounted && state == next) state = previous;
    return result;
  }
}
