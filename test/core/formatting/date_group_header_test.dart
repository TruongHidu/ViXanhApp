import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vi_xanh_app/core/clock.dart';
import 'package:vi_xanh_app/core/formatting/date_format.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('vi');
    await initializeDateFormatting('en');
  });

  final now = DateTime(2026, 11, 18, 9);
  final vi = DateLabelFormatter(
    clock: FixedClock(now),
    locale: 'vi',
    today: 'Hôm nay',
    yesterday: 'Hôm qua',
  );
  final en = DateLabelFormatter(
    clock: FixedClock(now),
    locale: 'en',
    today: 'Today',
    yesterday: 'Yesterday',
  );

  test('groupHeader: hôm nay, hôm qua kèm thứ và ngày ngắn', () {
    expect(vi.groupHeader(DateTime(2026, 11, 18)), 'Hôm nay · Thứ Tư 18/11');
    expect(vi.groupHeader(DateTime(2026, 11, 17, 21)), 'Hôm qua · Thứ Ba 17/11');
    expect(en.groupHeader(DateTime(2026, 11, 18)), 'Today · Wednesday 18/11');
  });

  test('groupHeader: ngày khác hiện đầy đủ', () {
    expect(vi.groupHeader(DateTime(2026, 11, 16)), 'Thứ Hai, 16/11/2026');
    expect(en.groupHeader(DateTime(2026, 11, 15)), 'Sunday, 15/11/2026');
  });

  test('fullDateTime và shortDate', () {
    expect(vi.fullDateTime(DateTime(2026, 11, 18, 8, 15)), '08:15, Thứ Tư 18/11/2026');
    expect(en.fullDateTime(DateTime(2026, 11, 18, 8, 15)), '08:15, Wednesday 18/11/2026');
    expect(vi.shortDate(DateTime(2026, 10, 25)), '25/10');
  });
}
