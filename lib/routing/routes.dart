/// Đường dẫn route — nơi DUY NHẤT viết chuỗi path; feature chỉ dùng hằng ở đây.
abstract final class Routes {
  static const onboarding = '/onboarding';

  // 4 tab của thanh điều hướng dưới, theo đúng thứ tự hiển thị.
  static const overview = '/overview';
  static const transactions = '/transactions';
  static const reports = '/reports';
  static const account = '/account';

  /// Con của [account] (đoạn path tương đối: [settingsSegment]).
  static const settings = '/account/settings';
  static const settingsSegment = 'settings';

  /// Mở toàn màn hình, che thanh điều hướng.
  static const addTransaction = '/add';

  /// Chi tiết giao dịch: con của [transactions] (đoạn path tương đối [transactionDetailSegment]).
  static String transactionDetail(String id) => '$transactions/$id';
  static const transactionDetailSegment = ':id';

  /// Sửa giao dịch: toàn màn hình như [addTransaction].
  static String editTransaction(String id) => '/edit/$id';
  static const editTransactionPattern = '/edit/:id';

  /// Tên tham số id trong các path trên.
  static const idParam = 'id';
}
