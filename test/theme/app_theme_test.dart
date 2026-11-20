import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/theme/app_colors.dart';
import 'package:vi_xanh_app/theme/app_theme.dart';
import 'package:vi_xanh_app/theme/tokens.dart';
import 'package:vi_xanh_app/theme/typography.dart';
import 'package:vi_xanh_app/theme/widgets/category_avatar.dart';
import 'package:vi_xanh_app/theme/widgets/empty_state.dart';

void main() {
  group('AppColors', () {
    final light = AppColors.fromPalette(AppPalette.light);
    final dark = AppColors.fromPalette(AppPalette.dark);

    test('lerp ở 0 và 1 trả về hai đầu', () {
      expect(light.lerp(dark, 0).income, light.income);
      expect(light.lerp(dark, 1).income, dark.income);
      expect(light.lerp(dark, 1).transferText, dark.transferText);
      expect(light.lerp(null, 0.5), same(light));
    });

    test('copyWith chỉ đổi trường được truyền', () {
      final changed = light.copyWith(income: Colors.pink);
      expect(changed.income, Colors.pink);
      expect(changed.expense, light.expense);
      expect(changed.textSecondary, light.textSecondary);
    });
  });

  test('AppTextStyles.lerp trả về hai đầu', () {
    final a = AppTextStyles.fromPalette(AppPalette.light);
    final b = AppTextStyles.fromPalette(AppPalette.dark);
    expect(a.lerp(b, 1).balanceLarge.color, b.balanceLarge.color);
  });

  for (final (name, theme) in [('sáng', AppTheme.light()), ('tối', AppTheme.dark())]) {
    group('ThemeData $name', () {
      test('dùng Be Vietnam Pro cho mọi style chữ', () {
        expect(theme.textTheme.bodyLarge!.fontFamily, appFontFamily);
        expect(theme.textTheme.headlineMedium!.fontFamily, appFontFamily);
      });

      test('thang chữ đúng đặc tả và không nhỏ hơn 12px', () {
        final t = theme.textTheme;
        expect((t.headlineMedium!.fontSize, t.headlineMedium!.fontWeight), (22, FontWeight.w600));
        expect((t.titleMedium!.fontSize, t.titleMedium!.fontWeight), (17, FontWeight.w600));
        expect((t.bodySmall!.fontSize, t.bodySmall!.fontWeight), (13, FontWeight.w400));
        for (final style in [
          t.displaySmall, t.headlineMedium, t.headlineSmall, t.titleLarge, t.titleMedium, //
          t.titleSmall, t.bodyLarge, t.bodyMedium, t.bodySmall, t.labelLarge, t.labelMedium,
          t.labelSmall,
        ]) {
          expect(style!.fontSize, greaterThanOrEqualTo(12));
        }
      });

      test('style số tiền có tabularFigures', () {
        final money = theme.extension<AppTextStyles>()!;
        expect(money.balanceLarge.fontSize, 32);
        expect(money.balanceLarge.fontWeight, FontWeight.w700);
        expect(money.balanceLarge.fontFeatures, contains(const FontFeature.tabularFigures()));
        expect(money.amountList.fontSize, 16);
        expect(money.amountList.fontFeatures, contains(const FontFeature.tabularFigures()));
      });

      test('có đủ extension và nền app đúng palette', () {
        expect(theme.extension<AppColors>(), isNotNull);
        expect(theme.scaffoldBackgroundColor, theme.extension<AppColors>()!.background);
      });
    });
  }

  testWidgets('Theme.of trả về font Be Vietnam Pro', (tester) async {
    late TextTheme textTheme;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Builder(
          builder: (context) {
            textTheme = Theme.of(context).textTheme;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(textTheme.bodyLarge!.fontFamily, appFontFamily);
  });

  group('widget dùng chung với chữ phóng to 2x', () {
    Future<void> pump(WidgetTester tester, Widget child, {double width = 320}) async {
      tester.view.physicalSize = Size(width, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(body: child),
          ),
        ),
      );
    }

    testWidgets('EmptyState có nút không tràn bố cục', (tester) async {
      var tapped = false;
      await pump(
        tester,
        EmptyState(
          icon: Icons.receipt_long_outlined,
          message: 'Chưa có giao dịch nào. Bấm nút + để ghi khoản đầu tiên của bạn nhé.',
          actionLabel: 'Thêm giao dịch',
          onAction: () => tapped = true,
        ),
      );
      expect(tester.takeException(), isNull);
      // Chữ 2x đẩy nút xuống dưới màn hình — EmptyState phải cuộn tới được.
      await tester.ensureVisible(find.text('Thêm giao dịch'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Thêm giao dịch'));
      expect(tapped, isTrue);
    });

    testWidgets('CategoryAvatar có nhãn ngữ nghĩa và không tràn', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(
        tester,
        const Center(
          child: CategoryAvatar(
            icon: Icons.restaurant_rounded,
            color: Color(0xFFE8A87C),
            semanticLabel: 'Ăn uống',
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.bySemanticsLabel('Ăn uống'), findsOneWidget);
      expect(tester.getSize(find.byType(CategoryAvatar)), const Size.square(AppSizes.categoryIcon));
      handle.dispose();
    });
  });
}
