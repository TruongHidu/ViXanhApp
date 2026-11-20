import 'package:flutter/widgets.dart';

import '../core/clock.dart';
import '../core/formatting/date_format.dart';
import 'gen/app_localizations.dart';

/// Tạo [DateLabelFormatter] theo ngôn ngữ đang hiển thị của [context].
DateLabelFormatter dateLabelsOf(BuildContext context, Clock clock) {
  final l10n = AppLocalizations.of(context);
  return DateLabelFormatter(
    clock: clock,
    locale: Localizations.localeOf(context).languageCode,
    today: l10n.today,
    yesterday: l10n.yesterday,
  );
}
