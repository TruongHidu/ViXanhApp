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
  String get onboardingStart => 'Get started';

  @override
  String get onboarding1Title => 'Know where your money goes';

  @override
  String get onboarding1Body => 'Log income and expenses in seconds.';

  @override
  String get onboarding2Title => 'Transfers recorded automatically';

  @override
  String get onboarding2Body =>
      'Connect bank notifications and the app suggests transactions for you.';

  @override
  String get onboarding3Title => 'Spend with a plan';

  @override
  String get onboarding3Body => 'Set budgets and get gentle reminders before you overspend.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Continue';

  @override
  String onboardingPageLabel(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get back => 'Back';

  @override
  String setupStep(int step, int total) {
    return 'Step $step/$total';
  }

  @override
  String get setupProgressLabel => 'Setup progress';

  @override
  String get setupProfileTitle => 'What should we call you?';

  @override
  String get setupProfileSubtitle => 'A few details to make Vi Xanh fit you better.';

  @override
  String get setupNameLabel => 'Your name';

  @override
  String get setupNameHint => 'e.g. Minh';

  @override
  String get setupCurrencyLabel => 'Currency';

  @override
  String get currencyVnd => '₫ VND';

  @override
  String get setupMonthStartLabel => 'Start day of your financial month';

  @override
  String setupMonthStartValue(int day) {
    return 'Day $day of each month';
  }

  @override
  String get setupMonthStartHint => 'Tip: pick your payday';

  @override
  String get dayDecrease => 'Previous day';

  @override
  String get dayIncrease => 'Next day';

  @override
  String get setupWalletTitle => 'Create your first wallet';

  @override
  String get setupWalletSubtitle =>
      'Pick where you keep most of your money. You can add more later.';

  @override
  String get setupFailed => 'Couldn\'t create the wallet. Please try again.';

  @override
  String get walletTypeCash => 'Cash';

  @override
  String get walletTypeCashHint => 'Money in your pocket';

  @override
  String get walletTypeBank => 'Bank';

  @override
  String get walletTypeBankHint => 'Vietcombank, MB…';

  @override
  String get walletTypeEwallet => 'E-wallet';

  @override
  String get walletTypeEwalletHint => 'MoMo, ZaloPay…';

  @override
  String get walletTypeCredit => 'Credit card';

  @override
  String get walletTypeCreditHint => 'Visa, Mastercard';

  @override
  String get walletDefaultNameCash => 'Cash';

  @override
  String get walletDefaultNameBank => 'Bank account';

  @override
  String get walletDefaultNameEwallet => 'MoMo wallet';

  @override
  String get walletDefaultNameCredit => 'Credit card';

  @override
  String get walletBalanceLabel => 'Current balance';

  @override
  String get walletDebtLabel => 'Current debt';

  @override
  String get walletNameLabel => 'Wallet name';

  @override
  String get walletNameInvalid => 'Wallet name must be 1 to 64 characters.';

  @override
  String get txnTypeExpense => 'Expense';

  @override
  String get txnTypeIncome => 'Income';

  @override
  String get txnTypeTransfer => 'Transfer';

  @override
  String get txnTypeTabsLabel => 'Transaction type';

  @override
  String get txnSave => 'Save';

  @override
  String get txnSaveMore => 'Save & add more';

  @override
  String txnAmountLabel(String amount) {
    return 'Amount $amount';
  }

  @override
  String txnQuickAmount(String amount) {
    return 'Quick amount $amount';
  }

  @override
  String get txnCategoriesLabel => 'Category';

  @override
  String get categoryAll => 'All';

  @override
  String get chooseCategory => 'Choose category';

  @override
  String get chooseWallet => 'Choose wallet';

  @override
  String get txnFieldWallet => 'Wallet';

  @override
  String get txnFromWallet => 'From';

  @override
  String get txnToWallet => 'To';

  @override
  String get swapWallets => 'Swap direction';

  @override
  String get txnFieldTime => 'Time';

  @override
  String txnDateTime(String day, String time) {
    return '$day, $time';
  }

  @override
  String get txnNoteLabel => 'Note';

  @override
  String get txnNoteHint => 'Add a note (e.g. coffee with Lan)';

  @override
  String get txnNoWallet => 'No wallet';

  @override
  String keypadDigit(String digit) {
    return 'Digit $digit';
  }

  @override
  String get keypadThousand => 'Triple zero';

  @override
  String get keypadBackspace => 'Backspace';

  @override
  String get keypadPlus => 'Add another amount';

  @override
  String get keypadMinus => 'Subtract';

  @override
  String txnSaved(String amount, String label) {
    return 'Saved $amount · $label';
  }

  @override
  String get txnErrorAmount => 'Enter an amount first';

  @override
  String get txnErrorCategory => 'Pick a category first';

  @override
  String get txnErrorWallet => 'This wallet can\'t be used anymore, pick another one';

  @override
  String get txnErrorTransfer => 'Pick two different wallets to transfer';

  @override
  String get txnErrorTooLong => 'The note is too long';

  @override
  String get txnSaveFailed => 'Couldn\'t save the transaction. Please try again.';

  @override
  String get txnLoadFailed => 'Couldn\'t open the transaction.';

  @override
  String get txnSearchTooltip => 'Search transactions';

  @override
  String get txnSearchHint => 'Search notes, names, categories';

  @override
  String get txnSearchClose => 'Close search';

  @override
  String get txnFilterTooltip => 'Filter by category';

  @override
  String get txnFilterGroupLabel => 'Filter transactions';

  @override
  String txnFilterClearCategory(String name) {
    return 'Clear filter $name';
  }

  @override
  String get filterAll => 'All';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String monthLabel(int month, int year) {
    return '$month/$year';
  }

  @override
  String periodRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get summaryIncome => 'Income';

  @override
  String get summaryExpense => 'Expense';

  @override
  String get summaryRemaining => 'Remaining';

  @override
  String get txnNoMatch => 'No transactions match this filter.';

  @override
  String get txnSwipeHint => 'Swipe a row left to edit or delete';

  @override
  String get txnEmptyMonthTitle => 'No transactions this month yet';

  @override
  String get txnEmptyMonthBody => 'Log your first one — it only takes a few seconds.';

  @override
  String get txnAddFirst => 'Add your first transaction';

  @override
  String get txnEdit => 'Edit';

  @override
  String get txnDelete => 'Delete';

  @override
  String get txnDeleted => 'Transaction deleted';

  @override
  String get txnDeleteFailed => 'Couldn\'t delete the transaction.';

  @override
  String get txnDetailTitle => 'Transaction details';

  @override
  String get txnEditAction => 'Edit';

  @override
  String get txnNotFound => 'This transaction no longer exists.';

  @override
  String get txnFieldSource => 'Source';

  @override
  String get txnSourceManual => 'Entered manually';

  @override
  String get txnSourceNotification => 'Bank notification';

  @override
  String get txnSourceWebhook => 'Sent by bank';

  @override
  String get txnSourceRecurring => 'Recurring transaction';

  @override
  String get txnSourceImport => 'Imported from file';

  @override
  String get txnLoadingLabel => 'Loading transactions';
}
