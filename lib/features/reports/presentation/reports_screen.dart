import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../../theme/widgets/empty_state.dart';

/// Tab Báo cáo (tạm): tiêu đề + trạng thái trống.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabReports)),
      body: EmptyState(icon: Icons.pie_chart_outline_rounded, message: l10n.emptyReports),
    );
  }
}
