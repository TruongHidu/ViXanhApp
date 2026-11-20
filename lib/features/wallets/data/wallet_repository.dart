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
  /// [accountLast4]: 4 số cuối tài khoản/thẻ (tùy chọn), lưu dạng "•••• 1234".
  Future<Result<WalletId>> create({
    required String name,
    required WalletType type,
    int initialBalance = 0,
    String? accountLast4,
  }) async {
    if (_validate(name, initialBalance, accountLast4) case final failure?) return Err(failure);
    return guardAsync(
      () => _db.walletsDao.insertWallet(
        WalletsCompanion(
          name: Value(name.trim()),
          type: Value(type),
          initialBalance: Value(initialBalance),
          accountMasked: Value(maskAccount(accountLast4)),
        ),
      ),
      onError: _toFailure,
    );
  }

  /// Sửa thông tin ví (giao dịch cũ giữ nguyên; số dư tính lại theo số dư ban đầu mới).
  Future<Result<void>> update(
    WalletId id, {
    required String name,
    required WalletType type,
    required int initialBalance,
    String? accountLast4,
  }) async {
    if (_validate(name, initialBalance, accountLast4) case final failure?) return Err(failure);
    return guardAsync(() async {
      final updated = await _db.walletsDao.updateWallet(
        id,
        WalletsCompanion(
          name: Value(name.trim()),
          type: Value(type),
          initialBalance: Value(initialBalance),
          accountMasked: Value(maskAccount(accountLast4)),
        ),
      );
      if (!updated) throw const _NotFound();
    }, onError: _toFailure);
  }

  /// Lưu trữ ví: ẩn khỏi danh sách và khỏi chọn ví; giao dịch cũ vẫn giữ.
  /// Không cho lưu trữ ví cuối cùng còn dùng (app luôn cần ít nhất một ví).
  Future<Result<void>> archive(WalletId id) => guardAsync(
    () => _db.transaction(() async {
      final active = await _db.walletsDao.watchActive().first;
      if (!active.any((w) => w.id == id)) throw const _NotFound();
      if (active.length == 1) throw const _LastWallet();
      await _db.walletsDao.archive(id);
    }),
    onError: _toFailure,
  );

  /// Một ví (chưa xóa, kể cả đã lưu trữ); `null` khi không còn.
  Stream<WalletRow?> watchWallet(WalletId id) => (_db.select(
    _db.wallets,
  )..where((w) => w.id.equalsValue(id) & w.deletedAt.isNull())).watchSingleOrNull();

  /// Số dư cuối mỗi ngày (giờ địa phương) của ví trong [days] ngày gần nhất tính đến [today].
  ///
  /// Tính bằng SQL: số dư đầu kỳ (số dư ban đầu + mọi thay đổi trước kỳ) và thay đổi ròng
  /// từng ngày trong kỳ (thu +, chi −, chuyển đi −, chuyển đến +); Dart chỉ cộng dồn.
  /// Ngày không có giao dịch giữ số dư hôm trước.
  Stream<List<({DateTime day, int balance})>> watchBalanceHistory(
    WalletId id, {
    required DateTime today,
    int days = 30,
  }) {
    const dayMs = Duration.millisecondsPerDay;
    final local = today.toLocal();
    final start = DateTime(local.year, local.month, local.day - (days - 1));
    final end = DateTime(local.year, local.month, local.day + 1);
    final offsetMs = start.timeZoneOffset.inMilliseconds;
    final startMs = start.toUtc().millisecondsSinceEpoch;

    return _db
        .customSelect(
          '''
          SELECT
            CASE WHEN t.occurred_at < ?2 THEN -1 ELSE (t.occurred_at + ?3) / $dayMs END AS day,
            SUM(
              CASE WHEN t.wallet_id = ?1 THEN
                (CASE t.type WHEN 'income' THEN t.amount ELSE -t.amount END) ELSE 0 END
              + CASE WHEN t.to_wallet_id = ?1 AND t.type = 'transfer' THEN t.amount ELSE 0 END
            ) AS net
          FROM transactions t
          WHERE t.deleted_at IS NULL
            AND (t.wallet_id = ?1 OR t.to_wallet_id = ?1)
            AND t.occurred_at < ?4
          GROUP BY day
          ''',
          variables: [
            Variable.withString(id.value),
            Variable.withInt(startMs),
            Variable.withInt(offsetMs),
            Variable.withInt(end.toUtc().millisecondsSinceEpoch),
          ],
          readsFrom: {_db.transactions, _db.wallets},
        )
        .watch()
        .asyncMap((rows) async {
          final wallet = await _db.walletsDao.findById(id);
          var balance = wallet?.initialBalance ?? 0;
          final byDay = <int, int>{};
          for (final r in rows) {
            final day = r.read<int>('day');
            if (day == -1) {
              balance += r.read<int>('net');
            } else {
              byDay[day] = r.read<int>('net');
            }
          }
          final firstDay = (startMs + offsetMs) ~/ dayMs;
          return [
            for (var i = 0; i < days; i++)
              (
                day: DateTime(start.year, start.month, start.day + i),
                balance: balance += byDay[firstDay + i] ?? 0,
              ),
          ];
        });
  }

  /// "1234" → "•••• 1234"; rỗng → null.
  static String? maskAccount(String? last4) {
    final digits = last4?.trim() ?? '';
    return digits.isEmpty ? null : '•••• $digits';
  }

  /// "•••• 1234" → "1234" (để nạp lại vào form sửa).
  static String? unmaskAccount(String? masked) =>
      masked == null ? null : RegExp(r'\d+').allMatches(masked).map((m) => m.group(0)).join();

  static ValidationFailure? _validate(String name, int initialBalance, String? last4) {
    final trimmed = name.trim();
    if (trimmed.length < minNameLength || trimmed.length > maxNameLength) {
      return const ValidationFailure(
        'Tên ví cần từ $minNameLength đến $maxNameLength ký tự',
        code: WalletErrors.nameInvalid,
      );
    }
    if (initialBalance.abs() > maxAbsInitialBalance) {
      return const ValidationFailure('Số dư ban đầu quá lớn', code: WalletErrors.balanceTooLarge);
    }
    final digits = last4?.trim() ?? '';
    if (digits.isNotEmpty && !RegExp(r'^\d{4}$').hasMatch(digits)) {
      return const ValidationFailure(
        'Số tài khoản cần đúng 4 chữ số cuối',
        code: WalletErrors.accountInvalid,
      );
    }
    return null;
  }

  /// Ví đang dùng (chưa lưu trữ, chưa xóa), theo thứ tự hiển thị.
  Stream<List<WalletRow>> watchActive() => _db.walletsDao.watchActive();

  /// Số dư hiện tại của mọi ví chưa xóa, tính lại từ giao dịch.
  Stream<Map<WalletId, int>> watchBalances() => _db.walletsDao.watchBalances();

  /// Tổng số dư của các ví đang dùng (bỏ ví lưu trữ / đã xóa), tính bằng SQL từ giao dịch.
  /// Thẻ tín dụng đang nợ làm giảm tổng.
  Stream<int> watchTotalBalance() => _db
      .customSelect(
        '''
        SELECT COALESCE(SUM(
          w.initial_balance
          + COALESCE((
              SELECT SUM(CASE t.type WHEN 'income' THEN t.amount ELSE -t.amount END)
              FROM transactions t
              WHERE t.wallet_id = w.id AND t.deleted_at IS NULL
            ), 0)
          + COALESCE((
              SELECT SUM(t.amount)
              FROM transactions t
              WHERE t.to_wallet_id = w.id AND t.type = 'transfer' AND t.deleted_at IS NULL
            ), 0)
        ), 0) AS total
        FROM wallets w
        WHERE w.deleted_at IS NULL AND w.archived = 0
        ''',
        readsFrom: {_db.wallets, _db.transactions},
      )
      .watch()
      .map((rows) => rows.single.read<int>('total'));

  /// Đã có ít nhất một ví đang dùng chưa.
  Future<Result<bool>> hasActiveWallet() => guardAsync(
    () async => (await _db.walletsDao.watchActive().first).isNotEmpty,
    onError: _toFailure,
  );

  static Failure _toFailure(Object error) => switch (error) {
    _LastWallet() => const ValidationFailure(
      'Không thể lưu trữ ví cuối cùng',
      code: WalletErrors.lastWallet,
    ),
    _NotFound() => const NotFoundFailure('Không tìm thấy ví', code: WalletErrors.notFound),
    InvalidDataException() => ValidationFailure('Dữ liệu ví không hợp lệ', cause: error),
    _ => DatabaseFailure('Không ghi được ví', cause: error),
  };
}

/// Mã lỗi của ví (đặt vào `Failure.code`); UI dịch theo mã.
abstract final class WalletErrors {
  static const nameInvalid = 'wallet_name_invalid';
  static const balanceTooLarge = 'wallet_balance_too_large';
  static const accountInvalid = 'wallet_account_invalid';
  static const lastWallet = 'wallet_last';
  static const notFound = 'wallet_not_found';
}

final class _LastWallet implements Exception {
  const _LastWallet();
}

final class _NotFound implements Exception {
  const _NotFound();
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

/// Tổng số dư các ví đang dùng.
final totalBalanceProvider = StreamProvider.autoDispose<int>(
  (ref) => ref.watch(walletRepositoryProvider).watchTotalBalance(),
);

/// Một ví cho màn chi tiết; `null` khi đã bị xóa.
final walletProvider = StreamProvider.autoDispose.family<WalletRow?, WalletId>(
  (ref, id) => ref.watch(walletRepositoryProvider).watchWallet(id),
);
