import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/failure.dart';
import 'package:vi_xanh_app/core/result.dart';
import 'package:vi_xanh_app/features/settings/data/settings_repository.dart';
import 'package:vi_xanh_app/features/settings/domain/app_preferences.dart';

import '../../fakes/fakes.dart';

void main() {
  const custom = AppPreferences(
    themeMode: ThemeMode.dark,
    localeCode: 'en',
    onboardingCompleted: true,
    monthStartDay: 25,
    hideBalance: true,
  );

  test('kho rỗng → mặc định', () {
    expect(SettingsRepository(FakeKeyValueStore()).load(), const AppPreferences());
  });

  test('round-trip đủ mọi trường qua một repository mới', () async {
    final store = FakeKeyValueStore();
    expect((await SettingsRepository(store).save(custom)).isOk, isTrue);
    expect(SettingsRepository(store).load(), custom);
  });

  test('từng trường được lưu đúng key', () async {
    final store = FakeKeyValueStore();
    await SettingsRepository(store).save(custom);
    expect(store.values, {
      'theme_mode': 'dark',
      'locale': 'en',
      'onboarding_completed': true,
      'month_start_day': 25,
      'hide_balance': true,
    });
  });

  test('locale null xóa key', () async {
    final store = FakeKeyValueStore();
    final repo = SettingsRepository(store);
    await repo.save(custom);
    await repo.save(custom.copyWith(localeCode: null));
    expect(store.values.containsKey('locale'), isFalse);
    expect(SettingsRepository(store).load().localeCode, isNull);
  });

  test('giá trị hỏng hoặc sai kiểu → mặc định, không ném lỗi', () {
    final store = FakeKeyValueStore({
      'theme_mode': 'abc',
      'locale': 'fr',
      'onboarding_completed': 'yes',
      'month_start_day': 99,
      'hide_balance': 1,
    });
    expect(SettingsRepository(store).load(), const AppPreferences());
  });

  test('month_start_day 0 và 29 → mặc định; 1 và 28 được giữ', () {
    int load(int day) =>
        SettingsRepository(FakeKeyValueStore({'month_start_day': day})).load().monthStartDay;
    expect(load(0), 1);
    expect(load(29), 1);
    expect(load(1), 1);
    expect(load(28), 28);
  });

  test('ghi thất bại → Err và cache giữ giá trị cũ', () async {
    final store = FakeKeyValueStore()..failWrites = true;
    final repo = SettingsRepository(store)..load();
    final result = await repo.save(custom);
    expect(result, isA<Err<void>>());
    expect((result as Err<void>).failure, isA<UnexpectedFailure>());
    expect(repo.current, const AppPreferences());
  });

  test('allowList chứa đủ mọi key được ghi', () async {
    final store = FakeKeyValueStore();
    await SettingsRepository(store).save(custom);
    expect(SettingsRepository.keys, containsAll(store.values.keys));
  });
}
