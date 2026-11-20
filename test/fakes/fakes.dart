import 'dart:io';

import 'package:vi_xanh_app/core/failure.dart';
import 'package:vi_xanh_app/core/result.dart';
import 'package:vi_xanh_app/services/backup_service.dart';
import 'package:vi_xanh_app/services/bank_listener_service.dart';
import 'package:vi_xanh_app/services/key_value_store.dart';

/// Kho key–value trong RAM; bật [failWrites] để giả lập ghi thất bại.
final class FakeKeyValueStore extends InMemoryKeyValueStore {
  FakeKeyValueStore([super.initial]);

  bool failWrites = false;

  void _guard() {
    if (failWrites) throw const FileSystemException('ghi giả lập thất bại');
  }

  @override
  Future<void> setString(String key, String value) async {
    _guard();
    await super.setString(key, value);
  }

  @override
  Future<void> setInt(String key, int value) async {
    _guard();
    await super.setInt(key, value);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _guard();
    await super.setBool(key, value);
  }

  @override
  Future<void> remove(String key) async {
    _guard();
    await super.remove(key);
  }
}

final class FakeBackupService implements BackupService {
  @override
  Future<Result<File>> exportBackup() async => const Err(UnexpectedFailure('fake'));

  @override
  Future<Result<void>> restoreFrom(File file) async => const Err(UnexpectedFailure('fake'));
}

final class FakeBankListenerService implements BankListenerService {
  @override
  Future<bool> isPermissionGranted() async => false;

  @override
  Future<void> openPermissionSettings() async {}

  @override
  Stream<BankNotification> get notifications => const Stream.empty();
}
