import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/enums.dart';
import '../core/financial_month.dart';
import '../core/ids.dart';
import '../features/categories/presentation/categories_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/reports/presentation/report_category_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/settings/presentation/account_screen.dart';
import '../features/settings/presentation/settings_notifier.dart';
import '../features/transactions/presentation/add_transaction_screen.dart';
import '../features/transactions/presentation/transaction_detail_screen.dart';
import '../features/transactions/presentation/transactions_screen.dart';
import '../features/wallets/presentation/wallet_detail_screen.dart';
import '../features/wallets/presentation/wallet_form_screen.dart';
import '../features/wallets/presentation/wallets_screen.dart';
import 'app_shell.dart';
import 'routes.dart';

/// Router sống suốt vòng đời app: đổi cài đặt KHÔNG tạo lại GoRouter (mất stack điều hướng),
/// mà chỉ báo `refreshListenable` để chạy lại `redirect`.
final routerProvider = Provider<GoRouter>((ref) {
  // Key tạo trong provider (không để global) để mỗi router — kể cả trong test — có key riêng.
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  GlobalKey<NavigatorState> branchKey(String label) => GlobalKey<NavigatorState>(debugLabel: label);

  final onboardingDone = ValueNotifier<bool>(ref.read(appPreferencesProvider).onboardingCompleted);
  ref.listen(
    appPreferencesProvider.select((p) => p.onboardingCompleted),
    (_, done) => onboardingDone.value = done,
  );

  final router = GoRouter(
    navigatorKey: rootKey,
    initialLocation: Routes.overview,
    refreshListenable: onboardingDone,
    redirect: (context, state) {
      final atOnboarding = state.matchedLocation == Routes.onboarding;
      if (!onboardingDone.value) return atOnboarding ? null : Routes.onboarding;
      return atOnboarding ? Routes.overview : null;
    },
    routes: [
      GoRoute(path: Routes.onboarding, builder: (context, state) => const OnboardingScreen()),
      StatefulShellRoute(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        navigatorContainerBuilder: (context, shell, children) =>
            BranchStack(currentIndex: shell.currentIndex, children: children),
        branches: [
          StatefulShellBranch(
            navigatorKey: branchKey('overview'),
            routes: [
              GoRoute(path: Routes.overview, builder: (context, state) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: branchKey('transactions'),
            routes: [
              GoRoute(
                path: Routes.transactions,
                builder: (context, state) => const TransactionsScreen(),
                routes: [
                  GoRoute(
                    path: Routes.transactionDetailSegment,
                    // Che cả thanh điều hướng (thiết kế màn chi tiết không có tab, và nút "+" nổi
                    // không được đè lên hai nút Xóa / Chỉnh sửa).
                    parentNavigatorKey: rootKey,
                    builder: (context, state) => TransactionDetailScreen(
                      id: TransactionId(state.pathParameters[Routes.idParam]!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: branchKey('reports'),
            routes: [
              GoRoute(
                path: Routes.reports,
                builder: (context, state) => const ReportsScreen(),
                routes: [
                  GoRoute(
                    path: Routes.reportCategorySegment,
                    parentNavigatorKey: rootKey,
                    builder: (context, state) {
                      final q = state.uri.queryParameters;
                      DateTime at(String key) =>
                          DateTime.fromMillisecondsSinceEpoch(int.tryParse(q[key] ?? '') ?? 0);
                      return ReportCategoryScreen(
                        categoryId: CategoryId(state.pathParameters[Routes.idParam]!),
                        range: DateRange(at(Routes.fromParam), at(Routes.toParam)),
                        type:
                            TransactionType.values.asNameMap()[q[Routes.typeParam]] ??
                            TransactionType.expense,
                        title: q[Routes.titleParam] ?? '',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: branchKey('account'),
            routes: [
              GoRoute(
                path: Routes.account,
                builder: (context, state) => const AccountScreen(),
                routes: [
                  GoRoute(
                    path: Routes.categoriesSegment,
                    parentNavigatorKey: rootKey,
                    builder: (context, state) => const CategoriesScreen(),
                  ),
                  // Ví phủ lên khung tab: thiết kế không có thanh điều hướng ở các màn này.
                  GoRoute(
                    path: Routes.walletsSegment,
                    parentNavigatorKey: rootKey,
                    builder: (context, state) => const WalletsScreen(),
                    routes: [
                      GoRoute(
                        path: Routes.walletDetailSegment,
                        parentNavigatorKey: rootKey,
                        builder: (context, state) =>
                            WalletDetailScreen(id: WalletId(state.pathParameters[Routes.idParam]!)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.addTransaction,
        parentNavigatorKey: rootKey,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: AddTransactionScreen(
            initialType: switch (state.uri.queryParameters[Routes.typeParam]) {
              final type? => TransactionType.values.asNameMap()[type] ?? TransactionType.expense,
              null => TransactionType.expense,
            },
          ),
        ),
      ),
      GoRoute(
        path: Routes.newWallet,
        parentNavigatorKey: rootKey,
        pageBuilder: (context, state) =>
            const MaterialPage(fullscreenDialog: true, child: WalletFormScreen()),
      ),
      GoRoute(
        path: Routes.editWalletPattern,
        parentNavigatorKey: rootKey,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: WalletFormScreen(walletId: WalletId(state.pathParameters[Routes.idParam]!)),
        ),
      ),
      GoRoute(
        path: Routes.editTransactionPattern,
        parentNavigatorKey: rootKey,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: AddTransactionScreen(
            transactionId: TransactionId(state.pathParameters[Routes.idParam]!),
          ),
        ),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    onboardingDone.dispose();
  });
  return router;
});
