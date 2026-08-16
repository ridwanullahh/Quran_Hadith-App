import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../data/models/hadith/hadith_models.dart';

// ═══════════════════════════════════════════════════════════════════
// Hadith Share Card
// Formats a hadith beautifully for sharing via share_plus.
// ═══════════════════════════════════════════════════════════════════

class HadithShareCard extends StatelessWidget {
  final Hadith hadith;
  final String? collectionName;
  final bool showIsnad;

  const HadithShareCard({
    super.key,
    required this.hadith,
    this.collectionName,
    this.showIsnad = true,
  });

  /// Formats the hadith as a shareable text string.
  String _formatShareText() {
    final buffer = StringBuffer();

    // Decorative header
    buffer.writeln('─' * 40);

    // Narrator chain (isnad)
    if (showIsnad) {
      if (hadith.narratorChainEnglish != null &&
          hadith.narratorChainEnglish!.isNotEmpty) {
        buffer.writeln('🔗 Narrator Chain:');
        buffer.writeln(hadith.narratorChainEnglish!);
        buffer.writeln();
      }
    }

    // Arabic text
    if (hadith.textArabic.isNotEmpty) {
      buffer.write('📜 ');
      buffer.writeln(hadith.textArabic);
      buffer.writeln();
    }

    // English translation
    if (hadith.textEnglish != null && hadith.textEnglish!.isNotEmpty) {
      buffer.write('💬 ');
      buffer.writeln(hadith.textEnglish!);
      buffer.writeln();
    }

    // Narrator
    if (hadith.narrator != null && hadith.narrator!.isNotEmpty) {
      buffer.write('👤 Narrated by: ');
      buffer.writeln(hadith.narrator!);
    }

    // Collection reference
    final source = collectionName ??
        hadith.collectionId.replaceAll('-', ' ').split(' ').map((w) {
      if (w.isEmpty) return '';
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
    buffer.write('📖 Source: ');
    buffer.writeln(source);
    buffer.write('📋 Hadith #${hadith.hadithNumber}');
    if (hadith.reference != null) buffer.write(' (${hadith.reference})');
    buffer.writeln();

    // Grade
    if (hadith.grade != null && hadith.grade!.isNotEmpty) {
      buffer.write('✅ Grade: ');
      buffer.writeln(hadith.grade!);
    }

    // Footer
    buffer.writeln('─' * 40);
    buffer.writeln('Shared from MinhaajulHudaa');

    return buffer.toString();
  }

  /// Builds a formatted text for the share sheet.
  String get shareText => _formatShareText();

  /// Opens the native share sheet.
  static void share({
    required Hadith hadith,
    String? collectionName,
    bool showIsnad = true,
  }) {
    final card = HadithShareCard(
      hadith: hadith,
      collectionName: collectionName,
      showIsnad: showIsnad,
    );
    Share.share(
      card.shareText,
      subject: 'Hadith - ${collectionName ?? hadith.collectionId} #${hadith.hadithNumber}',
    );
  }

  /// Renders a visual preview of the share card (for dialogs, etc.).
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Isnad
          if (showIsnad &&
              hadith.narratorChainEnglish != null &&
              hadith.narratorChainEnglish!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.15),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Narrator Chain',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hadith.narratorChainEnglish!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Arabic text
          if (hadith.textArabic.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                hadith.textArabic,
                style: AppTheme.arabicQuranText.copyWith(
                  fontSize: 20,
                  height: 2.0,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // English text
          if (hadith.textEnglish != null && hadith.textEnglish!.isNotEmpty) ...[
            Text(
              hadith.textEnglish!,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.7,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Divider
          Divider(
            color: (isDark ? AppColors.darkBorder : AppColors.lightBorder).withOpacity(0.5),
          ),
          const SizedBox(height: 8),

          // Metadata
          if (hadith.narrator != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.person_rounded, size: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Narrated by ${hadith.narrator}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(Icons.menu_book_rounded, size: 14, color: AppColors.secondary),
                const SizedBox(width: 6),
                Text(
                  collectionName ?? hadith.collectionId,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hadith.hadithNumber > 0) ...[
                  Text(
                    ' — Hadith #${hadith.hadithNumber}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (hadith.grade != null && hadith.grade!.isNotEmpty)
            Row(
              children: [
                Icon(Icons.verified_rounded, size: 14, color: AppColors.hifdhGreen),
                const SizedBox(width: 6),
                Text(
                  'Grade: ${hadith.grade}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.hifdhGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 12),

          // Attribution
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Shared from MinhaajulHudaa',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
