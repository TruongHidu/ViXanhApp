import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatting/money_format.dart';
import '../../../../core/ids.dart';
import '../../../../core/money.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/tokens.dart';
import '../../data/wallet_repository.dart';
import '../wallet_type_ui.dart';

/// Bottom sheet chọn một ví đang dùng (kèm số dư). Trả về id ví đã chọn, hoặc `null` khi đóng.
Future<WalletId?> showWalletPicker(BuildContext context, {WalletId? selected}) =>
    showModalBottomSheet<WalletId>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _WalletPickerSheet(selected: selected),
    );

class _WalletPickerSheet extends ConsumerWidget {
  const _WalletPickerSheet({this.selected});

  final WalletId? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final wallets = ref.watch(activeWalletsProvider).value ?? const [];
    final balances = ref.watch(walletBalancesProvider).value ?? const {};

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenGutter,
            0,
            AppSpacing.screenGutter,
            AppSpacing.sm,
          ),
          child: Semantics(
            header: true,
            child: Text(l10n.chooseWallet, style: theme.textTheme.titleMedium),
          ),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            children: [
              for (final w in wallets)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
                  selected: w.id == selected,
                  leading: CircleAvatar(
                    backgroundColor: w.type.color.withValues(alpha: 0.2),
                    child: Icon(w.type.icon, color: w.type.color),
                  ),
                  title: Text(w.name),
                  subtitle: Text(
                    formatMoney(Money(balances[w.id] ?? w.initialBalance)),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: (balances[w.id] ?? 0) < 0
                          ? context.appColors.expenseText
                          : context.appColors.textSecondary,
                    ),
                  ),
                  trailing: w.id == selected ? const Icon(Icons.check_rounded) : null,
                  onTap: () => Navigator.of(context).pop(w.id),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
