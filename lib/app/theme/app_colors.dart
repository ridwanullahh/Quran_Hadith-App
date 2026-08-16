import 'dart:ui';
import 'package:flutter/painting.dart';

/// Central color palette for MinhaajulHudaa.
/// All colors are defined here so both light and dark themes
/// reference a single source of truth.
class AppColors {
  AppColors._();

  // ── Brand Colors ──────────────────────────────────────────────

  /// Primary deep teal
  static const Color primary = Color(0xFF0D6E5B);

  /// Primary shade – darkest
  static const Color primaryDark = Color(0xFF094E3F);

  /// Primary shade – lightest
  static const Color primaryLight = Color(0xFF14A88A);

  /// Secondary gold
  static const Color secondary = Color(0xFFD4A843);

  /// Secondary shade – darkest
  static const Color secondaryDark = Color(0xFFB08A2F);

  /// Secondary shade – lightest
  static const Color secondaryLight = Color(0xFFF0D68A);

  // ── Backgrounds ───────────────────────────────────────────────

  /// Dark mode background
  static const Color darkBackground = Color(0xFF0A1628);

  /// Light mode background
  static const Color lightBackground = Color(0xFFF8F6F1);

  /// Dark surface
  static const Color darkSurface = Color(0xFF111D33);

  /// Light surface
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Dark surface variant
  static const Color darkSurfaceVariant = Color(0xFF172640);

  /// Light surface variant
  static const Color lightSurfaceVariant = Color(0xFFF0EDE5);

  // ── Text ──────────────────────────────────────────────────────

  /// Dark mode primary text (near white)
  static const Color darkTextPrimary = Color(0xFFE8E6E1);

  /// Dark mode secondary text (muted)
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  /// Dark mode tertiary text (very muted)
  static const Color darkTextTertiary = Color(0xFF6B7280);

  /// Light mode primary text (near black)
  static const Color lightTextPrimary = Color(0xFF1A1A2E);

  /// Light mode secondary text
  static const Color lightTextSecondary = Color(0xFF6B7280);

  /// Light mode tertiary text
  static const Color lightTextTertiary = Color(0xFF9CA3AF);

  // ── Borders & Dividers ────────────────────────────────────────

  static const Color darkBorder = Color(0xFF1E2D47);
  static const Color lightBorder = Color(0xFFE5E2D9);

  // ── Status Colors ─────────────────────────────────────────────

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── Surah-Specific Accents ────────────────────────────────────

  /// Meccan surah badge
  static const Color meccanBadge = Color(0xFF0D6E5B);

  /// Medinan surah badge
  static const Color medinanBadge = Color(0xFF7C3AED);

  // ── Audio Player ──────────────────────────────────────────────

  static const Color audioBarBackground = Color(0xFF0F1D32);
  static const Color audioProgressBar = Color(0xFF0D6E5B);
  static const Color audioProgressTrack = Color(0xFF1E2D47);

  // ── Gradients ─────────────────────────────────────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D6E5B), Color(0xFF0A4F40)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4A843), Color(0xFFF0D68A)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D6E5B), Color(0xFF094E3F)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A1628), Color(0xFF0D6E5B)],
    stops: [0.3, 1.0],
  );

  // ── Overlay / Scrim ───────────────────────────────────────────

  static const Color scrim = Color(0xCC000000);
  static const Color lightScrim = Color(0x33000000);

  // ── Misc ──────────────────────────────────────────────────────

  static const Color shadow = Color(0x1A000000);
  static const Color highlight = Color(0x33D4A843);
  static const Color bookmarkGold = Color(0xFFD4A843);
  static const Color hifdhGreen = Color(0xFF10B981);
  static const Color revisionBlue = Color(0xFF3B82F6);

  // ── Bottom Nav ────────────────────────────────────────────────

  static const Color navItemSelected = Color(0xFF0D6E5B);
  static const Color navItemUnselected = Color(0xFF6B7280);
  static const Color navItemDarkSelected = Color(0xFF14A88A);
  static const Color navItemDarkUnselected = Color(0xFF6B7280);
}
