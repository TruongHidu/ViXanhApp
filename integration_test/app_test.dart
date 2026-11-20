import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vi_xanh_app/bootstrap.dart';
import 'package:vi_xanh_app/features/home/presentation/home_screen.dart';
import 'package:vi_xanh_app/features/onboarding/presentation/onboarding_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('khởi động app thật, qua onboarding (nếu cài mới) tới Tổng quan', (tester) async {
    await bootstrap();
    await tester.pumpAndSettle();

    // Cài mới thì gặp màn chào; đã chạy trước đó thì vào thẳng Tổng quan.
    if (find.byType(OnboardingScreen).evaluate().isNotEmpty) {
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
    }
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
