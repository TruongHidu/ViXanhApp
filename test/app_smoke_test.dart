import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/features/home/presentation/home_screen.dart';

import 'fakes/fakes.dart';
import 'helpers.dart';

void main() {
  testWidgets('App đã qua onboarding mở thẳng màn Tổng quan', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await tester.pumpWidget(
      buildTestApp(db, store: FakeKeyValueStore({'locale': 'vi', 'onboarding_completed': true})),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Tổng quan'), findsWidgets);
  });
}
