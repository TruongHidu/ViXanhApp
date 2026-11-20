// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Ví Xanh';

  @override
  String get homeTitle => 'Tổng quan';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get themeMode => 'Giao diện';

  @override
  String get themeSystem => 'Theo hệ thống';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageSystem => 'Theo hệ thống';

  @override
  String get languageVi => 'Tiếng Việt';

  @override
  String get languageEn => 'English';

  @override
  String get settingsSaveFailed => 'Không lưu được cài đặt. Vui lòng thử lại.';

  @override
  String get tabOverview => 'Tổng quan';

  @override
  String get tabTransactions => 'Giao dịch';

  @override
  String get tabReports => 'Báo cáo';

  @override
  String get tabAccount => 'Tài khoản';

  @override
  String get addTransaction => 'Thêm giao dịch';

  @override
  String get today => 'Hôm nay';

  @override
  String get yesterday => 'Hôm qua';

  @override
  String get undo => 'Hoàn tác';

  @override
  String get emptyOverview => 'Chào bạn! Ghi khoản chi đầu tiên để xem tiền của mình đi đâu nhé.';

  @override
  String get emptyTransactions => 'Chưa có giao dịch nào. Bấm nút + để ghi khoản đầu tiên.';

  @override
  String get emptyReports => 'Báo cáo sẽ hiện ở đây khi bạn có vài giao dịch.';

  @override
  String get emptyAccount => 'Quản lý ví, danh mục và cài đặt của bạn tại đây.';

  @override
  String get onboardingStart => 'Bắt đầu';

  @override
  String get onboarding1Title => 'Biết tiền mình đi đâu';

  @override
  String get onboarding1Body => 'Ghi chép thu chi chỉ trong vài giây.';

  @override
  String get onboarding2Title => 'Tự động ghi nhận chuyển khoản';

  @override
  String get onboarding2Body => 'Kết nối thông báo ngân hàng, app tự gợi ý giao dịch cho bạn.';

  @override
  String get onboarding3Title => 'Chi tiêu có kế hoạch';

  @override
  String get onboarding3Body => 'Đặt ngân sách, nhận nhắc nhở nhẹ nhàng trước khi tiêu quá tay.';

  @override
  String get onboardingSkip => 'Bỏ qua';

  @override
  String get onboardingNext => 'Tiếp tục';

  @override
  String onboardingPageLabel(int current, int total) {
    return 'Trang $current trên $total';
  }

  @override
  String get back => 'Quay lại';

  @override
  String setupStep(int step, int total) {
    return 'Bước $step/$total';
  }

  @override
  String get setupProgressLabel => 'Tiến độ thiết lập';

  @override
  String get setupProfileTitle => 'Bạn muốn gọi là gì?';

  @override
  String get setupProfileSubtitle => 'Vài thông tin nhỏ để Ví Xanh hợp với bạn hơn.';

  @override
  String get setupNameLabel => 'Tên của bạn';

  @override
  String get setupNameHint => 'Ví dụ: Minh';

  @override
  String get setupCurrencyLabel => 'Đơn vị tiền';

  @override
  String get currencyVnd => '₫ VND';

  @override
  String get setupMonthStartLabel => 'Ngày bắt đầu tháng tài chính';

  @override
  String setupMonthStartValue(int day) {
    return 'Ngày $day hằng tháng';
  }

  @override
  String get setupMonthStartHint => 'Ví dụ: chọn ngày nhận lương';

  @override
  String get dayDecrease => 'Lùi một ngày';

  @override
  String get dayIncrease => 'Tăng một ngày';

  @override
  String get setupWalletTitle => 'Tạo ví đầu tiên';

  @override
  String get setupWalletSubtitle => 'Chọn nơi bạn hay giữ tiền nhất. Thêm ví khác sau cũng được.';

  @override
  String get setupFailed => 'Chưa tạo được ví. Vui lòng thử lại.';

  @override
  String get walletTypeCash => 'Tiền mặt';

  @override
  String get walletTypeCashHint => 'Tiền trong ví, túi';

  @override
  String get walletTypeBank => 'Ngân hàng';

  @override
  String get walletTypeBankHint => 'Vietcombank, MB…';

  @override
  String get walletTypeEwallet => 'Ví điện tử';

  @override
  String get walletTypeEwalletHint => 'MoMo, ZaloPay…';

  @override
  String get walletTypeCredit => 'Thẻ tín dụng';

  @override
  String get walletTypeCreditHint => 'Visa, Mastercard';

  @override
  String get walletDefaultNameCash => 'Tiền mặt';

  @override
  String get walletDefaultNameBank => 'Tài khoản ngân hàng';

  @override
  String get walletDefaultNameEwallet => 'Ví MoMo';

  @override
  String get walletDefaultNameCredit => 'Thẻ tín dụng';

  @override
  String get walletBalanceLabel => 'Số dư hiện tại';

  @override
  String get walletDebtLabel => 'Dư nợ hiện tại';

  @override
  String get walletNameLabel => 'Tên ví';

  @override
  String get walletNameInvalid => 'Tên ví cần từ 1 đến 64 ký tự.';

  @override
  String get txnTypeExpense => 'Chi tiêu';

  @override
  String get txnTypeIncome => 'Thu nhập';

  @override
  String get txnTypeTransfer => 'Chuyển khoản';

  @override
  String get txnTypeTabsLabel => 'Loại giao dịch';

  @override
  String get txnSave => 'Lưu';

  @override
  String get txnSaveMore => 'Lưu & thêm tiếp';

  @override
  String txnAmountLabel(String amount) {
    return 'Số tiền $amount';
  }

  @override
  String txnQuickAmount(String amount) {
    return 'Nhập nhanh $amount';
  }

  @override
  String get txnCategoriesLabel => 'Danh mục';

  @override
  String get categoryAll => 'Tất cả';

  @override
  String get chooseCategory => 'Chọn danh mục';

  @override
  String get chooseWallet => 'Chọn ví';

  @override
  String get txnFieldWallet => 'Ví';

  @override
  String get txnFromWallet => 'Từ ví';

  @override
  String get txnToWallet => 'Đến ví';

  @override
  String get swapWallets => 'Đổi chiều chuyển';

  @override
  String get txnFieldTime => 'Thời gian';

  @override
  String txnDateTime(String day, String time) {
    return '$day, $time';
  }

  @override
  String get txnNoteLabel => 'Ghi chú';

  @override
  String get txnNoteHint => 'Thêm ghi chú (vd: cà phê với Lan)';

  @override
  String get txnNoWallet => 'Chưa có ví';

  @override
  String keypadDigit(String digit) {
    return 'Số $digit';
  }

  @override
  String get keypadThousand => 'Ba số không';

  @override
  String get keypadBackspace => 'Xóa lùi';

  @override
  String get keypadPlus => 'Cộng thêm khoản';

  @override
  String get keypadMinus => 'Trừ bớt';

  @override
  String txnSaved(String amount, String label) {
    return 'Đã lưu $amount · $label';
  }

  @override
  String get txnErrorAmount => 'Nhập số tiền trước nhé';

  @override
  String get txnErrorCategory => 'Chọn danh mục trước nhé';

  @override
  String get txnErrorWallet => 'Ví này không còn dùng được, hãy chọn ví khác';

  @override
  String get txnErrorTransfer => 'Chọn hai ví khác nhau để chuyển khoản';

  @override
  String get txnErrorTooLong => 'Ghi chú quá dài';

  @override
  String get txnSaveFailed => 'Chưa lưu được giao dịch. Vui lòng thử lại.';

  @override
  String get txnLoadFailed => 'Không mở được giao dịch.';

  @override
  String get txnSearchTooltip => 'Tìm kiếm giao dịch';

  @override
  String get txnSearchHint => 'Tìm theo ghi chú, tên, danh mục';

  @override
  String get txnSearchClose => 'Đóng tìm kiếm';

  @override
  String get txnFilterTooltip => 'Lọc theo danh mục';

  @override
  String get txnFilterGroupLabel => 'Lọc giao dịch';

  @override
  String txnFilterClearCategory(String name) {
    return 'Bỏ lọc $name';
  }

  @override
  String get filterAll => 'Tất cả';

  @override
  String get previousMonth => 'Tháng trước';

  @override
  String get nextMonth => 'Tháng sau';

  @override
  String monthLabel(int month, int year) {
    return 'Tháng $month/$year';
  }

  @override
  String periodRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get summaryIncome => 'Thu';

  @override
  String get summaryExpense => 'Chi';

  @override
  String get summaryRemaining => 'Còn lại';

  @override
  String get txnNoMatch => 'Không có giao dịch phù hợp với bộ lọc này.';

  @override
  String get txnSwipeHint => 'Vuốt sang trái một dòng để sửa hoặc xóa';

  @override
  String get txnEmptyMonthTitle => 'Chưa có giao dịch nào trong tháng này';

  @override
  String get txnEmptyMonthBody => 'Ghi lại khoản đầu tiên, chỉ mất vài giây thôi.';

  @override
  String get txnAddFirst => 'Thêm giao dịch đầu tiên';

  @override
  String get txnEdit => 'Sửa';

  @override
  String get txnDelete => 'Xóa';

  @override
  String get txnDeleted => 'Đã xóa giao dịch';

  @override
  String get txnDeleteFailed => 'Chưa xóa được giao dịch.';

  @override
  String get txnDetailTitle => 'Chi tiết giao dịch';

  @override
  String get txnEditAction => 'Chỉnh sửa';

  @override
  String get txnNotFound => 'Giao dịch này không còn nữa.';

  @override
  String get txnFieldSource => 'Nguồn';

  @override
  String get txnSourceManual => 'Nhập tay';

  @override
  String get txnSourceNotification => 'Thông báo ngân hàng';

  @override
  String get txnSourceWebhook => 'Ngân hàng gửi về';

  @override
  String get txnSourceRecurring => 'Giao dịch định kỳ';

  @override
  String get txnSourceImport => 'Nhập từ file';

  @override
  String get txnLoadingLabel => 'Đang tải giao dịch';

  @override
  String get greetingMorning => 'Chào buổi sáng';

  @override
  String get greetingAfternoon => 'Chào buổi chiều';

  @override
  String get greetingEvening => 'Chào buổi tối';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get homeTotalBalance => 'Tổng số dư';

  @override
  String get homeIncomeMonth => 'Thu tháng này';

  @override
  String get homeExpenseMonth => 'Chi tháng này';

  @override
  String get hideBalance => 'Ẩn số dư';

  @override
  String get showBalance => 'Hiện số dư';

  @override
  String get homeWallets => 'Ví của tôi';

  @override
  String get seeAll => 'Xem tất cả';

  @override
  String get homeSpending7Days => 'Chi tiêu 7 ngày qua';

  @override
  String homeSpendingCaption(String total, String average) {
    return 'Tổng $total · trung bình $average/ngày';
  }

  @override
  String homeChartDay(String day, String amount) {
    return '$day: chi $amount';
  }

  @override
  String get homeRecent => 'Giao dịch gần đây';

  @override
  String weekdayShort(String weekday) {
    String _temp0 = intl.Intl.selectLogic(weekday, {
      '1': 'T2',
      '2': 'T3',
      '3': 'T4',
      '4': 'T5',
      '5': 'T6',
      '6': 'T7',
      '7': 'CN',
      'other': '',
    });
    return '$_temp0';
  }
}
