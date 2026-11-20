import 'package:drift/drift.dart';

import '../converters.dart';

/// Cột thời gian chung cho mọi bảng: epoch ms UTC. `deleted_at` NULL = chưa xóa (xóa mềm).
mixin Timestamps on Table {
  IntColumn get createdAt => integer().map(const EpochMsConverter())();
  IntColumn get updatedAt => integer().map(const EpochMsConverter())();
  IntColumn get deletedAt => integer().nullable().map(const EpochMsConverter())();
}
