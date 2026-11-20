import 'package:flutter/foundation.dart';

import '../../../core/enums.dart';
import '../../../core/financial_month.dart';
import '../../../core/ids.dart';

/// Một dòng trong danh sách giao dịch, đã kèm tên danh mục và tên ví (đọc bằng một truy vấn JOIN).
@immutable
final class TransactionListItem {
  const TransactionListItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.occurredAt,
    required this.walletId,
    required this.walletName,
    required this.source,
    this.toWalletId,
    this.toWalletName,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.payee,
    this.note,
  });

  final TransactionId id;
  final TransactionType type;
  final int amount;
  final DateTime occurredAt;
  final WalletId walletId;
  final String walletName;
  final WalletId? toWalletId;
  final String? toWalletName;
  final CategoryId? categoryId;
  final String? categoryName;

  /// Khóa icon (xem `category_icons.dart`).
  final String? categoryIcon;

  /// Màu ARGB.
  final int? categoryColor;
  final String? payee;
  final String? note;
  final TransactionSource source;

  bool get isTransfer => type == TransactionType.transfer;

  @override
  bool operator ==(Object other) =>
      other is TransactionListItem &&
      other.id == id &&
      other.type == type &&
      other.amount == amount &&
      other.occurredAt == occurredAt &&
      other.walletId == walletId &&
      other.walletName == walletName &&
      other.toWalletId == toWalletId &&
      other.toWalletName == toWalletName &&
      other.categoryId == categoryId &&
      other.categoryName == categoryName &&
      other.categoryIcon == categoryIcon &&
      other.categoryColor == categoryColor &&
      other.payee == payee &&
      other.note == note &&
      other.source == source;

  @override
  int get hashCode => Object.hash(
    id,
    type,
    amount,
    occurredAt,
    walletId,
    walletName,
    toWalletId,
    toWalletName,
    categoryId,
    categoryName,
    categoryIcon,
    categoryColor,
    payee,
    note,
    source,
  );
}

/// Điều kiện lọc danh sách giao dịch. Mọi điều kiện chạy bằng SQL.
@immutable
final class TransactionQuery {
  const TransactionQuery({
    required this.range,
    this.type,
    this.walletId,
    this.categoryId,
    this.search = '',
  });

  final DateRange range;
  final TransactionType? type;

  /// Ví đi hoặc ví đến (chuyển khoản liên quan ví này cũng hiện).
  final WalletId? walletId;

  /// Danh mục, gồm cả danh mục con của nó.
  final CategoryId? categoryId;

  /// Tìm trong ghi chú, tên giao dịch, tên danh mục — không phân biệt dấu và hoa thường.
  final String search;

  @override
  bool operator ==(Object other) =>
      other is TransactionQuery &&
      other.range == range &&
      other.type == type &&
      other.walletId == walletId &&
      other.categoryId == categoryId &&
      other.search == search;

  @override
  int get hashCode => Object.hash(range, type, walletId, categoryId, search);
}

/// Tổng thu / chi của một kỳ (chuyển khoản không tính).
@immutable
final class PeriodTotals {
  const PeriodTotals({required this.income, required this.expense});

  static const zero = PeriodTotals(income: 0, expense: 0);

  final int income;
  final int expense;

  int get remaining => income - expense;

  @override
  bool operator ==(Object other) =>
      other is PeriodTotals && other.income == income && other.expense == expense;

  @override
  int get hashCode => Object.hash(income, expense);
}
