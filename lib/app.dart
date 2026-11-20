import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/settings/presentation/settings_notifier.dart';
import 'l10n/gen/app_localizations.dart';
import 'routing/router.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

/// Cây widget không biết DI/flavor — chỉ đọc provider.
class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Warm-up sau khung hình đầu — không bao giờ chặn khởi động.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Lỗi khởi tạo thông báo không chặn app, nhưng không được nuốt im lặng:
      // chuyển cho FlutterError.onError (đã nối vào CrashLog trong bootstrap).
      unawaited(
        ref
            .read(notificationServiceProvider)
            .init()
            .catchError(
              (Object e, StackTrace s) => FlutterError.reportError(
                FlutterErrorDetails(exception: e, stack: s, library: 'notification init'),
              ),
            ),
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        // Flush trạng thái bền vững tại đây (OS có thể kill app ở nền).
        break;
      case AppLifecycleState.resumed:
        // Đọc lại trạng thái phụ thuộc thời gian (khoá bảo mật, ngày hiện tại...).
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(appPreferencesProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: prefs.themeMode,
      locale: switch (prefs.localeCode) {
        final code? => Locale(code),
        null => null,
      },
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(routerProvider),
    );
  }
}
