import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/stats_provider.dart';

/// Reading insights dashboard with statistics, charts, and history.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Statistics'),
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Failed to load stats: $error',
                  style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        data: (stats) => _buildContent(context, stats),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ReadingStats stats) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // ── Quick Stats Grid ────────────────────────────────────
        _SectionTitle(title: 'Overview', icon: Icons.insights_rounded),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _StatCard(
                    icon: Icons.today_rounded,
                    label: 'Today',
                    value: '${stats.ayahsToday}',
                    unit: 'ayahs',
                    color: AppColors.primary,
                    delay: 0,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(
                    icon: Icons.date_range_rounded,
                    label: 'This Week',
                    value: '${stats.ayahsThisWeek}',
                    unit: 'ayahs',
                    color: AppColors.secondary,
                    delay: 50,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(
                    icon: Icons.calendar_month_rounded,
                    label: 'This Month',
                    value: '${stats.ayahsThisMonth}',
                    unit: 'ayahs',
                    color: AppColors.revisionBlue,
                    delay: 100,
                  )),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _StatCard(
                    icon: Icons.library_books_rounded,
                    label: 'All Time',
                    value: '${stats.ayahsAllTime}',
                    unit: 'ayahs',
                    color: AppColors.hifdhGreen,
                    delay: 150,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Streak',
                    value: '${stats.currentStreak}',
                    unit: 'days',
                    color: AppColors.error,
                    delay: 200,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(
                    icon: Icons.trending_up_rounded,
                    label: 'Daily Avg',
                    value: stats.averageDaily.toStringAsFixed(1),
                    unit: 'ayahs',
                    color: AppColors.info,
                    delay: 250,
                  )),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Reading Time & Longest Streak ──────────────────────────
        _SectionTitle(title: 'Milestones', icon: Icons.emoji_events_rounded),
        _Card(
          child: Row(
            children: [
              Expanded(
                child: _MilestoneItem(
                  icon: Icons.timer_rounded,
                  iconColor: AppColors.secondary,
                  label: 'Total Reading Time',
                  value: _formatMinutes(stats.totalReadingTimeMinutes),
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.darkBorder),
              Expanded(
                child: _MilestoneItem(
                  icon: Icons.workspace_premium_rounded,
                  iconColor: AppColors.bookmarkGold,
                  label: 'Longest Streak',
                  value: '${stats.longestStreak} days',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Most Read Surahs Chart ────────────────────────────────
        if (stats.mostReadSurahs.isNotEmpty) ...[
          _SectionTitle(title: 'Most Read Surahs', icon: Icons.bar_chart_rounded),
          _Card(
            child: _buildMostReadChart(stats),
          ),
          const SizedBox(height: 16),
        ],

        // ── Daily History ─────────────────────────────────────────
        if (stats.dailyHistory.isNotEmpty) ...[
          _SectionTitle(title: 'Last 30 Days', icon: Icons.show_chart_rounded),
          _Card(
            child: _buildDailyChart(stats),
          ),
          const SizedBox(height: 16),
        ],

        const SizedBox(height: 40),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Charts
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildMostReadChart(ReadingStats stats) {
    final surahs = stats.mostReadSurahs.take(7).toList();
    final maxY = surahs.isEmpty
        ? 1
        : surahs.map((s) => s.ayahsRead).reduce((a, b) => a > b ? a : b).toDouble();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 220,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY * 1.2,
            barGroups: surahs.asMap().entries.map((entry) {
              final index = entry.key;
              final surah = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: surah.ayahsRead.toDouble(),
                    width: 20,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.6),
                        AppColors.primary,
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= surahs.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${surahs[idx].surahNumber}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                  reservedSize: 30,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const SizedBox();
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: AppColors.darkTextTertiary,
                      ),
                    );
                  },
                ),
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
              horizontalInterval: maxY / 4,
              getDrawingHorizontalLine: (value) => FlLine(
                color: AppColors.darkBorder.withValues(alpha: 0.3),
                strokeWidth: 0.5,
                dashArray: [4, 4],
              ),
            ),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyChart(ReadingStats stats) {
    final history = stats.dailyHistory;
    final maxY = history.isEmpty
        ? 1
        : history.map((d) => d.ayahsRead).reduce((a, b) => a > b ? a : b).toDouble();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: maxY * 1.2,
            lineBarsData: [
              LineChartBarData(
                spots: history.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value.ayahsRead.toDouble());
                }).toList(),
                isCurved: true,
                color: AppColors.primary,
                barWidth: 2,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.25),
                      AppColors.primary.withValues(alpha: 0.02),
                    ],
                  ),
                ),
              ),
            ],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 6,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= history.length) return const SizedBox();
                    final date = history[idx].date;
                    return Text(
                      DateFormat('MMM d').format(date),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        color: AppColors.darkTextTertiary,
                      ),
                    );
                  },
                  reservedSize: 28,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const SizedBox();
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: AppColors.darkTextTertiary,
                      ),
                    );
                  },
                ),
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
              horizontalInterval: maxY / 4,
              getDrawingHorizontalLine: (value) => FlLine(
                color: AppColors.darkBorder.withValues(alpha: 0.3),
                strokeWidth: 0.5,
                dashArray: [4, 4],
              ),
            ),
            borderData: FlBorderData(show: false),
            tooltipData: LineChartTooltipData(
              getTooltipColor: (_) => AppColors.darkSurface,
              tooltipRoundedRadius: 8,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final idx = spot.x.toInt();
                  final date = idx < history.length ? history[idx].date : null;
                  return LineTooltipItem(
                    '${date != null ? DateFormat('MMM d').format(date) : ''}\n',
                    const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.darkTextSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: '${spot.y.toInt()} ayahs',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '$hours h $mins min' : '$hours h';
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Reusable Widgets
// ═══════════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBorder
              : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: child,
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;
  final int delay;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: delay))
        .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: Duration(milliseconds: delay));
  }
}

class _MilestoneItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _MilestoneItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
