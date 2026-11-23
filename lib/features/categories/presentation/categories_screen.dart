import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums.dart';
import '../../../core/ids.dart';
import '../../../core/result.dart';
import '../../../data/daos/categories_dao.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import '../../../theme/widgets/category_avatar.dart';
import '../../../theme/widgets/empty_state.dart';
import '../data/category_repository.dart';
import '../domain/category_icons.dart';
import 'category_form_notifier.dart';
import 'widgets/category_form_sheet.dart';

/// Quản lý danh mục: tab Chi tiêu / Thu nhập, cây cha – con, kéo-thả sắp xếp danh mục chính,
/// thêm / sửa / xóa qua bảng dưới.
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  CategoryType _type = CategoryType.expense;
  final _expanded = <CategoryId>{};

  /// Thứ tự tạm trong lúc chờ DB ghi xong (kéo-thả không bị giật về chỗ cũ).
  List<CategoryNode>? _pendingOrder;

  Future<void> _reorder(List<CategoryNode> nodes, int oldIndex, int newIndex) async {
    final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final reordered = [...nodes];
    reordered.insert(target, reordered.removeAt(oldIndex));
    setState(() => _pendingOrder = reordered);

    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final result = await ref.read(categoryRepositoryProvider).reorder([
      for (final n in reordered) n.category.id,
    ]);
    if (!mounted) return;
    setState(() => _pendingOrder = null);
    if (result case Err(:final failure)) {
      messenger.showSnackBar(SnackBar(content: Text(categoryErrorMessage(failure, l10n))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tree = ref.watch(categoryTreeProvider(_type));

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenGutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(l10n.categoriesTitle, style: theme.textTheme.headlineMedium),
                ),
                const SizedBox(height: AppSpacing.md),
                Semantics(
                  label: l10n.categoryTypeTabsLabel,
                  container: true,
                  child: SegmentedButton<CategoryType>(
                    segments: [
                      ButtonSegment(value: CategoryType.expense, label: Text(l10n.txnTypeExpense)),
                      ButtonSegment(value: CategoryType.income, label: Text(l10n.txnTypeIncome)),
                    ],
                    selected: {_type},
                    onSelectionChanged: (s) => setState(() {
                      _type = s.single;
                      _pendingOrder = null;
                    }),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
          Expanded(
            child: switch (tree) {
              AsyncData(:final value) => _buildList(_pendingOrder ?? value),
              AsyncError() => Center(child: Text(l10n.categorySaveFailed)),
              _ => const SizedBox.shrink(),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<CategoryNode> nodes) {
    final l10n = AppLocalizations.of(context);
    final addButton = Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: FilledButton.icon(
        onPressed: () => showCategoryFormSheet(context, type: _type),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.categoryAdd),
      ),
    );
    if (nodes.isEmpty) {
      return EmptyState(
        icon: Icons.grid_view_rounded,
        message: l10n.categoryAdd,
        actionLabel: l10n.categoryAdd,
        onAction: () => showCategoryFormSheet(context, type: _type),
      );
    }
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenGutter,
        0,
        AppSpacing.screenGutter,
        AppSpacing.xl,
      ),
      buildDefaultDragHandles: false,
      itemCount: nodes.length,
      onReorder: (oldIndex, newIndex) => _reorder(nodes, oldIndex, newIndex),
      footer: addButton,
      itemBuilder: (context, i) {
        final node = nodes[i];
        return _CategoryItem(
          key: ValueKey(node.category.id),
          node: node,
          index: i,
          first: i == 0,
          last: i == nodes.length - 1,
          expanded: _expanded.contains(node.category.id),
          onToggle: () => setState(() {
            if (!_expanded.remove(node.category.id)) _expanded.add(node.category.id);
          }),
          type: _type,
        );
      },
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.node,
    required this.index,
    required this.first,
    required this.last,
    required this.expanded,
    required this.onToggle,
    required this.type,
    super.key,
  });

  final CategoryNode node;
  final int index;
  final bool first;
  final bool last;
  final bool expanded;
  final VoidCallback onToggle;
  final CategoryType type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final category = node.category;
    final color = Color(category.color);

    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: first ? AppRadius.card : Radius.zero,
          bottom: last ? AppRadius.card : Radius.zero,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (!first) Divider(color: colors.divider),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: Semantics(
                    label: l10n.categoryDragHandle(category.name),
                    child: SizedBox.square(
                      dimension: AppSizes.minTouch,
                      child: Icon(Icons.drag_indicator_rounded, color: colors.textMuted),
                    ),
                  ),
                ),
                CategoryAvatar(
                  icon: categoryIcon(category.icon),
                  color: color,
                  semanticLabel: category.name,
                ),
                Expanded(
                  child: Semantics(
                    button: true,
                    label: l10n.categoryShowChildren(category.name),
                    value: l10n.categorySubCount(node.children.length),
                    onTap: onToggle,
                    excludeSemantics: true,
                    child: InkWell(
                      onTap: onToggle,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 56),
                        child: Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.md),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      category.name,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      l10n.categorySubCount(node.children.length),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedRotation(
                                turns: expanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 180),
                                child: Icon(Icons.expand_more_rounded, color: colors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.categoryEditTooltip(category.name),
                  onPressed: () => showCategoryFormSheet(
                    context,
                    type: type,
                    editing: category,
                    hasChildren: node.children.isNotEmpty,
                  ),
                  icon: Icon(Icons.edit_outlined, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.only(left: 52, right: AppSpacing.xs, bottom: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final child in node.children) ...[
                    Divider(color: colors.divider),
                    Semantics(
                      button: true,
                      label: l10n.categoryEditTooltip(child.name),
                      excludeSemantics: true,
                      child: InkWell(
                        onTap: () => showCategoryFormSheet(context, type: type, editing: child),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 52),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Color(child.color),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(child: Text(child.name, style: theme.textTheme.bodyMedium)),
                              SizedBox.square(
                                dimension: AppSizes.minTouch,
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  Divider(color: colors.divider),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () =>
                          showCategoryFormSheet(context, type: type, parentId: category.id),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.categoryAddChild),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
