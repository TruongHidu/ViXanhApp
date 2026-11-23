import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums.dart';
import '../../../core/failure.dart';
import '../../../core/ids.dart';
import '../../../core/result.dart';
import '../../../data/database.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../data/category_repository.dart';
import '../domain/category_icons.dart';

/// Tham số mở bảng: [editing] `null` = thêm mới; [parentId] chọn sẵn khi bấm "Thêm mục con".
typedef CategoryFormArgs = ({CategoryType type, CategoryRow? editing, CategoryId? parentId});

/// Trạng thái bất biến của bảng Thêm / Sửa danh mục.
@immutable
final class CategoryFormState {
  const CategoryFormState({
    required this.icon,
    required this.color,
    this.name = '',
    this.nameEdited = false,
    this.parentId,
    this.saving = false,
  });

  final String name;
  final bool nameEdited;
  final String icon;

  /// Màu ARGB.
  final int color;
  final CategoryId? parentId;
  final bool saving;

  bool get isNameValid {
    final length = name.trim().length;
    return length >= CategoryRepository.minNameLength && length <= CategoryRepository.maxNameLength;
  }

  bool get canSave => isNameValid && !saving;

  static const Object _keep = Object();

  CategoryFormState copyWith({
    String? name,
    bool? nameEdited,
    String? icon,
    int? color,
    Object? parentId = _keep,
    bool? saving,
  }) => CategoryFormState(
    name: name ?? this.name,
    nameEdited: nameEdited ?? this.nameEdited,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    parentId: identical(parentId, _keep) ? this.parentId : parentId as CategoryId?,
    saving: saving ?? this.saving,
  );
}

final categoryFormProvider = NotifierProvider.autoDispose
    .family<CategoryFormNotifier, CategoryFormState, CategoryFormArgs>(CategoryFormNotifier.new);

final class CategoryFormNotifier extends Notifier<CategoryFormState> {
  CategoryFormNotifier(this.args);

  final CategoryFormArgs args;

  @override
  CategoryFormState build() => switch (args.editing) {
    final c? => CategoryFormState(
      name: c.name,
      nameEdited: true,
      icon: c.icon,
      color: c.color,
      parentId: c.parentId,
    ),
    null => CategoryFormState(
      icon: categoryIconChoices.first,
      color: CategoryPalette.choices.first.toARGB32(),
      parentId: args.parentId,
    ),
  };

  void setName(String name) => state = state.copyWith(name: name, nameEdited: true);
  void setIcon(String icon) => state = state.copyWith(icon: icon);
  void setColor(int color) => state = state.copyWith(color: color);
  void setParent(CategoryId? parent) => state = state.copyWith(parentId: parent);

  Future<Result<void>> save() async {
    if (!state.canSave) {
      return const Err(
        ValidationFailure('Tên danh mục không hợp lệ', code: CategoryErrors.nameInvalid),
      );
    }
    final current = state;
    state = current.copyWith(saving: true);
    final repo = ref.read(categoryRepositoryProvider);
    final Result<void> result = switch (args.editing) {
      final c? => await repo.update(
        c.id,
        name: current.name,
        icon: current.icon,
        color: current.color,
        parentId: current.parentId,
      ),
      null => await repo.create(
        name: current.name,
        type: args.type,
        icon: current.icon,
        color: current.color,
        parentId: current.parentId,
      ),
    };
    if (ref.mounted) state = current;
    return result;
  }

  Future<Result<void>> delete() async {
    final editing = args.editing;
    if (editing == null) return const Err(UnexpectedFailure('Không có danh mục để xóa'));
    return ref.read(categoryRepositoryProvider).delete(editing.id);
  }
}

/// Thông báo đã dịch cho lỗi danh mục.
String categoryErrorMessage(Failure failure, AppLocalizations l10n) => switch (failure.code) {
  CategoryErrors.nameInvalid => l10n.categoryErrorName,
  CategoryErrors.hierarchy => l10n.categoryErrorHierarchy,
  _ => l10n.categorySaveFailed,
};
