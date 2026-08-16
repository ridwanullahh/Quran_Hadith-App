import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../data/models/quran/surah_info.dart';
import '../../../../core/services/database/database.dart';

class MemorizationProgressCard extends StatelessWidget {
  final SurahInfo surahInfo;
  final List<MemorizationProgress> progress;
  final VoidCallback? onTap;

  const MemorizationProgressCard({
    super.key,
    required this.surahInfo,
    required this.progress,
    this.onTap,
  });

  int get memorizedCount =>
      progress.where((p) => p.status == 'memorized' || p.status == 'mastered').length;
  int get learningCount =>
      progress.where((p) => p.status == 'learning' || p.status == 'review').length;

  double get progressPercent =>
      surahInfo.totalAyahs > 0 ? memorizedCount / surahInfo.totalAyahs : 0.0;

  Color get _progressColor {
    if (progressPercent >= 1.0) return AppColors.hifdhGreen;
    if (progressPercent >= 0.75) return const Color(0xFF34D399);
    if (progressPercent >= 0.5) return AppColors.primary;
    if (progressPercent >= 0.25) return AppColors.secondary;
    return AppColors.darkTextTertiary;
  }

  String get _statusLabel {
    if (progress.isEmpty) return 'Not Started';
    if (progressPercent >= 1.0) return 'Mastered';
    if (memorizedCount > 0) return 'In Progress';
    return 'Learning';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          child: Row(
            children: [
              // Surah number badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: surahInfo.isMeccan
                      ? AppColors.meccanBadge.withValues(alpha: 0.12)
                      : AppColors.medinanBadge.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${surahInfo.number}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: surahInfo.isMeccan
                          ? AppColors.meccanBadge
                          : AppColors.medinanBadge,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Surah info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          surahInfo.nameEnglish,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: surahInfo.isMeccan
                                ? AppColors.meccanBadge.withValues(alpha: 0.1)
                                : AppColors.medinanBadge.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            surahInfo.revelationType,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: surahInfo.isMeccan
                                  ? AppColors.meccanBadge
                                  : AppColors.medinanBadge,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      surahInfo.nameArabic,
                      style: AppTheme.arabicQuranText.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Progress bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progressPercent.clamp(0.0, 1.0),
                              backgroundColor: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                              color: _progressColor,
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$memorizedCount/${surahInfo.totalAyahs}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Status chip
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _progressColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _statusLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _progressColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (learningCount > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '$learningCount learning',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
