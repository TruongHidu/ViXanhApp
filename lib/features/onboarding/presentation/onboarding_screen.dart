import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../settings/presentation/settings_notifier.dart';

/// Onboarding tạm: 1 nút "Bắt đầu". Router tự chuyển sang Tổng quan khi cờ được lưu.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenGutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xxl),
                      Text(l10n.onboardingTitle, style: theme.textTheme.headlineMedium),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l10n.onboardingBody,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Hành động chính ở nửa dưới màn hình, dễ với bằng một tay.
              FilledButton(
                onPressed: () => _start(context, ref),
                child: Text(l10n.onboardingStart),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).settingsSaveFailed;
    final result = await ref.read(appPreferencesProvider.notifier).setOnboardingCompleted(true);
    if (!result.isOk) messenger.showSnackBar(SnackBar(content: Text(failed)));
  }
}
