import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'tokens.dart';
import 'typography.dart';

abstract final class AppTheme {
  static ThemeData light() => build(AppPalette.light);
  static ThemeData dark() => build(AppPalette.dark);

  /// ColorScheme dựng tay từ [AppPalette] (không dùng fromSeed) để khớp đúng đặc tả.
  static ColorScheme colorScheme(AppPalette p) => ColorScheme(
    brightness: p.brightness,
    primary: p.primary,
    onPrimary: p.onPrimary,
    primaryContainer: p.primaryContainer,
    onPrimaryContainer: p.onPrimaryContainer,
    secondary: p.textSecondary,
    onSecondary: p.card,
    secondaryContainer: p.surfaceAlt,
    onSecondaryContainer: p.textPrimary,
    tertiary: p.transfer,
    onTertiary: p.card,
    tertiaryContainer: p.transferBg,
    onTertiaryContainer: p.transferText,
    error: p.expenseText,
    onError: p.onExpense,
    errorContainer: p.expenseBg,
    onErrorContainer: p.expenseText,
    surface: p.card,
    onSurface: p.textPrimary,
    onSurfaceVariant: p.textSecondary,
    surfaceContainerLowest: p.card,
    surfaceContainerLow: p.background,
    surfaceContainer: p.surfaceAlt,
    surfaceContainerHigh: p.surfaceAlt,
    surfaceContainerHighest: p.divider,
    outline: p.textMuted,
    outlineVariant: p.divider,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: p.textPrimary,
    onInverseSurface: p.background,
    inversePrimary: p.primaryContainer,
    surfaceTint: Colors.transparent,
  );

  static ThemeData build(AppPalette p) {
    final scheme = colorScheme(p);
    final text = AppTypography.textTheme(p);
    const buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.all(AppRadius.button));
    const buttonSize = Size(AppSizes.minTouch, AppSizes.buttonHeight);
    final inputBorder = const OutlineInputBorder(
      borderRadius: BorderRadius.all(AppRadius.input),
      borderSide: BorderSide.none,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: scheme,
      fontFamily: appFontFamily,
      textTheme: text,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      dividerColor: p.divider,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      extensions: [AppColors.fromPalette(p), AppTextStyles.fromPalette(p)],
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.headlineMedium,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.primaryText,
          minimumSize: buttonSize,
          shape: buttonShape,
          side: BorderSide(color: p.primary),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primaryText,
          minimumSize: const Size(AppSizes.minTouch, AppSizes.minTouch),
          shape: buttonShape,
          textStyle: text.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: text.bodyLarge?.copyWith(color: p.textMuted),
        labelStyle: text.bodyLarge?.copyWith(color: p.textSecondary),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(borderSide: BorderSide(color: p.primary, width: 1.5)),
        errorBorder: inputBorder.copyWith(borderSide: BorderSide(color: p.expenseText)),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: p.expenseText, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: p.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(AppRadius.card)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: AppRadius.sheet),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: AppRadius.pill,
        side: BorderSide.none,
        backgroundColor: p.surfaceAlt,
        selectedColor: p.primaryContainer,
        labelStyle: text.bodyMedium,
        secondaryLabelStyle: text.bodyMedium?.copyWith(color: p.onPrimaryContainer),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.textPrimary,
        contentTextStyle: text.bodyMedium?.copyWith(color: p.background),
        actionTextColor: p.brightness == Brightness.light ? p.primaryContainer : p.primary,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(AppRadius.button)),
      ),
      dividerTheme: DividerThemeData(color: p.divider, thickness: 1, space: 1),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const CircleBorder(),
        sizeConstraints: const BoxConstraints.tightFor(width: AppSizes.fab, height: AppSizes.fab),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.textSecondary,
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: text.bodySmall,
        minTileHeight: AppSizes.minTouch,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primary,
        linearTrackColor: p.surfaceAlt,
        linearMinHeight: AppSizes.progressBar,
        borderRadius: const BorderRadius.all(Radius.circular(AppSizes.progressBar / 2)),
      ),
      iconTheme: IconThemeData(color: p.textPrimary),
    );
  }
}
