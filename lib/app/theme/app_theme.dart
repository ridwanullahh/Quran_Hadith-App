import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Complete Material 3 theme configuration for MinhaajulHudaa.
///
/// Provides both [lightTheme] and [darkTheme] with:
/// - Custom Arabic (Amiri, ScheherazadeNew) and Latin (Inter) typography
/// - Card, AppBar, BottomNavigationBar, ElevatedButton, and InputDecoration themes
/// - RTL-friendly defaults

class AppTheme {
  AppTheme._();

  // ── Font Families ──────────────────────────────────────────────

  static const String arabicFontFamily = 'Amiri';
  static const String arabicHeaderFontFamily = 'ScheherazadeNew';
  static const String latinFontFamily = 'Inter';

  // ── Light Theme ────────────────────────────────────────────────

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFB8E8DE),
      onPrimaryContainer: const Color(0xFF00201A),
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFFCEFC8),
      onSecondaryContainer: const Color(0xFF2D2000),
      tertiary: const Color(0xFF4A6363),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFCCE8E8),
      onTertiaryContainer: const Color(0xFF051F1F),
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: const Color(0xFFF9DEDC),
      onErrorContainer: const Color(0xFF410E0B),
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerHighest: AppColors.lightSurfaceVariant,
      outline: AppColors.lightBorder,
      outlineVariant: const Color(0xFFD1CFC6),
      shadow: AppColors.shadow,
      scrim: AppColors.scrim,
      inverseSurface: const Color(0xFF2F3033),
      inversePrimary: const Color(0xFF5EDBC3),
    );

    return _buildTheme(colorScheme, isDark: false);
  }

  // ── Dark Theme ─────────────────────────────────────────────────

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.primaryLight,
      onPrimary: const Color(0xFF00382D),
      primaryContainer: const Color(0xFF005240),
      onPrimaryContainer: const Color(0xFFB8E8DE),
      secondary: AppColors.secondaryLight,
      onSecondary: const Color(0xFF3F2E00),
      secondaryContainer: const Color(0xFF5C4300),
      onSecondaryContainer: const Color(0xFFFCEFC8),
      tertiary: const Color(0xFFB1CBCB),
      onTertiary: const Color(0xFF1C3535),
      tertiaryContainer: const Color(0xFF334B4B),
      onTertiaryContainer: const Color(0xFFCCE8E8),
      error: const Color(0xFFF2B8B5),
      onError: const Color(0xFF601410),
      errorContainer: const Color(0xFF8C1D18),
      onErrorContainer: const Color(0xFFF9DEDC),
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerHighest: AppColors.darkSurfaceVariant,
      outline: AppColors.darkBorder,
      outlineVariant: const Color(0xFF404943),
      shadow: Colors.black,
      scrim: AppColors.scrim,
      inverseSurface: const Color(0xFFE8E6E1),
      inversePrimary: AppColors.primary,
    );

    return _buildTheme(colorScheme, isDark: true);
  }

  // ── Amoled (True Black) Theme ──────────────────────────────────

  /// A variant of dark that uses true black (#000000) backgrounds
  /// with reduced blue light for OLED-optimized night reading.
  static ThemeData get amoledTheme {
    final colorScheme = ColorScheme.dark(
      primary: const Color(0xFF0FAF8A),  // slightly warmer teal for less blue
      onPrimary: const Color(0xFF00382D),
      primaryContainer: const Color(0xFF005240),
      onPrimaryContainer: const Color(0xFFB8E8DE),
      secondary: const Color(0xFFE8C454), // warmer gold
      onSecondary: const Color(0xFF3F2E00),
      secondaryContainer: const Color(0xFF5C4300),
      onSecondaryContainer: const Color(0xFFFCEFC8),
      tertiary: const Color(0xFFB1CBCB),
      onTertiary: const Color(0xFF1C3535),
      tertiaryContainer: const Color(0xFF334B4B),
      onTertiaryContainer: const Color(0xFFCCE8E8),
      error: const Color(0xFFF2B8B5),
      onError: const Color(0xFF601410),
      errorContainer: const Color(0xFF8C1D18),
      onErrorContainer: const Color(0xFFF9DEDC),
      surface: const Color(0xFF000000),
      onSurface: const Color(0xFFE8E6E1),
      surfaceContainerHighest: const Color(0xFF111111),
      outline: const Color(0xFF222222),
      outlineVariant: const Color(0xFF1A1A1A),
      shadow: Colors.black,
      scrim: const Color(0xFF000000),
      inverseSurface: const Color(0xFFE8E6E1),
      inversePrimary: const Color(0xFF0D6E5B),
    );

    return _buildTheme(colorScheme, isDark: true).copyWith(
      scaffoldBackgroundColor: const Color(0xFF000000),
      drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF000000)),
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Color(0xFF000000)),
      dialogTheme: const DialogTheme(backgroundColor: Color(0xFF0A0A0A)),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF1A1A1A), width: 0.5),
        ),
        color: const Color(0xFF0A0A0A),
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        clipBehavior: Clip.antiAlias,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF000000),
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: const Color(0xFF6B7280),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ── Theme Builder ──────────────────────────────────────────────

  static ThemeData _buildTheme(ColorScheme colorScheme, {required bool isDark}) {
    final textTheme = _buildTextTheme(colorScheme, isDark: isDark);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,

      // ── AppBar ──────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: latinFontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.3,
        ),
        toolbarTextStyle: TextStyle(
          fontFamily: latinFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: 24,
        ),
      ),

      // ── Card ────────────────────────────────────────────────────
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        clipBehavior: Clip.antiAlias,
      ),

      // ── Bottom Navigation Bar ───────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: isDark ? AppColors.navItemDarkUnselected : AppColors.navItemUnselected,
        selectedLabelStyle: TextStyle(
          fontFamily: latinFontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: latinFontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
        elevation: 8,
        landscapeLayout: BottomNavigationBarLandscapeLayout.linear,
      ),

      // ── Navigation Rail (for tablets) ───────────────────────────
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        selectedIconTheme: IconThemeData(color: colorScheme.primary, size: 24),
        unselectedIconTheme: IconThemeData(
          color: isDark ? AppColors.navItemDarkUnselected : AppColors.navItemUnselected,
          size: 24,
        ),
        selectedLabelTextStyle: TextStyle(
          fontFamily: latinFontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontFamily: latinFontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: isDark ? AppColors.navItemDarkUnselected : AppColors.navItemUnselected,
        ),
        elevation: 2,
        useIndicator: true,
        indicatorColor: colorScheme.primaryContainer,
      ),

      // ── Elevated Button ─────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: TextStyle(
            fontFamily: latinFontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: colorScheme.onPrimary,
          ),
        ).copyWith(
          mouseCursor: WidgetStateProperty.all(MouseCursor.defer),
        ),
      ),

      // ── Filled Button ───────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontFamily: latinFontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // ── Text Button ─────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: TextStyle(
            fontFamily: latinFontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // ── Outlined Button ─────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.outline, width: 1.5),
          textStyle: TextStyle(
            fontFamily: latinFontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // ── Icon Button ─────────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),

      // ── Floating Action Button ──────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        iconSize: 24,
      ),

      // ── Input Decoration ────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Color(0xFF1A2436) : Color(0xFFE5E2D9),
            width: 1,
          ),
        ),
        hintStyle: TextStyle(
          fontFamily: latinFontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
        ),
        labelStyle: TextStyle(
          fontFamily: latinFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        prefixIconColor: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
        suffixIconColor: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
        isDense: false,
        helperMaxLines: 2,
        errorMaxLines: 2,
      ),

      // ── Divider ─────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // ── Chip ────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: TextStyle(
          fontFamily: latinFontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: latinFontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: colorScheme.onPrimaryContainer,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        elevation: 0,
        pressElevation: 0,
      ),

      // ── Dialog ──────────────────────────────────────────────────
      dialogTheme: DialogTheme(
        backgroundColor: colorScheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: TextStyle(
          fontFamily: latinFontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          letterSpacing: -0.3,
        ),
        contentTextStyle: TextStyle(
          fontFamily: latinFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          height: 1.5,
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),

      // ── Bottom Sheet ────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
        dragHandleSize: const Size(36, 4),
        showDragHandle: true,
      ),

      // ── SnackBar ────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightTextPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
        contentTextStyle: TextStyle(
          fontFamily: latinFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextPrimary : Colors.white,
        ),
        actionTextColor: AppColors.secondaryLight,
        showCloseIcon: true,
        closeIconColor: isDark ? AppColors.darkTextSecondary : Colors.white70,
        width: 560,
      ),

      // ── Tab Bar ─────────────────────────────────────────────────
      tabBarTheme: TabBarTheme(
        labelColor: colorScheme.primary,
        unselectedLabelColor: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
        labelStyle: TextStyle(
          fontFamily: latinFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: latinFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 3,
          ),
          insets: const EdgeInsets.symmetric(horizontal: 24),
        ),
        dividerColor: Colors.transparent,
      ),

      // ── Switch ──────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }
          return isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ── Slider ──────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withOpacity(0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        showValueIndicator: ShowValueIndicator.never,
      ),

      // ── Progress Indicator ──────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        circularTrackColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        linearTrackColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        linearMinHeight: 4,
      ),

      // ── List Tile ───────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        titleTextStyle: TextStyle(
          fontFamily: latinFontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: latinFontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        leadingAndTrailingTextStyle: TextStyle(
          fontFamily: latinFontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.transparent,
        selectedTileColor: colorScheme.primaryContainer.withOpacity(0.5),
        horizontalTitleGap: 12,
        minVerticalPadding: 8,
        minLeadingWidth: 24,
      ),

      // ── Popup Menu ──────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        elevation: 8,
        shadowColor: isDark ? Colors.black54 : AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: latinFontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
      ),

      // ── Tooltip ─────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightTextPrimary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        textStyle: TextStyle(
          fontFamily: latinFontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextPrimary : Colors.white,
        ),
        waitDuration: const Duration(milliseconds: 500),
        preferBelow: true,
        verticalOffset: 8,
      ),

      // ── Page Transitions ────────────────────────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),

      // ── Scrollbar ───────────────────────────────────────────────
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          isDark ? AppColors.darkTextTertiary.withOpacity(0.4) : AppColors.lightTextTertiary.withOpacity(0.4),
        ),
        trackColor: WidgetStateProperty.all(Colors.transparent),
        thickness: WidgetStateProperty.all(6),
        radius: const Radius.circular(3),
        thumbVisibility: WidgetStateProperty.all(false),
      ),

      // ── Splash & Highlight ──────────────────────────────────────
      splashColor: colorScheme.primary.withOpacity(0.08),
      highlightColor: colorScheme.primary.withOpacity(0.04),
      hoverColor: colorScheme.primary.withOpacity(0.06),
    );
  }

  // ── Text Theme ─────────────────────────────────────────────────

  static TextTheme _buildTextTheme(ColorScheme colorScheme, {required bool isDark}) {
    final primaryTextColor = colorScheme.onSurface;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final tertiaryTextColor = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;

    return TextTheme(
      // ── Display Styles (Latin) ───────────────────────────────────
      displayLarge: TextStyle(
        fontFamily: latinFontFamily,
        fontSize: 57,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        height: 1.1,
        color: primaryTextColor,
      ),
      displayMedium: TextStyle(
        fontFamily: latinFontFamily,
        fontSize: 45,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.15,
        color: primaryTextColor,
      ),
      displaySmall: TextStyle(
        fontFamily: latinFontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: primaryTextColor,
      ),

      // ── Headline Styles (Latin) ─────────────────────────────────
      headlineLarge: TextStyle(
        fontFamily: latinFontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.25,
        color: primaryTextColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: latinFontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.25,
        color: primaryTextColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: latinFontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
        color: primaryTextColor,
      ),

      // ── Title Styles (Latin) ────────────────────────────────────
      titleLarge: TextStyle(
        fontFamily: latinFontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.3,
        color: primaryTextColor,
      ),
      titleMedium: TextStyle(
        fontFamily: latinFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.4,
        color: primaryTextColor,
      ),
      titleSmall: TextStyle(
        fontFamily: latinFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
        color: primaryTextColor,
      ),

      // ── Body Styles (Latin) ─────────────────────────────────────
      bodyLarge: TextStyle(
        fontFamily: latinFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.5,
        color: secondaryTextColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: latinFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.5,
        color: secondaryTextColor,
      ),
      bodySmall: TextStyle(
        fontFamily: latinFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.5,
        color: tertiaryTextColor,
      ),

      // ── Label Styles (Latin) ────────────────────────────────────
      labelLarge: TextStyle(
        fontFamily: latinFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
        color: primaryTextColor,
      ),
      labelMedium: TextStyle(
        fontFamily: latinFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.4,
        color: secondaryTextColor,
      ),
      labelSmall: TextStyle(
        fontFamily: latinFontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.4,
        color: tertiaryTextColor,
      ),
    );
  }

  // ── Arabic Text Styles ─────────────────────────────────────────
  // These are used explicitly for Quran text and Arabic headings.

  static const TextStyle arabicQuranText = TextStyle(
    fontFamily: arabicFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 2.0,
    letterSpacing: 0.5,
  );

  static const TextStyle arabicQuranTextLarge = TextStyle(
    fontFamily: arabicFontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 2.0,
    letterSpacing: 0.5,
  );

  static const TextStyle arabicQuranTextXL = TextStyle(
    fontFamily: arabicFontFamily,
    fontSize: 44,
    fontWeight: FontWeight.w700,
    height: 2.0,
    letterSpacing: 0.5,
  );

  static const TextStyle arabicHeader = TextStyle(
    fontFamily: arabicHeaderFontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.6,
    letterSpacing: 0.3,
  );

  static const TextStyle arabicHeaderSmall = TextStyle(
    fontFamily: arabicHeaderFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: 0.3,
  );

  static const TextStyle arabicBody = TextStyle(
    fontFamily: arabicFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.8,
  );

  static const TextStyle arabicBodySmall = TextStyle(
    fontFamily: arabicFontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.7,
  );

  static const TextStyle bismillahStyle = TextStyle(
    fontFamily: arabicHeaderFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.6,
    color: AppColors.secondary,
  );

  static const TextStyle ayahNumberStyle = TextStyle(
    fontFamily: arabicFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
    height: 1.0,
  );

  // ── Surah Name Styles ──────────────────────────────────────────

  static TextStyle get surahNameArabic {
    return const TextStyle(
      fontFamily: arabicHeaderFontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
      height: 1.3,
    );
  }

  static const TextStyle surahNameEnglish = TextStyle(
    fontFamily: latinFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle surahMeta = TextStyle(
    fontFamily: latinFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );
}
