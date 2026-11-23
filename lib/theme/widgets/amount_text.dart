import 'package:flutter/widgets.dart';

/// Số tiền trên MỘT dòng: không bao giờ bị ngắt giữa các chữ số ("130.513.0 / 00 ₫").
///
/// Đủ chỗ thì hiện đúng cỡ chữ (kể cả khi người dùng phóng to chữ); thiếu chỗ thì thu nhỏ
/// vừa khung — một con số bị cắt đôi khó đọc hơn nhiều so với một con số nhỏ hơn một chút.
/// Cần cha giới hạn chiều ngang (Expanded, Flexible, cột có độ rộng...).
class AmountText extends StatelessWidget {
  const AmountText(
    this.text, {
    this.style,
    this.textAlign,
    this.alignment = AlignmentDirectional.centerStart,
    super.key,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: alignment,
    child: Text(text, style: style, textAlign: textAlign, maxLines: 1, softWrap: false),
  );
}
