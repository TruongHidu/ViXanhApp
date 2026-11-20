import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../services/key_value_store.dart';
import '../domain/app_preferences.dart';

/// Đọc đồng bộ một lần trong bootstrap() (trước runApp), sau đó phục vụ từ cache.
final class SettingsRepository {
  SettingsRepository(this._store);

  static const kThemeMode = 'theme_mode';
  static const kLocale = 'locale';
  static const kOnboardingCompleted = 'onboarding_completed';
  static const kMonthStartDay = 'month_start_day';
  static const kHideBalance = 'hide_balance';

  /// Toàn bộ key được lưu — dùng làm allowList của shared_preferences.
  static const keys = {kThemeMode, kLocale, kOnboardingCompleted, kMonthStartDay, kHideBalance};

  final KeyValueStore _store;
  AppPreferences _cached = const AppPreferences();

  AppPreferences get current => _cached;

  /// Giá trị thiếu, sai kiểu hoặc ngoài miền hợp lệ đều rơi về mặc định.
  AppPreferences load() {
    const defaults = AppPreferences();
    final locale = _store.getString(kLocale);
    final day = _store.getInt(kMonthStartDay);
    _cached = AppPreferences(
      themeMode: ThemeMode.values.asNameMap()[_store.getString(kThemeMode)] ?? defaults.themeMode,
      localeCode: AppPreferences.supportedLocaleCodes.contains(locale) ? locale : null,
      onboardingCompleted: _store.getBool(kOnboardingCompleted) ?? defaults.onboardingCompleted,
      monthStartDay: day != null && AppPreferences.isValidMonthStartDay(day)
          ? day
          : defaults.monthStartDay,
      hideBalance: _store.getBool(kHideBalance) ?? defaults.hideBalance,
    );
    return _cached;
  }

  /// Ghi toàn bộ [prefs]; cache chỉ đổi khi ghi thành công.
  Future<Result<void>> save(AppPreferences prefs) async {
    final result = await guardAsync<void>(() async {
      await _store.setString(kThemeMode, prefs.themeMode.name);
      if (prefs.localeCode case final code?) {
        await _store.setString(kLocale, code);
      } else {
        await _store.remove(kLocale);
      }
      await _store.setBool(kOnboardingCompleted, prefs.onboardingCompleted);
      await _store.setInt(kMonthStartDay, prefs.monthStartDay);
      await _store.setBool(kHideBalance, prefs.hideBalance);
    }, onError: (e) => UnexpectedFailure('Không lưu được cài đặt', cause: e));
    if (result.isOk) _cached = prefs;
    return result;
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => throw UnimplementedError('override trong bootstrap()'),
);
