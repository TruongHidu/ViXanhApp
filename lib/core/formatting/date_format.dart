import 'package:intl/intl.dart';

import '../clock.dart';

/// Nhãn ngày giờ theo đặc tả: "Hôm nay", "Hôm qua", "Thứ Hai, 16/11/2026", "14:30".
///
/// Thuần Dart: nhận [Clock], mã ngôn ngữ và chuỗi đã dịch từ ngoài vào (không tự gọi
/// `DateTime.now()` hay đọc l10n). So sánh theo ngày giờ ĐỊA PHƯƠNG, không theo UTC.
/// Cần gọi `initializeDateFormatting` cho [locale] trước khi dùng.
final class DateLabelFormatter {
  const DateLabelFormatter({
    required Clock clock,
    required String locale,
    required String today,
    required String yesterday,
  }) : _clock = clock,
       _locale = locale,
       _today = today,
       _yesterday = yesterday;

  final Clock _clock;
  final String _locale;
  final String _today;
  final String _yesterday;

  String dayLabel(DateTime at) {
    final local = at.toLocal();
    final now = _clock.now().toLocal();
    final day = DateTime(local.year, local.month, local.day);
    final today = DateTime(now.year, now.month, now.day);
    // Tạo bằng constructor thay vì trừ Duration(days: 1) để không lệch khi đổi giờ mùa hè.
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (day == today) return _today;
    if (day == yesterday) return _yesterday;
    return DateFormat('EEEE, dd/MM/yyyy', _locale).format(local);
  }

  /// Giờ 24h: "14:30".
  String timeLabel(DateTime at) => DateFormat('HH:mm', _locale).format(at.toLocal());

  /// Tiêu đề nhóm ngày trong danh sách: "Hôm nay · Thứ Tư 18/11", "Hôm qua · Thứ Ba 17/11",
  /// ngày khác "Thứ Hai, 16/11/2026".
  String groupHeader(DateTime at) {
    final label = dayLabel(at);
    final full = DateFormat('EEEE, dd/MM/yyyy', _locale).format(at.toLocal());
    if (label == full) return full;
    return '$label · ${DateFormat('EEEE dd/MM', _locale).format(at.toLocal())}';
  }

  /// Thời điểm đầy đủ ở màn chi tiết: "08:15, Thứ Tư 18/11/2026".
  String fullDateTime(DateTime at) =>
      DateFormat('HH:mm, EEEE dd/MM/yyyy', _locale).format(at.toLocal());

  /// Ngày đầy đủ không kèm "Hôm nay": "Thứ Tư, 18/11/2026".
  String longDate(DateTime at) => DateFormat('EEEE, dd/MM/yyyy', _locale).format(at.toLocal());

  /// Tháng ngắn dưới cột biểu đồ: "T11" (vi), "Nov" (en).
  String shortMonth(DateTime at) {
    final local = at.toLocal();
    return _locale.startsWith('vi') ? 'T${local.month}' : DateFormat('MMM', _locale).format(local);
  }

  /// Ngày đầy đủ ngắn "16/11/2026".
  String numericDate(DateTime at) => DateFormat('dd/MM/yyyy', _locale).format(at.toLocal());

  /// Ngày ngắn "25/10" (dùng cho khoảng kỳ "25/10 – 24/11").
  String shortDate(DateTime at) => DateFormat('dd/MM', _locale).format(at.toLocal());
}
