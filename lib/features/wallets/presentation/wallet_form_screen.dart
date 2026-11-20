import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/failure.dart';
import '../../../core/ids.dart';
import '../../../core/result.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../../theme/widgets/thousands_input_formatter.dart';
import '../data/wallet_repository.dart';
import 'wallet_form_notifier.dart';
import 'wallet_type_ui.dart';
import 'widgets/wallet_form_fields.dart';

/// Màn Thêm ví ([walletId] `null`) hoặc Sửa ví. Mở toàn màn hình.
class WalletFormScreen extends ConsumerStatefulWidget {
  const WalletFormScreen({this.walletId, super.key});

  final WalletId? walletId;

  @override
  ConsumerState<WalletFormScreen> createState() => _WalletFormScreenState();
}

class _WalletFormScreenState extends ConsumerState<WalletFormScreen> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _account = TextEditingController();
  bool _loaded = false;

  WalletFormNotifier get _notifier => ref.read(walletFormProvider(widget.walletId).notifier);

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _account.dispose();
    super.dispose();
  }

  void _fill(WalletFormState s) {
    _name.text = s.name;
    _amount.text = s.amount == 0 ? '' : ThousandsInputFormatter.format(s.amount);
    _account.text = s.accountLast4;
    _loaded = true;
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context);
    final result = await _notifier.save();
    switch (result) {
      case Ok():
        await navigator.maybePop();
      case Err(:final failure):
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(_message(failure, l10n))));
    }
  }

  static String _message(Failure failure, AppLocalizations l10n) => switch (failure.code) {
    WalletErrors.nameInvalid => l10n.walletNameInvalid,
    WalletErrors.accountInvalid => l10n.walletAccountInvalid,
    _ => l10n.walletSaveFailed,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(walletFormProvider(widget.walletId));
    final state = async.value;
    if (state != null && !_loaded) _fill(state);

    // Đổi loại ví khi chưa tự sửa tên → tên gợi ý mới phải hiện trong ô nhập.
    ref.listen(walletFormProvider(widget.walletId).select((s) => s.value?.name), (_, name) {
      if (name != null && _name.text != name) _name.text = name;
    });

    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(
          widget.walletId == null ? l10n.walletAdd : l10n.walletEditTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: true,
      ),
      body: switch (async) {
        AsyncData(:final value) => Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.screenGutter),
                child: WalletFormFields(
                  type: value.type,
                  onPickType: (t) => _notifier.pickType(t, t.defaultName(l10n)),
                  balanceController: _amount,
                  onBalanceChanged: _notifier.setAmount,
                  nameController: _name,
                  onNameChanged: _notifier.setName,
                  nameError: value.nameEdited && !value.isNameValid ? l10n.walletNameInvalid : null,
                  accountController: _account,
                  onAccountChanged: _notifier.setAccount,
                  accountError: value.isAccountValid ? null : l10n.walletAccountInvalid,
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenGutter,
                  AppSpacing.md,
                  AppSpacing.screenGutter,
                  AppSpacing.lg,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: value.canSave ? _save : null,
                    child: Text(l10n.walletSave),
                  ),
                ),
              ),
            ),
          ],
        ),
        AsyncError() => Center(child: Text(l10n.walletNotFound)),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
