import 'failure.dart';

/// Kết quả của một thao tác có thể thất bại: [Ok] hoặc [Err].
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;

  R fold<R>(R Function(T value) onOk, R Function(Failure failure) onErr) => switch (this) {
    Ok(:final value) => onOk(value),
    Err(:final failure) => onErr(failure),
  };

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Ok(:final value) => Ok(transform(value)),
    Err(:final failure) => Err(failure),
  };

  T? get valueOrNull => switch (this) {
    Ok(:final value) => value,
    Err() => null,
  };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;

  @override
  bool operator ==(Object other) => other is Ok<T> && other.value == value;
  @override
  int get hashCode => value.hashCode;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}

/// Chạy [body]; exception được chuyển thành [Err] qua [onError].
Future<Result<T>> guardAsync<T>(
  Future<T> Function() body, {
  required Failure Function(Object error) onError,
}) async {
  try {
    return Ok(await body());
  } catch (e) {
    return Err(onError(e));
  }
}
