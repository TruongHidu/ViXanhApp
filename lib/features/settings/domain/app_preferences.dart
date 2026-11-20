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
  });

  /// Mã ngôn ngữ app hỗ trợ; `null` nghĩa là theo ngôn ngữ hệ thống.
  static const supportedLocaleCodes = {'vi', 'en'};

  static const defaultMonthStartDay = 1;
  static const minMonthStartDay = 1;

  /// Tối đa 28 để tháng nào (kể cả tháng 2) cũng có ngày bắt đầu.
  static const maxMonthStartDay = 28;

  static bool isValidMonthStartDay(int day) => day >= minMonthStartDay && day <= maxMonthStartDay;

  final ThemeMode themeMode;
  final String? localeCode;
  final bool onboardingCompleted;
  final int monthStartDay;
  final bool hideBalance;

  static const Object _keep = Object();

  /// [localeCode] nhận `null` để quay về "theo hệ thống"; bỏ trống thì giữ nguyên.
  AppPreferences copyWith({
    ThemeMode? themeMode,
    Object? localeCode = _keep,
    bool? onboardingCompleted,
    int? monthStartDay,
    bool? hideBalance,
  }) => AppPreferences(
    themeMode: themeMode ?? this.themeMode,
    localeCode: identical(localeCode, _keep) ? this.localeCode : localeCode as String?,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    monthStartDay: monthStartDay ?? this.monthStartDay,
    hideBalance: hideBalance ?? this.hideBalance,
  );

  @override
  bool operator ==(Object other) =>
      other is AppPreferences &&
      other.themeMode == themeMode &&
      other.localeCode == localeCode &&
      other.onboardingCompleted == onboardingCompleted &&
      other.monthStartDay == monthStartDay &&
      other.hideBalance == hideBalance;

  @override
  int get hashCode =>
      Object.hash(themeMode, localeCode, onboardingCompleted, monthStartDay, hideBalance);

  @override
  String toString() =>
      'AppPreferences(themeMode: $themeMode, localeCode: $localeCode, '
      'onboardingCompleted: $onboardingCompleted, monthStartDay: $monthStartDay, '
      'hideBalance: $hideBalance)';
}
