import 'package:integration_test/integration_test_driver.dart';

/// Đo hiệu năng ở profile mode:
///   flutter drive --profile --driver=test_driver/perf_driver.dart
///     --target=integration_test/perf_scroll_test.dart -d DEVICE_ID
/// Số liệu khung hình (FrameTiming) ghi ra build/integration_response_data.json.
Future<void> main() => integrationDriver();
