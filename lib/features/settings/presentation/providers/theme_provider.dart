import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Extended theme modes supporting Light, Dark, and Amoled (true black).
enum AppThemeMode {
  light('Light'),
  dark('Dark'),
  amoled('Amoled (Black)');

  const AppThemeMode(this.label);
  final String label;
}

/// Persists the user's theme preference and provides the correct
/// [ThemeData] (including the Amoled variant).
///
/// Defaults to [AppThemeMode.light] as requested by the product brief
/// ("light by default and support dark mode"). Users can switch to Dark
/// or Amoled from the Settings screen; the choice is persisted via Hive.
class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  ThemeModeNotifier() : super(AppThemeMode.light);

  void setThemeMode(AppThemeMode mode) {
    state = mode;
  }

  void toggleTheme() {
    switch (state) {
      case AppThemeMode.light:
        state = AppThemeMode.dark;
      case AppThemeMode.dark:
        state = AppThemeMode.amoled;
      case AppThemeMode.amoled:
        state = AppThemeMode.light;
    }
  }

  /// Convert the persisted string back to [AppThemeMode].
  /// Defaults to light for any unrecognized value (including legacy
  /// "dark" installs — those users will see light on first launch
  /// after this update, then can switch back to dark from Settings).
  static AppThemeMode fromString(String value) {
    switch (value) {
      case 'dark':
        return AppThemeMode.dark;
      case 'amoled':
        return AppThemeMode.amoled;
      case 'light':
      default:
        return AppThemeMode.light;
    }
  }

  /// Convert to a string for Hive persistence.
  static String toStringValue(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.amoled:
        return 'amoled';
    }
  }
}

/// Provider for the extended theme mode (Light / Dark / Amoled).
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, AppThemeMode>(
  (ref) => ThemeModeNotifier(),
);

/// Convenience provider that maps [AppThemeMode] → Flutter's [ThemeMode]
/// for [MaterialApp.router]'s `themeMode` property.
///
/// Both Dark and Amoled map to [ThemeMode.dark] so Flutter picks the
/// `darkTheme` from [MinhaajulHudaaApp]. The actual ThemeData (dark vs
/// amoled) is resolved by [selectedThemeProvider].
final flutterThemeModeProvider = Provider<ThemeMode>((ref) {
  final mode = ref.watch(themeModeProvider);
  return mode == AppThemeMode.light ? ThemeMode.light : ThemeMode.dark;
});
