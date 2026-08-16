import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/database/database.dart';

// ═══════════════════════════════════════════════════════════════════
// Daily Progress Provider
// ═══════════════════════════════════════════════════════════════════

class DailyProgressData {
  final int ayahsReadToday;
  final int dailyGoalAyahs;
  final int currentStreak;
  final List<DateTime> last30DaysActivity;

  const DailyProgressData({
    required this.ayahsReadToday,
    required this.dailyGoalAyahs,
    required this.currentStreak,
    required this.last30DaysActivity,
  });

  double get goalProgress => dailyGoalAyahs > 0 ? ayahsReadToday / dailyGoalAyahs : 0;
  bool get goalMet => ayahsReadToday >= dailyGoalAyahs;
}

final dailyProgressProvider = FutureProvider<DailyProgressData>((ref) async {
  final db = AppDatabase.instance;

  // Today's date key
  final now = DateTime.now();
  final todayKey = now.toIso8601String().substring(0, 10);

  // Get all reading history
  final history = await db.getReadingHistory(limit: 50000);

  // Count ayahs read today (unique surah:ayah pairs)
  final todaySet = <String>{};
  for (final h in history) {
    if (h.readAt.toIso8601String().substring(0, 10) == todayKey) {
      todaySet.add('${h.surahNumber}:${h.ayahNumber}');
    }
  }

  // Calculate last 30 days activity
  final dayActivity = <DateTime>[];
  final daySet = <String>{};
  for (final h in history) {
    final key = h.readAt.toIso8601String().substring(0, 10);
    if (!daySet.contains(key)) {
      daySet.add(key);
      dayActivity.add(h.readAt);
    }
  }

  // Calculate streak
  int streak = 0;
  for (int i = 0; i < 365; i++) {
    final check = now.subtract(Duration(days: i));
    final checkKey = check.toIso8601String().substring(0, 10);
    if (daySet.contains(checkKey)) {
      streak++;
    } else {
      break;
    }
  }

  // Default daily goal: ~4 pages = ~20 ayahs
  const dailyGoal = 20;

  return DailyProgressData(
    ayahsReadToday: todaySet.length,
    dailyGoalAyahs: dailyGoal,
    currentStreak: streak,
    last30DaysActivity: dayActivity,
  );
});

// ═══════════════════════════════════════════════════════════════════
// Daily Progress Widget — can be embedded in surah list header
// ═══════════════════════════════════════════════════════════════════

class DailyProgressWidget extends ConsumerWidget {
  final VoidCallback? onTap;
  const DailyProgressWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressAsync = ref.watch(dailyProgressProvider);

    return progressAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) => _buildWidget(context, data, isDark),
    );
  }

  Widget _buildWidget(BuildContext context, DailyProgressData data, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row: today's progress + streak
            Row(
              children: [
                // Progress ring mini
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: CircularProgressIndicator(
                          value: data.goalProgress.clamp(0.0, 1.0),
                          strokeWidth: 5,
                          backgroundColor: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightBorder,
                          valueColor: AlwaysStoppedAnimation(
                            data.goalMet ? AppColors.success : AppColors.primary,
                          ),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Center(
                        child: Text(
                          '${data.ayahsReadToday}',
                          style: TextStyle(
                            fontFamily: AppTheme.latinFontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.goalMet
                            ? 'Daily goal complete! 🎉'
                            : 'Today\'s Reading',
                        style: TextStyle(
                          fontFamily: AppTheme.latinFontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: data.goalMet
                              ? AppColors.success
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${data.ayahsReadToday} of ${data.dailyGoalAyahs} ayahs',
                        style: TextStyle(
                          fontFamily: AppTheme.latinFontFamily,
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Streak badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: data.currentStreak > 0
                        ? AppColors.secondary.withOpacity(0.1)
                        : (isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightBorder),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 14,
                        color: data.currentStreak > 0
                            ? AppColors.secondary
                            : (isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${data.currentStreak}d',
                        style: TextStyle(
                          fontFamily: AppTheme.latinFontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: data.currentStreak > 0
                              ? AppColors.secondary
                              : (isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Mini Calendar Heatmap ────────────────────────────────
            const SizedBox(height: 12),
            _buildHeatmap(data, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmap(DailyProgressData data, bool isDark) {
    final now = DateTime.now();
    final activityDates = <String>{};
    for (final d in data.last30DaysActivity) {
      activityDates.add(d.toIso8601String().substring(0, 10));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(30, (i) {
        final date = now.subtract(Duration(days: 29 - i));
        final key = date.toIso8601String().substring(0, 10);
        final isActive = activityDates.contains(key);
        final isToday = i == 29;

        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isToday
                ? AppColors.primary
                : isActive
                    ? AppColors.success
                    : (isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightBorder),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
