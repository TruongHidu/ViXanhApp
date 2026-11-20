import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/l10n/compact_amount.dart';
import 'package:vi_xanh_app/l10n/gen/app_localizations.dart';

void main() {
  test('rút gọn tiếng Việt', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('vi'));
    expect(compactAmount(16000000, l10n), '16 tr');
    expect(compactAmount(1500000000, l10n), '1,5 tỷ');
    expect(compactAmount(250000, l10n), '250k');
    expect(compactAmount(-2000000, l10n), '−2 tr');
    expect(compactAmount(500, l10n), '500');
  });

  test('rút gọn tiếng Anh', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(compactAmount(16000000, l10n), '16M');
    expect(compactAmount(1500000000, l10n), '1.5B');
  });
}
