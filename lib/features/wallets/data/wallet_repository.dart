import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums.dart';
import '../../../core/failure.dart';
import '../../../core/ids.dart';
import '../../../core/result.dart';
import '../../../data/database.dart';

/// Đường ghi duy nhất cho ví. Không ném exception: mọi lỗi thành [Failure].
final class WalletRepository {
  WalletRepository(this._db);

  final AppDatabase _db;

  static const minNameLength = 1;
  static const maxNameLength = 64;

  /// Giới hạn trị tuyệt đối của số dư ban đầu (đồng) — đủ lớn, tránh tràn khi cộng dồn.
  static const maxAbsInitialBalance = 999999999999;

  /// Tạo ví. [initialBalance] được âm (thẻ tín dụng đang nợ).
  Future<Result<WalletId>> create({
    required String name,
    required WalletType type,
    int initialBalance = 0,
  }) async {
    final trimmed = name.trim();
    if (trimmed.length < minNameLength || trimmed.length > maxNameLength) {
      return const Err(ValidationFailure('Tên ví cần từ $minNameLength đến $maxNameLength ký tự'));
    }
    if (initialBalance.abs() > maxAbsInitialBalance) {
      return const Err(ValidationFailure('Số dư ban đầu quá lớn'));
    }
    return guardAsync(
      () => _db.walletsDao.insertWallet(
        WalletsCompanion(
          name: Value(trimmed),
          type: Value(type),
          initialBalance: Value(initialBalance),
        ),
      ),
      onError: _toFailure,
    );
  }

  /// Ví đang dùng (chưa lưu trữ, chưa xóa), theo thứ tự hiển thị.
  Stream<List<WalletRow>> watchActive() => _db.walletsDao.watchActive();

  /// Số dư hiện tại của mọi ví chưa xóa, tính lại từ giao dịch.
  Stream<Map<WalletId, int>> watchBalances() => _db.walletsDao.watchBalances();

  /// Đã có ít nhất một ví đang dùng chưa.
  Future<Result<bool>> hasActiveWallet() => guardAsync(
    () async => (await _db.walletsDao.watchActive().first).isNotEmpty,
    onError: _toFailure,
  );

  static Failure _toFailure(Object error) => switch (error) {
    InvalidDataException() => ValidationFailure('Dữ liệu ví không hợp lệ', cause: error),
    _ => DatabaseFailure('Không ghi được ví', cause: error),
  };
}

final walletRepositoryProvider = Provider<WalletRepository>(
  (ref) => WalletRepository(ref.watch(appDatabaseProvider)),
);

/// Ví đang dùng, tự cập nhật khi DB đổi.
final activeWalletsProvider = StreamProvider.autoDispose<List<WalletRow>>(
  (ref) => ref.watch(walletRepositoryProvider).watchActive(),
);

/// Số dư hiện tại theo ví, tự cập nhật khi có giao dịch mới.
final walletBalancesProvider = StreamProvider.autoDispose<Map<WalletId, int>>(
  (ref) => ref.watch(walletRepositoryProvider).watchBalances(),
);
