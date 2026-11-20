/// Enum domain dùng chung giữa DB và các feature.
///
/// Tên giá trị chính là chuỗi lưu trong DB (cột textEnum + CHECK): đổi tên = phải viết migration.
library;

enum WalletType { cash, bank, ewallet, credit }

enum CategoryType { income, expense }

enum TransactionType { income, expense, transfer }

enum TransactionSource { manual, notification, webhook, recurring, import }
