import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/failure.dart';
import '../core/result.dart';
import '../data/database.dart';

/// Sao lưu / khôi phục DB ra file.
abstract interface class BackupService {
  Future<Result<File>> exportBackup();
  Future<Result<void>> restoreFrom(File file);
}

final class FileBackupService implements BackupService {
  FileBackupService(this._db);
  final AppDatabase _db;

  @override
  Future<Result<File>> exportBackup() => guardAsync(() async {
    final dir = await getApplicationDocumentsDirectory();
    final stamp = _db.clock.now().millisecondsSinceEpoch;
    final out = File(p.join(dir.path, 'vi_xanh_backup_$stamp.sqlite'));
    await _db.customStatement('VACUUM INTO ?', [out.path]);
    await _deleteOlderBackups(dir, keep: out);
    return out;
  }, onError: (e) => DatabaseFailure('Không thể sao lưu', cause: e));

  /// Bản sao lưu đã được chia sẻ ra ngoài; giữ trong máy mỗi bản mới nhất để không tốn dung
  /// lượng. Xóa lỗi (file đang mở...) thì bỏ qua: bản mới đã tạo xong.
  static Future<void> _deleteOlderBackups(Directory dir, {required File keep}) async {
    await for (final entity in dir.list()) {
      final name = p.basename(entity.path);
      if (entity is! File || entity.path == keep.path) continue;
      if (!name.startsWith('vi_xanh_backup_') || !name.endsWith('.sqlite')) continue;
      try {
        await entity.delete();
      } on FileSystemException {
        // Không xóa được bản cũ không làm hỏng bản sao lưu vừa tạo.
      }
    }
  }

  @override
  Future<Result<void>> restoreFrom(File file) async =>
      const Err(UnexpectedFailure('Chưa triển khai khôi phục'));
}

final backupServiceProvider = Provider<BackupService>(
  (ref) => throw UnimplementedError('override trong bootstrap()'),
);
