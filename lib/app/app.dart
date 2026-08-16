import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'theme/app_theme.dart';
import '../core/services/popup/popup_overlay.dart';
import '../features/settings/presentation/providers/theme_provider.dart';

/// The root application widget.
///
/// Configures [MaterialApp.router] with:
/// - Light, Dark, and Amoled themes from [AppTheme]
/// - [GoRouter] via [routerProvider]
/// - RTL as the default text direction
/// - Riverpod [ProviderScope]
class MinhaajulHudaaApp extends ConsumerWidget {
  const MinhaajulHudaaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    // Map AppThemeMode → Flutter's ThemeMode + select the correct ThemeData
    final ThemeMode flutterThemeMode;
    final ThemeData activeTheme;

    switch (appThemeMode) {
      case AppThemeMode.light:
        flutterThemeMode = ThemeMode.light;
        activeTheme = AppTheme.lightTheme;
      case AppThemeMode.dark:
        flutterThemeMode = ThemeMode.dark;
        activeTheme = AppTheme.darkTheme;
      case AppThemeMode.amoled:
        flutterThemeMode = ThemeMode.dark;
        activeTheme = AppTheme.amoledTheme;
    }

    return MaterialApp.router(
      title: 'MinhaajulHudaa',
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: activeTheme,
      themeMode: flutterThemeMode,

      // ── Router ─────────────────────────────────────────────────
      routerConfig: router,

      // ── RTL as default text direction ──────────────────────────
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: PopupOverlay(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
