import 'package:drift/drift.dart';

import '../../core/enums.dart';
import '../converters.dart';
import 'timestamps.dart';

/// Danh mục tối đa 2 cấp (cha – con); con cùng loại với cha. Ràng buộc cấp được kiểm tra ở DAO.
@DataClassName('CategoryRow')
class Categories extends Table with Timestamps {
  TextColumn get id => text().map(const CategoryIdConverter())();
  TextColumn get parentId =>
      text().nullable().references(Categories, #id).map(const CategoryIdConverter())();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  TextColumn get type => textEnum<CategoryType>()();

  /// Khóa icon (xem `category_icons.dart`), không lưu codepoint.
  TextColumn get icon => text()();

  /// Màu ARGB.
  IntColumn get color => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  /// Khóa ổn định của danh mục mặc định (ví dụ `an_uong`); NULL với danh mục người dùng tạo.
  TextColumn get systemKey => text().nullable().unique()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  bool get isStrict => true;

  @override
  List<String> get customConstraints => [
    "CHECK (type IN ('income', 'expense'))",
    'CHECK (length(name) BETWEEN 1 AND 64)',
    'CHECK (parent_id IS NULL OR parent_id <> id)',
  ];
}
