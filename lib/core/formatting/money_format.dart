import '../enums.dart';
import '../money.dart';

/// Nơi DUY NHẤT định dạng số tiền để hiển thị.

/// "1.250.000 ₫"; số âm (ví dụ số dư thẻ tín dụng) là "−1.250.000 ₫".
String formatMoney(Money money) => money.format();

/// Số tiền một giao dịch kèm dấu theo chiều tiền — không chỉ phân biệt bằng màu:
/// thu "+1.250.000 ₫", chi "−1.250.000 ₫", chuyển giữa ví không dấu.
String formatSigned(Money amount, TransactionType type) {
  final value = amount.abs().format();
  return switch (type) {
    TransactionType.income => '+$value',
    TransactionType.expense => '${Money.minusSign}$value',
    TransactionType.transfer => value,
  };
}

/// Chuỗi thay thế khi người dùng bật ẩn số dư.
const maskedAmount = '••••••';

String formatMasked() => maskedAmount;
