import 'package:drift/drift.dart';

import '../../core/enums.dart';
import '../../core/ids.dart';
import '../database.dart';
import '../tables/tables.dart';

part 'categories_dao.g.dart';

/// Một danh mục gốc kèm các danh mục con (đã sắp xếp).
final class CategoryNode {
  const CategoryNode(this.category, this.children);

  final CategoryRow category;
  final List<CategoryRow> children;
}

/// Vi phạm cấu trúc cây danh mục (quá 2 cấp, khác loại với cha, cha không tồn tại).
final class InvalidCategoryHierarchy implements Exception {
  const InvalidCategoryHierarchy(this.message);
  final String message;

  @override
  String toString() => 'InvalidCategoryHierarchy: $message';
}

@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoMixin {
  CategoriesDao(super.attachedDatabase);

  /// Cây cha – con của một loại, theo `sort_order` rồi tên.
  Stream<List<CategoryNode>> watchByType(CategoryType type) =>
      (select(categories)
            ..where((c) => c.type.equalsValue(type) & c.deletedAt.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.sortOrder), (c) => OrderingTerm.asc(c.name)]))
          .watch()
          .map(_buildTree);

  static List<CategoryNode> _buildTree(List<CategoryRow> rows) {
    final children = <CategoryId, List<CategoryRow>>{};
    for (final r in rows) {
      if (r.parentId case final parent?) (children[parent] ??= []).add(r);
    }
    return [
      for (final r in rows)
        if (r.parentId == null) CategoryNode(r, children[r.id] ?? const []),
    ];
  }

  Future<CategoryRow?> findById(CategoryId id) => (select(
    categories,
  )..where((c) => c.id.equalsValue(id) & c.deletedAt.isNull())).getSingleOrNull();

  /// Ném [InvalidCategoryHierarchy] nếu vi phạm cây 2 cấp.
  Future<CategoryId> insertCategory(CategoriesCompanion entry) => transaction(() async {
    if ((entry.parentId.present ? entry.parentId.value : null) case final parent?) {
      await _checkParent(parent, entry.type.value);
    }
    final now = attachedDatabase.clock.now();
    final id = entry.id.present ? entry.id.value : CategoryId(attachedDatabase.ids.newId());
    await into(
      categories,
    ).insert(entry.copyWith(id: Value(id), createdAt: Value(now), updatedAt: Value(now)));
    return id;
  });

  /// Ném [InvalidCategoryHierarchy] nếu thay đổi làm vi phạm cây 2 cấp.
  Future<bool> updateCategory(CategoryId id, CategoriesCompanion patch) => transaction(() async {
    final current = await findById(id);
    if (current == null) return false;
    final parent = patch.parentId.present ? patch.parentId.value : current.parentId;
    final type = patch.type.present ? patch.type.value : current.type;
    if (parent != null) {
      if (parent == id) {
        throw const InvalidCategoryHierarchy('Danh mục không thể là cha của chính nó');
      }
      if (await _hasChildren(id)) {
        throw const InvalidCategoryHierarchy('Danh mục đang có danh mục con không thể làm con');
      }
      await _checkParent(parent, type);
    } else if (type != current.type && await _hasChildren(id)) {
      throw const InvalidCategoryHierarchy('Không đổi loại danh mục đang có danh mục con');
    }
    final count = await (update(categories)..where((c) => c.id.equalsValue(id))).write(
      patch.copyWith(id: const Value.absent(), updatedAt: Value(attachedDatabase.clock.now())),
    );
    return count > 0;
  });

  /// Đặt lại `sort_order` theo thứ tự [ordered] (0, 1, 2…) trong một transaction.
  /// Chỉ đổi các danh mục có trong danh sách; nơi gọi đảm bảo chúng cùng cấp.
  Future<void> reorder(List<CategoryId> ordered) => transaction(() async {
    final now = attachedDatabase.clock.now();
    for (final (index, id) in ordered.indexed) {
      await (update(categories)..where((c) => c.id.equalsValue(id))).write(
        CategoriesCompanion(sortOrder: Value(index), updatedAt: Value(now)),
      );
    }
  });

  /// `sort_order` để đặt một danh mục mới xuống cuối nhóm cùng cấp: lớn nhất hiện có + 1
  /// ([parentId] `null` = danh mục gốc). Seed đánh số theo cả danh sách nên không dùng số lượng.
  Future<int> nextSortOrder(CategoryType type, CategoryId? parentId) async {
    final query = select(categories)
      ..where(
        (c) =>
            c.type.equalsValue(type) &
            c.deletedAt.isNull() &
            (parentId == null ? c.parentId.isNull() : c.parentId.equalsValue(parentId)),
      );
    final orders = (await query.get()).map((c) => c.sortOrder);
    return orders.isEmpty ? 0 : orders.reduce((a, b) => a > b ? a : b) + 1;
  }

  /// Xóa mềm danh mục và mọi danh mục con của nó.
  Future<bool> softDelete(CategoryId id) => transaction(() async {
    final now = attachedDatabase.clock.now();
    final stamp = CategoriesCompanion(deletedAt: Value(now), updatedAt: Value(now));
    await (update(
      categories,
    )..where((c) => c.parentId.equalsValue(id) & c.deletedAt.isNull())).write(stamp);
    final count = await (update(
      categories,
    )..where((c) => c.id.equalsValue(id) & c.deletedAt.isNull())).write(stamp);
    return count > 0;
  });

  Future<void> _checkParent(CategoryId parentId, CategoryType childType) async {
    final parent = await findById(parentId);
    if (parent == null) throw const InvalidCategoryHierarchy('Danh mục cha không tồn tại');
    if (parent.parentId != null) {
      throw const InvalidCategoryHierarchy('Danh mục chỉ có tối đa 2 cấp');
    }
    if (parent.type != childType) {
      throw const InvalidCategoryHierarchy('Danh mục con phải cùng loại với danh mục cha');
    }
  }

  Future<bool> _hasChildren(CategoryId id) async {
    final child =
        await (select(categories)
              ..where((c) => c.parentId.equalsValue(id) & c.deletedAt.isNull())
              ..limit(1))
            .getSingleOrNull();
    return child != null;
  }
}
