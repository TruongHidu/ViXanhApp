import 'package:flutter/foundation.dart';

import '../../../core/ids.dart';

/// Tổng tiền của một danh mục chính trong kỳ (đã gộp các mục con).
@immutable
final class CategoryTotal {
  const CategoryTotal({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.color,
    required this.amount,
  });

  final CategoryId categoryId;
  final String name;
  final String icon;
  final int color;
  final int amount;

  @override
  bool operator ==(Object other) =>
      other is CategoryTotal &&
      other.categoryId == categoryId &&
      other.name == name &&
      other.icon == icon &&
      other.color == color &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(categoryId, name, icon, color, amount);
}

/// Một lát của biểu đồ tròn. [categoryId] `null` = lát "Khác" gộp các danh mục nhỏ.
@immutable
final class CategoryShare {
  const CategoryShare({
    required this.amount,
    required this.fraction,
    this.categoryId,
    this.name,
    this.icon,
    this.color,
  });

  final CategoryId? categoryId;
  final String? name;
  final String? icon;
  final int? color;
  final int amount;

  /// Tỉ lệ trên tổng (0..1).
  final double fraction;

  bool get isOther => categoryId == null;

  /// Phần trăm làm tròn để hiển thị.
  int get percent => (fraction * 100).round();
}

/// Tính tỉ lệ từng danh mục; các danh mục dưới [threshold] (mặc định 3%) gộp thành một lát
/// "Khác" đặt cuối. Chỉ gộp khi có từ hai danh mục nhỏ trở lên (gộp một mục là vô ích).
List<CategoryShare> toShares(List<CategoryTotal> totals, {double threshold = 0.03}) {
  final sum = totals.fold<int>(0, (s, t) => s + t.amount);
  if (sum <= 0) return const [];
  final sorted = [...totals]..sort((a, b) => b.amount.compareTo(a.amount));
  final big = sorted.where((t) => t.amount / sum >= threshold).toList();
  final small = sorted.where((t) => t.amount / sum < threshold).toList();
  final keep = small.length < 2 ? sorted : big;
  return [
    for (final t in keep)
      CategoryShare(
        categoryId: t.categoryId,
        name: t.name,
        icon: t.icon,
        color: t.color,
        amount: t.amount,
        fraction: t.amount / sum,
      ),
    if (small.length >= 2)
      CategoryShare(
        amount: small.fold(0, (s, t) => s + t.amount),
        fraction: small.fold<int>(0, (s, t) => s + t.amount) / sum,
      ),
  ];
}

/// Chênh lệch phần trăm của [current] so với [previous]; `null` khi kỳ trước không có dữ liệu.
int? percentChange(int current, int previous) {
  if (previous <= 0) return null;
  return ((current - previous) * 100 / previous).round();
}
