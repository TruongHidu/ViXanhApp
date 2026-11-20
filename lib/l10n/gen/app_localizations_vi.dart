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
}
