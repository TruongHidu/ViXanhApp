import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Thông báo cục bộ (nhắc ghi chép, cảnh báo ngân sách, giao dịch định kỳ).
abstract interface class NotificationService {
  Future<void> init();
  Future<void> show({required int id, required String title, required String body});
  Future<void> cancel(int id);
}

/// Bản tạm — thay bằng impl dùng flutter_local_notifications.
final class NoopNotificationService implements NotificationService {
  const NoopNotificationService();
  @override
  Future<void> init() async {}
  @override
  Future<void> show({required int id, required String title, required String body}) async {}
  @override
  Future<void> cancel(int id) async {}
}

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => throw UnimplementedError('override trong bootstrap()'),
);
