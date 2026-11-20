import 'package:flutter/foundation.dart';

/// Tổng hợp tài sản của các ví đang dùng.
@immutable
final class WalletSummary {
  const WalletSummary({required this.assets, required this.debt});

  /// Từ số dư từng ví: số dư dương cộng vào tài sản, số dư âm (thẻ tín dụng đang nợ) vào nợ.
  factory WalletSummary.fromBalances(Iterable<int> balances) {
    var assets = 0;
    var debt = 0;
    for (final b in balances) {
      if (b >= 0) {
        assets += b;
      } else {
        debt += b;
      }
    }
    return WalletSummary(assets: assets, debt: debt);
  }

  /// Tổng số dư dương.
  final int assets;

  /// Tổng số dư âm (≤ 0).
  final int debt;

  int get netWorth => assets + debt;

  @override
  bool operator ==(Object other) =>
      other is WalletSummary && other.assets == assets && other.debt == debt;

  @override
  int get hashCode => Object.hash(assets, debt);
}
