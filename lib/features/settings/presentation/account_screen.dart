import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../../routing/routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';

/// Tab Tài khoản (tạm): giới thiệu + lối vào Cài đặt.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabAccount)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenGutter,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              l10n.emptyAccount,
              style: theme.textTheme.bodyLarge?.copyWith(color: context.appColors.textSecondary),
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
            leading: const Icon(Icons.settings_outlined),
            title: Text(l10n.settingsTitle),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.go(Routes.settings),
          ),
        ],
      ),
    );
  }
}
