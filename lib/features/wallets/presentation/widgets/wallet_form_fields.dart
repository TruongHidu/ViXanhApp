import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/enums.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../theme/tokens.dart';
import '../../../../theme/widgets/labeled_field.dart';
import '../../../../theme/widgets/thousands_input_formatter.dart';
import '../../data/wallet_repository.dart';
import 'wallet_type_picker.dart';

/// Các ô của form ví, dùng chung cho Thiết lập ban đầu và màn Thêm/Sửa ví:
/// loại ví → số dư (hoặc dư nợ với thẻ tín dụng) → tên ví → [4 số cuối tài khoản].
///
/// Không giữ state: nơi dùng sở hữu controller và nhận thay đổi qua callback.
class WalletFormFields extends StatelessWidget {
  const WalletFormFields({
    required this.type,
    required this.onPickType,
    required this.balanceController,
    required this.onBalanceChanged,
    required this.nameController,
    required this.onNameChanged,
    this.nameError,
    this.accountController,
    this.onAccountChanged,
    this.accountError,
    super.key,
  });

  final WalletType? type;
  final ValueChanged<WalletType> onPickType;
  final TextEditingController balanceController;

  /// Số tiền đã đọc (≥ 0). Với thẻ tín dụng là số dư nợ.
  final ValueChanged<int> onBalanceChanged;
  final TextEditingController nameController;
  final ValueChanged<String> onNameChanged;
  final String? nameError;

  /// Có [accountController] thì hiện ô "4 số cuối" cho ví ngân hàng / thẻ tín dụng.
  final TextEditingController? accountController;
  final ValueChanged<String>? onAccountChanged;
  final String? accountError;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = type;
    final showAccount =
        accountController != null && (current == WalletType.bank || current == WalletType.credit);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WalletTypePicker(selected: current, onPick: onPickType),
        if (current != null) ...[
          const SizedBox(height: AppSpacing.xl),
          LabeledField(
            label: current == WalletType.credit ? l10n.walletDebtLabel : l10n.walletBalanceLabel,
            child: TextField(
              controller: balanceController,
              keyboardType: TextInputType.number,
              inputFormatters: const [ThousandsInputFormatter()],
              onChanged: (text) => onBalanceChanged(ThousandsInputFormatter.parse(text)),
              decoration: const InputDecoration(hintText: '0', suffixText: '₫'),
            ),
          ),
          const SizedBox(height: 20),
          LabeledField(
            label: l10n.walletNameLabel,
            child: TextField(
              controller: nameController,
              onChanged: onNameChanged,
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: [LengthLimitingTextInputFormatter(WalletRepository.maxNameLength)],
              decoration: InputDecoration(errorText: nameError),
            ),
          ),
          if (showAccount) ...[
            const SizedBox(height: 20),
            LabeledField(
              label: l10n.walletAccountLabel,
              child: TextField(
                controller: accountController,
                onChanged: onAccountChanged,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: InputDecoration(
                  hintText: l10n.walletAccountHint,
                  prefixText: '•••• ',
                  errorText: accountError,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
