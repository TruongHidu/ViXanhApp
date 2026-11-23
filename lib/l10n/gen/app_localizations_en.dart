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

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get homeTotalBalance => 'Total balance';

  @override
  String get homeIncomeMonth => 'Income this month';

  @override
  String get homeExpenseMonth => 'Spent this month';

  @override
  String get hideBalance => 'Hide balances';

  @override
  String get showBalance => 'Show balances';

  @override
  String get homeWallets => 'My wallets';

  @override
  String get seeAll => 'See all';

  @override
  String get homeSpending7Days => 'Spending, last 7 days';

  @override
  String homeSpendingCaption(String total, String average) {
    return 'Total $total · average $average/day';
  }

  @override
  String homeChartDay(String day, String amount) {
    return '$day: spent $amount';
  }

  @override
  String get homeRecent => 'Recent transactions';

  @override
  String weekdayShort(String weekday) {
    String _temp0 = intl.Intl.selectLogic(weekday, {
      '1': 'Mon',
      '2': 'Tue',
      '3': 'Wed',
      '4': 'Thu',
      '5': 'Fri',
      '6': 'Sat',
      '7': 'Sun',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get walletAccountLabel => 'Last 4 digits of account / card (optional)';

  @override
  String get walletAccountHint => '1234';

  @override
  String get walletAccountInvalid => 'Enter exactly the last 4 digits.';

  @override
  String get walletsTitle => 'My wallets';

  @override
  String get walletsTotalAssets => 'Total assets';

  @override
  String get walletsDebt => 'Credit card debt';

  @override
  String get walletsNetWorth => 'Net worth';

  @override
  String get walletAdd => 'Add wallet';

  @override
  String get walletTransferBetween => 'Transfer between wallets';

  @override
  String get walletEditTitle => 'Edit wallet';

  @override
  String get walletSave => 'Save';

  @override
  String get walletSaveFailed => 'Couldn\'t save the wallet. Please try again.';

  @override
  String get walletOptions => 'Wallet options';

  @override
  String get walletArchive => 'Archive wallet';

  @override
  String walletArchiveConfirmTitle(String name) {
    return 'Archive $name?';
  }

  @override
  String get walletArchiveConfirmBody =>
      'The wallet will be hidden from lists and can\'t be picked for new transactions. Past transactions are kept.';

  @override
  String get cancel => 'Cancel';

  @override
  String get walletArchived => 'Wallet archived';

  @override
  String get walletArchiveLast => 'Keep at least one active wallet.';

  @override
  String get walletBalance30Days => 'Balance, last 30 days';

  @override
  String walletChartSummary(
    String from,
    String to,
    String min,
    String minDay,
    String max,
    String maxDay,
  ) {
    return 'Balance chart from $from to $to: lowest $min on $minDay, highest $max on $maxDay';
  }

  @override
  String get walletTransactions => 'Wallet transactions';

  @override
  String get walletNoTransactions => 'No transactions in this wallet yet.';

  @override
  String get walletNotFound => 'This wallet no longer exists.';

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
    return '${value}M';
  }

  @override
  String compactBillion(String value) {
    return '${value}B';
  }

  @override
  String walletTransferTo(String name) {
    return 'Transfer to $name';
  }

  @override
  String walletTransferFrom(String name) {
    return 'Received from $name';
  }

  @override
  String get categoriesTitle => 'Categories';

  @override
  String get categoryTypeTabsLabel => 'Category type';

  @override
  String categorySubCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subcategories',
      one: '1 subcategory',
      zero: 'No subcategories',
    );
    return '$_temp0';
  }

  @override
  String get categoryAddChild => 'Add subcategory';

  @override
  String get categoryAdd => 'Add category';

  @override
  String get categoryEdit => 'Edit category';

  @override
  String categoryEditTooltip(String name) {
    return 'Edit $name';
  }

  @override
  String categoryDragHandle(String name) {
    return 'Hold and drag to reorder $name';
  }

  @override
  String categoryShowChildren(String name) {
    return 'Show subcategories of $name';
  }

  @override
  String get categoryNameLabel => 'Category name';

  @override
  String get categoryNameHint => 'e.g. Pets';

  @override
  String get categoryIconLabel => 'Icon';

  @override
  String get categoryColorLabel => 'Color';

  @override
  String get categoryParentLabel => 'Parent category';

  @override
  String get categoryParentNone => 'None · this is a main category';

  @override
  String get categoryParentLocked => 'This category has subcategories, so it can\'t become one.';

  @override
  String get categorySave => 'Save';

  @override
  String get categoryDelete => 'Delete category';

  @override
  String categoryDeleteConfirmTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get categoryDeleteConfirmBody =>
      'The category and its subcategories will be hidden. Past transactions keep the category name.';

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get categoryErrorName => 'Category name must be 1 to 64 characters.';

  @override
  String get categoryErrorHierarchy =>
      'Categories have at most 2 levels, and a subcategory must match its parent\'s type.';

  @override
  String get categorySaveFailed => 'Couldn\'t save the category. Please try again.';

  @override
  String categoryIconName(String key) {
    String _temp0 = intl.Intl.selectLogic(key, {
      'restaurant': 'Food',
      'directions_car': 'Car',
      'home': 'Home',
      'bolt': 'Electricity',
      'shopping_bag': 'Shopping',
      'sports_esports': 'Entertainment',
      'favorite': 'Health',
      'school': 'Books',
      'redeem': 'Gift',
      'pets': 'Pets',
      'flight': 'Travel',
      'smartphone': 'Phone',
      'other': 'Icon',
    });
    return '$_temp0';
  }

  @override
  String categoryColorName(String index) {
    String _temp0 = intl.Intl.selectLogic(index, {
      '0': 'Peach',
      '1': 'Blue',
      '2': 'Lavender',
      '3': 'Teal',
      '4': 'Pink',
      '5': 'Yellow',
      '6': 'Green',
      '7': 'Light blue',
      '8': 'Moss green',
      '9': 'Ochre',
      'other': 'Color',
    });
    return '$_temp0';
  }

  @override
  String get reportTypeGroup => 'Report type';

  @override
  String get reportPeriodGroup => 'Report period';

  @override
  String get reportPeriodWeek => 'Week';

  @override
  String get reportPeriodMonth => 'Month';

  @override
  String get reportPeriodYear => 'Year';

  @override
  String get reportPeriodCustom => 'Custom';

  @override
  String get previousPeriod => 'Previous period';

  @override
  String get nextPeriod => 'Next period';

  @override
  String reportYearLabel(int year) {
    return 'Year $year';
  }

  @override
  String reportTotal(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {'income': 'Total income', 'other': 'Total spent'});
    return '$_temp0';
  }

  @override
  String get reportOther => 'Other';

  @override
  String reportCategoryRow(String name, String amount, int percent) {
    return '$name: $amount, $percent%';
  }

  @override
  String reportDonutSummary(String total, String top) {
    return '$total. Largest: $top';
  }

  @override
  String reportCompareTitle(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'week': 'Compared with last week',
      'month': 'Compared with last month',
      'year': 'Compared with last year',
      'other': 'Compared with the previous period',
    });
    return '$_temp0';
  }

  @override
  String reportPreviousName(String kind, String month, String year) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'week': 'last week',
      'month': 'month $month',
      'year': '$year',
      'other': 'the previous period',
    });
    return '$_temp0';
  }

  @override
  String reportCompareMore(String type, int percent, String period) {
    String _temp0 = intl.Intl.selectLogic(type, {'income': 'Income', 'other': 'Spending'});
    return '$_temp0 is $percent% higher than $period';
  }

  @override
  String reportCompareLess(String type, int percent, String period) {
    String _temp0 = intl.Intl.selectLogic(type, {'income': 'Income', 'other': 'Spending'});
    return '$_temp0 is $percent% lower than $period';
  }

  @override
  String reportCompareSame(String type, String period) {
    String _temp0 = intl.Intl.selectLogic(type, {'income': 'Income', 'other': 'Spending'});
    return '$_temp0 is the same as $period';
  }

  @override
  String reportSeriesTitle(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'week': 'Income vs spending, 6 weeks',
      'month': 'Income vs spending, 6 months',
      'year': 'Income vs spending, 6 years',
      'other': 'Income vs spending, 6 periods',
    });
    return '$_temp0';
  }

  @override
  String reportSeriesDetail(String period, String income, String expense) {
    return '$period: Income $income · Spent $expense';
  }

  @override
  String reportEmpty(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'income': 'No income in this period yet.',
      'other': 'No spending in this period yet.',
    });
    return '$_temp0';
  }

  @override
  String reportCategoryTitle(String name, String period) {
    return '$name · $period';
  }

  @override
  String get accountDefaultName => 'You';

  @override
  String get accountEditName => 'Edit name';

  @override
  String get accountNameHint => 'Your name';

  @override
  String get accountSave => 'Save';

  @override
  String accountBackedUpAt(String time) {
    return 'Backed up $time';
  }

  @override
  String get accountNotBackedUp => 'Not backed up yet';

  @override
  String get accountGroupManage => 'Manage';

  @override
  String get accountGroupAppearance => 'Appearance';

  @override
  String get accountGroupData => 'Data';

  @override
  String get accountGroupOther => 'Other';

  @override
  String accountWalletCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wallets',
      one: '1 wallet',
    );
    return '$_temp0';
  }

  @override
  String get accountDarkMode => 'Dark mode';

  @override
  String get accountMonthStart => 'Month starts on';

  @override
  String accountMonthStartValue(int day) {
    return 'Day $day';
  }

  @override
  String get accountHideBalance => 'Hide balance on open';

  @override
  String get accountBackup => 'Back up';

  @override
  String get accountBackupNever => 'Never';

  @override
  String get accountBackupHint =>
      'Save the backup file to Drive, a chat app or your device so you never lose data.';

  @override
  String get accountBackupReminder =>
      'It\'s been a while since your last backup. Back up now to keep your data safe.';

  @override
  String get accountBackupDone => 'Backup created';

  @override
  String get accountBackupFailed => 'Couldn\'t back up. Please try again.';

  @override
  String get accountVersion => 'Version';
}
