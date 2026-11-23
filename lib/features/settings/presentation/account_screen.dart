import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/core_providers.dart';
import '../../../core/result.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../routing/routes.dart';
import '../../../services/app_info_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../backup/presentation/backup_notifier.dart';
import '../../wallets/data/wallet_repository.dart';
import 'settings_notifier.dart';

/// Tab Tài khoản: hồ sơ, Quản lý, Giao diện, Dữ liệu (sao lưu), Khác.
/// Chỉ hiện các mục đã chạy được; ngân sách, bảo mật, thông báo... ẩn cho tới khi có.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenGutter,
            AppSpacing.md,
            AppSpacing.screenGutter,
            // Chừa chỗ cho nút "+" nhô lên trên thanh điều hướng.
            AppSpacing.xxl * 3,
          ),
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppSizes.minTouch),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Semantics(
                  header: true,
                  child: Text(l10n.tabAccount, style: theme.textTheme.headlineMedium),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const _ProfileCard(),
            const _ManageGroup(),
            const _AppearanceGroup(),
            const _DataGroup(),
            const _OtherGroup(),
          ],
        ),
      ),
    );
  }
}

/// "12:30" nếu sao lưu hôm nay, ngược lại "12:30 18/11/2026".
String _backupTimeLabel(BuildContext context, DateTime at, DateTime now) {
  final locale = Localizations.localeOf(context).languageCode;
  final local = at.toLocal();
  final today = now.toLocal();
  final sameDay = local.year == today.year && local.month == today.month && local.day == today.day;
  return DateFormat(sameDay ? 'HH:mm' : 'HH:mm dd/MM/yyyy', locale).format(local);
}

/// Ghi cài đặt; lỗi → snackbar (notifier đã tự hoàn tác state).
Future<void> _apply(BuildContext context, Future<Result<void>> pending) async {
  final messenger = ScaffoldMessenger.of(context);
  final message = AppLocalizations.of(context).settingsSaveFailed;
  final result = await pending;
  if (!result.isOk) messenger.showSnackBar(SnackBar(content: Text(message)));
}

// ---------------------------------------------------------------- Hồ sơ

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final name = ref.watch(appPreferencesProvider.select((p) => p.userName));
    final lastBackup = ref.watch(backupProvider.select((s) => s.lastBackupAt));
    final now = ref.watch(clockProvider).now();
    final display = (name == null || name.trim().isEmpty) ? l10n.accountDefaultName : name.trim();
    final initial = display.characters.first.toUpperCase();

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.all(AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  initial,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(display, style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  _BackupStatusLine(
                    text: lastBackup == null
                        ? l10n.accountNotBackedUp
                        : l10n.accountBackedUpAt(_backupTimeLabel(context, lastBackup, now)),
                    ok: lastBackup != null,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.accountEditName,
              onPressed: () => _editName(context, ref, name),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editName(BuildContext context, WidgetRef ref, String? current) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _EditNameDialog(initial: current ?? ''),
    );
    if (name == null || !context.mounted) return;
    await _apply(context, ref.read(appPreferencesProvider.notifier).setUserName(name));
  }
}

class _BackupStatusLine extends StatelessWidget {
  const _BackupStatusLine({required this.text, required this.ok});

  final String text;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Màu + biểu tượng khác nhau: không chỉ dựa vào màu để báo trạng thái.
    final color = ok ? colors.incomeText : colors.warningText;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            ok ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
        ),
      ],
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.initial});

  final String initial;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.accountEditName),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 40,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(hintText: l10n.accountNameHint),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancel)),
        FilledButton(onPressed: _submit, child: Text(l10n.accountSave)),
      ],
    );
  }
}

// ---------------------------------------------------------------- Nhóm & dòng

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children, this.footer});

  final String title;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xs,
            AppSpacing.xl,
            AppSpacing.xs,
            AppSpacing.sm,
          ),
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(color: context.appColors.textSecondary),
            ),
          ),
        ),
        Material(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.all(AppRadius.card),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final (i, child) in children.indexed) ...[
                if (i > 0) const Divider(indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                child,
              ],
            ],
          ),
        ),
        ?footer,
      ],
    );
  }
}

class _RowIcon extends StatelessWidget {
  const _RowIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, size: 20, color: context.appColors.primaryText),
  );
}

