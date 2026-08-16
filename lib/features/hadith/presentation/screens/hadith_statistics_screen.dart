import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive/hive.dart';

import '../../../../app/theme/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════
// Reading Log Entry
// ═══════════════════════════════════════════════════════════════════

class HadithReadingLog {
  final DateTime date;
  final int hadithsRead;
  final String? collectionId;
  final int minutesSpent;

  const HadithReadingLog({
    required this.date,
    required this.hadithsRead,
    this.collectionId,
    required this.minutesSpent,
  });
}

// ═══════════════════════════════════════════════════════════════════
// Hadith Statistics Screen
// ═══════════════════════════════════════════════════════════════════

class HadithStatisticsScreen extends StatefulWidget {
  const HadithStatisticsScreen({super.key});

  @override
  State<HadithStatisticsScreen> createState() => _HadithStatisticsScreenState();
}

class _HadithStatisticsScreenState extends State<HadithStatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<HadithReadingLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLogs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadLogs() {
    try {
      final box = Hive.box('hadith_stats');
      final raw = box.get('reading_logs') as List? ?? [];
      _logs = raw.map((e) {
        final map = e as Map;
        return HadithReadingLog(
          date: DateTime.tryParse(map['date'] as String) ?? DateTime.now(),
          hadithsRead: map['hadithsRead'] as int? ?? 0,
          collectionId: map['collectionId'] as String?,
          minutesSpent: map['minutesSpent'] as int? ?? 0,
        );
      }).toList();
    } catch (_) {
      _logs = _generateSampleLogs();
    }
    setState(() => _isLoading = false);
  }

  List<HadithReadingLog> _generateSampleLogs() {
    final random = Random(42);
    final collections = ['bukhari', 'muslim', 'tirmidhi', 'abudawud', 'nasai', 'ibnmajah'];
    final now = DateTime.now();
    return List.generate(30, (i) {
      final date = now.subtract(Duration(days: 29 - i));
      return HadithReadingLog(
        date: date,
        hadithsRead: 2 + random.nextInt(18),
        collectionId: collections[random.nextInt(collections.length)],
        minutesSpent: 3 + random.nextInt(25),
      );
    });
  }

  // ── Computed Stats ──────────────────────────────────────────

  int get _totalHadithsRead => _logs.fold(0, (sum, log) => sum + log.hadithsRead);
  int get _totalMinutes => _logs.fold(0, (sum, log) => sum + log.minutesSpent);
  int get _currentStreak {
    if (_logs.isEmpty) return 0;
    final today = DateTime.now();
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final hasLog = _logs.any((l) {
        final lStr = '${l.date.year}-${l.date.month.toString().padLeft(2, '0')}-${l.date.day.toString().padLeft(2, '0')}';
        return lStr == dateStr;
      });
      if (hasLog) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  double get _dailyAverage {
    if (_logs.isEmpty) return 0;
    return _totalHadithsRead / _logs.length;
  }

  Map<String, int> get _collectionBreakdown {
    final map = <String, int>{};
    for (final log in _logs) {
      final col = log.collectionId ?? 'other';
      map[col] = (map[col] ?? 0) + log.hadithsRead;
    }
    return Map.fromEntries(map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadith Statistics'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Activity'),
            Tab(text: 'Collections'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(theme, isDark),
                _buildActivityTab(theme, isDark),
                _buildCollectionsTab(theme, isDark),
              ],
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Overview Tab
  // ═══════════════════════════════════════════════════════════════

  Widget _buildOverviewTab(ThemeData theme, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Streak card
        _StatHeroCard(
          title: 'Current Streak',
          value: '$_currentStreak days',
          icon: Icons.local_fire_department_rounded,
          color: const Color(0xFFF97316),
          isDark: isDark,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 12),

        // Stats grid
        Row(
          children: [
            Expanded(
              child: _StatHeroCard(
                title: 'Hadiths Read',
                value: '$_totalHadithsRead',
                icon: Icons.auto_stories_rounded,
                color: AppColors.primary,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatHeroCard(
                title: 'Daily Avg',
                value: _dailyAverage.toStringAsFixed(1),
                icon: Icons.trending_up_rounded,
                color: AppColors.hifdhGreen,
                isDark: isDark,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
        const SizedBox(height: 12),

        // Minutes
        _StatHeroCard(
          title: 'Total Reading Time',
          value: _totalMinutes < 60 ? '$_totalMinutes min' : '${(_totalMinutes / 60).toStringAsFixed(1)} hrs',
          icon: Icons.schedule_rounded,
          color: AppColors.secondary,
          isDark: isDark,
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

        const SizedBox(height: 24),

        // Week chart
        Text(
          'This Week',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _WeekChart(logs: _logs, isDark: isDark).animate().fadeIn(delay: 300.ms, duration: 400.ms),

        const SizedBox(height: 24),

        // Milestones
        Text(
          'Milestones',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ..._buildMilestones(theme, isDark),
      ],
    );
  }

  List<Widget> _buildMilestones(ThemeData theme, bool isDark) {
    final milestones = [
      (10, 'First 10 Hadiths', Icons.emoji_events_rounded),
      (50, '50 Hadiths Read', Icons.star_rounded),
      (100, 'Century of Hadiths', Icons.military_tech_rounded),
      (500, '500 Hadiths!', Icons.workspace_premium_rounded),
      (1000, '1000 Hadiths!', Icons.diamond_rounded),
    ];

    return milestones.map((m) {
      final target = m.$1 as int;
      final label = m.$2 as String;
      final icon = m.$3 as IconData;
      final progress = (_totalHadithsRead / target).clamp(0.0, 1.0);
      final isCompleted = _totalHadithsRead >= target;

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, size: 24, color: isCompleted ? AppColors.secondary : AppColors.darkTextTertiary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isCompleted ? FontWeight.w700 : FontWeight.w500,
                          color: isCompleted ? AppColors.secondary : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_totalHadithsRead}/$target',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  const Icon(Icons.check_circle_rounded, color: AppColors.hifdhGreen, size: 22),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // Activity Tab
  // ═══════════════════════════════════════════════════════════════

  Widget _buildActivityTab(ThemeData theme, bool isDark) {
    // Group by week
    final weekMap = <String, int>{};
    for (final log in _logs) {
      final weekStart = log.date.subtract(Duration(days: log.date.weekday - 1));
      final key = '${weekStart.month}/${weekStart.day}';
      weekMap[key] = (weekMap[key] ?? 0) + log.hadithsRead;
    }
    final weeks = weekMap.entries.toList().reversed.take(8).toList();
    final maxVal = weeks.isEmpty ? 1 : weeks.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Weekly Activity',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        if (weeks.isEmpty)
          _buildEmptyState(theme, isDark, 'No activity recorded yet')
        else
          ...weeks.asMap().entries.map((entry) {
            final week = entry.value;
            final height = (week.value / maxVal * 120).clamp(20.0, 120.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      week.key,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: height,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '${week.value} hadiths',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Collections Tab
  // ═══════════════════════════════════════════════════════════════

  Widget _buildCollectionsTab(ThemeData theme, bool isDark) {
    final breakdown = _collectionBreakdown;
    final total = _totalHadithsRead == 0 ? 1 : _totalHadithsRead;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Collection Breakdown',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        if (breakdown.isEmpty)
          _buildEmptyState(theme, isDark, 'No collection data yet')
        else
          ...breakdown.entries.asMap().entries.map((entry) {
            final colName = _formatCollectionName(entry.value.key);
            final count = entry.value.value;
            final pct = count / total;
            final colors = [
              AppColors.primary,
              AppColors.secondary,
              AppColors.hifdhGreen,
              const Color(0xFF7C3AED),
              const Color(0xFFEC4899),
              const Color(0xFFF97316),
            ];
            final color = colors[entry.key % colors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        colName,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '$count (${(pct * 100).toStringAsFixed(0)}%)',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 10,
                      backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  String _formatCollectionName(String id) {
    const names = {
      'bukhari': 'Sahih al-Bukhari',
      'muslim': 'Sahih Muslim',
      'tirmidhi': 'Sunan al-Tirmidhi',
      'abudawud': 'Sunan Abu Dawud',
      'nasai': "Sunan an-Nasa'i",
      'ibnmajah': 'Sunan Ibn Majah',
    };
    return names[id] ?? id;
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 48, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            const SizedBox(height: 16),
            Text(message, style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            )),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Stat Hero Card
// ═══════════════════════════════════════════════════════════════════

class _StatHeroCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatHeroCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Week Chart
// ═══════════════════════════════════════════════════════════════════

class _WeekChart extends StatelessWidget {
  final List<HadithReadingLog> logs;
  final bool isDark;

  const _WeekChart({required this.logs, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final weekData = List.generate(7, (i) {
      final date = weekStart.add(Duration(days: i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final dayLogs = logs.where((l) {
        final lStr = '${l.date.year}-${l.date.month.toString().padLeft(2, '0')}-${l.date.day.toString().padLeft(2, '0')}';
        return lStr == dateStr;
      });
      return dayLogs.fold(0, (sum, l) => sum + l.hadithsRead);
    });

    final maxVal = weekData.reduce((a, b) => a > b ? a : b).toDouble().clamp(1.0, double.infinity);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (i) {
            final val = weekData[i];
            final height = (val / maxVal * 80).clamp(8.0, 80.0);
            final isToday = i == (now.weekday - 1) % 7;

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (val > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '$val',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 28,
                  height: height,
                  decoration: BoxDecoration(
                    color: val == 0
                        ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                        : isToday
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  days[i],
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                    color: isToday ? AppColors.primary : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
