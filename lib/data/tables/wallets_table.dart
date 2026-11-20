import 'package:drift/drift.dart';

import '../../core/enums.dart';
import '../converters.dart';
import 'timestamps.dart';

@DataClassName('WalletRow')
class Wallets extends Table with Timestamps {
  TextColumn get id => text().map(const WalletIdConverter())();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  TextColumn get type => textEnum<WalletType>()();
  TextColumn get currency => text().withDefault(const Constant('VND'))();

  /// Số dư ban đầu, đơn vị nhỏ nhất (đồng). Được âm (thẻ tín dụng đang nợ).
  /// Số dư hiện tại KHÔNG lưu — luôn tính lại từ giao dịch.
  IntColumn get initialBalance => integer().withDefault(const Constant(0))();
  TextColumn get bankCode => text().nullable()();
  TextColumn get accountMasked => text().nullable()();
  BoolColumn get autoSync => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  bool get isStrict => true;

  @override
  List<String> get customConstraints => [
    "CHECK (type IN ('cash', 'bank', 'ewallet', 'credit'))",
    'CHECK (length(name) BETWEEN 1 AND 64)',
  ];
}
