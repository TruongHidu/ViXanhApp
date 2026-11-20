import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Sink ghi lỗi đồng bộ, giới hạn kích thước, KHÔNG BAO GIỜ ném lỗi.
/// Ghi đồng bộ để entry sống sót kể cả khi tiến trình bị kill ngay sau đó.
final class CrashLog {
  CrashLog._(this._file);

  static const _maxBytes = 256 * 1024;
  final File? _file;

  static Future<CrashLog> open() async {
    try {
      final dir = await getApplicationSupportDirectory();
      return CrashLog._(File(p.join(dir.path, 'crash.log')));
    } catch (_) {
      // Không mở được file → vẫn trả về sink no-op để main() tiếp tục.
      return CrashLog._(null);
    }
  }

  /// Sink rỗng cho test.
  factory CrashLog.noop() => CrashLog._(null);

  void record(String message, StackTrace? stack) {
    final file = _file;
    if (file == null) return;
    try {
      if (file.existsSync() && file.lengthSync() > _maxBytes) {
        file.writeAsStringSync(''); // xoay vòng đơn giản
      }
      file.writeAsStringSync(
        '[${DateTime.now().toIso8601String()}] $message\n$stack\n\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {
      // Sink lỗi không được phép ném — cố ý bỏ qua.
    }
  }
}
