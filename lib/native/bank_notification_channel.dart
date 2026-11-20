import 'package:flutter/services.dart';

/// Nơi DUY NHẤT gọi native. Tên channel phải khớp `MainActivity.kt`.
final class BankNotificationChannel {
  const BankNotificationChannel();

  static const _method = MethodChannel('vi_xanh/bank_listener');
  static const _events = EventChannel('vi_xanh/bank_notifications');

  Future<bool> isPermissionGranted() async =>
      await _method.invokeMethod<bool>('isPermissionGranted') ?? false;

  Future<void> openPermissionSettings() => _method.invokeMethod<void>('openPermissionSettings');

  Stream<Map<Object?, Object?>> events() =>
      _events.receiveBroadcastStream().map((e) => e as Map<Object?, Object?>);
}
