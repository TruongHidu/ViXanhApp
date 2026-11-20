/// Lỗi có kiểu của domain. Mọi lớp data/services trả về [Failure] qua `Result`
/// thay vì ném exception lên UI.
sealed class Failure {
  const Failure(this.message, {this.cause, this.code});

  /// Mô tả cho log/lập trình viên (không hiển thị thẳng cho người dùng).
  final String message;
  final Object? cause;

  /// Mã ổn định để UI chọn thông báo đã dịch (ví dụ "amount_invalid"); `null` = lỗi chung.
  final String? code;

  @override
  String toString() => '$runtimeType: $message${cause == null ? '' : ' ($cause)'}';
}

final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.cause, super.code});
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.cause, super.code});
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.cause, super.code});
}

final class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.cause, super.code});
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.cause, super.code});
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.cause, super.code});
}
