import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Thông tin bản app đang chạy (đọc từ gói cài đặt, không cần mạng).
abstract interface class AppInfoService {
  /// "1.0.0 (1)".
  Future<String> version();
}

final class PackageAppInfoService implements AppInfoService {
  const PackageAppInfoService();

  @override
  Future<String> version() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version} (${info.buildNumber})';
  }
}

final appInfoServiceProvider = Provider<AppInfoService>(
  (ref) => throw UnimplementedError('override trong bootstrap()'),
);

/// Phiên bản app để hiện ở Tài khoản.
final appVersionProvider = FutureProvider.autoDispose<String>(
  (ref) => ref.watch(appInfoServiceProvider).version(),
);
