import 'package:drift/drift.dart';

import '../../core/enums.dart';
import '../converters.dart';
import 'categories_table.dart';
import 'timestamps.dart';
import 'wallets_table.dart';

/// Giao dịch thu / chi / chuyển giữa ví.
///
/// `amount` luôn DƯƠNG; chiều tiền nằm ở `type`. Chuyển khoản: `wallet_id` là ví đi,
/// `to_wallet_id` là ví đến, không có danh mục.
@DataClassName('TransactionRow')
@TableIndex(name: 'idx_transactions_occurred_at', columns: {#occurredAt})
@TableIndex(name: 'idx_transactions_wallet_occurred_at', columns: {#walletId, #occurredAt})
@TableIndex(name: 'idx_transactions_category_occurred_at', columns: {#categoryId, #occurredAt})
class Transactions extends Table with Timestamps {
  TextColumn get id => text().map(const TransactionIdConverter())();
  @ReferenceName('outgoingTransactions')
  TextColumn get walletId => text().references(Wallets, #id).map(const WalletIdConverter())();
  @ReferenceName('incomingTransfers')
  TextColumn get toWalletId =>
      text().nullable().references(Wallets, #id).map(const WalletIdConverter())();
  TextColumn get categoryId =>
      text().nullable().references(Categories, #id).map(const CategoryIdConverter())();
  TextColumn get type => textEnum<TransactionType>()();

  /// Đơn vị nhỏ nhất (đồng), luôn > 0.
  IntColumn get amount => integer()();
  IntColumn get occurredAt => integer().map(const EpochMsConverter())();
  TextColumn get note => text().nullable()();
  TextColumn get source =>
      textEnum<TransactionSource>().withDefault(Constant(TransactionSource.manual.name))();

  /// FK tới bank_events / recurring_rules sẽ thêm bằng migration khi có 2 bảng đó.
  TextColumn get bankEventId => text().nullable()();
  TextColumn get recurringId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  bool get isStrict => true;

  @override
  List<String> get customConstraints => [
    'CHECK (amount > 0)',
    "CHECK (type IN ('income', 'expense', 'transfer'))",
    "CHECK (source IN ('manual', 'notification', 'webhook', 'recurring', 'import'))",
    "CHECK ((type = 'transfer') = (to_wallet_id IS NOT NULL))",
    'CHECK (to_wallet_id IS NULL OR to_wallet_id <> wallet_id)',
    "CHECK (type <> 'transfer' OR category_id IS NULL)",
  ];
}
