import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../providers/engagement_provider.dart';

// ═══════════════════════════════════════════════════════════════════
// Weekly Digest Screen
// ═══════════════════════════════════════════════════════════════════

class WeeklyDigestScreen extends ConsumerWidget {
  const WeeklyDigestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final data = ref.watch(engagementProvider);
    final notifier = ref.read(engagementProvider.notifier);
    final weeklyRecords = notifier.getWeeklyRecords();
    final mostReadSurah = notifier.getMostReadSurah();

    // Calculate weekly totals
    int weeklyAyahs = 0;
    int weeklyHadiths = 0;
    int weeklyMinutes = 0;
    int activeDays = 0;

    for (final record in weeklyRecords) {
      weeklyAyahs += record.ayahsRead;
      weeklyHadiths += record.hadithsRead;
      weeklyMinutes += record.minutesSpent;
      if (record.ayahsRead > 0 || record.hadithsRead > 0 || record.minutesSpent > 0) {
        activeDays++;
      }
    }

    final weekStart = DateTime.now().subtract(const Duration(days: 7));
    final weekLabel = '${DateFormat('MMM d').format(weekStart)} – ${DateFormat('MMM d, yyyy').format(DateTime.now())}';

    // Suggested reading for next week
    final suggestions = _getSuggestions(weeklyAyahs, data.currentStreak);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Digest'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Week label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(
                    weekLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 20),

            // Weekly summary card
            _SummaryCard(
              weeklyAyahs: weeklyAyahs,
              weeklyHadiths: weeklyHadiths,
              weeklyMinutes: weeklyMinutes,
              activeDays: activeDays,
              mostReadSurah: mostReadSurah,
              currentStreak: data.currentStreak,
              isDark: isDark,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms),

            const SizedBox(height: 16),

            // Daily breakdown
            Text(
              'Daily Breakdown',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 200.ms),
            const SizedBox(height: 10),

            if (weeklyRecords.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.inbox_rounded, size: 48, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                    const SizedBox(height: 12),
                    Text(
                      'No activity recorded this week',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start reading the Quran or hadiths to see your weekly summary here.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...weeklyRecords.asMap().entries.map((entry) {
                return _DayRow(
                  record: entry.value,
                  index: entry.key,
                  isDark: isDark,
                );
              }),

            const SizedBox(height: 20),

            // Suggested reading for next week
            Text(
              'Suggested Reading for Next Week',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 300.ms),
            const SizedBox(height: 10),

            ...suggestions.asMap().entries.map((entry) {
              return _SuggestionCard(
                suggestion: entry.value,
                index: entry.key,
                onTap: () {
                  if (entry.value.route != null) {
                    context.push(entry.value.route!);
                  }
                },
              );
            }),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  List<_Suggestion> _getSuggestions(int weeklyAyahs, int streak) {
    if (weeklyAyahs < 50) {
      return [
        _Suggestion(
          icon: Icons.auto_stories_rounded,
          title: 'Read Surah Al-Mulk (67)',
          description: 'A short surah (30 ayahs) that the Prophet ﷺ recommended reading every night for protection.',
          color: AppColors.primary,
          route: '/quran/67',
        ),
        _Suggestion(
          icon: Icons.menu_book_rounded,
          title: 'Explore Sahih al-Bukhari',
          description: 'Start with the Book of Revelation — the very first hadiths in the most authentic collection.',
          color: AppColors.secondary,
          route: '/hadith/collection/bukhari',
        ),
        _Suggestion(
          icon: Icons.local_fire_department_rounded,
          title: 'Maintain Your Streak',
          description: streak > 0
              ? 'Great job on your $streak-day streak! Keep reading daily to maintain it.'
              : 'Start a reading streak today. Even one ayah a day makes a difference!',
          color: AppColors.hifdhGreen,
          route: '/engagement',
        ),
      ];
    } else if (weeklyAyahs < 150) {
      return [
        _Suggestion(
          icon: Icons.auto_stories_rounded,
          title: 'Read Surah Al-Kahf (18)',
          description: 'The Prophet ﷺ encouraged reading it every Friday. It has 110 ayahs.',
          color: AppColors.primary,
          route: '/quran/18',
        ),
        _Suggestion(
          icon: Icons.explore_rounded,
          title: 'Explore Surah Yasin (36)',
          description: 'Known as the heart of the Quran. Read it for blessings and reflection.',
          color: AppColors.revisionBlue,
          route: '/quran/36',
        ),
        _Suggestion(
          icon: Icons.timeline_rounded,
          title: 'Set a Reading Goal',
          description: 'Try reading at least 5 pages a day to complete the Quran in about 5 months.',
          color: AppColors.secondary,
          route: '/reading-plan',
        ),
      ];
    } else {
      return [
        _Suggestion(
          icon: Icons.mosque_rounded,
          title: 'Explore Juz Amma',
          description: 'The 30th juz contains the shortest surahs. Perfect for memorization practice.',
          color: AppColors.primary,
          route: '/quran',
        ),
        _Suggestion(
          icon: Icons.military_tech_rounded,
          title: 'Start a Hifdh Plan',
          description: 'With your strong reading habit, you\'re ready for a structured memorization plan.',
          color: AppColors.hifdhGreen,
          route: '/hifdh',
        ),
        _Suggestion(
          icon: Icons.tips_and_updates_rounded,
          title: 'Study Hadith Grading',
          description: 'Learn about Sahih, Hasan, Da\'if and Maudu\' to better understand hadith authenticity.',
          color: AppColors.warning,
          route: '/hadith/grading',
        ),
      ];
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// Summary Card
// ═══════════════════════════════════════════════════════════════════

class _SummaryCard extends StatelessWidget {
  final int weeklyAyahs;
  final int weeklyHadiths;
  final int weeklyMinutes;
  final int activeDays;
  final String mostReadSurah;
  final int currentStreak;
  final bool isDark;

  const _SummaryCard({
    required this.weeklyAyahs,
    required this.weeklyHadiths,
    required this.weeklyMinutes,
    required this.activeDays,
    required this.mostReadSurah,
    required this.currentStreak,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.12),
            AppColors.secondary.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.summarize_rounded, size: 24, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                'Weekly Summary',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats rows
          _SummaryRow(
            icon: Icons.auto_stories_rounded,
            label: 'Ayahs Read',
            value: '$weeklyAyahs',
            color: AppColors.primary,
          ),
          _SummaryRow(
            icon: Icons.menu_book_rounded,
            label: 'Hadiths Read',
            value: '$weeklyHadiths',
            color: AppColors.secondary,
          ),
          _SummaryRow(
            icon: Icons.timer_rounded,
            label: 'Time Spent',
            value: '$weeklyMinutes min',
            color: AppColors.revisionBlue,
          ),
          _SummaryRow(
            icon: Icons.calendar_today_rounded,
            label: 'Active Days',
            value: '$activeDays / 7',
            color: AppColors.hifdhGreen,
          ),
          _SummaryRow(
            icon: Icons.local_fire_department_rounded,
            label: 'Current Streak',
            value: '$currentStreak days',
            color: AppColors.warning,
          ),
          _SummaryRow(
            icon: Icons.star_rounded,
            label: 'Most Read Surah',
            value: mostReadSurah,
            color: AppColors.medinanBadge,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Day Row
// ═══════════════════════════════════════════════════════════════════

class _DayRow extends StatelessWidget {
  final DailyRecord record;
  final int index;
  final bool isDark;

  const _DayRow({required this.record, required this.index, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayName = DateFormat('EEEE').format(record.date);
    final dateStr = DateFormat('MMM d').format(record.date);
    final totalActivity = record.ayahsRead + record.hadithsRead + record.minutesSpent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  dateStr,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (record.ayahsRead > 0)
              Text(
                '${record.ayahsRead} verses',
                style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            if (record.ayahsRead > 0 && record.hadithsRead > 0)
              Text(' · ', style: TextStyle(fontSize: 12, color: AppColors.darkTextTertiary)),
            if (record.hadithsRead > 0)
              Text(
                '${record.hadithsRead} hadiths',
                style: TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600),
              ),
            if (totalActivity == 0)
              Text(
                'No activity',
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms, duration: 250.ms);
  }
}

// ═══════════════════════════════════════════════════════════════════
// Suggestion
// ═══════════════════════════════════════════════════════════════════

class _Suggestion {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String? route;

  const _Suggestion({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.route,
  });
}

class _SuggestionCard extends StatelessWidget {
  final _Suggestion suggestion;
  final int index;
  final VoidCallback onTap;

  const _SuggestionCard({required this.suggestion, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: suggestion.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(suggestion.icon, size: 22, color: suggestion.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      suggestion.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.5,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 80).ms, duration: 300.ms);
  }
}
