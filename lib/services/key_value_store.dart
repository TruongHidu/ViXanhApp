import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kho key–value nhỏ cho cài đặt của từng máy (không nằm trong DB, không vào bản sao lưu).
///
/// Đọc là đồng bộ (phục vụ từ cache) để theme có trước khung hình đầu tiên.
/// Đọc một key có giá trị sai kiểu trả `null` thay vì ném lỗi.
abstract interface class KeyValueStore {
  String? getString(String key);
  int? getInt(String key);
  bool? getBool(String key);
  Future<void> setString(String key, String value);
  Future<void> setInt(String key, int value);
  Future<void> setBool(String key, bool value);
  Future<void> remove(String key);
}

/// Bản thật, bọc [SharedPreferencesWithCache].
final class SharedPrefsKeyValueStore implements KeyValueStore {
  SharedPrefsKeyValueStore._(this._prefs);

  final SharedPreferencesWithCache _prefs;

  /// [allowList] là toàn bộ key app được phép đọc/ghi; key ngoài danh sách sẽ bị từ chối.
  static Future<SharedPrefsKeyValueStore> create({required Set<String> allowList}) async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(allowList: allowList),
    );
    return SharedPrefsKeyValueStore._(prefs);
  }

  @override
  String? getString(String key) => _read(() => _prefs.getString(key));
  @override
  int? getInt(String key) => _read(() => _prefs.getInt(key));
  @override
  bool? getBool(String key) => _read(() => _prefs.getBool(key));
  @override
  Future<void> setString(String key, String value) => _prefs.setString(key, value);
  @override
  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);
  @override
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);
  @override
  Future<void> remove(String key) => _prefs.remove(key);

  /// Giá trị lưu sai kiểu (ví dụ int ở key String) ném TypeError — coi như chưa có.
  static T? _read<T>(T? Function() body) {
    try {
      return body();
    } on TypeError {
      return null;
    }
  }
}

/// Kho chỉ sống trong RAM: dự phòng khi không mở được shared_preferences,
/// để app vẫn chạy với cài đặt mặc định thay vì treo.
class InMemoryKeyValueStore implements KeyValueStore {
  InMemoryKeyValueStore([Map<String, Object>? initial]) : values = {...?initial};

  final Map<String, Object> values;

  T? _get<T>(String key) => switch (values[key]) {
    final T v => v,
    _ => null,
  };

  @override
  String? getString(String key) => _get<String>(key);
  @override
  int? getInt(String key) => _get<int>(key);
  @override
  bool? getBool(String key) => _get<bool>(key);
  @override
  Future<void> setString(String key, String value) async => values[key] = value;
  @override
  Future<void> setInt(String key, int value) async => values[key] = value;
  @override
  Future<void> setBool(String key, bool value) async => values[key] = value;
  @override
  Future<void> remove(String key) async => values.remove(key);
}

/// Placeholder: ném lỗi cho tới khi `bootstrap()` override.
final keyValueStoreProvider = Provider<KeyValueStore>(
  (ref) => throw UnimplementedError('keyValueStoreProvider phải được override trong bootstrap()'),
);
