import 'package:flutter/material.dart';

import '../core/enums.dart';

/// Design tokens — nguồn DUY NHẤT cho màu, khoảng cách, bo góc, kích thước.
/// Widget không viết mã màu trực tiếp; đọc qua `Theme.of(context)` / `context.appColors`.

/// Bảng màu thô cho một chế độ sáng/tối.
///
/// Màu gốc (`income`, `expense`, ...) dùng cho icon, nền, biểu đồ. Biến thể `*Text` đậm hơn
/// để CHỮ đạt WCAG AA 4,5:1 trên nền app và nền thẻ (xem test/theme/contrast_test.dart).
@immutable
final class AppPalette {
  const AppPalette._({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.primaryText,
    required this.background,
    required this.card,
    required this.surfaceAlt,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.divider,
    required this.income,
    required this.incomeBg,
    required this.incomeText,
    required this.expense,
    required this.expenseBg,
    required this.expenseText,
    required this.onExpense,
    required this.warning,
    required this.warningBg,
    required this.warningText,
    required this.transfer,
    required this.transferBg,
    required this.transferText,
  });

  final Brightness brightness;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  /// Primary dùng làm màu CHỮ trên nền app (primary gốc chỉ đạt ~4,45:1 trên nền ngà).
  final Color primaryText;
  final Color background;
  final Color card;
  final Color surfaceAlt;
  final Color textPrimary;
  final Color textSecondary;

  /// Chỉ cho placeholder, trạng thái disabled, đồ họa trang trí — KHÔNG đạt 4,5:1.
  final Color textMuted;
  final Color divider;
  final Color income;
  final Color incomeBg;
  final Color incomeText;
  final Color expense;
  final Color expenseBg;
  final Color expenseText;
  final Color onExpense;
  final Color warning;
  final Color warningBg;
  final Color warningText;
  final Color transfer;
  final Color transferBg;
  final Color transferText;

  static const light = AppPalette._(
    brightness: Brightness.light,
    primary: Color(0xFF3F7D6E),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDCEFE9),
    onPrimaryContainer: Color(0xFF1F4A40),
    primaryText: Color(0xFF356A5D),
    background: Color(0xFFF7F6F2),
    card: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEFEEE9),
    textPrimary: Color(0xFF1F2A2E),
    textSecondary: Color(0xFF5F6B70),
    textMuted: Color(0xFF9AA3A7),
    divider: Color(0xFFE6E4DE),
    income: Color(0xFF2E8B6A),
    incomeBg: Color(0xFFE3F4EC),
    incomeText: Color(0xFF287559),
    expense: Color(0xFFD0685A),
    expenseBg: Color(0xFFFBE9E6),
    expenseText: Color(0xFFA9493A),
    onExpense: Color(0xFFFFFFFF),
    warning: Color(0xFFD9A441),
    warningBg: Color(0xFFFBF1DC),
    warningText: Color(0xFF8A6414),
    transfer: Color(0xFF5B7FB5),
    transferBg: Color(0xFFE7EEF8),
    transferText: Color(0xFF44659A),
  );

  /// Đặc tả chỉ cho nền, thẻ, bề mặt phụ, chữ, primary, thu, chi, cảnh báo.
  /// Phần còn lại suy ra: nền nhạt = màu gốc ~16–20% phủ trên nền thẻ.
  static const dark = AppPalette._(
    brightness: Brightness.dark,
    primary: Color(0xFF7CC2AE),
    onPrimary: Color(0xFF0F2A24),
    primaryContainer: Color(0xFF2E403C),
    onPrimaryContainer: Color(0xFFCDEBE2),
    primaryText: Color(0xFF7CC2AE),
    background: Color(0xFF121615),
    card: Color(0xFF1A201F),
    surfaceAlt: Color(0xFF222A28),
    textPrimary: Color(0xFFE6ECEA),
    textSecondary: Color(0xFFA3B0AC),
    textMuted: Color(0xFF6F7C78),
    divider: Color(0xFF2C3533),
    income: Color(0xFF6FCF9F),
    incomeBg: Color(0xFF283C34),
    incomeText: Color(0xFF6FCF9F),
    expense: Color(0xFFEE8F82),
    expenseBg: Color(0xFF3C322F),
    expenseText: Color(0xFFEE8F82),
    onExpense: Color(0xFF3A1410),
    warning: Color(0xFFE8BE6A),
    warningBg: Color(0xFF3B392B),
    warningText: Color(0xFFE8BE6A),
    transfer: Color(0xFF8FB0DE),
    transferBg: Color(0xFF2D373E),
    transferText: Color(0xFF8FB0DE),
  );
}

/// Lưới 8px.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Lề hai bên màn hình.
  static const screenGutter = 20.0;

  /// Khoảng cách giữa các thẻ.
  static const cardGap = 12.0;
}

abstract final class AppRadius {
  static const card = Radius.circular(20);
  static const button = Radius.circular(14);
  static const input = Radius.circular(14);

  /// Chỉ góc trên của bottom sheet.
  static const sheet = Radius.circular(28);

  /// Chip / nền mục điều hướng dạng viên thuốc.
  static const pill = StadiumBorder();
}

abstract final class AppSizes {
  static const minTouch = 48.0;
  static const buttonHeight = 52.0;
  static const fab = 60.0;
  static const categoryIcon = 40.0;
  static const progressBar = 8.0;
}

/// Màu danh mục mặc định theo `system_key` (khớp seed trong lib/data/seed/default_categories.dart).
abstract final class CategoryPalette {
  static const fallback = Color(0xFFB5B5B5);

  static const bySystemKey = <String, Color>{
    'an_uong': Color(0xFFE8A87C),
    'di_chuyen': Color(0xFF7FA7D9),
    'nha_cua': Color(0xFFA99BD6),
    'hoa_don': Color(0xFF6FB7B7),
    'mua_sam': Color(0xFFE59AB0),
    'giai_tri': Color(0xFFF0C66B),
    'suc_khoe': Color(0xFF8CC79A),
    'giao_duc': Color(0xFF9BB0E0),
    'khac_chi': fallback,
    'luong': Color(0xFF5FAE8C),
    'thuong': Color(0xFFC9B26B),
    'ban_hang': Color(0xFFE8A87C),
    'lai_tiet_kiem': Color(0xFF9BB0E0),
    'khac_thu': fallback,
  };
}

/// Màu nhận diện theo loại ví (icon và nền nhạt của icon).
abstract final class WalletPalette {
  static const byType = <WalletType, Color>{
    WalletType.cash: Color(0xFF5FAE8C),
    WalletType.bank: Color(0xFF6FB7B7),
    WalletType.ewallet: Color(0xFFE59AB0),
    WalletType.credit: Color(0xFF7FA7D9),
  };
}

/// Màu pastel cho hình minh họa (onboarding, trạng thái trống). Chỉ dùng cho đồ họa trang trí.
abstract final class IllustrationColors {
  static const yellow = Color(0xFFF0C66B);
  static const blue = Color(0xFF7FA7D9);
  static const pink = Color(0xFFE59AB0);
  static const green = Color(0xFF8CC79A);
  static const orange = Color(0xFFE8A87C);
  static const teal = Color(0xFF6FB7B7);
  static const coral = Color(0xFFE8A2A0);
}
