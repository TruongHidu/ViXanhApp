import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/data/seed/default_categories.dart';
import 'package:vi_xanh_app/features/categories/domain/category_icons.dart';

void main() {
  test('mọi khóa icon của danh mục mặc định đều có IconData', () {
    for (final c in defaultCategories) {
      expect(categoryIcons, contains(c.icon), reason: c.systemKey);
    }
  });

  test('khóa lạ dùng icon dự phòng', () {
    expect(categoryIcon('khong-co'), Icons.category_rounded);
  });
}
