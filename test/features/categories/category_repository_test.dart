import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/enums.dart';
import 'package:vi_xanh_app/core/failure.dart';
import 'package:vi_xanh_app/core/ids.dart';
import 'package:vi_xanh_app/core/result.dart';
import 'package:vi_xanh_app/data/database.dart';
import 'package:vi_xanh_app/features/categories/data/category_repository.dart';

import '../../helpers.dart';

void main() {
  late AppDatabase db;
  late CategoryRepository repo;

  CategoryId cat(String key) => CategoryId(stableUuid('category:$key'));

  String? codeOf(Result<Object?> r) => switch (r) {
    Err(:final failure) => failure.code,
    _ => null,
  };

  Future<Result<CategoryId>> create(
    String name, {
    CategoryType type = CategoryType.expense,
    CategoryId? parent,
  }) => repo.create(name: name, type: type, icon: 'pets', color: 0xFFE8A87C, parentId: parent);

  setUp(() {
    db = inMemoryDatabase();
    repo = CategoryRepository(db);
  });
  tearDown(() => db.close());

  test('tạo mục con hợp lệ: nằm cuối danh sách con của cha', () async {
    final id = (await create('Trà sữa', parent: cat('an_uong'))).valueOrNull!;
    final tree = await repo.watchByType(CategoryType.expense).first;
    final food = tree.firstWhere((n) => n.category.id == cat('an_uong'));
    expect(food.children.last.id, id);
    expect(food.children.last.name, 'Trà sữa');
  });

  test('tạo danh mục chính mới nằm cuối danh sách gốc', () async {
    final id = (await create('  Thú cưng ')).valueOrNull!;
    final tree = await repo.watchByType(CategoryType.expense).first;
    expect(tree.last.category.id, id);
    expect(tree.last.category.name, 'Thú cưng');
  });

  test('tên rỗng / quá dài → category_name_invalid', () async {
    expect(codeOf(await create('  ')), CategoryErrors.nameInvalid);
    expect(codeOf(await create('a' * 65)), CategoryErrors.nameInvalid);
  });

  test('cấp 3 → category_hierarchy (ValidationFailure)', () async {
    final result = await create('Latte', parent: cat('ca_phe'));
    expect((result as Err<CategoryId>).failure, isA<ValidationFailure>());
    expect(codeOf(result), CategoryErrors.hierarchy);
  });

  test('chọn cha khác loại → category_hierarchy', () async {
    expect(
      codeOf(await create('Hoàn tiền', type: CategoryType.income, parent: cat('an_uong'))),
      CategoryErrors.hierarchy,
    );
    expect(
      codeOf(
        await repo.update(
          cat('ca_phe'),
          name: 'Cà phê',
          icon: 'restaurant',
          color: 0xFFE8A87C,
          parentId: cat('luong'),
        ),
      ),
      CategoryErrors.hierarchy,
    );
  });

  test('danh mục đang có con không thể thành mục con', () async {
    expect(
      codeOf(
        await repo.update(
          cat('an_uong'),
          name: 'Ăn uống',
          icon: 'restaurant',
          color: 0xFFE8A87C,
          parentId: cat('mua_sam'),
        ),
      ),
      CategoryErrors.hierarchy,
    );
  });

  test('sửa tên, biểu tượng, màu; chuyển mục con sang cha khác cùng loại', () async {
    final result = await repo.update(
      cat('ca_phe'),
      name: 'Cà phê sáng',
      icon: 'redeem',
      color: 0xFF7FA7D9,
      parentId: cat('giai_tri'),
    );
    expect(result.isOk, isTrue);
    final tree = await repo.watchByType(CategoryType.expense).first;
    final fun = tree.firstWhere((n) => n.category.id == cat('giai_tri'));
    expect(fun.children.single.name, 'Cà phê sáng');
    expect(fun.children.single.icon, 'redeem');
  });

  test('reorder đổi đúng thứ tự danh mục chính', () async {
    final roots = (await repo.watchByType(CategoryType.income).first)
        .map((n) => n.category.id)
        .toList();
    final reversed = roots.reversed.toList();
    expect((await repo.reorder(reversed)).isOk, isTrue);
    final after = (await repo.watchByType(CategoryType.income).first)
        .map((n) => n.category.id)
        .toList();
    expect(after, reversed);
  });

  test('xóa cha ẩn cả con; xóa lần nữa → not found', () async {
    expect((await repo.delete(cat('hoa_don'))).isOk, isTrue);
    final tree = await repo.watchByType(CategoryType.expense).first;
    expect(tree.map((n) => n.category.id), isNot(contains(cat('hoa_don'))));
    expect(await db.categoriesDao.findById(cat('dien')), isNull);
    expect(codeOf(await repo.delete(cat('hoa_don'))), CategoryErrors.notFound);
  });
}
