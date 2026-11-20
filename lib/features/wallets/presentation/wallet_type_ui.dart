import 'package:flutter/material.dart';

import '../../../core/enums.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../theme/tokens.dart';

/// Cách hiển thị từng loại ví: icon, màu, nhãn, gợi ý và tên mặc định (đã dịch).
extension WalletTypeUi on WalletType {
  IconData get icon => switch (this) {
    WalletType.cash => Icons.payments_outlined,
    WalletType.bank => Icons.account_balance_outlined,
    WalletType.ewallet => Icons.account_balance_wallet_outlined,
    WalletType.credit => Icons.credit_card_outlined,
  };

  Color get color => WalletPalette.byType[this]!;

  String label(AppLocalizations l10n) => switch (this) {
    WalletType.cash => l10n.walletTypeCash,
    WalletType.bank => l10n.walletTypeBank,
    WalletType.ewallet => l10n.walletTypeEwallet,
    WalletType.credit => l10n.walletTypeCredit,
  };

  String hint(AppLocalizations l10n) => switch (this) {
    WalletType.cash => l10n.walletTypeCashHint,
    WalletType.bank => l10n.walletTypeBankHint,
    WalletType.ewallet => l10n.walletTypeEwalletHint,
    WalletType.credit => l10n.walletTypeCreditHint,
  };

  /// Tên gợi ý điền sẵn khi chọn loại ví.
  String defaultName(AppLocalizations l10n) => switch (this) {
    WalletType.cash => l10n.walletDefaultNameCash,
    WalletType.bank => l10n.walletDefaultNameBank,
    WalletType.ewallet => l10n.walletDefaultNameEwallet,
    WalletType.credit => l10n.walletDefaultNameCredit,
  };
}
