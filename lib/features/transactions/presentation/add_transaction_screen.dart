import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';

/// Màn Thêm giao dịch (tạm, chưa có form). Mở toàn màn hình, che thanh điều hướng.
class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(leading: const CloseButton(), title: Text(l10n.addTransaction)),
      body: const SizedBox.expand(),
    );
  }
}
