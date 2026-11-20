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
}
