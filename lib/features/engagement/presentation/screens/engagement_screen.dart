import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../providers/engagement_provider.dart';

// ═══════════════════════════════════════════════════════════════════
// Engagement / Streak Tracker Screen
// ═══════════════════════════════════════════════════════════════════

class EngagementScreen extends ConsumerWidget {
  const EngagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final data = ref.watch(engagementProvider);
    final motivational = ref.read(engagementProvider.notifier).getMotivationalMessage();
    final milestones = ref.read(engagementProvider.notifier).getMilestones();
    final weeklyRecords = ref.read(engagementProvider.notifier).getWeeklyRecords();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.data_usage_rounded),
            onPressed: () {
              // Simulate recording activity for demo
              ref.read(engagementProvider.notifier).recordAppOpen();
            },
            tooltip: 'Record Activity',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Streak banner
            _StreakBanner(
              currentStreak: data.currentStreak,
              longestStreak: data.longestStreak,
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.95, 0.95)),

            const SizedBox(height: 16),

            // Motivational message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      motivational,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms),

            const SizedBox(height: 20),

            // Stats grid
            _StatsGrid(data: data, isDark: isDark)
                .animate()
                .fadeIn(duration: 400.ms, delay: 150.ms),

            const SizedBox(height: 20),

            // Milestones
            Text(
              'Milestones',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 200.ms),
            const SizedBox(height: 10),
            _MilestonesList(milestones: milestones, isDark: isDark)
                .animate()
                .fadeIn(duration: 400.ms, delay: 250.ms),

            const SizedBox(height: 20),

            // Weekly activity
            Text(
              'This Week',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 300.ms),
            const SizedBox(height: 10),
            _WeeklyActivityGrid(records: weeklyRecords, isDark: isDark)
                .animate()
                .fadeIn(duration: 400.ms, delay: 350.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Streak Banner
// ═══════════════════════════════════════════════════════════════════

class _StreakBanner extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const _StreakBanner({required this.currentStreak, required this.longestStreak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 32),
              const SizedBox(width: 10),
              Text(
                '$currentStreak',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day Streak',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    'Keep it going!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events_rounded, size: 16, color: AppColors.secondaryLight),
                const SizedBox(width: 8),
                Text(
                  'Longest: $longestStreak days',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Stats Grid
// ═══════════════════════════════════════════════════════════════════

class _StatsGrid extends StatelessWidget {
  final EngagementData data;
  final bool isDark;

  const _StatsGrid({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Statistics',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: [
            _StatCard(
              icon: Icons.auto_stories_rounded,
              label: 'Ayahs Read',
              value: '${data.totalAyahsRead}',
              color: AppColors.primary,
              isDark: isDark,
            ),
            _StatCard(
              icon: Icons.menu_book_rounded,
              label: 'Hadiths Read',
              value: '${data.totalHadithsRead}',
              color: AppColors.secondary,
              isDark: isDark,
            ),
            _StatCard(
              icon: Icons.timer_rounded,
              label: 'Minutes',
              value: '${data.totalMinutesSpent}',
              color: AppColors.revisionBlue,
              isDark: isDark,
            ),
            _StatCard(
              icon: Icons.calendar_today_rounded,
              label: 'Sessions',
              value: '${data.totalSessions}',
              color: AppColors.hifdhGreen,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Milestones List
// ═══════════════════════════════════════════════════════════════════

class _MilestonesList extends StatelessWidget {
  final List<Milestone> milestones;
  final bool isDark;

  const _MilestonesList({required this.milestones, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: milestones.map((m) {
          return Container(
            width: 90,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: m.achieved
                  ? AppColors.hifdhGreen.withOpacity(0.1)
                  : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: m.achieved
                    ? AppColors.hifdhGreen.withOpacity(0.3)
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  m.icon,
                  size: 24,
                  color: m.achieved ? AppColors.hifdhGreen : AppColors.darkTextTertiary,
                ),
                const SizedBox(height: 6),
                Text(
                  m.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: m.achieved ? AppColors.hifdhGreen : AppColors.darkTextTertiary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Weekly Activity Grid
// ═══════════════════════════════════════════════════════════════════

class _WeeklyActivityGrid extends StatelessWidget {
  final List<DailyRecord> records;
  final bool isDark;

  const _WeeklyActivityGrid({required this.records, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Build a map of day -> record for the last 7 days
    final dayMap = <int, DailyRecord>{};
    for (final record in records) {
      final dayDiff = now.difference(record.date).inDays;
      if (dayDiff >= 0 && dayDiff < 7) {
        dayMap[dayDiff] = record;
      }
    }

    // Calculate max activity for color intensity
    int maxActivity = 1;
    for (final record in records) {
      final total = record.ayahsRead + record.hadithsRead + record.minutesSpent;
      if (total > maxActivity) maxActivity = total;
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              // daysAgo: 6 (oldest) to 0 (today)
              final daysAgo = 6 - index;
              final adjustedDay = (now.weekday - 1 - index + 7) % 7;
              final record = dayMap[daysAgo];
              final hasActivity = record != null && (record.ayahsRead + record.hadithsRead + record.minutesSpent) > 0;
              final activity = record != null ? record.ayahsRead + record.hadithsRead + record.minutesSpent : 0;
              final intensity = maxActivity > 0 ? (activity / maxActivity).clamp(0.0, 1.0) : 0.0;

              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: hasActivity
                          ? AppColors.primary.withOpacity(0.2 + intensity * 0.8)
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: hasActivity
                        ? Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayNames[adjustedDay],
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Less',
                style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
              ),
              const SizedBox(width: 4),
              Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 4),
              Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.5), borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 4),
              Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.8), borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 4),
              Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 4),
              Text(
                'More',
                style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
