import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums.dart';
import '../../../../core/ids.dart';
import '../../../../data/database.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../theme/tokens.dart';
import '../../../../theme/widgets/category_avatar.dart';
import '../../data/category_repository.dart';
import '../../domain/category_icons.dart';

/// Bottom sheet chọn danh mục (cây cha – con) của một loại. Trả về id đã chọn hoặc `null`.
Future<CategoryId?> showCategoryPicker(
  BuildContext context, {
  required CategoryType type,
  CategoryId? selected,
}) => showModalBottomSheet<CategoryId>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.7,
    maxChildSize: 0.95,
    builder: (context, controller) =>
        _CategoryPickerSheet(type: type, selected: selected, controller: controller),
  ),
);

class _CategoryPickerSheet extends ConsumerWidget {
  const _CategoryPickerSheet({required this.type, required this.controller, this.selected});

  final CategoryType type;
  final CategoryId? selected;
  final ScrollController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tree = ref.watch(categoryTreeProvider(type)).value ?? const [];

    Widget tile(CategoryRow c, {bool child = false}) => ListTile(
      contentPadding: EdgeInsets.only(
        left: AppSpacing.screenGutter + (child ? AppSpacing.xxl : 0),
        right: AppSpacing.screenGutter,
      ),
      selected: c.id == selected,
      leading: CategoryAvatar(
        icon: categoryIcon(c.icon),
        color: Color(c.color),
        semanticLabel: c.name,
        size: child ? 32 : AppSizes.categoryIcon,
      ),
      title: Text(c.name),
      trailing: c.id == selected ? const Icon(Icons.check_rounded) : null,
      onTap: () => Navigator.of(context).pop(c.id),
    );

    return ListView(
      controller: controller,
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenGutter,
            0,
            AppSpacing.screenGutter,
            AppSpacing.sm,
          ),
          child: Semantics(
            header: true,
            child: Text(l10n.chooseCategory, style: theme.textTheme.titleMedium),
          ),
        ),
        for (final node in tree) ...[
          tile(node.category),
          for (final c in node.children) tile(c, child: true),
        ],
      ],
    );
  }
}
