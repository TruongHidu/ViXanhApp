import 'package:flutter/material.dart';

/// Cài đặt của từng máy, cần có trước khung hình đầu tiên.
@immutable
final class AppPreferences {
  const AppPreferences({
    this.themeMode = ThemeMode.system,
    this.localeCode,
    this.onboardingCompleted = false,
    this.monthStartDay = defaultMonthStartDay,
    this.hideBalance = false,
    this.userName,
  });

  /// Mã ngôn ngữ app hỗ trợ; `null` nghĩa là theo ngôn ngữ hệ thống.
  static const supportedLocaleCodes = {'vi', 'en'};

  static const defaultMonthStartDay = 1;
  static const minMonthStartDay = 1;

  /// Tối đa 28 để tháng nào (kể cả tháng 2) cũng có ngày bắt đầu.
  static const maxMonthStartDay = 28;

  /// Độ dài tối đa của tên hiển thị (sau khi bỏ khoảng trắng hai đầu).
  static const maxUserNameLength = 40;

  static bool isValidMonthStartDay(int day) => day >= minMonthStartDay && day <= maxMonthStartDay;

  /// Chuẩn hóa tên người dùng: bỏ khoảng trắng hai đầu, rỗng → `null`.
  /// Trả `null` cũng khi tên quá dài — gọi [isValidUserName] để phân biệt.
  static String? normalizeUserName(String? raw) {
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty || trimmed.length > maxUserNameLength) return null;
    return trimmed;
  }

  static bool isValidUserName(String? raw) => (raw?.trim().length ?? 0) <= maxUserNameLength;

  final ThemeMode themeMode;
  final String? localeCode;
  final bool onboardingCompleted;
  final int monthStartDay;
  final bool hideBalance;

  /// Tên để chào ("Chào buổi sáng, Minh"); `null` = chào chung không kèm tên.
  final String? userName;

  static const Object _keep = Object();

  /// [localeCode] và [userName] nhận `null` để xóa giá trị; bỏ trống thì giữ nguyên.
  AppPreferences copyWith({
    ThemeMode? themeMode,
    Object? localeCode = _keep,
    bool? onboardingCompleted,
    int? monthStartDay,
    bool? hideBalance,
    Object? userName = _keep,
  }) => AppPreferences(
    themeMode: themeMode ?? this.themeMode,
    localeCode: identical(localeCode, _keep) ? this.localeCode : localeCode as String?,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    monthStartDay: monthStartDay ?? this.monthStartDay,
    hideBalance: hideBalance ?? this.hideBalance,
    userName: identical(userName, _keep) ? this.userName : userName as String?,
  );

  @override
  bool operator ==(Object other) =>
      other is AppPreferences &&
      other.themeMode == themeMode &&
      other.localeCode == localeCode &&
      other.onboardingCompleted == onboardingCompleted &&
      other.monthStartDay == monthStartDay &&
      other.hideBalance == hideBalance &&
      other.userName == userName;

  @override
  int get hashCode =>
      Object.hash(themeMode, localeCode, onboardingCompleted, monthStartDay, hideBalance, userName);

  @override
  String toString() =>
      'AppPreferences(themeMode: $themeMode, localeCode: $localeCode, '
      'onboardingCompleted: $onboardingCompleted, monthStartDay: $monthStartDay, '
      'hideBalance: $hideBalance, userName: $userName)';
}
