import 'package:drift/drift.dart';

import '../core/ids.dart';

/// DateTime ↔ INTEGER epoch milliseconds UTC. Đọc ra luôn là UTC.
final class EpochMsConverter extends TypeConverter<DateTime, int> {
  const EpochMsConverter();

  @override
  DateTime fromSql(int fromDb) => DateTime.fromMillisecondsSinceEpoch(fromDb, isUtc: true);

  @override
  int toSql(DateTime value) => value.toUtc().millisecondsSinceEpoch;
}

final class WalletIdConverter extends TypeConverter<WalletId, String> {
  const WalletIdConverter();
  @override
  WalletId fromSql(String fromDb) => WalletId(fromDb);
  @override
  String toSql(WalletId value) => value.value;
}

final class CategoryIdConverter extends TypeConverter<CategoryId, String> {
  const CategoryIdConverter();
  @override
  CategoryId fromSql(String fromDb) => CategoryId(fromDb);
  @override
  String toSql(CategoryId value) => value.value;
}

final class TransactionIdConverter extends TypeConverter<TransactionId, String> {
  const TransactionIdConverter();
  @override
  TransactionId fromSql(String fromDb) => TransactionId(fromDb);
  @override
  String toSql(TransactionId value) => value.value;
}
