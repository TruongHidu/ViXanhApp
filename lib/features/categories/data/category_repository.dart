import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums.dart';
import '../../../core/failure.dart';
import '../../../core/ids.dart';
import '../../../core/result.dart';
import '../../../data/daos/categories_dao.dart';
import '../../../data/database.dart';

/// Mã lỗi danh mục (đặt vào `Failure.code`); UI dịch theo mã, repository không chứa chuỗi hiển thị.
abstract final class CategoryErrors {
  static const nameInvalid = 'category_name_invalid';
  static const hierarchy = 'category_hierarchy';
  static const notFound = 'category_not_found';
}

/// Đường ghi duy nhất cho danh mục. Không ném exception: mọi lỗi thành [Failure].
final class CategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;

  static const minNameLength = 1;
  static const maxNameLength = 64;

  /// Cây cha – con của một loại, theo thứ tự hiển thị.
  Stream<List<CategoryNode>> watchByType(CategoryType type) => _db.categoriesDao.watchByType(type);

  /// Tạo danh mục; đặt cuối danh sách cùng cấp. [parentId] `null` = danh mục chính.
  Future<Result<CategoryId>> create({
    required String name,
    required CategoryType type,
    required String icon,
    required int color,
    CategoryId? parentId,
  }) async {
    if (_nameFailure(name) case final failure?) return Err(failure);
    return guardAsync(() async {
      final position = await _db.categoriesDao.nextSortOrder(type, parentId);
      return _db.categoriesDao.insertCategory(
        CategoriesCompanion(
          name: Value(name.trim()),
          type: Value(type),
          icon: Value(icon),
          color: Value(color),
          parentId: Value(parentId),
          sortOrder: Value(position),
        ),
      );
    }, onError: _toFailure);
  }

  /// Sửa tên, biểu tượng, màu, danh mục cha. Không đổi loại (thu/chi) của danh mục.
  Future<Result<void>> update(
    CategoryId id, {
    required String name,
    required String icon,
    required int color,
    CategoryId? parentId,
  }) async {
    if (_nameFailure(name) case final failure?) return Err(failure);
    return guardAsync(() async {
      final updated = await _db.categoriesDao.updateCategory(
        id,
        CategoriesCompanion(
          name: Value(name.trim()),
          icon: Value(icon),
          color: Value(color),
          parentId: Value(parentId),
        ),
      );
      if (!updated) throw const _NotFound();
    }, onError: _toFailure);
  }

  /// Xóa mềm danh mục và các mục con. Giao dịch cũ vẫn giữ tên danh mục.
  Future<Result<void>> delete(CategoryId id) => guardAsync(() async {
    if (!await _db.categoriesDao.softDelete(id)) throw const _NotFound();
  }, onError: _toFailure);

  /// Sắp xếp lại các danh mục cùng cấp theo thứ tự [ordered].
  Future<Result<void>> reorder(List<CategoryId> ordered) =>
      guardAsync(() => _db.categoriesDao.reorder(ordered), onError: _toFailure);

  static ValidationFailure? _nameFailure(String name) {
    final length = name.trim().length;
    if (length >= minNameLength && length <= maxNameLength) return null;
    return const ValidationFailure('Tên danh mục không hợp lệ', code: CategoryErrors.nameInvalid);
  }

  static Failure _toFailure(Object error) => switch (error) {
    InvalidCategoryHierarchy(:final message) => ValidationFailure(
      message,
      code: CategoryErrors.hierarchy,
      cause: error,
    ),
    _NotFound() => const NotFoundFailure('Không tìm thấy danh mục', code: CategoryErrors.notFound),
    InvalidDataException() => ValidationFailure(
      'Dữ liệu danh mục không hợp lệ',
      code: CategoryErrors.nameInvalid,
      cause: error,
    ),
    _ => DatabaseFailure('Không ghi được danh mục', cause: error),
  };
}

final class _NotFound implements Exception {
  const _NotFound();
}

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(ref.watch(appDatabaseProvider)),
);

/// Cây danh mục theo loại, tự cập nhật khi DB đổi.
final categoryTreeProvider = StreamProvider.autoDispose.family<List<CategoryNode>, CategoryType>(
  (ref, type) => ref.watch(categoryRepositoryProvider).watchByType(type),
);
