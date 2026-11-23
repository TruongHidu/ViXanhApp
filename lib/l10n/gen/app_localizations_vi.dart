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

  @override
  String get walletAccountLabel => '4 số cuối tài khoản / thẻ (không bắt buộc)';

  @override
  String get walletAccountHint => '1234';

  @override
  String get walletAccountInvalid => 'Nhập đúng 4 chữ số cuối.';

  @override
  String get walletsTitle => 'Ví của tôi';

  @override
  String get walletsTotalAssets => 'Tổng tài sản';

  @override
  String get walletsDebt => 'Nợ thẻ tín dụng';

  @override
  String get walletsNetWorth => 'Tài sản ròng';

  @override
  String get walletAdd => 'Thêm ví';

  @override
  String get walletTransferBetween => 'Chuyển tiền giữa các ví';

  @override
  String get walletEditTitle => 'Sửa ví';

  @override
  String get walletSave => 'Lưu';

  @override
  String get walletSaveFailed => 'Chưa lưu được ví. Vui lòng thử lại.';

  @override
  String get walletOptions => 'Tùy chọn ví';

  @override
  String get walletArchive => 'Lưu trữ ví';

  @override
  String walletArchiveConfirmTitle(String name) {
    return 'Lưu trữ ví $name?';
  }

  @override
  String get walletArchiveConfirmBody =>
      'Ví sẽ ẩn khỏi danh sách và không chọn được khi thêm giao dịch. Giao dịch cũ vẫn được giữ.';

  @override
  String get cancel => 'Hủy';

  @override
  String get walletArchived => 'Đã lưu trữ ví';

  @override
  String get walletArchiveLast => 'Cần giữ ít nhất một ví đang dùng.';

  @override
  String get walletBalance30Days => 'Số dư 30 ngày';

  @override
  String walletChartSummary(
    String from,
    String to,
    String min,
    String minDay,
    String max,
    String maxDay,
  ) {
    return 'Biểu đồ số dư từ $from đến $to: thấp nhất $min ngày $minDay, cao nhất $max ngày $maxDay';
  }

  @override
  String get walletTransactions => 'Giao dịch của ví';

  @override
  String get walletNoTransactions => 'Ví này chưa có giao dịch nào.';

  @override
  String get walletNotFound => 'Ví này không còn nữa.';

  @override
  String walletTypeAndAccount(String type, String account) {
    return '$type · $account';
  }

  @override
  String compactThousand(String value) {
    return '${value}k';
  }

  @override
  String compactMillion(String value) {
    return '$value tr';
  }

  @override
  String compactBillion(String value) {
    return '$value tỷ';
  }

  @override
  String walletTransferTo(String name) {
    return 'Chuyển sang $name';
  }

  @override
  String walletTransferFrom(String name) {
    return 'Nhận từ $name';
  }

  @override
  String get categoriesTitle => 'Danh mục';

  @override
  String get categoryTypeTabsLabel => 'Loại danh mục';

  @override
  String categorySubCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mục con',
      zero: 'Chưa có mục con',
    );
    return '$_temp0';
  }

  @override
  String get categoryAddChild => 'Thêm mục con';

  @override
  String get categoryAdd => 'Thêm danh mục';

  @override
  String get categoryEdit => 'Sửa danh mục';

  @override
  String categoryEditTooltip(String name) {
    return 'Sửa $name';
  }

  @override
  String categoryDragHandle(String name) {
    return 'Giữ và kéo để sắp xếp $name';
  }

  @override
  String categoryShowChildren(String name) {
    return 'Xem mục con của $name';
  }

  @override
  String get categoryNameLabel => 'Tên danh mục';

  @override
  String get categoryNameHint => 'Ví dụ: Thú cưng';

  @override
  String get categoryIconLabel => 'Biểu tượng';

  @override
  String get categoryColorLabel => 'Màu';

  @override
  String get categoryParentLabel => 'Danh mục cha';

  @override
  String get categoryParentNone => 'Không có · đây là danh mục chính';

  @override
  String get categoryParentLocked => 'Danh mục đang có mục con nên không thể làm mục con.';

  @override
  String get categorySave => 'Lưu';

  @override
  String get categoryDelete => 'Xóa danh mục';

  @override
  String categoryDeleteConfirmTitle(String name) {
    return 'Xóa danh mục $name?';
  }

  @override
  String get categoryDeleteConfirmBody =>
      'Danh mục và các mục con sẽ bị ẩn. Giao dịch cũ vẫn giữ tên danh mục.';

  @override
  String get categoryDeleted => 'Đã xóa danh mục';

  @override
  String get categoryErrorName => 'Tên danh mục cần từ 1 đến 64 ký tự.';

  @override
  String get categoryErrorHierarchy =>
      'Danh mục chỉ có tối đa 2 cấp và mục con phải cùng loại với danh mục cha.';

  @override
  String get categorySaveFailed => 'Chưa lưu được danh mục. Vui lòng thử lại.';

  @override
  String categoryIconName(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'restaurant': 'Ăn uống',
      'directions_car': 'Xe',
      'home': 'Nhà',
      'bolt': 'Điện',
      'shopping_bag': 'Mua sắm',
      'sports_esports': 'Giải trí',
      'favorite': 'Sức khỏe',
      'school': 'Sách',
      'redeem': 'Quà',
      'pets': 'Thú cưng',
      'flight': 'Du lịch',
      'smartphone': 'Điện thoại',
      'other': 'Biểu tượng',
    });
    return '$_temp0';
  }

  @override
  String categoryColorName(String index) {
    String _temp0 = intl.Intl.selectLogic(index, {
      '0': 'Màu cam đào',
      '1': 'Màu xanh dương',
      '2': 'Màu tím oải hương',
      '3': 'Màu xanh ngọc',
      '4': 'Màu hồng',
      '5': 'Màu vàng',
      '6': 'Màu xanh lá',
      '7': 'Màu xanh lam nhạt',
      '8': 'Màu xanh rêu',
      '9': 'Màu vàng đất',
      'other': 'Màu',
    });
    return '$_temp0';
  }

  @override
  String get reportTypeGroup => 'Loại báo cáo';

  @override
  String get reportPeriodGroup => 'Kỳ báo cáo';

  @override
  String get reportPeriodWeek => 'Tuần';

  @override
  String get reportPeriodMonth => 'Tháng';

  @override
  String get reportPeriodYear => 'Năm';

  @override
  String get reportPeriodCustom => 'Tùy chọn';

  @override
  String get previousPeriod => 'Kỳ trước';

  @override
  String get nextPeriod => 'Kỳ sau';

  @override
  String reportYearLabel(int year) {
    return 'Năm $year';
  }

  @override
  String reportTotal(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {'income': 'Tổng thu', 'other': 'Tổng chi'});
    return '$_temp0';
  }

  @override
  String get reportOther => 'Khác';

  @override
  String reportCategoryRow(String name, String amount, int percent) {
    return '$name: $amount, $percent%';
  }

  @override
  String reportDonutSummary(String total, String top) {
    return '$total. Lớn nhất: $top';
  }

  @override
  String reportCompareTitle(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'week': 'So với tuần trước',
      'month': 'So với tháng trước',
      'year': 'So với năm trước',
      'other': 'So với kỳ trước',
    });
    return '$_temp0';
  }

  @override
  String reportPreviousName(String kind, String month, String year) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'week': 'tuần trước',
      'month': 'tháng $month',
      'year': 'năm $year',
      'other': 'kỳ trước',
    });
    return '$_temp0';
  }

  @override
  String reportCompareMore(String type, int percent, String period) {
    String _temp0 = intl.Intl.selectLogic(type, {'income': 'Thu', 'other': 'Chi'});
    return '$_temp0 nhiều hơn $percent% so với $period';
  }

  @override
  String reportCompareLess(String type, int percent, String period) {
    String _temp0 = intl.Intl.selectLogic(type, {'income': 'Thu', 'other': 'Chi'});
    return '$_temp0 ít hơn $percent% so với $period';
  }

  @override
  String reportCompareSame(String type, String period) {
    String _temp0 = intl.Intl.selectLogic(type, {'income': 'Thu', 'other': 'Chi'});
    return '$_temp0 bằng $period';
  }

  @override
  String reportSeriesTitle(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'week': 'Thu – chi 6 tuần',
      'month': 'Thu – chi 6 tháng',
      'year': 'Thu – chi 6 năm',
      'other': 'Thu – chi 6 kỳ',
    });
    return '$_temp0';
  }

  @override
  String reportSeriesDetail(String period, String income, String expense) {
    return '$period: Thu $income · Chi $expense';
  }

  @override
  String reportEmpty(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'income': 'Chưa có khoản thu nào trong kỳ này.',
      'other': 'Chưa có khoản chi nào trong kỳ này.',
    });
    return '$_temp0';
  }

  @override
  String reportCategoryTitle(String name, String period) {
    return '$name · $period';
  }

  @override
  String get accountDefaultName => 'Bạn';

  @override
  String get accountEditName => 'Sửa tên';

  @override
  String get accountNameHint => 'Tên của bạn';

  @override
  String get accountSave => 'Lưu';

  @override
  String accountBackedUpAt(String time) {
    return 'Đã sao lưu lúc $time';
  }

  @override
  String get accountNotBackedUp => 'Chưa sao lưu';

  @override
  String get accountGroupManage => 'Quản lý';

  @override
  String get accountGroupAppearance => 'Giao diện';

  @override
  String get accountGroupData => 'Dữ liệu';

  @override
  String get accountGroupOther => 'Khác';

  @override
  String accountWalletCount(int count) {
    return '$count ví';
  }

  @override
  String get accountDarkMode => 'Chế độ tối';

  @override
  String get accountMonthStart => 'Ngày bắt đầu tháng';

  @override
  String accountMonthStartValue(int day) {
    return 'Ngày $day';
  }

  @override
  String get accountHideBalance => 'Ẩn số dư khi mở app';

  @override
  String get accountBackup => 'Sao lưu';

  @override
  String get accountBackupNever => 'Chưa có';

  @override
  String get accountBackupHint => 'Lưu file sao lưu lên Drive, Zalo hoặc máy để không mất dữ liệu.';

  @override
  String get accountBackupReminder =>
      'Đã lâu chưa sao lưu. Sao lưu ngay để giữ an toàn dữ liệu nhé.';

  @override
  String get accountBackupDone => 'Đã tạo bản sao lưu';

  @override
  String get accountBackupFailed => 'Không sao lưu được. Vui lòng thử lại.';

  @override
  String get accountVersion => 'Phiên bản';
}
