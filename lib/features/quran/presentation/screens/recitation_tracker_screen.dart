import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/database/database.dart';
import '../../../../data/models/quran/surah_info.dart';
import '../providers/quran_providers.dart';

// ═══════════════════════════════════════════════════════════════════
// Recitation Progress Data
// ═══════════════════════════════════════════════════════════════════

class _SurahProgress {
  final SurahInfo surah;
  final int ayahsRead;
  final int totalAyahs;

  double get percentage => totalAyahs > 0 ? ayahsRead / totalAyahs : 0;
  bool get isCompleted => ayahsRead >= totalAyahs;
  bool get isPartial => ayahsRead > 0 && !isCompleted;

  const _SurahProgress({
    required this.surah,
    required this.ayahsRead,
    required this.totalAyahs,
  });
}

class _ProgressStats {
  final int totalAyahsRead;
  final int totalSecondsSpent;
  final int streakDays;
  final double overallPercentage;

  const _ProgressStats({
    required this.totalAyahsRead,
    required this.totalSecondsSpent,
    required this.streakDays,
    required this.overallPercentage,
  });

  String get formattedTime {
    final hours = totalSecondsSpent ~/ 3600;
    final minutes = (totalSecondsSpent % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  String get averagePerSession {
    if (totalSecondsSpent == 0) return '0m';
    final avgSeconds = totalSecondsSpent ~/ 30; // assume ~30 sessions
    final m = avgSeconds ~/ 60;
    return '${m}m';
  }
}

// ═══════════════════════════════════════════════════════════════════
// Progress Provider
// ═══════════════════════════════════════════════════════════════════

final recitationProgressProvider = FutureProvider<_ProgressData>((ref) async {
  final surahs = await ref.watch(surahListProvider.future);
  final db = AppDatabase.instance;

  // Get all reading history
  final allHistory = await db.getReadingHistory(limit: 50000);

  // Count unique (surah, ayah) pairs
  final readSet = <String>{};
  int totalSeconds = 0;
  final daySet = <String>{};

  for (final h in allHistory) {
    readSet.add('${h.surahNumber}:${h.ayahNumber}');
    totalSeconds += h.timeSpentSeconds;
    daySet.add(h.readAt.toIso8601String().substring(0, 10));
  }

  // Calculate streak
  final today = DateTime.now();
  int streak = 0;
  for (int i = 0; i < 365; i++) {
    final check = today.subtract(Duration(days: i));
    final key = check.toIso8601String().substring(0, 10);
    if (daySet.contains(key)) {
      streak++;
    } else {
      break;
    }
  }

  final surahProgresses = <_SurahProgress>[];
  for (final surah in surahs) {
    int count = 0;
    for (int a = 1; a <= surah.totalAyahs; a++) {
      if (readSet.contains('${surah.number}:$a')) {
        count++;
      }
    }
    surahProgresses.add(_SurahProgress(
      surah: surah,
      ayahsRead: count,
      totalAyahs: surah.totalAyahs,
    ));
  }

  final stats = _ProgressStats(
    totalAyahsRead: readSet.length,
    totalSecondsSpent: totalSeconds,
    streakDays: streak,
    overallPercentage: readSet.length / AppConstants.totalAyahs,
  );

  return _ProgressData(stats: stats, surahProgresses: surahProgresses);
});

class _ProgressData {
  final _ProgressStats stats;
  final List<_SurahProgress> surahProgresses;
  const _ProgressData({required this.stats, required this.surahProgresses});
}

// ═══════════════════════════════════════════════════════════════════
// Recitation Tracker Screen
// ═══════════════════════════════════════════════════════════════════

class RecitationTrackerScreen extends ConsumerWidget {
  const RecitationTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressAsync = ref.watch(recitationProgressProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Recitation Progress'),
      ),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Failed to load progress', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        data: (data) {
          return CustomScrollView(
            slivers: [
              // ── Stats Cards ──────────────────────────────────────
              SliverToBoxAdapter(child: _StatsOverview(stats: data.stats, isDark: isDark)),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ── Section Header ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Surah-wise Progress',
                        style: TextStyle(
                          fontFamily: AppTheme.latinFontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${data.surahProgresses.where((s) => s.isCompleted).length}/${AppConstants.totalSurahs} completed',
                        style: TextStyle(
                          fontFamily: AppTheme.latinFontFamily,
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ── Surah List ──────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final sp = data.surahProgresses[index];
                      return _SurahProgressTile(
                        progress: sp,
                        isDark: isDark,
                      ).animate().fadeIn(duration: 200.ms, delay: ((index % 20) * 20).ms);
                    },
                    childCount: data.surahProgresses.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Stats Overview
// ═══════════════════════════════════════════════════════════════════

class _StatsOverview extends StatelessWidget {
  final _ProgressStats stats;
  final bool isDark;

  const _StatsOverview({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          // Overall progress ring
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  'Overall Quran Progress',
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Circular indicator
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: Stack(
                        children: [
                          SizedBox(
                            width: 90,
                            height: 90,
                            child: CircularProgressIndicator(
                              value: stats.overallPercentage,
                              strokeWidth: 8,
                              backgroundColor: Colors.white.withOpacity(0.15),
                              valueColor: const AlwaysStoppedAnimation(AppColors.secondaryLight),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Center(
                            child: Text(
                              '${(stats.overallPercentage * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontFamily: AppTheme.latinFontFamily,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Stats
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StatItem(label: 'Ayahs Read', value: '${stats.totalAyahsRead}/${AppConstants.totalAyahs}'),
                        const SizedBox(height: 8),
                        _StatItem(label: 'Reading Streak', value: '${stats.streakDays} days'),
                        const SizedBox(height: 8),
                        _StatItem(label: 'Time Spent', value: stats.formattedTime),
                        const SizedBox(height: 8),
                        _StatItem(label: 'Avg / Session', value: stats.averagePerSession),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontFamily: AppTheme.latinFontFamily,
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: AppTheme.latinFontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.secondaryLight,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Surah Progress Tile
// ═══════════════════════════════════════════════════════════════════

class _SurahProgressTile extends StatelessWidget {
  final _SurahProgress progress;
  final bool isDark;

  const _SurahProgressTile({required this.progress, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surah = progress.surah;
    final statusColor = progress.isCompleted
        ? AppColors.success
        : progress.isPartial
            ? AppColors.primary
            : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary);
    final statusText = progress.isCompleted
        ? 'Completed'
        : progress.isPartial
            ? '${progress.ayahsRead}/${progress.totalAyahs}'
            : 'Not started';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Surah number badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${surah.number}',
                      style: TextStyle(
                        fontFamily: AppTheme.latinFontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Surah name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            surah.nameEnglish,
                            style: TextStyle(
                              fontFamily: AppTheme.latinFontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: surah.isMeccan
                                  ? AppColors.meccanBadge.withOpacity(0.1)
                                  : AppColors.medinanBadge.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              surah.isMeccan ? 'Meccan' : 'Medinan',
                              style: TextStyle(
                                fontFamily: AppTheme.latinFontFamily,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: surah.isMeccan ? AppColors.meccanBadge : AppColors.medinanBadge,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        surah.nameArabic,
                        style: TextStyle(
                          fontFamily: AppTheme.arabicHeaderFontFamily,
                          fontSize: 16,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
                // Status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        fontFamily: AppTheme.latinFontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                    if (progress.percentage > 0 && !progress.isCompleted)
                      Text(
                        '${(progress.percentage * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontFamily: AppTheme.latinFontFamily,
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            // Progress bar
            if (progress.percentage > 0) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress.percentage,
                  backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  valueColor: AlwaysStoppedAnimation(statusColor),
                  minHeight: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