/// Dòng bấm được: biểu tượng · nhãn · giá trị · mũi tên.
class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
    this.chevron = true,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = context.appColors.textSecondary;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              ExcludeSemantics(child: _RowIcon(icon)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
              if (value != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    value!,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodyMedium?.copyWith(color: secondary),
                  ),
                ),
              ],
              ?trailing,
              if (chevron) ...[
                const SizedBox(width: AppSpacing.xs),
                ExcludeSemantics(child: Icon(Icons.chevron_right_rounded, color: secondary)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Quản lý

class _ManageGroup extends ConsumerWidget {
  const _ManageGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final count = ref.watch(activeWalletsProvider).value?.length;
    return _Group(
      title: l10n.accountGroupManage,
      children: [
        _LinkRow(
          icon: Icons.account_balance_wallet_outlined,
          label: l10n.walletsTitle,
          value: count == null ? null : l10n.accountWalletCount(count),
          onTap: () => context.push(Routes.wallets),
        ),
        _LinkRow(
          icon: Icons.grid_view_rounded,
          label: l10n.categoriesTitle,
          onTap: () => context.push(Routes.categories),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Giao diện

class _AppearanceGroup extends ConsumerWidget {
  const _AppearanceGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(appPreferencesProvider);
    final notifier = ref.read(appPreferencesProvider.notifier);

    final themeOptions = [
      (ThemeMode.system, l10n.themeSystem),
      (ThemeMode.light, l10n.themeLight),
      (ThemeMode.dark, l10n.themeDark),
    ];
    final languageOptions = [
      (null, l10n.languageSystem),
      ('vi', l10n.languageVi),
      ('en', l10n.languageEn),
    ];
    String labelOf<T>(List<(T, String)> options, T value) =>
        options.firstWhere((o) => o.$1 == value, orElse: () => options.first).$2;

    return _Group(
      title: l10n.accountGroupAppearance,
      children: [
        _LinkRow(
          icon: Icons.dark_mode_outlined,
          label: l10n.accountDarkMode,
          value: labelOf(themeOptions, prefs.themeMode),
          onTap: () async {
            final picked = await _pick(
              context,
              l10n.accountDarkMode,
              themeOptions,
              prefs.themeMode,
            );
            if (picked != null && context.mounted) {
              await _apply(context, notifier.setThemeMode(picked.$1));
            }
          },
        ),
        _LinkRow(
          icon: Icons.language_rounded,
          label: l10n.language,
          value: labelOf(languageOptions, prefs.localeCode),
          onTap: () async {
            final picked = await _pick(context, l10n.language, languageOptions, prefs.localeCode);
            if (picked != null && context.mounted) {
              await _apply(context, notifier.setLocale(picked.$1));
            }
          },
        ),
        _LinkRow(
          icon: Icons.calendar_month_outlined,
          label: l10n.accountMonthStart,
          value: l10n.accountMonthStartValue(prefs.monthStartDay),
          onTap: () async {
            final days = [for (var d = 1; d <= 28; d++) (d, l10n.accountMonthStartValue(d))];
            final picked = await _pick(context, l10n.accountMonthStart, days, prefs.monthStartDay);
            if (picked != null && context.mounted) {
              await _apply(context, notifier.setMonthStartDay(picked.$1));
            }
          },
        ),
        _SwitchRow(
          icon: Icons.visibility_off_outlined,
          label: l10n.accountHideBalance,
          value: prefs.hideBalance,
          onChanged: (v) => _apply(context, notifier.setHideBalance(v)),
        ),
      ],
    );
  }
}

/// Bottom sheet chọn một giá trị. Trả về bản ghi bọc giá trị (để phân biệt "chọn null"
/// với "đóng sheet").
Future<(T,)?> _pick<T>(BuildContext context, String title, List<(T, String)> options, T current) =>
    showModalBottomSheet<(T,)>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: options.length > 6 ? 0.6 : 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
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
                child: Text(title, style: Theme.of(sheetContext).textTheme.titleMedium),
              ),
            ),
            for (final (i, option) in options.indexed)
              RadioListTile<int>(
                value: i,
                groupValue: options.indexWhere((o) => o.$1 == current),
                title: Text(option.$2),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
                onChanged: (_) => Navigator.of(sheetContext).pop((option.$1,)),
              ),
          ],
        ),
      ),
    );

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.sm,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              ExcludeSemantics(child: _RowIcon(icon)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------- Dữ liệu

class _DataGroup extends ConsumerWidget {
  const _DataGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final backup = ref.watch(backupProvider);
    final remind = ref.watch(backupReminderProvider);
    final now = ref.watch(clockProvider).now();
    final last = backup.lastBackupAt;

    return _Group(
      title: l10n.accountGroupData,
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.sm, AppSpacing.xs, 0),
        child: remind
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: colors.warningText),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.accountBackupReminder,
                      style: theme.textTheme.bodySmall?.copyWith(color: colors.warningText),
                    ),
                  ),
                ],
              )
            : Text(
                l10n.accountBackupHint,
                style: theme.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
              ),
      ),
      children: [
        _LinkRow(
          icon: Icons.cloud_upload_outlined,
          label: l10n.accountBackup,
          value: last == null ? l10n.accountBackupNever : _backupTimeLabel(context, last, now),
          chevron: !backup.running,
          trailing: backup.running
              ? const Padding(
                  padding: EdgeInsets.only(left: AppSpacing.sm),
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                )
              : null,
          onTap: backup.running ? null : () => _backup(context, ref),
        ),
      ],
    );
  }

  Future<void> _backup(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final result = await ref.read(backupProvider.notifier).backupNow();
    messenger.showSnackBar(
      SnackBar(content: Text(result.isOk ? l10n.accountBackupDone : l10n.accountBackupFailed)),
    );
  }
}

// ---------------------------------------------------------------- Khác

class _OtherGroup extends ConsumerWidget {
  const _OtherGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final version = ref.watch(appVersionProvider).value;
    return _Group(
      title: l10n.accountGroupOther,
      children: [
        _LinkRow(
          icon: Icons.info_outline_rounded,
          label: l10n.accountVersion,
          value: version ?? '…',
          chevron: false,
        ),
      ],
    );
  }
}
