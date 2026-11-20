import 'package:intl/intl.dart';

import 'gen/app_localizations.dart';

/// Số tiền rút gọn cho trục biểu đồ: 16.000.000 → "16 tr" (vi) / "16M" (en),
/// 1.500.000.000 → "1,5 tỷ", 250.000 → "250k". Giữ dấu âm (U+2212).
String compactAmount(int value, AppLocalizations l10n) {
  final sign = value < 0 ? '−' : '';
  final abs = value.abs();
  final number = NumberFormat('#,##0.#', l10n.localeName);
  final text = switch (abs) {
    >= 1000000000 => l10n.compactBillion(number.format(abs / 1000000000)),
    >= 1000000 => l10n.compactMillion(number.format(abs / 1000000)),
    >= 1000 => l10n.compactThousand(number.format(abs / 1000)),
    _ => '$abs',
  };
  return '$sign$text';
}
