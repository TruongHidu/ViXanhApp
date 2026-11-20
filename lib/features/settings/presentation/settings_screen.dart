import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../../../l10n/gen/app_localizations.dart';
import 'settings_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mode = ref.watch(appPreferencesProvider.select((p) => p.themeMode));
    final locale = ref.watch(appPreferencesProvider.select((p) => p.localeCode));
    final notifier = ref.read(appPreferencesProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(title: Text(l10n.themeMode)),
          for (final (value, label) in [
            (ThemeMode.system, l10n.themeSystem),
            (ThemeMode.light, l10n.themeLight),
            (ThemeMode.dark, l10n.themeDark),
          ])
            RadioListTile<ThemeMode>(
              value: value,
              groupValue: mode,
              title: Text(label),
              onChanged: (m) {
                if (m != null) _apply(context, notifier.setThemeMode(m));
              },
            ),
          const Divider(),
          ListTile(title: Text(l10n.language)),
          for (final (value, label) in [
            (null, l10n.languageSystem),
            ('vi', l10n.languageVi),
            ('en', l10n.languageEn),
          ])
            RadioListTile<String?>(
              value: value,
              groupValue: locale,
              title: Text(label),
              // Dùng `value` của mục thay vì tham số: mục "Theo hệ thống" có value null.
              onChanged: (_) => _apply(context, notifier.setLocale(value)),
            ),
        ],
      ),
    );
  }

  /// Ghi lỗi → báo bằng snackbar; notifier đã tự hoàn tác state.
  Future<void> _apply(BuildContext context, Future<Result<void>> pending) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context).settingsSaveFailed;
    final result = await pending;
    if (!result.isOk) messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}
