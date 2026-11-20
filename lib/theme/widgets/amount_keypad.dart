import 'package:flutter/material.dart';

import '../../core/amount_input.dart';
import '../../l10n/gen/app_localizations.dart';
import '../app_colors.dart';
import '../tokens.dart';

/// Bàn phím số riêng của app (không dùng bàn phím hệ thống cho số tiền):
///
/// ```
/// 1   2   3   −
/// 4   5   6   +
/// 7   8   9   Lưu
/// 000 0   ⌫   Lưu
/// ```
class AmountKeypad extends StatelessWidget {
  const AmountKeypad({
    required this.onDigit,
    required this.onThousand,
    required this.onSign,
    required this.onBackspace,
    required this.onSave,
    this.saving = false,
    super.key,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onThousand;
  final ValueChanged<String> onSign;
  final VoidCallback onBackspace;
  final VoidCallback onSave;

  /// Đang lưu: tắt nút Lưu để không lưu hai lần.
  final bool saving;

  static const _keyHeight = 64.0;
  static const _gap = AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    Widget digit(String d) =>
        _Key(label: d, semantics: l10n.keypadDigit(d), onTap: () => onDigit(d));
    Widget sign(String s, String semantics) =>
        _Key(label: s, semantics: semantics, onTap: () => onSign(s), accent: true);
    Widget row(List<Widget> keys) => Row(
      children: [
        for (var i = 0; i < keys.length; i++) ...[
          if (i > 0) const SizedBox(width: _gap),
          Expanded(child: keys[i]),
        ],
      ],
    );

    return Material(
      color: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: AppRadius.sheet),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              row([digit('1'), digit('2'), digit('3'), sign(AmountInput.minus, l10n.keypadMinus)]),
              const SizedBox(height: _gap),
              row([digit('4'), digit('5'), digit('6'), sign(AmountInput.plus, l10n.keypadPlus)]),
              const SizedBox(height: _gap),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        row([digit('7'), digit('8'), digit('9')]),
                        const SizedBox(height: _gap),
                        row([
                          _Key(label: '000', semantics: l10n.keypadThousand, onTap: onThousand),
                          digit('0'),
                          _Key(
                            icon: Icons.backspace_outlined,
                            semantics: l10n.keypadBackspace,
                            onTap: onBackspace,
                          ),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(width: _gap),
                  Expanded(
                    child: SizedBox(
                      height: _keyHeight * 2 + _gap,
                      child: FilledButton(
                        onPressed: saving ? null : onSave,
                        style: FilledButton.styleFrom(padding: EdgeInsets.zero),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_rounded, size: 26),
                            const SizedBox(height: AppSpacing.xs),
                            Text(l10n.txnSave),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.semantics,
    required this.onTap,
    this.label,
    this.icon,
    this.accent = false,
  }) : assert(label != null || icon != null, 'phím cần chữ hoặc icon');

  final String? label;
  final IconData? icon;
  final String semantics;
  final VoidCallback onTap;

  /// Phím dấu + / − dùng màu nhấn.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final color = accent ? colors.primaryText : theme.colorScheme.onSurface;
    return Semantics(
      button: true,
      label: semantics,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: colors.surfaceAlt,
        borderRadius: const BorderRadius.all(AppRadius.button),
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.all(AppRadius.button),
          child: SizedBox(
            height: AmountKeypad._keyHeight,
            child: Center(
              child: icon != null
                  ? Icon(icon, color: color)
                  : Text(
                      label!,
                      maxLines: 1,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: accent ? 30 : (label!.length > 1 ? 22 : 26),
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
