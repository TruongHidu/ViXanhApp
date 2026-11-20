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
    return out;
  }, onError: (e) => DatabaseFailure('Không thể sao lưu', cause: e));

  @override
  Future<Result<void>> restoreFrom(File file) async =>
      const Err(UnexpectedFailure('Chưa triển khai khôi phục'));
}

final backupServiceProvider = Provider<BackupService>(
  (ref) => throw UnimplementedError('override trong bootstrap()'),
);
