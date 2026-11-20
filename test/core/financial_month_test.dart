import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/financial_month.dart';
import 'package:vi_xanh_app/core/text_fold.dart';

void main() {
  group('FinancialMonth', () {
    test('ngày bắt đầu 1 → đúng tháng dương lịch', () {
      final m = FinancialMonth.containing(DateTime(2026, 11, 18), 1);
      expect(m, const FinancialMonth(2026, 11));
      expect(m.range(1), DateRange(DateTime(2026, 11), DateTime(2026, 12)));
    });

    test('ngày bắt đầu 25: "Tháng 11" là 25/10 – 24/11', () {
      const m = FinancialMonth(2026, 11);
      expect(m.range(25), DateRange(DateTime(2026, 10, 25), DateTime(2026, 11, 25)));
      expect(FinancialMonth.containing(DateTime(2026, 10, 25), 25), m);
      expect(FinancialMonth.containing(DateTime(2026, 11, 24, 23, 59), 25), m);
      expect(FinancialMonth.containing(DateTime(2026, 11, 25), 25), const FinancialMonth(2026, 12));
    });

    test('qua năm: ngày bắt đầu 25, 28/12 thuộc tháng 1 năm sau', () {
      final m = FinancialMonth.containing(DateTime(2026, 12, 28), 25);
      expect(m, const FinancialMonth(2027, 1));
      expect(m.range(25), DateRange(DateTime(2026, 12, 25), DateTime(2027, 1, 25)));
    });

    test('tháng 2 và ngày bắt đầu 28', () {
      const m = FinancialMonth(2027, 3);
      expect(m.range(28), DateRange(DateTime(2027, 2, 28), DateTime(2027, 3, 28)));
      expect(const FinancialMonth(2027, 2).range(1).end, DateTime(2027, 3));
    });

    test('tháng trước / sau qua năm', () {
      expect(const FinancialMonth(2026, 1).previous, const FinancialMonth(2025, 12));
      expect(const FinancialMonth(2026, 12).next, const FinancialMonth(2027, 1));
    });

    test('DateRange.contains là nửa mở [start, end)', () {
      final r = DateRange(DateTime(2026, 11), DateTime(2026, 12));
      expect(r.contains(DateTime(2026, 11)), isTrue);
      expect(r.contains(DateTime(2026, 12)), isFalse);
    });
  });

  group('foldVietnamese', () {
    test('bỏ dấu và chữ hoa', () {
      expect(foldVietnamese('Cà Phê Sữa Đá'), 'ca phe sua da');
      expect(foldVietnamese('Tiền điện EVN'), 'tien dien evn');
      expect(foldVietnamese('Ăn uống Ở Hà Nội'), 'an uong o ha noi');
    });

    test('ký tự không phải chữ Việt giữ nguyên', () {
      expect(foldVietnamese('Grab #123'), 'grab #123');
    });
  });
}
