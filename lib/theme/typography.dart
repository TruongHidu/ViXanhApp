import 'package:flutter/material.dart';

import 'tokens.dart';

/// Font đóng gói trong assets/fonts (khai báo ở pubspec.yaml).
const appFontFamily = 'BeVietnamPro';

/// Bật chữ số đều độ rộng cho số tiền.
///
/// LƯU Ý: bản Be Vietnam Pro hiện tại KHÔNG có bảng `tnum` (chữ số tỉ lệ, "1" hẹp hơn
/// các số khác), nên cờ này chưa có tác dụng. Giữ lại để tự hoạt động nếu đổi sang font có `tnum`.
const tabularFigures = [FontFeature.tabularFigures()];

abstract final class AppTypography {
  /// Ánh xạ thang chữ của đặc tả vào [TextTheme]. Không style nào nhỏ hơn 12px.
  static TextTheme textTheme(AppPalette p) {
    TextStyle s(double size, FontWeight weight, Color color, {double height = 1.4}) => TextStyle(
      fontFamily: appFontFamily,
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );

    return TextTheme(
      displaySmall: s(32, FontWeight.w700, p.textPrimary, height: 1.25),
      headlineMedium: s(22, FontWeight.w600, p.textPrimary, height: 1.3), // tiêu đề màn hình
      headlineSmall: s(20, FontWeight.w600, p.textPrimary, height: 1.3),
      titleLarge: s(22, FontWeight.w600, p.textPrimary, height: 1.3),
      titleMedium: s(17, FontWeight.w600, p.textPrimary), // tiêu đề mục / thẻ
      titleSmall: s(15, FontWeight.w600, p.textPrimary),
      bodyLarge: s(16, FontWeight.w400, p.textPrimary),
      bodyMedium: s(15, FontWeight.w400, p.textPrimary),
      bodySmall: s(13, FontWeight.w400, p.textSecondary), // chú thích
      labelLarge: s(16, FontWeight.w600, p.textPrimary),
      labelMedium: s(13, FontWeight.w500, p.textSecondary),
      labelSmall: s(12, FontWeight.w500, p.textSecondary),
    );
  }
}

/// Style số tiền: đọc bằng `Theme.of(context).extension<AppTextStyles>()!`.
@immutable
final class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({required this.balanceLarge, required this.amountList});

  factory AppTextStyles.fromPalette(AppPalette p) => AppTextStyles(
    balanceLarge: TextStyle(
      fontFamily: appFontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.25,
      color: p.textPrimary,
      fontFeatures: tabularFigures,
    ),
    amountList: TextStyle(
      fontFamily: appFontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: p.textPrimary,
      fontFeatures: tabularFigures,
    ),
  );

  /// Số dư lớn: 32/700.
  final TextStyle balanceLarge;

  /// Số tiền trong danh sách: 16/600.
  final TextStyle amountList;

  @override
  AppTextStyles copyWith({TextStyle? balanceLarge, TextStyle? amountList}) => AppTextStyles(
    balanceLarge: balanceLarge ?? this.balanceLarge,
    amountList: amountList ?? this.amountList,
  );

  @override
  AppTextStyles lerp(covariant ThemeExtension<AppTextStyles>? other, double t) {
    if (other is! AppTextStyles) return this;
    return AppTextStyles(
      balanceLarge: TextStyle.lerp(balanceLarge, other.balanceLarge, t)!,
      amountList: TextStyle.lerp(amountList, other.amountList, t)!,
    );
  }
}
