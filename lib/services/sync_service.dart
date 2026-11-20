import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/result.dart';

/// Đồng bộ giao dịch từ webhook SePay (Supabase) về DB cục bộ.
abstract interface class SyncService {
  Future<Result<int>> pull();
}

final class DisabledSyncService implements SyncService {
  const DisabledSyncService();
  @override
  Future<Result<int>> pull() async => const Ok(0);
}

final syncServiceProvider = Provider<SyncService>(
  (ref) => throw UnimplementedError('override trong bootstrap()'),
);
