import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../data/models/quran/surah_info.dart';
import '../../../../core/services/database/database.dart';
import '../providers/hifdh_providers.dart';
import '../widgets/memorization_progress_card.dart';

class HifdhDashboardScreen extends ConsumerWidget {
  const HifdhDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statsAsync = ref.watch(hifzhStatsProvider);
    final chartAsync = ref.watch(weeklyChartDataProvider);
    final surahsAsync = ref.watch(surahListForHifdhProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memorization'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {},
            tooltip: 'Revision History',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(hifzhStatsProvider);
          ref.invalidate(weeklyChartDataProvider);
        },
        child: statsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
          error: (error, _) => _ErrorBody(message: error.toString()),
          data: (stats) => ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const SizedBox(height: 8),

              // ── Header greeting ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Your Hifdh Journey',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Stay consistent — even a few ayahs a day matters.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Overview Stats Row ──────────────────────────────
              _StatsRow(stats: stats),
              const SizedBox(height: 20),

              // ── Weekly Progress Chart ────────────────────────────
              _WeeklyChartSection(
                chartAsync: chartAsync,
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              // ── Quick Actions ────────────────────────────────────
              _QuickActionsSection(ref: ref),
              const SizedBox(height: 20),

              // ── Due Revisions ────────────────────────────────────
              if (stats.dueReviewItems.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Due for Revision',
                  subtitle: '${stats.dueReviewItems.length} ayahs need review',
                  icon: Icons.schedule_rounded,
                  iconColor: AppColors.warning,
                ),
                const SizedBox(height: 8),
                ...stats.dueReviewItems.take(5).map(
                  (item) => _DueRevisionCard(
                    item: item,
                    surahsAsync: surahsAsync,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── Weak Areas ───────────────────────────────────────
              if (stats.weakAreas.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Weak Areas',
                  subtitle: '${stats.weakAreas.length} areas need attention',
                  icon: Icons.warning_amber_rounded,
                  iconColor: AppColors.error,
                ),
                const SizedBox(height: 8),
                ...stats.weakAreas.take(5).map(
                  (mistake) => _WeakAreaCard(
                    mistake: mistake,
                    surahsAsync: surahsAsync,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── Surah Progress List ──────────────────────────────
              _SectionHeader(
                title: 'Surah Progress',
                subtitle: '${stats.progressBySurah.length} surahs tracked',
                icon: Icons.auto_stories_rounded,
                iconColor: AppColors.primary,
              ),
              const SizedBox(height: 8),
              surahsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (surahs) {
                  final trackedSurahs = surahs
                      .where((s) => stats.progressBySurah.containsKey(s.number))
                      .toList();

                  if (trackedSurahs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 48,
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No surahs tracked yet',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Start memorizing to see progress here.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: trackedSurahs.map((surah) {
                      final progress = stats.progressBySurah[surah.number] ?? [];
                      return MemorizationProgressCard(
                        surahInfo: surah,
                        progress: progress,
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Stats Row
// ═══════════════════════════════════════════════════════════════════

class _StatsRow extends StatelessWidget {
  final HifzhStats stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatCard(
            label: 'Memorized',
            value: '${stats.totalMemorized + stats.totalMastered}',
            subtitle: '/6236 ayahs',
            icon: Icons.check_circle_rounded,
            color: AppColors.hifdhGreen,
            isDark: isDark,
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
          const SizedBox(width: 10),
          _StatCard(
            label: 'Juz Done',
            value: '${stats.juzCompleted}',
            subtitle: '/30 juz',
            icon: Icons.library_books_rounded,
            color: AppColors.primary,
            isDark: isDark,
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: -0.1, end: 0),
          const SizedBox(width: 10),
          _StatCard(
            label: 'Streak',
            value: '${stats.currentStreak}',
            subtitle: 'days',
            icon: Icons.local_fire_department_rounded,
            color: AppColors.secondary,
            isDark: isDark,
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideX(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
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
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Weekly Chart
// ═══════════════════════════════════════════════════════════════════

class _WeeklyChartSection extends StatelessWidget {
  final AsyncValue<List<DailyChartData>> chartAsync;
  final bool isDark;

  const _WeeklyChartSection({required this.chartAsync, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'This Week',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: chartAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
                error: (_, __) => const Center(
                  child: Text('Unable to load chart data'),
                ),
                data: (data) => _WeeklyBarChart(data: data, isDark: isDark),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final List<DailyChartData> data;
  final bool isDark;

  const _WeeklyBarChart({required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No activity this week'));
    }

    final maxVal = data.fold<double>(
      1,
      (max, d) => d.reviewsCompleted > max ? d.reviewsCompleted.toDouble() : max,
    );

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final day = data[group.x.toInt()];
              return BarTooltipItem(
                '${day.reviewsCompleted} reviews\n${day.newAyahs} new',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= data.length) return const SizedBox.shrink();
                final day = data[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat.E().format(day.date),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              );
            },
            reservedSize: 28,
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxVal > 5 ? (maxVal / 4).ceilToDouble() : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            strokeWidth: 0.5,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final idx = entry.key;
          final day = entry.value;
          return BarChartGroupData(
            x: idx,
            barRods: [
              BarChartRodData(
                toY: day.reviewsCompleted.toDouble(),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                width: 28,
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.6),
                    AppColors.primaryLight,
                  ],
                ),
              ),
            ],
          );
        }).toList(),
        maxY: (maxVal * 1.3).ceilToDouble().clamp(1.0, double.infinity),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Quick Actions
// ═══════════════════════════════════════════════════════════════════

class _QuickActionsSection extends StatelessWidget {
  final WidgetRef ref;
  const _QuickActionsSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on_rounded, size: 18, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ActionChip(
                icon: Icons.replay_rounded,
                label: 'Start Revision',
                color: AppColors.revisionBlue,
                isDark: isDark,
                onTap: () => context.push('/hifdh/test'),
              ),
              const SizedBox(width: 10),
              _ActionChip(
                icon: Icons.add_circle_rounded,
                label: 'New Memorization',
                color: AppColors.hifdhGreen,
                isDark: isDark,
                onTap: () => context.push('/hifdh/test'),
              ),
              const SizedBox(width: 10),
              _ActionChip(
                icon: Icons.quiz_rounded,
                label: 'Test Mode',
                color: AppColors.secondary,
                isDark: isDark,
                onTap: () => context.push('/hifdh/test'),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Due Revision Card
// ═══════════════════════════════════════════════════════════════════

class _DueRevisionCard extends StatelessWidget {
  final MemorizationProgress item;
  final AsyncValue<List<SurahInfo>> surahsAsync;

  const _DueRevisionCard({required this.item, required this.surahsAsync});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final surahName = surahsAsync.whenOrNull(
      data: (surahs) => surahs
          .where((s) => s.number == item.surahNumber)
          .firstOrNull?.nameEnglish,
    ) ?? 'Surah ${item.surahNumber}';

    final daysOverdue = item.nextReviewDate != null
        ? DateTime.now().difference(item.nextReviewDate!).inDays
        : 0;

    final dueLabel = daysOverdue <= 0
        ? 'Due today'
        : daysOverdue == 1
            ? '1 day overdue'
            : '$daysOverdue days overdue';

    final dueColor = daysOverdue <= 0
        ? AppColors.warning
        : daysOverdue <= 3
            ? AppColors.secondary
            : AppColors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              size: 20,
              color: AppColors.warning,
            ),
          ),
          title: Text(
            '$surahName : ${item.ayahNumber}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: dueColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  dueLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: dueColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Rep: ${item.repetitions}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          trailing: FilledButton.tonal(
            onPressed: () => context.push('/hifdh/test'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              textStyle: theme.textTheme.labelSmall,
            ),
            child: const Text('Review'),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Weak Area Card
// ═══════════════════════════════════════════════════════════════════

class _WeakAreaCard extends StatelessWidget {
  final MistakeLog mistake;
  final AsyncValue<List<SurahInfo>> surahsAsync;

  const _WeakAreaCard({required this.mistake, required this.surahsAsync});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final surahName = surahsAsync.whenOrNull(
      data: (surahs) => surahs
          .where((s) => s.number == mistake.surahNumber)
          .firstOrNull?.nameEnglish,
    ) ?? 'Surah ${mistake.surahNumber}';

    final mistakeLabel = mistake.mistakeType.replaceAll('_', ' ').split(' ').map(
      (w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}',
    ).join(' ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 20,
              color: AppColors.error,
            ),
          ),
          title: Text(
            '$surahName : ${mistake.ayahNumber}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Row(
            children: [
              Text(
                mistakeLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Reviewed ${mistake.reviewCount}x',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onPressed: () => context.push('/quran/${mistake.surahNumber}'),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Section Header
// ═══════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Error Body
// ═══════════════════════════════════════════════════════════════════

class _ErrorBody extends StatelessWidget {
  final String message;
  const _ErrorBody({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
