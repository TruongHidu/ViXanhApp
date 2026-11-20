import 'package:flutter/material.dart';

/// Khóa icon lưu trong DB → IconData. Lưu khóa thay vì codepoint để tree-shaking icon
/// vẫn hoạt động và đổi bộ icon sau này không làm hỏng dữ liệu.
const categoryIcons = <String, IconData>{
  'restaurant': Icons.restaurant_rounded,
  'directions_car': Icons.directions_car_rounded,
  'home': Icons.home_rounded,
  'receipt_long': Icons.receipt_long_rounded,
  'shopping_bag': Icons.shopping_bag_rounded,
  'sports_esports': Icons.sports_esports_rounded,
  'favorite': Icons.favorite_rounded,
  'school': Icons.school_rounded,
  'more_horiz': Icons.more_horiz_rounded,
  'payments': Icons.payments_rounded,
  'redeem': Icons.redeem_rounded,
  'local_cafe': Icons.local_cafe_rounded,
  'shopping_basket': Icons.shopping_basket_rounded,
  'bolt': Icons.bolt_rounded,
  'water_drop': Icons.water_drop_rounded,
  'wifi': Icons.wifi_rounded,
  'storefront': Icons.storefront_rounded,
  'trending_up': Icons.trending_up_rounded,
};

/// Icon dự phòng cho khóa lạ (ví dụ dữ liệu từ bản app mới hơn).
const fallbackCategoryIcon = Icons.category_rounded;

IconData categoryIcon(String key) => categoryIcons[key] ?? fallbackCategoryIcon;
