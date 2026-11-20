import 'package:flutter/material.dart';

import '../tokens.dart';

/// Icon danh mục trong vòng tròn 40px: nền là màu danh mục ở độ đậm 20%, icon là màu danh mục.
///
/// [semanticLabel] là tên danh mục, để trình đọc màn hình đọc được thay cho icon.
class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({
    required this.icon,
    required this.color,
    required this.semanticLabel,
    this.size = AppSizes.categoryIcon,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    image: true,
    excludeSemantics: true,
    child: Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: size * 0.55),
    ),
  );
}
