import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Phiên đăng nhập (Supabase) — tuỳ chọn, chỉ cần khi bật đồng bộ.
abstract interface class AuthService {
  String? get currentUserId;
  Stream<String?> get userIdChanges;
  Future<void> signOut();
}

final class GuestAuthService implements AuthService {
  const GuestAuthService();
  @override
  String? get currentUserId => null;
  @override
  Stream<String?> get userIdChanges => const Stream.empty();
  @override
  Future<void> signOut() async {}
}

final authServiceProvider = Provider<AuthService>(
  (ref) => throw UnimplementedError('override trong bootstrap()'),
);
