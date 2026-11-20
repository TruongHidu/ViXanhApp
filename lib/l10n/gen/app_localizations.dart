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

  /// Tiêu đề màn chào mừng lần đầu mở app
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng đến với Ví Xanh'**
  String get onboardingTitle;

  /// Mô tả ngắn dưới tiêu đề màn chào mừng
  ///
  /// In vi, this message translates to:
  /// **'Ghi chi tiêu chỉ trong vài giây. Dữ liệu nằm trên máy của bạn, dùng được cả khi mất mạng.'**
  String get onboardingBody;

  /// Nút hoàn tất màn chào mừng
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu'**
  String get onboardingStart;
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
