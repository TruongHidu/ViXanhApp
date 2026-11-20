import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/failure.dart';
import 'package:vi_xanh_app/core/result.dart';
import 'package:vi_xanh_app/features/settings/data/settings_repository.dart';
import 'package:vi_xanh_app/features/settings/domain/app_preferences.dart';
import 'package:vi_xanh_app/features/settings/presentation/settings_notifier.dart';

import '../../fakes/fakes.dart';

void main() {
  late FakeKeyValueStore store;
  late ProviderContainer container;

  setUp(() {
    store = FakeKeyValueStore();
    final repo = SettingsRepository(store)..load();
    container = ProviderContainer(overrides: [settingsRepositoryProvider.overrideWithValue(repo)]);
    addTearDown(container.dispose);
  });

  AppPreferences state() => container.read(appPreferencesProvider);
  AppPreferencesNotifier notifier() => container.read(appPreferencesProvider.notifier);

  test('setMonthStartDay(0) và (29) trả ValidationFailure, state không đổi', () async {
    for (final day in [0, 29]) {
      final result = await notifier().setMonthStartDay(day);
      expect((result as Err<void>).failure, isA<ValidationFailure>());
      expect(state().monthStartDay, 1);
    }
    expect(store.values, isEmpty);
  });

  test('setMonthStartDay(28) lưu được', () async {
    expect((await notifier().setMonthStartDay(28)).isOk, isTrue);
    expect(state().monthStartDay, 28);
    expect(store.values['month_start_day'], 28);
  });

  test('setLocale đổi rồi quay về theo hệ thống', () async {
    await notifier().setLocale('en');
    expect(state().localeCode, 'en');
    await notifier().setLocale(null);
    expect(state().localeCode, isNull);
    expect(store.values.containsKey('locale'), isFalse);
  });

  test('setLocale mã không hỗ trợ → ValidationFailure', () async {
    final result = await notifier().setLocale('fr');
    expect((result as Err<void>).failure, isA<ValidationFailure>());
    expect(state().localeCode, isNull);
  });

  test('các setter còn lại cập nhật state và kho', () async {
    await notifier().setThemeMode(ThemeMode.dark);
    await notifier().setOnboardingCompleted(true);
    await notifier().setHideBalance(true);
    expect(
      state(),
      const AppPreferences(themeMode: ThemeMode.dark, onboardingCompleted: true, hideBalance: true),
    );
    expect(store.values['theme_mode'], 'dark');
  });

  test('ghi thất bại → state được hoàn tác', () async {
    store.failWrites = true;
    final result = await notifier().setThemeMode(ThemeMode.dark);
    expect(result.isOk, isFalse);
    expect(state().themeMode, ThemeMode.system);
  });
}
