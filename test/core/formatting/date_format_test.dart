import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vi_xanh_app/core/clock.dart';
import 'package:vi_xanh_app/core/formatting/date_format.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('vi');
    await initializeDateFormatting('en');
  });

  DateLabelFormatter vi(DateTime now) => DateLabelFormatter(
    clock: FixedClock(now),
    locale: 'vi',
    today: 'Hôm nay',
    yesterday: 'Hôm qua',
  );

  DateLabelFormatter en(DateTime now) => DateLabelFormatter(
    clock: FixedClock(now),
    locale: 'en',
    today: 'Today',
    yesterday: 'Yesterday',
  );

  // Mọi mốc dùng giờ địa phương để test không phụ thuộc múi giờ của máy chạy.
  final now = DateTime(2026, 11, 18, 9, 15);

  group('dayLabel', () {
    test('hôm nay (kể cả đầu ngày và cuối ngày)', () {
      expect(vi(now).dayLabel(DateTime(2026, 11, 18)), 'Hôm nay');
      expect(vi(now).dayLabel(DateTime(2026, 11, 18, 23, 59)), 'Hôm nay');
      expect(en(now).dayLabel(DateTime(2026, 11, 18, 8)), 'Today');
    });

    test('hôm qua', () {
      expect(vi(now).dayLabel(DateTime(2026, 11, 17, 23, 59)), 'Hôm qua');
      expect(en(now).dayLabel(DateTime(2026, 11, 17)), 'Yesterday');
    });

    test('2 ngày trước → thứ, ngày đầy đủ', () {
      expect(vi(now).dayLabel(DateTime(2026, 11, 16, 14, 30)), 'Thứ Hai, 16/11/2026');
      expect(en(now).dayLabel(DateTime(2026, 11, 16, 14, 30)), 'Monday, 16/11/2026');
    });

    test('vừa qua nửa đêm: 23:59 hôm trước là "Hôm qua"', () {
      final justAfterMidnight = DateTime(2026, 11, 18, 0, 1);
      expect(vi(justAfterMidnight).dayLabel(DateTime(2026, 11, 17, 23, 59)), 'Hôm qua');
      expect(vi(justAfterMidnight).dayLabel(DateTime(2026, 11, 18)), 'Hôm nay');
    });

    test('qua năm mới: 31/12 là "Hôm qua" của 1/1', () {
      final newYear = DateTime(2027, 1, 1, 7);
      expect(vi(newYear).dayLabel(DateTime(2026, 12, 31, 22)), 'Hôm qua');
      expect(vi(newYear).dayLabel(DateTime(2026, 12, 30)), 'Thứ Tư, 30/12/2026');
    });

    test('ngày tương lai không bị gọi là hôm nay', () {
      expect(vi(now).dayLabel(DateTime(2026, 11, 19)), 'Thứ Năm, 19/11/2026');
    });

    test('thời điểm UTC được đổi sang giờ địa phương trước khi so', () {
      final localMorning = DateTime(2026, 11, 18, 1);
      expect(vi(now).dayLabel(localMorning.toUtc()), 'Hôm nay');
    });
  });

  test('timeLabel 24h', () {
    expect(vi(now).timeLabel(DateTime(2026, 11, 16, 14, 30)), '14:30');
    expect(en(now).timeLabel(DateTime(2026, 11, 16, 9, 5)), '09:05');
  });
}
