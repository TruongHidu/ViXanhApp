import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../core/failure.dart';
import '../core/result.dart';

/// Mở bảng chia sẻ của hệ điều hành để người dùng lưu / gửi file (Drive, Zalo, máy tính…).
abstract interface class ShareService {
  /// `Ok(true)` = đã chia sẻ; `Ok(false)` = người dùng đóng bảng chia sẻ.
  Future<Result<bool>> shareFile(File file, {String? subject});
}

final class SharePlusShareService implements ShareService {
  const SharePlusShareService();

  @override
  Future<Result<bool>> shareFile(File file, {String? subject}) => guardAsync(() async {
    final result = await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: subject),
    );
    return result.status != ShareResultStatus.dismissed;
  }, onError: (e) => UnexpectedFailure('Không mở được bảng chia sẻ', cause: e));
}

final shareServiceProvider = Provider<ShareService>(
  (ref) => throw UnimplementedError('override trong bootstrap()'),
);
