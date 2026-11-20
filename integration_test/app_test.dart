import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vi_xanh_app/bootstrap.dart';
import 'package:vi_xanh_app/features/home/presentation/home_screen.dart';
import 'package:vi_xanh_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:vi_xanh_app/features/wallets/presentation/widgets/wallet_type_picker.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('khởi động app thật, qua onboarding + thiết lập (nếu cài mới) tới Tổng quan', (
    tester,
  ) async {
    await bootstrap();
    await tester.pumpAndSettle();

    // Cài mới thì đi hết luồng chào mừng; đã chạy trước đó thì vào thẳng Tổng quan.
    if (find.byType(OnboardingScreen).evaluate().isNotEmpty) {
      Future<void> tapPrimary() async {
        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();
      }

      await tapPrimary(); // trang 2
      await tapPrimary(); // trang 3
      await tapPrimary(); // Thiết lập bước 1
      await tapPrimary(); // bước 2
      await tester.tap(
        find.descendant(of: find.byType(WalletTypePicker), matching: find.byType(InkWell)).first,
      );
      await tester.pumpAndSettle();
      await tapPrimary(); // hoàn tất
    }
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
