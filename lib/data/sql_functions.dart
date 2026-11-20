import 'package:sqlite3/common.dart' show AllowedArgumentCount, CommonDatabase;

import '../core/text_fold.dart';

/// Tên hàm SQL bỏ dấu + chữ thường, dùng cho tìm kiếm: `instr(vx_fold(note), ?)`.
const foldFunctionName = 'vx_fold';

/// Đăng ký hàm SQL riêng của app trên kết nối SQLite. Gọi khi mở DB (app và test).
/// Hàm top-level vì có thể chạy trong isolate nền của drift.
void registerSqlFunctions(CommonDatabase db) {
  db.createFunction(
    functionName: foldFunctionName,
    argumentCount: const AllowedArgumentCount(1),
    deterministic: true,
    directOnly: false,
    function: (args) => switch (args[0]) {
      final String text => foldVietnamese(text),
      _ => null,
    },
  );
}
