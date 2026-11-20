import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/common.dart' show CommonDatabase;

import '../core/clock.dart';
import '../core/enums.dart';
import '../core/ids.dart';
import 'converters.dart';
import 'daos/categories_dao.dart';
import 'daos/transactions_dao.dart';
import 'daos/wallets_dao.dart';
import 'migrations/migration_strategy.dart';
import 'tables/tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Wallets, Categories, Transactions],
  daos: [WalletsDao, CategoriesDao, TransactionsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(
    super.executor, {
    this.clock = const SystemClock(),
    this.ids = const UuidIdGenerator(),
  });

  /// Nguồn thời gian cho created_at / updated_at / deleted_at.
  final Clock clock;

  /// Nguồn sinh id cho bản ghi mới.
  final IdGenerator ids;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => buildMigrationStrategy(this);
}

/// Factory thuần — không phụ thuộc Riverpod, dùng lại được trong isolate.
AppDatabase openAppDatabase() => AppDatabase(
  driftDatabase(
    name: 'vi_xanh',
    native: const DriftNativeOptions(setup: _configureNativeDatabase),
  ),
);

/// Chạy ngay khi mở file, ngoài transaction (journal_mode không đổi được trong transaction).
/// Phải là hàm top-level vì có thể được gửi sang isolate nền.
void _configureNativeDatabase(CommonDatabase db) {
  db.execute('PRAGMA journal_mode = WAL');
}

/// Placeholder: ném lỗi cho tới khi `bootstrap()` override.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('appDatabaseProvider phải được override trong bootstrap()'),
);
