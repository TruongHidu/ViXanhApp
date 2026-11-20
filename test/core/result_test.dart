import 'package:flutter_test/flutter_test.dart';
import 'package:vi_xanh_app/core/failure.dart';
import 'package:vi_xanh_app/core/result.dart';

void main() {
  test('fold chọn đúng nhánh', () {
    const Result<int> ok = Ok(2);
    const Result<int> err = Err(ValidationFailure('x'));
    expect(ok.fold((v) => v * 2, (_) => -1), 4);
    expect(err.fold((v) => v, (_) => -1), -1);
  });

  test('guardAsync chuyển exception thành Err', () async {
    final r = await guardAsync<int>(
      () async => throw StateError('boom'),
      onError: (e) => UnexpectedFailure('wrapped', cause: e),
    );
    expect(r, isA<Err<int>>());
  });
}
