import 'package:flutter/material.dart';

import 'tokens.dart';

/// Màu ngữ nghĩa mà [ColorScheme] không có (thu/chi/cảnh báo/chuyển khoản, chữ phụ...).
/// Đọc bằng `context.appColors`.
@immutable
final class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surfaceAlt,
    required this.textSecondary,
    required this.textMuted,
    required this.divider,
    required this.primaryText,
    required this.income,
    required this.incomeBg,
    required this.incomeText,
    required this.expense,
    required this.expenseBg,
    required this.expenseText,
    required this.warning,
    required this.warningBg,
    required this.warningText,
    required this.transfer,
    required this.transferBg,
    required this.transferText,
  });

  factory AppColors.fromPalette(AppPalette p) => AppColors(
    background: p.background,
    surfaceAlt: p.surfaceAlt,
    textSecondary: p.textSecondary,
    textMuted: p.textMuted,
    divider: p.divider,
    primaryText: p.primaryText,
    income: p.income,
    incomeBg: p.incomeBg,
    incomeText: p.incomeText,
    expense: p.expense,
    expenseBg: p.expenseBg,
    expenseText: p.expenseText,
    warning: p.warning,
    warningBg: p.warningBg,
    warningText: p.warningText,
    transfer: p.transfer,
    transferBg: p.transferBg,
    transferText: p.transferText,
  );

  final Color background;
  final Color surfaceAlt;
  final Color textSecondary;
  final Color textMuted;
  final Color divider;
  final Color primaryText;
  final Color income;
  final Color incomeBg;
  final Color incomeText;
  final Color expense;
  final Color expenseBg;
  final Color expenseText;
  final Color warning;
  final Color warningBg;
  final Color warningText;
  final Color transfer;
  final Color transferBg;
  final Color transferText;

  @override
  AppColors copyWith({
    Color? background,
    Color? surfaceAlt,
    Color? textSecondary,
    Color? textMuted,
    Color? divider,
    Color? primaryText,
    Color? income,
    Color? incomeBg,
    Color? incomeText,
    Color? expense,
    Color? expenseBg,
    Color? expenseText,
    Color? warning,
    Color? warningBg,
    Color? warningText,
    Color? transfer,
    Color? transferBg,
    Color? transferText,
  }) => AppColors(
    background: background ?? this.background,
    surfaceAlt: surfaceAlt ?? this.surfaceAlt,
    textSecondary: textSecondary ?? this.textSecondary,
    textMuted: textMuted ?? this.textMuted,
    divider: divider ?? this.divider,
    primaryText: primaryText ?? this.primaryText,
    income: income ?? this.income,
    incomeBg: incomeBg ?? this.incomeBg,
    incomeText: incomeText ?? this.incomeText,
    expense: expense ?? this.expense,
    expenseBg: expenseBg ?? this.expenseBg,
    expenseText: expenseText ?? this.expenseText,
    warning: warning ?? this.warning,
    warningBg: warningBg ?? this.warningBg,
    warningText: warningText ?? this.warningText,
    transfer: transfer ?? this.transfer,
    transferBg: transferBg ?? this.transferBg,
    transferText: transferText ?? this.transferText,
  );

  @override
  AppColors lerp(covariant ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      background: l(background, other.background),
      surfaceAlt: l(surfaceAlt, other.surfaceAlt),
      textSecondary: l(textSecondary, other.textSecondary),
      textMuted: l(textMuted, other.textMuted),
      divider: l(divider, other.divider),
      primaryText: l(primaryText, other.primaryText),
      income: l(income, other.income),
      incomeBg: l(incomeBg, other.incomeBg),
      incomeText: l(incomeText, other.incomeText),
      expense: l(expense, other.expense),
      expenseBg: l(expenseBg, other.expenseBg),
      expenseText: l(expenseText, other.expenseText),
      warning: l(warning, other.warning),
      warningBg: l(warningBg, other.warningBg),
      warningText: l(warningText, other.warningText),
      transfer: l(transfer, other.transfer),
      transferBg: l(transferBg, other.transferBg),
      transferText: l(transferText, other.transferText),
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
