// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vi Xanh';

  @override
  String get homeTitle => 'Overview';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeMode => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageVi => 'Tiếng Việt';

  @override
  String get languageEn => 'English';

  @override
  String get settingsSaveFailed => 'Couldn\'t save settings. Please try again.';

  @override
  String get tabOverview => 'Overview';

  @override
  String get tabTransactions => 'Transactions';

  @override
  String get tabReports => 'Reports';

  @override
  String get tabAccount => 'Account';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get undo => 'Undo';

  @override
  String get emptyOverview => 'Hi there! Add your first expense to see where your money goes.';

  @override
  String get emptyTransactions => 'No transactions yet. Tap + to add your first one.';

  @override
  String get emptyReports => 'Reports will show up here once you have a few transactions.';

  @override
  String get emptyAccount => 'Manage your wallets, categories and settings here.';

  @override
  String get onboardingTitle => 'Welcome to Vi Xanh';

  @override
  String get onboardingBody =>
      'Log expenses in seconds. Your data stays on your device and works offline.';

  @override
  String get onboardingStart => 'Get started';
}
