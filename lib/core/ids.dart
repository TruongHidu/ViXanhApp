import 'package:uuid/uuid.dart';

/// Định danh có kiểu cho các entity — tránh truyền nhầm id ví vào chỗ id danh mục.
/// Giá trị là UUID dạng chuỗi (để sau này đồng bộ nhiều máy không bị trùng).
extension type const WalletId(String value) {}

extension type const CategoryId(String value) {}

extension type const TransactionId(String value) {}

/// Nguồn sinh id, inject được để test có id cố định.
abstract interface class IdGenerator {
  String newId();
}

/// UUID v4 ngẫu nhiên.
final class UuidIdGenerator implements IdGenerator {
  const UuidIdGenerator();

  static const _uuid = Uuid();

  @override
  String newId() => _uuid.v4();
}

/// UUID v5 cố định sinh từ một khóa ổn định (ví dụ `system_key` của danh mục mặc định):
/// cùng khóa → cùng id trên mọi máy, nên sao lưu/đồng bộ nhận ra là một bản ghi.
String stableUuid(String key) => const Uuid().v5(_viXanhNamespace, key);

/// Namespace riêng của app cho UUID v5. Không bao giờ được đổi.
const _viXanhNamespace = '3f7d6e00-5b1a-4c3e-9d2a-0a1b2c3d4e5f';
