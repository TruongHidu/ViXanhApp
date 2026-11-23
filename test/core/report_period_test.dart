import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/financial_month.dart';
import 'package:vi_xanh_app/core/ids.dart';
import 'package:vi_xanh_app/core/report_period.dart';
import 'package:vi_xanh_app/features/reports/domain/category_share.dart';

void main() {
  group('ReportPeriod', () {
    test('tuần bắt đầu thứ Hai, kể cả khi ngày là Chủ nhật', () {
      final p = ReportPeriod.week(DateTime(2026, 11, 22, 20)); // Chủ nhật
      expect(p.range, DateRange(DateTime(2026, 11, 16), DateTime(2026, 11, 23)));
      expect(p.lastDay, DateTime(2026, 11, 22));
      expect(ReportPeriod.week(DateTime(2026, 11, 16)).range.start, DateTime(2026, 11, 16));
    });

    test('tuần trước / sau qua tháng', () {
      final p = ReportPeriod.week(DateTime(2026, 12, 2));
      expect(p.previous.range.start, DateTime(2026, 11, 23));
      expect(p.next.range.start, DateTime(2026, 12, 7));
    });

    test('tháng tài chính theo ngày bắt đầu 25', () {
      final p = ReportPeriod.monthOf(DateTime(2026, 11, 26), 25);
      expect(p.month, const FinancialMonth(2026, 12));
      expect(p.range, DateRange(DateTime(2026, 11, 25), DateTime(2026, 12, 25)));
      expect(p.previous.month, const FinancialMonth(2026, 11));
    });

    test('năm dương lịch', () {
      final p = ReportPeriod.year(2026);
      expect(p.range, DateRange(DateTime(2026), DateTime(2027)));
      expect(p.next.range.start, DateTime(2027));
    });

    test('tùy chọn: kỳ trước / sau cùng số ngày, liền kề', () {
      final p = ReportPeriod.custom(DateTime(2026, 11, 1), DateTime(2026, 11, 18));
      expect(p.range, DateRange(DateTime(2026, 11, 1), DateTime(2026, 11, 19)));
      expect(p.previous.range, DateRange(DateTime(2026, 10, 14), DateTime(2026, 11, 1)));
      expect(p.next.range, DateRange(DateTime(2026, 11, 19), DateTime(2026, 12, 7)));
    });

    test('tùy chọn đảo ngược ngày → một ngày', () {
      final p = ReportPeriod.custom(DateTime(2026, 11, 18), DateTime(2026, 11, 1));
      expect(p.range, DateRange(DateTime(2026, 11, 18), DateTime(2026, 11, 19)));
    });

    test('lastN: 6 kỳ liên tiếp, cũ nhất trước, kỳ hiện tại cuối', () {
      final p = ReportPeriod.month(const FinancialMonth(2026, 3), 1);
      final six = p.lastN(6);
      expect(six.map((x) => x.month), [
        const FinancialMonth(2025, 10),
        const FinancialMonth(2025, 11),
        const FinancialMonth(2025, 12),
        const FinancialMonth(2026, 1),
        const FinancialMonth(2026, 2),
        const FinancialMonth(2026, 3),
      ]);
    });
  });

  group('toShares', () {
    CategoryTotal t(String id, int amount) => CategoryTotal(
      categoryId: CategoryId(id),
      name: id,
      icon: 'more_horiz',
      color: 0xFFB5B5B5,
      amount: amount,
    );

    test('các danh mục dưới 3% (từ 2 mục) gộp thành "Khác" ở cuối', () {
      final shares = toShares([t('a', 600), t('b', 370), t('c', 20), t('d', 10)]);
      expect(shares.map((s) => s.categoryId?.value), ['a', 'b', null]);
      expect(shares.last.amount, 30);
      expect(shares.last.isOther, isTrue);
      expect(shares.fold<double>(0, (s, x) => s + x.fraction), closeTo(1, 1e-9));
    });

    test('chỉ một danh mục nhỏ → giữ nguyên, không gộp', () {
      final shares = toShares([t('a', 980), t('b', 20)]);
      expect(shares.map((s) => s.categoryId?.value), ['a', 'b']);
      expect(shares.last.percent, 2);
    });

    test('tổng 0 → rỗng', () => expect(toShares([]), isEmpty));
  });

  test('percentChange', () {
    expect(percentChange(88, 100), -12);
    expect(percentChange(150, 100), 50);
    expect(percentChange(100, 100), 0);
    expect(percentChange(100, 0), isNull);
  });
}
