import 'package:flutter/material.dart';

import '../tokens.dart';

/// Nhãn đặt phía trên ô nhập (theo thiết kế); gộp ngữ nghĩa để trình đọc màn hình đọc kèm nhãn.
class LabeledField extends StatelessWidget {
  const LabeledField({required this.label, required this.child, super.key});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    ),
  );
}
