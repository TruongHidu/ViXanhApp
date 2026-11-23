import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../core/clock.dart';
import '../core/enums.dart';
import '../core/ids.dart';
import '../data/database.dart';

/// CHỈ DÙNG KHI PHÁT TRIỂN: thêm [count] giao dịch giả rải đều trong [span] gần nhất vào
/// [walletId] để thử hiệu năng (cuộn danh sách, báo cáo). Không bao giờ gọi trong bản release.
///
/// Dữ liệu tất định theo [seed] để các lần đo so sánh được với nhau.
Future<void> seedDemoTransactions(
  AppDatabase db, {
  required WalletId walletId,
  required Clock clock,
  int count = 10000,
  int seed = 42,
  Duration span = const Duration(days: 365),
}) async {
  if (kReleaseMode) throw StateError('seedDemoTransactions chỉ dành cho debug/profile');
  final random = Random(seed);
  const expenseKeys = ['an_uong', 'ca_phe', 'di_cho', 'di_chuyen', 'mua_sam', 'dien', 'giai_tri'];
  const incomeKeys = ['luong', 'thuong', 'ban_hang'];
  final now = clock.now();

  await db.batch((b) {
    for (var i = 0; i < count; i++) {
      final income = random.nextInt(10) == 0;
      final keys = income ? incomeKeys : expenseKeys;
      final at = now.subtract(
        Duration(milliseconds: (random.nextDouble() * span.inMilliseconds).round()),
      );
      b.insert(
        db.transactions,
        TransactionsCompanion.insert(
          id: TransactionId('demo-$seed-$i'),
          walletId: walletId,
          categoryId: Value(
            CategoryId(stableUuid('category:${keys[random.nextInt(keys.length)]}')),
          ),
          type: income ? TransactionType.income : TransactionType.expense,
          // Bội số 1.000 đồng cho giống thật.
          amount: (income ? 500 + random.nextInt(20000) : 5 + random.nextInt(800)) * 1000,
          occurredAt: at,
          createdAt: at,
          updatedAt: at,
        ),
      );
    }
  });
}
