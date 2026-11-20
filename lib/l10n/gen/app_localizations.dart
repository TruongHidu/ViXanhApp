import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('vi')];

  /// Tên app hiển thị trong trình chuyển ứng dụng
  ///
  /// In vi, this message translates to:
  /// **'Ví Xanh'**
  String get appTitle;

  /// Tiêu đề màn Tổng quan
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan'**
  String get homeTitle;

  /// Tiêu đề màn Cài đặt
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settingsTitle;

  /// Tiêu đề nhóm chọn chế độ sáng/tối trong Cài đặt
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get themeMode;

  /// Chế độ giao diện theo hệ điều hành
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get themeSystem;

  /// Chế độ giao diện sáng
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get themeLight;

  /// Chế độ giao diện tối
  ///
  /// In vi, this message translates to:
  /// **'Tối'**
  String get themeDark;

  /// Tiêu đề nhóm chọn ngôn ngữ trong Cài đặt
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// Lựa chọn ngôn ngữ: dùng ngôn ngữ của hệ điều hành
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get languageSystem;

  /// Tên tiếng Việt, luôn viết bằng tiếng Việt ở mọi ngôn ngữ
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVi;

  /// Tên tiếng Anh, luôn viết bằng tiếng Anh ở mọi ngôn ngữ
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get languageEn;

  /// Snackbar khi ghi cài đặt thất bại
  ///
  /// In vi, this message translates to:
  /// **'Không lưu được cài đặt. Vui lòng thử lại.'**
  String get settingsSaveFailed;

  /// Nhãn tab Tổng quan trên thanh điều hướng dưới
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan'**
  String get tabOverview;

  /// Nhãn tab Giao dịch trên thanh điều hướng dưới
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch'**
  String get tabTransactions;

  /// Nhãn tab Báo cáo trên thanh điều hướng dưới
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo'**
  String get tabReports;

  /// Nhãn tab Tài khoản trên thanh điều hướng dưới
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get tabAccount;

  /// Nhãn trợ năng của nút + và tiêu đề màn thêm giao dịch
  ///
  /// In vi, this message translates to:
  /// **'Thêm giao dịch'**
  String get addTransaction;

  /// Nhãn ngày cho hôm nay trong danh sách giao dịch
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get today;

  /// Nhãn ngày cho hôm qua trong danh sách giao dịch
  ///
  /// In vi, this message translates to:
  /// **'Hôm qua'**
  String get yesterday;

  /// Nút trên snackbar để hoàn tác thao tác vừa làm (ví dụ xóa)
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tác'**
  String get undo;

  /// Trạng thái trống của màn Tổng quan
  ///
  /// In vi, this message translates to:
  /// **'Chào bạn! Ghi khoản chi đầu tiên để xem tiền của mình đi đâu nhé.'**
  String get emptyOverview;

  /// Trạng thái trống của danh sách giao dịch
  ///
  /// In vi, this message translates to:
  /// **'Chưa có giao dịch nào. Bấm nút + để ghi khoản đầu tiên.'**
  String get emptyTransactions;

  /// Trạng thái trống của màn Báo cáo
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo sẽ hiện ở đây khi bạn có vài giao dịch.'**
  String get emptyReports;

  /// Dòng giới thiệu ở màn Tài khoản khi chưa có ví
  ///
  /// In vi, this message translates to:
  /// **'Quản lý ví, danh mục và cài đặt của bạn tại đây.'**
  String get emptyAccount;

  /// Nút ở trang giới thiệu cuối, chuyển sang Thiết lập
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu'**
  String get onboardingStart;

  /// Tiêu đề trang giới thiệu 1
  ///
  /// In vi, this message translates to:
  /// **'Biết tiền mình đi đâu'**
  String get onboarding1Title;

  /// Mô tả trang giới thiệu 1
  ///
  /// In vi, this message translates to:
  /// **'Ghi chép thu chi chỉ trong vài giây.'**
  String get onboarding1Body;

  /// Tiêu đề trang giới thiệu 2
  ///
  /// In vi, this message translates to:
  /// **'Tự động ghi nhận chuyển khoản'**
  String get onboarding2Title;

  /// Mô tả trang giới thiệu 2
  ///
  /// In vi, this message translates to:
  /// **'Kết nối thông báo ngân hàng, app tự gợi ý giao dịch cho bạn.'**
  String get onboarding2Body;

  /// Tiêu đề trang giới thiệu 3
  ///
  /// In vi, this message translates to:
  /// **'Chi tiêu có kế hoạch'**
  String get onboarding3Title;

  /// Mô tả trang giới thiệu 3
  ///
  /// In vi, this message translates to:
  /// **'Đặt ngân sách, nhận nhắc nhở nhẹ nhàng trước khi tiêu quá tay.'**
  String get onboarding3Body;

  /// Nút bỏ qua phần giới thiệu
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua'**
  String get onboardingSkip;

  /// Nút sang trang/bước tiếp theo
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục'**
  String get onboardingNext;

  /// Nhãn trợ năng cho chấm chỉ trang giới thiệu
  ///
  /// In vi, this message translates to:
  /// **'Trang {current} trên {total}'**
  String onboardingPageLabel(int current, int total);

  /// Nhãn trợ năng của nút quay lại
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get back;

  /// Chỉ bước hiện tại của Thiết lập ban đầu
  ///
  /// In vi, this message translates to:
  /// **'Bước {step}/{total}'**
  String setupStep(int step, int total);

  /// Nhãn trợ năng của thanh tiến độ Thiết lập
  ///
  /// In vi, this message translates to:
  /// **'Tiến độ thiết lập'**
  String get setupProgressLabel;

  /// Tiêu đề Thiết lập bước 1
  ///
  /// In vi, this message translates to:
  /// **'Bạn muốn gọi là gì?'**
  String get setupProfileTitle;

  /// Mô tả Thiết lập bước 1
  ///
  /// In vi, this message translates to:
  /// **'Vài thông tin nhỏ để Ví Xanh hợp với bạn hơn.'**
  String get setupProfileSubtitle;

  /// Nhãn ô nhập tên người dùng
  ///
  /// In vi, this message translates to:
  /// **'Tên của bạn'**
  String get setupNameLabel;

  /// Gợi ý trong ô nhập tên
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ: Minh'**
  String get setupNameHint;

  /// Nhãn chọn đơn vị tiền
  ///
  /// In vi, this message translates to:
  /// **'Đơn vị tiền'**
  String get setupCurrencyLabel;

  /// Lựa chọn đơn vị tiền Việt Nam đồng
  ///
  /// In vi, this message translates to:
  /// **'₫ VND'**
  String get currencyVnd;

  /// Nhãn chọn ngày bắt đầu tháng
  ///
  /// In vi, this message translates to:
  /// **'Ngày bắt đầu tháng tài chính'**
  String get setupMonthStartLabel;

  /// Giá trị ngày bắt đầu tháng đang chọn
  ///
  /// In vi, this message translates to:
  /// **'Ngày {day} hằng tháng'**
  String setupMonthStartValue(int day);

  /// Gợi ý dưới ô chọn ngày bắt đầu tháng
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ: chọn ngày nhận lương'**
  String get setupMonthStartHint;

  /// Nhãn trợ năng nút giảm ngày
  ///
  /// In vi, this message translates to:
  /// **'Lùi một ngày'**
  String get dayDecrease;

  /// Nhãn trợ năng nút tăng ngày
  ///
  /// In vi, this message translates to:
  /// **'Tăng một ngày'**
  String get dayIncrease;

  /// Tiêu đề Thiết lập bước 2
  ///
  /// In vi, this message translates to:
  /// **'Tạo ví đầu tiên'**
  String get setupWalletTitle;

  /// Mô tả Thiết lập bước 2
  ///
  /// In vi, this message translates to:
  /// **'Chọn nơi bạn hay giữ tiền nhất. Thêm ví khác sau cũng được.'**
  String get setupWalletSubtitle;

  /// Snackbar khi hoàn tất Thiết lập thất bại
  ///
  /// In vi, this message translates to:
  /// **'Chưa tạo được ví. Vui lòng thử lại.'**
  String get setupFailed;

  /// Loại ví tiền mặt
  ///
  /// In vi, this message translates to:
  /// **'Tiền mặt'**
  String get walletTypeCash;

  /// Gợi ý dưới loại ví tiền mặt
  ///
  /// In vi, this message translates to:
  /// **'Tiền trong ví, túi'**
  String get walletTypeCashHint;

  /// Loại ví tài khoản ngân hàng
  ///
  /// In vi, this message translates to:
  /// **'Ngân hàng'**
  String get walletTypeBank;

  /// Gợi ý dưới loại ví ngân hàng
  ///
  /// In vi, this message translates to:
  /// **'Vietcombank, MB…'**
  String get walletTypeBankHint;

  /// Loại ví điện tử
  ///
  /// In vi, this message translates to:
  /// **'Ví điện tử'**
  String get walletTypeEwallet;

  /// Gợi ý dưới loại ví điện tử
  ///
  /// In vi, this message translates to:
  /// **'MoMo, ZaloPay…'**
  String get walletTypeEwalletHint;

  /// Loại ví thẻ tín dụng
  ///
  /// In vi, this message translates to:
  /// **'Thẻ tín dụng'**
  String get walletTypeCredit;

  /// Gợi ý dưới loại ví thẻ tín dụng
  ///
  /// In vi, this message translates to:
  /// **'Visa, Mastercard'**
  String get walletTypeCreditHint;

  /// Tên ví điền sẵn khi chọn tiền mặt
  ///
  /// In vi, this message translates to:
  /// **'Tiền mặt'**
  String get walletDefaultNameCash;

  /// Tên ví điền sẵn khi chọn ngân hàng
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản ngân hàng'**
  String get walletDefaultNameBank;

  /// Tên ví điền sẵn khi chọn ví điện tử
  ///
  /// In vi, this message translates to:
  /// **'Ví MoMo'**
  String get walletDefaultNameEwallet;

  /// Tên ví điền sẵn khi chọn thẻ tín dụng
  ///
  /// In vi, this message translates to:
  /// **'Thẻ tín dụng'**
  String get walletDefaultNameCredit;

  /// Nhãn ô nhập số dư ban đầu của ví
  ///
  /// In vi, this message translates to:
  /// **'Số dư hiện tại'**
  String get walletBalanceLabel;

  /// Nhãn ô nhập dư nợ ban đầu của thẻ tín dụng
  ///
  /// In vi, this message translates to:
  /// **'Dư nợ hiện tại'**
  String get walletDebtLabel;

  /// Nhãn ô nhập tên ví
  ///
  /// In vi, this message translates to:
  /// **'Tên ví'**
  String get walletNameLabel;

  /// Lỗi khi tên ví rỗng hoặc quá dài
  ///
  /// In vi, this message translates to:
  /// **'Tên ví cần từ 1 đến 64 ký tự.'**
  String get walletNameInvalid;

  /// Loại giao dịch chi
  ///
  /// In vi, this message translates to:
  /// **'Chi tiêu'**
  String get txnTypeExpense;

  /// Loại giao dịch thu
  ///
  /// In vi, this message translates to:
  /// **'Thu nhập'**
  String get txnTypeIncome;

  /// Loại giao dịch chuyển giữa các ví
  ///
  /// In vi, this message translates to:
  /// **'Chuyển khoản'**
  String get txnTypeTransfer;

  /// Nhãn trợ năng của nhóm tab loại giao dịch
  ///
  /// In vi, this message translates to:
  /// **'Loại giao dịch'**
  String get txnTypeTabsLabel;

  /// Nút lưu giao dịch trên bàn phím số
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get txnSave;

  /// Lưu rồi giữ màn hình để nhập khoản tiếp theo
  ///
  /// In vi, this message translates to:
  /// **'Lưu & thêm tiếp'**
  String get txnSaveMore;

  /// Nhãn trợ năng đọc số tiền đang nhập
  ///
  /// In vi, this message translates to:
  /// **'Số tiền {amount}'**
  String txnAmountLabel(String amount);

  /// Nhãn trợ năng chip số tiền nhanh
  ///
  /// In vi, this message translates to:
  /// **'Nhập nhanh {amount}'**
  String txnQuickAmount(String amount);

  /// Nhãn nhóm chọn danh mục
  ///
  /// In vi, this message translates to:
  /// **'Danh mục'**
  String get txnCategoriesLabel;

  /// Mở danh sách mọi danh mục
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get categoryAll;

  /// Tiêu đề bảng chọn danh mục
  ///
  /// In vi, this message translates to:
  /// **'Chọn danh mục'**
  String get chooseCategory;

  /// Tiêu đề bảng chọn ví
  ///
  /// In vi, this message translates to:
  /// **'Chọn ví'**
  String get chooseWallet;

  /// Nhãn dòng chọn ví
  ///
  /// In vi, this message translates to:
  /// **'Ví'**
  String get txnFieldWallet;

  /// Nhãn ví nguồn khi chuyển khoản
  ///
  /// In vi, this message translates to:
  /// **'Từ ví'**
  String get txnFromWallet;

  /// Nhãn ví đích khi chuyển khoản
  ///
  /// In vi, this message translates to:
  /// **'Đến ví'**
  String get txnToWallet;

  /// Nút đổi chỗ ví nguồn và ví đích
  ///
  /// In vi, this message translates to:
  /// **'Đổi chiều chuyển'**
  String get swapWallets;

  /// Nhãn dòng chọn thời gian
  ///
  /// In vi, this message translates to:
  /// **'Thời gian'**
  String get txnFieldTime;

  /// Ngày và giờ giao dịch, ví dụ 'Hôm nay, 08:15'
  ///
  /// In vi, this message translates to:
  /// **'{day}, {time}'**
  String txnDateTime(String day, String time);

  /// Nhãn ô ghi chú
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get txnNoteLabel;

  /// Gợi ý trong ô ghi chú
  ///
  /// In vi, this message translates to:
  /// **'Thêm ghi chú (vd: cà phê với Lan)'**
  String get txnNoteHint;

  /// Khi chưa chọn được ví
  ///
  /// In vi, this message translates to:
  /// **'Chưa có ví'**
  String get txnNoWallet;

  /// Nhãn trợ năng phím số
  ///
  /// In vi, this message translates to:
  /// **'Số {digit}'**
  String keypadDigit(String digit);

  /// Nhãn trợ năng phím 000
  ///
  /// In vi, this message translates to:
  /// **'Ba số không'**
  String get keypadThousand;

  /// Nhãn trợ năng phím xóa
  ///
  /// In vi, this message translates to:
  /// **'Xóa lùi'**
  String get keypadBackspace;

  /// Nhãn trợ năng phím cộng
  ///
  /// In vi, this message translates to:
  /// **'Cộng thêm khoản'**
  String get keypadPlus;

  /// Nhãn trợ năng phím trừ
  ///
  /// In vi, this message translates to:
  /// **'Trừ bớt'**
  String get keypadMinus;

  /// Thông báo sau khi lưu và thêm tiếp
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu {amount} · {label}'**
  String txnSaved(String amount, String label);

  /// Lỗi khi chưa nhập số tiền
  ///
  /// In vi, this message translates to:
  /// **'Nhập số tiền trước nhé'**
  String get txnErrorAmount;

  /// Lỗi khi chưa chọn danh mục
  ///
  /// In vi, this message translates to:
  /// **'Chọn danh mục trước nhé'**
  String get txnErrorCategory;

  /// Lỗi khi ví không hợp lệ
  ///
  /// In vi, this message translates to:
  /// **'Ví này không còn dùng được, hãy chọn ví khác'**
  String get txnErrorWallet;

  /// Lỗi chuyển khoản thiếu ví hoặc trùng ví
  ///
  /// In vi, this message translates to:
  /// **'Chọn hai ví khác nhau để chuyển khoản'**
  String get txnErrorTransfer;

  /// Lỗi ghi chú vượt độ dài
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú quá dài'**
  String get txnErrorTooLong;

  /// Lỗi chung khi lưu giao dịch
  ///
  /// In vi, this message translates to:
  /// **'Chưa lưu được giao dịch. Vui lòng thử lại.'**
  String get txnSaveFailed;

  /// Lỗi khi không tải được giao dịch để sửa
  ///
  /// In vi, this message translates to:
  /// **'Không mở được giao dịch.'**
  String get txnLoadFailed;

  /// Nút mở ô tìm kiếm giao dịch
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm giao dịch'**
  String get txnSearchTooltip;

  /// Gợi ý trong ô tìm kiếm giao dịch
  ///
  /// In vi, this message translates to:
  /// **'Tìm theo ghi chú, tên, danh mục'**
  String get txnSearchHint;

  /// Nút đóng ô tìm kiếm
  ///
  /// In vi, this message translates to:
  /// **'Đóng tìm kiếm'**
  String get txnSearchClose;

  /// Nút mở bảng chọn danh mục để lọc
  ///
  /// In vi, this message translates to:
  /// **'Lọc theo danh mục'**
  String get txnFilterTooltip;

  /// Nhãn trợ năng nhóm chip lọc
  ///
  /// In vi, this message translates to:
  /// **'Lọc giao dịch'**
  String get txnFilterGroupLabel;

  /// Nhãn trợ năng chip danh mục đang lọc
  ///
  /// In vi, this message translates to:
  /// **'Bỏ lọc {name}'**
  String txnFilterClearCategory(String name);

  /// Chip bỏ lọc loại/ví
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get filterAll;

  /// Nút xem tháng trước
  ///
  /// In vi, this message translates to:
  /// **'Tháng trước'**
  String get previousMonth;

  /// Nút xem tháng sau
  ///
  /// In vi, this message translates to:
  /// **'Tháng sau'**
  String get nextMonth;

  /// Nhãn tháng tài chính đang xem
  ///
  /// In vi, this message translates to:
  /// **'Tháng {month}/{year}'**
  String monthLabel(int month, int year);

  /// Khoảng ngày của kỳ khi tháng không bắt đầu từ ngày 1
  ///
  /// In vi, this message translates to:
  /// **'{from} – {to}'**
  String periodRange(String from, String to);

  /// Tổng thu của kỳ
  ///
  /// In vi, this message translates to:
  /// **'Thu'**
  String get summaryIncome;

  /// Tổng chi của kỳ
  ///
  /// In vi, this message translates to:
  /// **'Chi'**
  String get summaryExpense;

  /// Thu trừ chi của kỳ
  ///
  /// In vi, this message translates to:
  /// **'Còn lại'**
  String get summaryRemaining;

  /// Khi bộ lọc không ra kết quả
  ///
  /// In vi, this message translates to:
  /// **'Không có giao dịch phù hợp với bộ lọc này.'**
  String get txnNoMatch;

  /// Gợi ý cuối danh sách giao dịch
  ///
  /// In vi, this message translates to:
  /// **'Vuốt sang trái một dòng để sửa hoặc xóa'**
  String get txnSwipeHint;

  /// Tiêu đề trạng thái trống của danh sách giao dịch
  ///
  /// In vi, this message translates to:
  /// **'Chưa có giao dịch nào trong tháng này'**
  String get txnEmptyMonthTitle;

  /// Mô tả trạng thái trống của danh sách giao dịch
  ///
  /// In vi, this message translates to:
  /// **'Ghi lại khoản đầu tiên, chỉ mất vài giây thôi.'**
  String get txnEmptyMonthBody;

  /// Nút ở trạng thái trống
  ///
  /// In vi, this message translates to:
  /// **'Thêm giao dịch đầu tiên'**
  String get txnAddFirst;

  /// Hành động sửa khi vuốt dòng giao dịch
  ///
  /// In vi, this message translates to:
  /// **'Sửa'**
  String get txnEdit;

  /// Hành động xóa giao dịch
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get txnDelete;

  /// Snackbar sau khi xóa giao dịch
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa giao dịch'**
  String get txnDeleted;

  /// Lỗi khi xóa giao dịch
  ///
  /// In vi, this message translates to:
  /// **'Chưa xóa được giao dịch.'**
  String get txnDeleteFailed;

  /// Tiêu đề màn chi tiết giao dịch
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết giao dịch'**
  String get txnDetailTitle;

  /// Nút mở màn sửa giao dịch
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa'**
  String get txnEditAction;

  /// Khi giao dịch đã bị xóa
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch này không còn nữa.'**
  String get txnNotFound;

  /// Nhãn dòng nguồn của giao dịch
  ///
  /// In vi, this message translates to:
  /// **'Nguồn'**
  String get txnFieldSource;

  /// Nguồn: người dùng tự nhập
  ///
  /// In vi, this message translates to:
  /// **'Nhập tay'**
  String get txnSourceManual;

  /// Nguồn: đọc từ thông báo ngân hàng
  ///
  /// In vi, this message translates to:
  /// **'Thông báo ngân hàng'**
  String get txnSourceNotification;

  /// Nguồn: webhook ngân hàng
  ///
  /// In vi, this message translates to:
  /// **'Ngân hàng gửi về'**
  String get txnSourceWebhook;

  /// Nguồn: tạo từ giao dịch định kỳ
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch định kỳ'**
  String get txnSourceRecurring;

  /// Nguồn: nhập từ file
  ///
  /// In vi, this message translates to:
  /// **'Nhập từ file'**
  String get txnSourceImport;

  /// Nhãn trợ năng khi danh sách đang tải
  ///
  /// In vi, this message translates to:
  /// **'Đang tải giao dịch'**
  String get txnLoadingLabel;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
