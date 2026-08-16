import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:arabic_numbers/arabic_numbers.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/models/quran/ayah_data.dart';

class AyahWidget extends StatelessWidget {
  final AyahData ayah;
  final int surahNumber;
  final String? translation;
  final String? tafseerText;
  final String? tafseerSourceName;
  final bool showTranslation;
  final bool showTafseer;
  final bool isPlaying;
  final bool isSajdah;
  final VoidCallback? onTap;

  const AyahWidget({
    super.key,
    required this.ayah,
    required this.surahNumber,
    this.translation,
    this.tafseerText,
    this.tafseerSourceName,
    this.showTranslation = false,
    this.showTafseer = false,
    this.isPlaying = false,
    this.isSajdah = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final arabicNumber = ArabicNumbers().convert(ayah.ayahNumber);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isPlaying
            ? AppColors.primary.withOpacity(isDark ? 0.12 : 0.08)
            : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPlaying
              ? AppColors.primary.withOpacity(0.4)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isPlaying ? 1.5 : 1,
        ),
        boxShadow: [
          if (isPlaying)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 2),
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              children: [
                _buildArabicRow(context, arabicNumber, isDark),
                if (isSajdah) ...[
                  const SizedBox(height: 8),
                  _buildSajdahIndicator(isDark),
                ],
                if (showTranslation && translation != null) ...[
                  const SizedBox(height: 12),
                  _buildTranslationSection(translation!, isDark),
                ],
                if (showTafseer && tafseerText != null) ...[
                  const SizedBox(height: 10),
                  _buildTafseerSection(context, tafseerText!, tafseerSourceName, isDark),
                ],
              ],
            ),
          ),
        ),
      ),
    )
        .animate(target: isPlaying ? 1 : 0)
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.008, 1.0),
          duration: 300.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildArabicRow(
      BuildContext context, String arabicNumber, bool isDark) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              ayah.textUthmani,
              style: AppTheme.arabicQuranText.copyWith(
                color: isPlaying
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary),
                height: 2.2,
                fontSize: 26,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          _buildAyahNumberBadge(arabicNumber, isDark),
        ],
      ),
    );
  }

  Widget _buildAyahNumberBadge(String arabicNumber, bool isDark) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPlaying
            ? AppColors.primary
            : (isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightSurfaceVariant),
        border: isPlaying
            ? null
            : Border.all(
                color: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
              ),
      ),
      child: Center(
        child: Text(
          arabicNumber,
          style: TextStyle(
            fontFamily: AppTheme.arabicFontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isPlaying
                ? Colors.white
                : AppColors.primary,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildSajdahIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.self_improvement_rounded,
            size: 14,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 6),
          Text(
            ayah.sajdaType == 'obligatory'
                ? 'Sajdah (Obligatory)'
                : 'Sajdah (Recommended)',
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationSection(String translation, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        translation,
        style: TextStyle(
          fontFamily: AppTheme.latinFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      ),
    );
  }

  Widget _buildTafseerSection(
    BuildContext context,
    String tafseerText,
    String? sourceName,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 14,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                sourceName ?? 'Tafseer',
                style: TextStyle(
                  fontFamily: AppTheme.latinFontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tafseerText,
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.6,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
