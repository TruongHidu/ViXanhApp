import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../native/bank_notification_channel.dart';

/// Thông báo biến động số dư thô đọc từ notification của app ngân hàng.
final class BankNotification {
  const BankNotification({
    required this.packageName,
    required this.title,
    required this.text,
    required this.postedAt,
  });

  final String packageName;
  final String title;
  final String text;
  final DateTime postedAt;

  factory BankNotification.fromMap(Map<Object?, Object?> map) => BankNotification(
    packageName: map['package'] as String? ?? '',
    title: map['title'] as String? ?? '',
    text: map['text'] as String? ?? '',
    postedAt: DateTime.fromMillisecondsSinceEpoch(map['postedAt'] as int? ?? 0),
  );
}

abstract interface class BankListenerService {
  Future<bool> isPermissionGranted();
  Future<void> openPermissionSettings();
  Stream<BankNotification> get notifications;
}

final class NativeBankListenerService implements BankListenerService {
  NativeBankListenerService(this._channel);
  final BankNotificationChannel _channel;

  @override
  Future<bool> isPermissionGranted() => _channel.isPermissionGranted();
  @override
  Future<void> openPermissionSettings() => _channel.openPermissionSettings();
  @override
  Stream<BankNotification> get notifications => _channel.events().map(BankNotification.fromMap);
}

final bankListenerServiceProvider = Provider<BankListenerService>(
  (ref) => throw UnimplementedError('override trong bootstrap()'),
);
