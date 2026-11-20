import 'package:drift/drift.dart';

import '../database.dart';
import '../seed/default_categories.dart';

/// Toàn bộ lịch sử migration. Mỗi lần tăng `schemaVersion` thêm một nhánh
/// `from < N` — không bao giờ sửa nhánh cũ.
MigrationStrategy buildMigrationStrategy(AppDatabase db) => MigrationStrategy(
  onCreate: (m) async {
    // Tạo bảng + seed cùng một transaction: hoặc có đủ cả hai, hoặc không có gì.
    await db.transaction(() async {
      await m.createAll();
      await seedDefaultCategories(db);
    });
  },
  onUpgrade: (m, from, to) async {
    // if (from < 2) { await m.addColumn(db.wallets, db.wallets.icon); }
  },
  beforeOpen: (details) async {
    await db.customStatement('PRAGMA foreign_keys = ON');
    // Bật khóa ngoại thất bại thì mọi FK chỉ còn là trang trí — phát hiện ngay.
    final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
    if (row.read<int>('foreign_keys') != 1) {
      throw StateError('Không bật được PRAGMA foreign_keys');
    }
  },
);
