import 'package:flutter/foundation.dart';

import '../../../core/enums.dart';
import '../../../core/ids.dart';

/// Dữ liệu một giao dịch trước khi ghi (thêm mới hoặc sửa). Bất biến.
///
/// Quy tắc (kiểm tra ở `TransactionRepository`): `amount` > 0; thu/chi có danh mục cùng loại
/// và không có `toWalletId`; chuyển khoản có hai ví khác nhau và không có danh mục.
@immutable
final class TransactionDraft {
  const TransactionDraft({
    required this.type,
    required this.amount,
    required this.walletId,
    required this.occurredAt,
    this.toWalletId,
    this.categoryId,
    this.payee,
    this.note,
  });

  final TransactionType type;

  /// Đồng, luôn > 0.
  final int amount;
  final WalletId walletId;
  final WalletId? toWalletId;
  final CategoryId? categoryId;
  final DateTime occurredAt;
  final String? payee;
  final String? note;

  @override
  bool operator ==(Object other) =>
      other is TransactionDraft &&
      other.type == type &&
      other.amount == amount &&
      other.walletId == walletId &&
      other.toWalletId == toWalletId &&
      other.categoryId == categoryId &&
      other.occurredAt == occurredAt &&
      other.payee == payee &&
      other.note == note;

  @override
  int get hashCode =>
      Object.hash(type, amount, walletId, toWalletId, categoryId, occurredAt, payee, note);
}

/// Mã lỗi kiểm tra giao dịch (đặt vào `Failure.code`); UI dịch theo mã.
abstract final class TransactionErrors {
  static const amountInvalid = 'amount_invalid';
  static const categoryRequired = 'category_required';
  static const categoryInvalid = 'category_invalid';
  static const walletInvalid = 'wallet_invalid';
  static const transferWallets = 'transfer_wallets';
  static const textTooLong = 'text_too_long';
  static const notFound = 'not_found';
}
