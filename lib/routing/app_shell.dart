import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/gen/app_localizations.dart';
import '../theme/widgets/app_bottom_bar.dart';
import 'routes.dart';

/// Khung 4 tab + nút "+" ở giữa.
///
/// Nút Back Android: đang ở tab khác Tổng quan → về Tổng quan; ở Tổng quan → thoát app.
/// (Màn con trong một tab, ví dụ Cài đặt, được pop trước khi tới đây.)
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _overviewIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final index = navigationShell.currentIndex;
    return PopScope(
      canPop: index == _overviewIndex,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigationShell.goBranch(_overviewIndex);
      },
      child: Scaffold(
        body: navigationShell,
        floatingActionButton: AppAddButton(
          label: l10n.addTransaction,
          onPressed: () => context.push(Routes.addTransaction),
        ),
        floatingActionButtonLocation: AppAddButton.location,
        bottomNavigationBar: AppBottomBar(
          currentIndex: index,
          // Bấm lại tab đang mở → về màn gốc của tab đó.
          onSelect: (i) => navigationShell.goBranch(i, initialLocation: i == index),
          items: [
            AppBottomBarItem(
              label: l10n.tabOverview,
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
            ),
            AppBottomBarItem(
              label: l10n.tabTransactions,
              icon: Icons.format_list_bulleted_rounded,
              selectedIcon: Icons.view_list_rounded,
            ),
            AppBottomBarItem(
              label: l10n.tabReports,
              icon: Icons.bar_chart_rounded,
              selectedIcon: Icons.insert_chart_rounded,
            ),
            AppBottomBarItem(
              label: l10n.tabAccount,
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

/// Chứa navigator của 4 tab, chỉ hiện tab đang chọn và giữ nguyên state các tab còn lại.
///
/// Khác `StatefulShellRoute.indexedStack`: KHÔNG tắt TickerMode của tab ẩn. Riverpod 3 tạm
/// dừng provider của widget có TickerMode tắt; khi tab hiện lại, chuỗi provider bị flush ngay
/// giữa lúc build (lỗi "setState() called during build", số liệu cũ không cập nhật — gặp khi đổi
/// ngày bắt đầu tháng ở Tài khoản rồi quay lại Tổng quan / Báo cáo). Các tab không có animation
/// lặp nên giữ ticker chạy không tốn gì đáng kể.
class BranchStack extends StatelessWidget {
  const BranchStack({required this.currentIndex, required this.children, super.key});

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      for (final (i, child) in children.indexed)
        Offstage(
          offstage: i != currentIndex,
          // Tab ẩn: không nhận focus bàn phím; Offstage đã chặn chạm và ngữ nghĩa.
          child: ExcludeFocus(excluding: i != currentIndex, child: child),
        ),
    ],
  );
}
