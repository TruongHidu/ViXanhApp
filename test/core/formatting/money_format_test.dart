import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/enums.dart';
import 'package:vi_xanh_app/core/formatting/money_format.dart';
import 'package:vi_xanh_app/core/money.dart';

const nbsp = ' ';
const minus = '−';

void main() {
  group('formatMoney', () {
    final cases = {
      0: '0$nbsp₫',
      1000: '1.000$nbsp₫',
      1250000: '1.250.000$nbsp₫',
      1000000000: '1.000.000.000$nbsp₫',
      -5000: '${minus}5.000$nbsp₫',
    };
    for (final MapEntry(key: minor, value: expected) in cases.entries) {
      test('$minor → $expected', () => expect(formatMoney(Money(minor)), expected));
    }

    test('dấu trừ là U+2212, khoảng trắng là U+00A0', () {
      final s = formatMoney(const Money(-1250000));
      expect(s.codeUnitAt(0), 0x2212);
      expect(s, isNot(contains('-')));
      expect(s, contains(nbsp));
      expect(s, isNot(contains(' ')));
    });

    test('giữ kiểu VND dù không truyền locale', () {
      expect(const Money(1250000).format(), '1.250.000$nbsp₫');
    });
  });

  group('formatSigned', () {
    test('thu có dấu +', () {
      expect(formatSigned(const Money(1250000), TransactionType.income), '+1.250.000$nbsp₫');
    });

    test('chi có dấu − (U+2212)', () {
      expect(
        formatSigned(const Money(1250000), TransactionType.expense),
        '${minus}1.250.000$nbsp₫',
      );
    });

    test('chuyển khoản không dấu', () {
      expect(formatSigned(const Money(1250000), TransactionType.transfer), '1.250.000$nbsp₫');
    });

    test('dùng giá trị tuyệt đối nên không ra hai dấu', () {
      expect(formatSigned(const Money(-1000), TransactionType.expense), '${minus}1.000$nbsp₫');
    });
  });

  test('formatMasked', () => expect(formatMasked(), '••••••'));
}
