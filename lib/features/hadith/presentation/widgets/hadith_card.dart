import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../data/models/hadith/hadith_models.dart';

class HadithCard extends StatelessWidget {
  final Hadith hadith;
  final String? collectionName;
  final String? bookName;
  final VoidCallback? onTap;
  final bool showFullText;
  final bool showNarratorChain;

  const HadithCard({
    super.key,
    required this.hadith,
    this.collectionName,
    this.bookName,
    this.onTap,
    this.showFullText = false,
    this.showNarratorChain = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final displayText = showFullText
        ? hadith.textArabic
        : hadith.arabicPreview;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: number + grade badge
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${hadith.hadithNumber}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (hadith.narrator != null) ...[
                    Expanded(
                      child: Text(
                        hadith.narrator!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ] else ...[
                    const Spacer(),
                  ],
                  if (hadith.hasGrade) _GradeBadge(grade: hadith.grade!),
                ],
              ),
              const SizedBox(height: 12),

              // Arabic text
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  displayText,
                  style: AppTheme.arabicQuranText.copyWith(
                    fontSize: showFullText ? 22 : 18,
                    height: 2.0,
                    color: theme.colorScheme.onSurface,
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.justify,
                ),
              ),

              // English translation
              if (hadith.textEnglish != null) ...[
                const SizedBox(height: 12),
                Text(
                  showFullText
                      ? hadith.textEnglish!
                      : (hadith.textEnglish!.length > 200
                          ? '${hadith.textEnglish!.substring(0, 200)}...'
                          : hadith.textEnglish!),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.left,
                ),
              ],

              // Narrator chain
              if (showNarratorChain && hadith.narratorChainEnglish != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.15),
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
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Reference & chapter
              if (hadith.chapterTitle != null || hadith.reference != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (hadith.chapterTitle != null) ...[
                      Icon(
                        Icons.menu_book_rounded,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hadith.chapterTitle!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (hadith.reference != null)
                      Text(
                        hadith.reference!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primary.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.02, end: 0);
  }
}

// ═══════════════════════════════════════════════════════════════════
// Grade Badge
// ═══════════════════════════════════════════════════════════════════

class _GradeBadge extends StatelessWidget {
  final String grade;

  const _GradeBadge({required this.grade});

  Color get _color {
    final g = grade.toLowerCase();
    if (g.contains('sahih') || g.contains('صحيح')) return AppColors.hifdhGreen;
    if (g.contains('hasan') || g.contains('حسن')) return AppColors.primary;
    if (g.contains('daif') || g.contains('ضعيف') || g.contains("da'if"))
      return AppColors.error;
    return AppColors.darkTextTertiary;
  }

  String get _label {
    final g = grade.toLowerCase();
    if (g.contains('sahih') || g.contains('صحيح')) return 'Sahih';
    if (g.contains('hasan') || g.contains('حسن')) return 'Hasan';
    if (g.contains('daif') || g.contains('ضعيف') || g.contains("da'if"))
      return "Da'if";
    return grade;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
