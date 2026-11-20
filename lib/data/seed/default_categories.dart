import 'package:drift/drift.dart';

import '../../core/enums.dart';
import '../../core/ids.dart';
import '../database.dart';

/// Một danh mục mặc định. `id` = UUID v5 từ [systemKey] nên giống nhau trên mọi máy.
final class DefaultCategory {
  const DefaultCategory(
    this.systemKey,
    this.name,
    this.type,
    this.icon,
    this.color, {
    this.parentKey,
  });

  final String systemKey;

  /// Tên tiếng Việt. Giới hạn đã biết: chưa dịch theo ngôn ngữ app.
  final String name;
  final CategoryType type;
  final String icon;
  final int color;
  final String? parentKey;

  CategoryId get id => CategoryId(stableUuid('category:$systemKey'));
}

const _e = CategoryType.expense;
const _i = CategoryType.income;

/// Thứ tự trong danh sách = `sort_order`. Danh mục cha phải đứng trước con.
const defaultCategories = <DefaultCategory>[
  DefaultCategory('an_uong', 'Ăn uống', _e, 'restaurant', 0xFFE8A87C),
  DefaultCategory('di_chuyen', 'Di chuyển', _e, 'directions_car', 0xFF7FA7D9),
  DefaultCategory('nha_cua', 'Nhà cửa', _e, 'home', 0xFFA99BD6),
  DefaultCategory('hoa_don', 'Hóa đơn', _e, 'receipt_long', 0xFF6FB7B7),
  DefaultCategory('mua_sam', 'Mua sắm', _e, 'shopping_bag', 0xFFE59AB0),
  DefaultCategory('giai_tri', 'Giải trí', _e, 'sports_esports', 0xFFF0C66B),
  DefaultCategory('suc_khoe', 'Sức khỏe', _e, 'favorite', 0xFF8CC79A),
  DefaultCategory('giao_duc', 'Giáo dục', _e, 'school', 0xFF9BB0E0),
  DefaultCategory('khac_chi', 'Khác', _e, 'more_horiz', 0xFFB5B5B5),
  DefaultCategory('luong', 'Lương', _i, 'payments', 0xFF5FAE8C),
  DefaultCategory('thuong', 'Thưởng', _i, 'redeem', 0xFFC9B26B),
  DefaultCategory('khac_thu', 'Khác', _i, 'more_horiz', 0xFFB5B5B5),
  // Danh mục con.
  DefaultCategory('ca_phe', 'Cà phê', _e, 'local_cafe', 0xFFE8A87C, parentKey: 'an_uong'),
  DefaultCategory('di_cho', 'Đi chợ', _e, 'shopping_basket', 0xFFE8A87C, parentKey: 'an_uong'),
  DefaultCategory('dien', 'Điện', _e, 'bolt', 0xFF6FB7B7, parentKey: 'hoa_don'),
  DefaultCategory('nuoc', 'Nước', _e, 'water_drop', 0xFF6FB7B7, parentKey: 'hoa_don'),
  DefaultCategory('internet', 'Internet', _e, 'wifi', 0xFF6FB7B7, parentKey: 'hoa_don'),
];

/// Ghi bộ danh mục mặc định trong một batch (nguyên tử).
Future<void> seedDefaultCategories(AppDatabase db) async {
  final now = db.clock.now();
  final byKey = {for (final c in defaultCategories) c.systemKey: c};
  await db.batch((b) {
    for (final (index, c) in defaultCategories.indexed) {
      b.insert(
        db.categories,
        CategoriesCompanion.insert(
          id: c.id,
          parentId: Value(c.parentKey == null ? null : byKey[c.parentKey]!.id),
          name: c.name,
          type: c.type,
          icon: c.icon,
          color: c.color,
          sortOrder: Value(index),
          isDefault: const Value(true),
          systemKey: Value(c.systemKey),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  });
}
