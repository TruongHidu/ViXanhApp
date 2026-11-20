import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums.dart';
import '../../../data/daos/categories_dao.dart';
import '../../../data/database.dart';

/// Truy cập danh mục. Phần ghi (thêm/sửa/xóa/sắp xếp) làm cùng màn quản lý Danh mục.
final class CategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;

  /// Cây cha – con của một loại, theo thứ tự hiển thị.
  Stream<List<CategoryNode>> watchByType(CategoryType type) => _db.categoriesDao.watchByType(type);
}

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(ref.watch(appDatabaseProvider)),
);

/// Cây danh mục theo loại, tự cập nhật khi DB đổi.
final categoryTreeProvider = StreamProvider.autoDispose.family<List<CategoryNode>, CategoryType>(
  (ref, type) => ref.watch(categoryRepositoryProvider).watchByType(type),
);
