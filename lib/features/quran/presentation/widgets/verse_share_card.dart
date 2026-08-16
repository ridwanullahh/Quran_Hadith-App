import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/quran/ayah_data.dart';

// ═══════════════════════════════════════════════════════════════════
// Verse Share Card — builds a formatted text for sharing a verse
// ═══════════════════════════════════════════════════════════════════

class VerseShareCard extends StatelessWidget {
  final AyahData ayah;
  final String surahNameEnglish;
  final String surahNameArabic;
  final String? translationText;
  final int surahNumber;

  const VerseShareCard({
    super.key,
    required this.ayah,
    required this.surahNameEnglish,
    required this.surahNameArabic,
    this.translationText,
    required this.surahNumber,
  });

  /// Build the formatted text that will be shared.
  String _buildShareText() {
    final buffer = StringBuffer();

    // Bismillah header (for non-Fatiha, non-Tawbah)
    if (surahNumber != 1 && surahNumber != 9) {
      buffer.writeln(AppConstants.bismillahArabic);
      buffer.writeln();
    }

    // Arabic ayah
    buffer.writeln(ayah.textUthmani);
    buffer.writeln();

    // Translation
    if (translationText != null && translationText!.isNotEmpty) {
      buffer.writeln(translationText);
      buffer.writeln();
    }

    // Reference
    buffer.writeln('— $surahNameEnglish ($surahNameArabic) : $surahNumber:${ayah.ayahNumber}');
    buffer.writeln();

    // Attribution
    buffer.writeln('Shared from MinhaajulHudaa');

    return buffer.toString();
  }

  /// Show the share dialog.
  static void share({
    required AyahData ayah,
    required String surahNameEnglish,
    required String surahNameArabic,
    String? translationText,
    required int surahNumber,
  }) {
    final card = VerseShareCard(
      ayah: ayah,
      surahNameEnglish: surahNameEnglish,
      surahNameArabic: surahNameArabic,
      translationText: translationText,
      surahNumber: surahNumber,
    );
    final text = card._buildShareText();
    Share.share(text, subject: '$surahNameEnglish : $surahNumber:${ayah.ayahNumber}');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bismillah
          if (surahNumber != 1 && surahNumber != 9) ...[
            Text(
              AppConstants.bismillahArabic,
              style: const TextStyle(
                fontFamily: AppTheme.arabicHeaderFontFamily,
                fontSize: 18,
                color: AppColors.secondaryLight,
                height: 2.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],

          // Arabic ayah
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              ayah.textUthmani,
              style: const TextStyle(
                fontFamily: AppTheme.arabicFontFamily,
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 2.2,
              ),
              textAlign: TextAlign.right,
            ),
          ),

          const SizedBox(height: 16),

          // Divider
          Container(
            width: 60,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(1),
            ),
          ),

          const SizedBox(height: 12),

          // Translation
          if (translationText != null && translationText!.isNotEmpty) ...[
            Text(
              translationText!,
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 14,
                color: Colors.white.withOpacity(0.85),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],

          // Reference
          Text(
            '$surahNameEnglish ($surahNameArabic) : $surahNumber:${ayah.ayahNumber}',
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryLight,
            ),
          ),

          const SizedBox(height: 4),

          // Attribution
          Text(
            'MinhaajulHudaa',
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 11,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
