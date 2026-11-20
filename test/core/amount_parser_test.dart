import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/amount_parser.dart';

void main() {
  const valid = {
    '50k': 50000,
    '50K': 50000,
    ' 50 k ': 50000,
    '2k5': 2500,
    '1tr': 1000000,
    '2tr': 2000000,
    '1tr2': 1200000,
    '1tr25': 1250000,
    '1.5tr': 1500000,
    '1,5tr': 1500000,
    '1,25tr': 1250000,
    '1 triệu': 1000000,
    '2tỷ': 2000000000,
    '1.250.000': 1250000,
    '1,250,000': 1250000,
    '120': 120,
    '45000': 45000,
    '999.999.999.999': 999999999999,
  };
  for (final MapEntry(key: input, value: expected) in valid.entries) {
    test('"$input" → $expected', () => expect(parseAmount(input), expected));
  }

  const invalid = [
    '',
    '   ',
    '0',
    '0k',
    '-50k',
    'abc',
    '50kk',
    '1.2.3',
    '1.25',
    '12.5k3',
    '1tr2345678',
    '1.000.000.000.000',
    '1000tỷ',
  ];
  for (final input in invalid) {
    test('"$input" → null', () => expect(parseAmount(input), isNull));
  }
}
