import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../../theme/widgets/empty_state.dart';

/// Tab Tổng quan (tạm): tiêu đề + trạng thái trống.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: EmptyState(icon: Icons.savings_outlined, message: l10n.emptyOverview),
    );
  }
}
