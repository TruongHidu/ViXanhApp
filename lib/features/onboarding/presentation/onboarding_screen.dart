import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/tokens.dart';
import 'setup_notifier.dart';
import 'setup_view.dart';
import 'widgets/onboarding_illustration.dart';

/// Luồng chào mừng: 3 trang giới thiệu → Thiết lập (thông tin, ví đầu tiên).
/// Xong thiết lập thì router tự chuyển sang Tổng quan (cờ onboardingCompleted).
///
/// Back Android: bước 2 → bước 1 → trang 3 → trang trước … → trang 1 thì thoát app.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _pageCount = 3;
  static const _lastPage = _pageCount - 1;
  static const _pageTransition = Duration(milliseconds: 280);

  PageController _pages = PageController();
  int _page = 0;
  bool _inSetup = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _goToPage(int page) =>
      _pages.animateToPage(page, duration: _pageTransition, curve: Curves.easeOutCubic);

  void _startSetup() => setState(() => _inSetup = true);

  void _backFromSetup() {
    if (ref.read(setupNotifierProvider.notifier).back()) return;
    // Đang ở bước 1 → về trang giới thiệu cuối (PageView được dựng lại tại trang đó).
    setState(() {
      _pages.dispose();
      _pages = PageController(initialPage: _lastPage);
      _page = _lastPage;
      _inSetup = false;
    });
  }

  void _handleBack() {
    if (_inSetup) {
      _backFromSetup();
    } else if (_page > 0) {
      _goToPage(_page - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Giữ state Thiết lập sống suốt luồng (kể cả khi quay lại trang giới thiệu).
    ref.watch(setupNotifierProvider.select((s) => s.step));
    return PopScope(
      canPop: !_inSetup && _page == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        body: SafeArea(
          child: _inSetup
              ? SetupView(onBack: _backFromSetup)
              : _IntroPager(
                  controller: _pages,
                  page: _page,
                  onPageChanged: (page) => setState(() => _page = page),
                  onNext: () => _goToPage(_page + 1),
                  onSkip: () => _goToPage(_lastPage),
                  onBack: () => _goToPage(_page - 1),
                  onStart: _startSetup,
                ),
        ),
      ),
    );
  }
}

class _IntroPager extends StatelessWidget {
  const _IntroPager({
    required this.controller,
    required this.page,
    required this.onPageChanged,
    required this.onNext,
    required this.onSkip,
    required this.onBack,
    required this.onStart,
  });

  final PageController controller;
  final int page;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onBack;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final isLast = page == _OnboardingScreenState._lastPage;
    final pages = [
      (OnboardingArt.record, l10n.onboarding1Title, l10n.onboarding1Body),
      (OnboardingArt.autoSync, l10n.onboarding2Title, l10n.onboarding2Body),
      (OnboardingArt.plan, l10n.onboarding3Title, l10n.onboarding3Body),
    ];

    return Column(
      children: [
        SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                if (isLast)
                  IconButton(
                    tooltip: l10n.back,
                    onPressed: onBack,
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                const Spacer(),
                if (!isLast)
                  TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(foregroundColor: colors.textSecondary),
                    child: Text(l10n.onboardingSkip),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: PageView(
            controller: controller,
            onPageChanged: onPageChanged,
            children: [
              for (final (art, title, body) in pages)
                _IntroPage(art: art, title: title, body: body),
            ],
          ),
        ),
        Semantics(
          label: l10n.onboardingPageLabel(page + 1, pages.length),
          child: ExcludeSemantics(
            child: _PageDots(count: pages.length, current: page),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenGutter,
            0,
            AppSpacing.screenGutter,
            AppSpacing.lg,
          ),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isLast ? onStart : onNext,
              child: Text(isLast ? l10n.onboardingStart : l10n.onboardingNext),
            ),
          ),
        ),
      ],
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.art, required this.title, required this.body});

  final OnboardingArt art;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final artSize = [
          320.0,
          constraints.maxWidth - 2 * AppSpacing.screenGutter,
          constraints.maxHeight * 0.55,
        ].reduce((a, b) => a < b ? a : b).clamp(120.0, 320.0);
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OnboardingIllustration(art: art, size: artSize),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                  child: Column(
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(fontSize: 26, height: 1.3),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        body,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            width: i == current ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == current ? scheme.primary : scheme.outlineVariant,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
          ),
      ],
    );
  }
}
