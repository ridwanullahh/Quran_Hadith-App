import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'theme/app_theme.dart';

/// Notifier that controls light/dark theme mode.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark);

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

/// Provider for the app's theme mode.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// The root application widget.
///
/// Configures [MaterialApp.router] with:
/// - Light and dark themes from [AppTheme]
/// - [GoRouter] via [routerProvider]
/// - RTL as the default text direction
/// - Riverpod [ProviderScope]
class MinhaajulHudaaApp extends ConsumerWidget {
  const MinhaajulHudaaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'MinhaajulHudaa',
      debugShowCheckedModeBanner: false,

      // ── Theme ──────────────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // ── Router ─────────────────────────────────────────────────
      routerConfig: router,

      // ── RTL as default text direction ──────────────────────────
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
