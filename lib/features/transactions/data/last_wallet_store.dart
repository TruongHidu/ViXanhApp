import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ids.dart';
import '../../../services/key_value_store.dart';

/// Nhớ ví dùng gần nhất để màn Thêm giao dịch chọn sẵn.
///
/// Để riêng khỏi AppPreferences: đổi ví sau mỗi lần lưu không được làm dựng lại cả app.
final class LastWalletStore {
  LastWalletStore(this._store);

  static const kLastWalletId = 'last_wallet_id';

  /// Key cần có trong allowList của shared_preferences.
  static const keys = {kLastWalletId};

  final KeyValueStore _store;

  WalletId? read() => switch (_store.getString(kLastWalletId)) {
    final id? when id.isNotEmpty => WalletId(id),
    _ => null,
  };

  /// Lỗi ghi được bỏ qua có chủ đích: đây chỉ là tiện ích, không phải dữ liệu.
  Future<void> write(WalletId id) async {
    try {
      await _store.setString(kLastWalletId, id.value);
    } on Exception {
      return;
    }
  }
}

final lastWalletStoreProvider = Provider<LastWalletStore>(
  (ref) => LastWalletStore(ref.watch(keyValueStoreProvider)),
);
