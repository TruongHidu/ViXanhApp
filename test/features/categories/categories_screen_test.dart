import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/enums.dart';
import 'package:vi_xanh_app/data/database.dart';
import 'package:vi_xanh_app/features/categories/presentation/categories_screen.dart';
import 'package:vi_xanh_app/features/transactions/presentation/add_transaction_screen.dart';
import 'package:vi_xanh_app/features/wallets/data/wallet_repository.dart';
import 'package:vi_xanh_app/theme/widgets/app_bottom_bar.dart';

import '../../fakes/fakes.dart';
import '../../helpers.dart';

void main() {
  Future<AppDatabase> openCategories(
    WidgetTester tester, {
    Size size = const Size(400, 1400),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await tester.runAsync(
      () => WalletRepository(db).create(name: 'Tiền mặt', type: WalletType.cash),
    );
    await tester.pumpWidget(
      buildTestApp(db, store: FakeKeyValueStore({'locale': 'vi', 'onboarding_completed': true})),
    );
    await settleDb(tester);
    await tester.tap(
      find.descendant(of: find.byType(AppBottomBar), matching: find.text('Tài khoản')),
    );
    await settleDb(tester);
    await tester.scrollUntilVisible(
      find.text('Danh mục'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    // Đưa dòng lên phần trên màn để không nằm dưới thanh điều hướng / nút "+".
    await Scrollable.ensureVisible(tester.element(find.text('Danh mục')), alignment: 0.3);
    await tester.pumpAndSettle();
    // Chạm mép trái chữ: nút "+" nổi ở giữa đáy màn có thể che phần giữa dòng.
    await tester.tapAt(tester.getTopLeft(find.text('Danh mục')) + const Offset(8, 8));
    await settleDb(tester);
    expect(find.byType(CategoriesScreen), findsOneWidget);
    return db;
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await settleDb(tester);
  }

  Future<List<String>> rootNames(WidgetTester tester, AppDatabase db, CategoryType type) async =>
      (await tester.runAsync(
        () => db.categoriesDao.watchByType(type).first,
      ))!.map((n) => n.category.name).toList();

  testWidgets('hiện danh mục chính kèm số mục con; tab Thu nhập', (tester) async {
    await openCategories(tester);
    expect(find.text('Ăn uống'), findsOneWidget);
    expect(find.text('2 mục con'), findsOneWidget);
    expect(find.text('3 mục con'), findsOneWidget, reason: 'Hóa đơn');
    await tester.tap(find.text('Thu nhập'));
    await settleDb(tester);
    expect(find.text('Lương'), findsOneWidget);
    expect(find.text('Ăn uống'), findsNothing);
  });

  testWidgets('mở Ăn uống → Thêm mục con → có dưới cha và trong màn Thêm giao dịch', (
    tester,
  ) async {
    final db = await openCategories(tester);
    await tester.tap(find.text('Ăn uống'));
    await tester.pumpAndSettle();
    expect(find.text('Cà phê'), findsOneWidget);

    await tapVisible(tester, find.text('Thêm mục con'));
    await tester.enterText(find.byType(TextField), 'Trà sữa');
    await tester.tap(find.bySemanticsLabel('Thú cưng'));
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await tapVisible(tester, find.text('Lưu'));

    expect(find.text('Trà sữa'), findsOneWidget);
    expect(find.text('3 mục con'), findsNWidgets(2), reason: 'Ăn uống giờ có 3 mục con');

    final all = (await tester.runAsync(
      () => db.categoriesDao.watchByType(CategoryType.expense).first,
    ))!;
    final food = all.firstWhere((n) => n.category.name == 'Ăn uống');
    expect(food.children.map((c) => c.name), contains('Trà sữa'));

    // Màn Thêm giao dịch: "Tất cả" → thấy Trà sữa.
    await tester.binding.handlePopRoute();
    await settleDb(tester);
    await tester.tap(find.byTooltip('Thêm giao dịch'));
    await settleDb(tester);
    expect(find.byType(AddTransactionScreen), findsOneWidget);
    await tapVisible(tester, find.text('Tất cả'));
    expect(find.text('Trà sữa'), findsOneWidget);
  });

  testWidgets('Thêm danh mục chính với tên rỗng → nút Lưu tắt', (tester) async {
    await openCategories(tester);
    await tapVisible(tester, find.text('Thêm danh mục'));
    final save = find.widgetWithText(FilledButton, 'Lưu');
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'Thú cưng');
    await tester.pump();
    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
  });

  testWidgets('kéo-thả đổi thứ tự được lưu', (tester) async {
    final db = await openCategories(tester);
    final before = await rootNames(tester, db, CategoryType.expense);
    expect(before.first, 'Ăn uống');

    // Tay kéo của dòng đầu tiên (Ăn uống).
    final handle = find.byIcon(Icons.drag_indicator_rounded).first;
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await gesture.moveBy(const Offset(0, 160));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(0, 10));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await settleDb(tester);

    final after = await rootNames(tester, db, CategoryType.expense);
    expect(after.first, isNot('Ăn uống'));
    expect(after.toSet(), before.toSet());
  });

  testWidgets('sửa → Xóa danh mục (xác nhận) → biến mất', (tester) async {
    final db = await openCategories(tester);
    await tester.tap(find.byTooltip('Sửa Giáo dục'));
    await settleDb(tester);
    await tapVisible(tester, find.text('Xóa danh mục'));
    expect(find.text('Xóa danh mục Giáo dục?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Xóa danh mục').last);
    await settleDb(tester);
    expect(find.text('Đã xóa danh mục'), findsOneWidget);
    expect(await rootNames(tester, db, CategoryType.expense), isNot(contains('Giáo dục')));
  });

  testWidgets('màn 320px, chữ 2x: danh sách và bảng không tràn', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openCategories(tester, size: const Size(320, 640));
    expect(tester.takeException(), isNull);
    await tapVisible(tester, find.byTooltip('Sửa Ăn uống'));
    expect(tester.takeException(), isNull);
  });
}
