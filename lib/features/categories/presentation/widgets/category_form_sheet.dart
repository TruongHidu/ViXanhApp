import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums.dart';
import '../../../../core/ids.dart';
import '../../../../core/result.dart';
import '../../../../data/daos/categories_dao.dart';
import '../../../../data/database.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/tokens.dart';
import '../../../../theme/widgets/category_avatar.dart';
import '../../../../theme/widgets/labeled_field.dart';
import '../../data/category_repository.dart';
import '../../domain/category_icons.dart';
import '../category_form_notifier.dart';

/// Bảng Thêm / Sửa danh mục (theo thiết kế "Categories-Sheet").
Future<void> showCategoryFormSheet(
  BuildContext context, {
  required CategoryType type,
  CategoryRow? editing,
  CategoryId? parentId,
  bool hasChildren = false,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => _CategoryFormSheet(
    args: (type: type, editing: editing, parentId: parentId),
    hasChildren: hasChildren,
  ),
);

class _CategoryFormSheet extends ConsumerStatefulWidget {
  const _CategoryFormSheet({required this.args, required this.hasChildren});

  final CategoryFormArgs args;

  /// Danh mục đang sửa có mục con → không được chọn danh mục cha.
  final bool hasChildren;

  @override
  ConsumerState<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<_CategoryFormSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.args.editing?.name ?? '',
  );

  CategoryFormNotifier get _notifier => ref.read(categoryFormProvider(widget.args).notifier);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context);
    final result = await _notifier.save();
    switch (result) {
      case Ok():
        navigator.pop();
      case Err(:final failure):
        messenger.showSnackBar(SnackBar(content: Text(categoryErrorMessage(failure, l10n))));
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final name = widget.args.editing?.name ?? '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.categoryDeleteConfirmTitle(name)),
        content: Text(l10n.categoryDeleteConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.categoryDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await _notifier.delete();
    switch (result) {
      case Ok():
        navigator.pop();
        messenger.showSnackBar(SnackBar(content: Text(l10n.categoryDeleted)));
      case Err(:final failure):
        messenger.showSnackBar(SnackBar(content: Text(categoryErrorMessage(failure, l10n))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final state = ref.watch(categoryFormProvider(widget.args));
    final editing = widget.args.editing;
    final roots = [
      for (final CategoryNode node
          in ref.watch(categoryTreeProvider(widget.args.type)).value ?? const <CategoryNode>[])
        if (node.category.id != editing?.id) node.category,
    ];
    final color = Color(state.color);

    return Padding(
      // Bàn phím mở thì nội dung đẩy lên trên.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenGutter,
          0,
          AppSpacing.screenGutter,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                editing == null ? l10n.categoryAdd : l10n.categoryEdit,
                style: theme.textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            LabeledField(
              label: l10n.categoryNameLabel,
              child: Row(
                children: [
                  CategoryAvatar(
                    icon: categoryIcon(state.icon),
                    color: color,
                    semanticLabel: l10n.categoryIconName(state.icon),
                    size: 52,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _name,
                      onChanged: _notifier.setName,
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: CategoryRepository.maxNameLength,
                      decoration: InputDecoration(
                        hintText: l10n.categoryNameHint,
                        counterText: '',
                        errorText: state.nameEdited && !state.isNameValid
                            ? l10n.categoryErrorName
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.categoryIconLabel,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final key in categoryIconChoices)
                  _ChoiceButton(
                    label: l10n.categoryIconName(key),
                    selected: state.icon == key,
                    onTap: () => _notifier.setIcon(key),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: state.icon == key ? color.withValues(alpha: 0.2) : colors.surfaceAlt,
                        border: Border.all(
                          color: state.icon == key ? theme.colorScheme.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        categoryIcon(key),
                        size: 22,
                        color: state.icon == key ? color : colors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.categoryColorLabel,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final (i, c) in CategoryPalette.choices.indexed)
                  _ChoiceButton(
                    label: l10n.categoryColorName('$i'),
                    selected: state.color == c.toARGB32(),
                    onTap: () => _notifier.setColor(c.toARGB32()),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: state.color == c.toARGB32()
                              ? theme.colorScheme.onSurface
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: state.color == c.toARGB32()
                          ? Icon(Icons.check_rounded, size: 18, color: colors.textSecondary)
                          : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            LabeledField(
              label: l10n.categoryParentLabel,
              child: widget.hasChildren
                  ? Text(l10n.categoryParentLocked, style: theme.textTheme.bodySmall)
                  : DropdownButtonFormField<CategoryId?>(
                      value: roots.any((r) => r.id == state.parentId) ? state.parentId : null,
                      isExpanded: true,
                      onChanged: _notifier.setParent,
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.categoryParentNone)),
                        for (final r in roots) DropdownMenuItem(value: r.id, child: Text(r.name)),
                      ],
                    ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(onPressed: state.canSave ? _save : null, child: Text(l10n.categorySave)),
            if (editing != null) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: _delete,
                style: TextButton.styleFrom(foregroundColor: colors.expenseText),
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(l10n.categoryDelete),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Ô chọn tròn (biểu tượng / màu) có vùng chạm 48px và trạng thái chọn cho trình đọc màn hình.
class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: label,
    onTap: onTap,
    excludeSemantics: true,
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox.square(
        dimension: AppSizes.minTouch,
        child: Center(child: child),
      ),
    ),
  );
}
