import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/failure.dart';
import '../../../core/result.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../theme/widgets/labeled_field.dart';
import '../../../theme/widgets/thousands_input_formatter.dart';
import '../../settings/domain/app_preferences.dart';
import '../../wallets/presentation/wallet_type_ui.dart';
import '../../wallets/presentation/widgets/wallet_form_fields.dart';
import 'setup_notifier.dart';

/// Thiết lập ban đầu: bước 1 (tên, đơn vị tiền, ngày bắt đầu tháng), bước 2 (ví đầu tiên).
class SetupView extends ConsumerStatefulWidget {
  const SetupView({required this.onBack, super.key});

  /// Nút quay lại ở đầu màn (bước 2 → 1, bước 1 → trang giới thiệu).
  final VoidCallback onBack;

  @override
  ConsumerState<SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends ConsumerState<SetupView> {
  late final TextEditingController _name;
  late final TextEditingController _walletName;
  late final TextEditingController _balance;

  @override
  void initState() {
    super.initState();
    final state = ref.read(setupNotifierProvider);
    _name = TextEditingController(text: state.userName);
    _walletName = TextEditingController(text: state.walletName);
    _balance = TextEditingController(
      text: state.balance == 0 ? '' : ThousandsInputFormatter.format(state.balance),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _walletName.dispose();
    _balance.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final notifier = ref.read(setupNotifierProvider.notifier);
    if (ref.read(setupNotifierProvider).step == SetupStep.profile) {
      notifier.next();
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final result = await notifier.submit();
    if (result case Err(:final failure)) {
      final message = failure is ValidationFailure ? l10n.walletNameInvalid : l10n.setupFailed;
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(setupNotifierProvider);

    // Đổi loại ví khi chưa tự sửa tên → tên gợi ý mới phải hiện trong ô nhập.
    ref.listen(setupNotifierProvider.select((s) => s.walletName), (_, name) {
      if (_walletName.text != name) _walletName.text = name;
    });

    return Column(
      children: [
        SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                IconButton(
                  tooltip: l10n.back,
                  onPressed: state.submitting ? null : widget.onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Expanded(
                  child: Text(
                    l10n.setupStep(state.stepNumber, SetupState.totalSteps),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.appColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.minTouch),
              ],
            ),
          ),
        ),
        _StepProgress(current: state.stepNumber, total: SetupState.totalSteps),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenGutter,
              28,
              AppSpacing.screenGutter,
              AppSpacing.lg,
            ),
            child: switch (state.step) {
              SetupStep.profile => _ProfileStep(state: state, nameController: _name),
              SetupStep.wallet => _WalletStep(
                state: state,
                nameController: _walletName,
                balanceController: _balance,
              ),
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenGutter,
            AppSpacing.md,
            AppSpacing.screenGutter,
            AppSpacing.lg,
          ),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.canContinue ? _continue : null,
              child: Text(l10n.onboardingNext),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: l10n.setupProgressLabel,
      value: l10n.setupStep(current, total),
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenGutter,
            AppSpacing.xs,
            AppSpacing.screenGutter,
            0,
          ),
          child: Row(
            children: [
              for (var i = 1; i <= total; i++) ...[
                if (i > 1) const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= current ? scheme.primary : scheme.outlineVariant,
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(header: true, child: Text(title, style: theme.textTheme.headlineMedium)),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(color: context.appColors.textSecondary),
        ),
      ],
    );
  }
}

class _ProfileStep extends ConsumerWidget {
  const _ProfileStep({required this.state, required this.nameController});

  final SetupState state;
  final TextEditingController nameController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final notifier = ref.read(setupNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepHeader(title: l10n.setupProfileTitle, subtitle: l10n.setupProfileSubtitle),
        const SizedBox(height: 28),
        LabeledField(
          label: l10n.setupNameLabel,
          child: TextField(
            controller: nameController,
            onChanged: notifier.setUserName,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.givenName],
            inputFormatters: [LengthLimitingTextInputFormatter(AppPreferences.maxUserNameLength)],
            decoration: InputDecoration(hintText: l10n.setupNameHint),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          l10n.setupCurrencyLabel,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.md),
        // MVP chỉ hỗ trợ VND (Money và định dạng đang theo VND) nên chỉ hiện một lựa chọn đã chọn.
        Align(
          alignment: Alignment.centerLeft,
          child: Semantics(
            selected: true,
            label: l10n.currencyVnd,
            excludeSemantics: true,
            child: Container(
              constraints: const BoxConstraints(minHeight: AppSizes.minTouch),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: ShapeDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: StadiumBorder(side: BorderSide(color: theme.colorScheme.primary, width: 2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_rounded, size: 18, color: theme.colorScheme.onPrimaryContainer),
                  const SizedBox(width: 6),
                  Text(
                    l10n.currencyVnd,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          l10n.setupMonthStartLabel,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: colors.surfaceAlt,
            borderRadius: const BorderRadius.all(AppRadius.input),
          ),
          child: Row(
            children: [
              _DayButton(
                icon: Icons.remove_rounded,
                tooltip: l10n.dayDecrease,
                onPressed: notifier.decreaseDay,
              ),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.setupMonthStartValue(state.monthStartDay),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
              _DayButton(
                icon: Icons.add_rounded,
                tooltip: l10n.dayIncrease,
                onPressed: notifier.increaseDay,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 16, color: colors.textSecondary),
            const SizedBox(width: 6),
            Expanded(child: Text(l10n.setupMonthStartHint, style: theme.textTheme.bodySmall)),
          ],
        ),
      ],
    );
  }
}

class _DayButton extends StatelessWidget {
  const _DayButton({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    icon: Icon(icon),
    style: IconButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.surface,
      fixedSize: const Size.square(AppSizes.minTouch),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
  );
}

class _WalletStep extends ConsumerWidget {
  const _WalletStep({
    required this.state,
    required this.nameController,
    required this.balanceController,
  });

  final SetupState state;
  final TextEditingController nameController;
  final TextEditingController balanceController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(setupNotifierProvider.notifier);
    final type = state.walletType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepHeader(title: l10n.setupWalletTitle, subtitle: l10n.setupWalletSubtitle),
        const SizedBox(height: AppSpacing.xl),
        WalletFormFields(
          type: type,
          onPickType: (picked) => notifier.pickWalletType(picked, picked.defaultName(l10n)),
          balanceController: balanceController,
          onBalanceChanged: notifier.setBalance,
          nameController: nameController,
          onNameChanged: notifier.setWalletName,
          nameError: state.walletNameEdited && !state.isWalletNameValid
              ? l10n.walletNameInvalid
              : null,
        ),
      ],
    );
  }
}
