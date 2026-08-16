import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════
// Sajdah Verse Indicator
// Shows a gold badge for sajda verses, distinguishing between
// recommended (سجدة تلاوة) and obligatory (سجدة شكر).
// ═══════════════════════════════════════════════════════════════════

/// All sajdah verses with their type.
const Map<String, String> sajdaVerses = {
  '7:206': 'recommended',
  '13:15': 'recommended',
  '16:49': 'recommended',
  '17:107': 'recommended',
  '19:58': 'recommended',
  '22:18': 'recommended',
  '22:77': 'obligatory',
  '25:60': 'recommended',
  '27:25': 'obligatory',
  '32:15': 'obligatory',
  '38:24': 'recommended',
  '41:37': 'recommended',
  '53:62': 'obligatory',
  '84:21': 'obligatory',
  '96:19': 'obligatory',
};

class SajdahIndicator extends StatelessWidget {
  final int surahNumber;
  final int ayahNumber;
  final String? sajdaType;
  final double iconSize;

  const SajdahIndicator({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
    this.sajdaType,
    this.iconSize = 16,
  });

  bool get isSajdah => sajdaVerses.containsKey('$surahNumber:$ayahNumber');
  bool get isObligatory => sajdaType == 'obligatory';

  @override
  Widget build(BuildContext context) {
    if (!isSajdah && sajdaType == null) return const SizedBox.shrink();

    final effectiveType = sajdaType ?? sajdaVerses['$surahNumber:$ayahNumber'] ?? 'recommended';
    final obligatory = effectiveType == 'obligatory';

    return Tooltip(
      message: obligatory ? 'سجدة شكر (Obligatory Sajdah of Gratitude)' : 'سجدة تلاوة (Recommended Sajdah of Recitation)',
      preferBelow: false,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: iconSize * 0.5,
          vertical: iconSize * 0.2,
        ),
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(iconSize * 0.3),
          border: Border.all(
            color: AppColors.secondary.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              obligatory ? Icons.star_rounded : Icons.south_rounded,
              size: iconSize,
              color: AppColors.secondary,
            ),
            if (iconSize >= 14) ...[
              SizedBox(width: iconSize * 0.2),
              Text(
                'سجدة',
                style: TextStyle(
                  fontFamily: AppTheme.arabicFontFamily,
                  fontSize: iconSize * 0.65,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryDark,
                  height: 1.0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline sajdah badge that can be placed within a text flow.
class InlineSajdahBadge extends StatelessWidget {
  final String sajdaType;
  final double size;

  const InlineSajdahBadge({
    super.key,
    required this.sajdaType,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    final obligatory = sajdaType == 'obligatory';

    return Container(
      height: size,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: obligatory
              ? [const Color(0xFFD4A843), const Color(0xFFB08A2F)]
              : [const Color(0xFFF0D68A), const Color(0xFFD4A843)],
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Text(
          obligatory ? '﴿﴾' : '﴿﴾',
          style: TextStyle(
            fontFamily: AppTheme.arabicFontFamily,
            fontSize: size * 0.55,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
