import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════
// Daily Tracker Screen
// ═══════════════════════════════════════════════════════════════════

class HadithDailyTrackerScreen extends StatefulWidget {
  const HadithDailyTrackerScreen({super.key});

  @override
  State<HadithDailyTrackerScreen> createState() => _HadithDailyTrackerScreenState();
}

class _HadithDailyTrackerScreenState extends State<HadithDailyTrackerScreen> {
  Map<String, int> _dailyCounts = {};
  int _todayCount = 0;
  final TextEditingController _countController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _loadData() {
    try {
      final box = Hive.box('hadith_daily_tracker');
      final raw = box.get('daily_counts') as Map? ?? {};
      _dailyCounts = raw.map((k, v) => MapEntry(k.toString(), v as int));
      _todayCount = _dailyCounts[_dateKey(DateTime.now())] ?? 0;
      setState(() {});
    } catch (_) {
      setState(() {});
    }
  }

  Future<void> _saveToday(int count) async {
    final today = _dateKey(DateTime.now());
    _dailyCounts[today] = count;
    try {
      final box = Hive.box('hadith_daily_tracker');
      await box.put('daily_counts', _dailyCounts);
    } catch (_) {}
    setState(() => _todayCount = count);
  }

  int get _currentStreak {
    final today = DateTime.now();
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final key = _dateKey(date);
      if (_dailyCounts.containsKey(key) && _dailyCounts[key]! > 0) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  int get _longestStreak {
    if (_dailyCounts.isEmpty) return 0;
    final sorted = _dailyCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    int maxStreak = 0, current = 0;
    DateTime? prevDate;
    for (final entry in sorted) {
      final parts = entry.key.split('-');
      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      if (entry.value > 0) {
        if (prevDate == null || date.difference(prevDate).inDays == 1) {
          current++;
        } else {
          current = 1;
        }
        maxStreak = maxStreak > current ? maxStreak : current;
        prevDate = date;
      } else {
        current = 0;
        prevDate = null;
      }
    }
    return maxStreak;
  }

  int get _totalHadithsThisMonth {
    final now = DateTime.now();
    return _dailyCounts.entries
        .where((e) {
          final parts = e.key.split('-');
          return int.parse(parts[0]) == now.year && int.parse(parts[1]) == now.month;
        })
        .fold(0, (sum, e) => sum + e.value);
  }

  int get _totalHadithsAllTime => _dailyCounts.values.fold(0, (sum, v) => sum + v);

  int get _activeDays => _dailyCounts.values.where((v) => v > 0).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tracker'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Today's counter
          _TodayCounter(
            count: _todayCount,
            isDark: isDark,
            onAdd: () => _saveToday(_todayCount + 1),
            onRemove: () => _saveToday((_todayCount - 1).clamp(0, 9999)),
            onSet: (val) => _saveToday(val),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 20),

          // Streak cards
          Row(
            children: [
              Expanded(
                child: _StreakCard(
                  label: 'Current Streak',
                  value: '$_currentStreak days',
                  icon: Icons.local_fire_department_rounded,
                  color: const Color(0xFFF97316),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StreakCard(
                  label: 'Best Streak',
                  value: '$_longestStreak days',
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.secondary,
                  isDark: isDark,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _StreakCard(
                  label: 'This Month',
                  value: '$_totalHadithsThisMonth hadiths',
                  icon: Icons.calendar_month_rounded,
                  color: AppColors.primary,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StreakCard(
                  label: 'All Time',
                  value: '$_totalHadithsAllTime',
                  icon: Icons.auto_stories_rounded,
                  color: AppColors.hifdhGreen,
                  isDark: isDark,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

          const SizedBox(height: 8),

          // Active days badge
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '$_activeDays active days total',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Calendar heatmap
          Text(
            'Last 35 Days',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _CalendarHeatmap(
            dailyCounts: _dailyCounts,
            isDark: isDark,
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

          const SizedBox(height: 24),

          // Recent log
          Text(
            'Recent Activity',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ..._buildRecentLog(theme, isDark),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  List<Widget> _buildRecentLog(ThemeData theme, bool isDark) {
    final sorted = _dailyCounts.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    final recent = sorted.take(10).toList();
    if (recent.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'No activity yet. Start tracking today!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
          ),
        ),
      ];
    }

    return recent.map((entry) {
      final date = DateTime.tryParse(entry.key);
      final formatted = date != null ? DateFormat('MMM d, EEE').format(date) : entry.key;
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: ListTile(
          dense: true,
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${entry.value}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          title: Text(formatted, style: theme.textTheme.bodySmall),
          trailing: Text(
            '${entry.value} hadiths',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }).toList();
  }
}

// ═══════════════════════════════════════════════════════════════════
// Today Counter
// ═══════════════════════════════════════════════════════════════════

class _TodayCounter extends StatelessWidget {
  final int count;
  final bool isDark;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final void Function(int) onSet;

  const _TodayCounter({
    required this.count,
    required this.isDark,
    required this.onAdd,
    required this.onRemove,
    required this.onSet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Today\'s Reading',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CountButton(
                  icon: Icons.remove_rounded,
                  onTap: onRemove,
                  color: AppColors.error.withOpacity(0.1),
                  iconColor: AppColors.error,
                ),
                const SizedBox(width: 32),
                Text(
                  '$count',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontSize: 56,
                  ),
                ),
                const SizedBox(width: 32),
                _CountButton(
                  icon: Icons.add_rounded,
                  onTap: onAdd,
                  color: AppColors.hifdhGreen.withOpacity(0.1),
                  iconColor: AppColors.hifdhGreen,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'hadiths read',
              style: theme.textTheme.labelMedium?.copyWith(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 120,
              child: OutlinedButton.icon(
                onPressed: () => _showSetDialog(context),
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Set Count', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSetDialog(BuildContext context) {
    final controller = TextEditingController(text: '$count');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Set Today\'s Count'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Number of hadiths'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final val = int.tryParse(controller.text) ?? 0;
                onSet(val.clamp(0, 9999));
                Navigator.pop(ctx);
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }
}

class _CountButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color iconColor;

  const _CountButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Streak Card
// ═══════════════════════════════════════════════════════════════════

class _StreakCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StreakCard({
    required this.label,
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
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: theme.textTheme.titleSmall?.copyWith(
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
// Calendar Heatmap
// ═══════════════════════════════════════════════════════════════════

class _CalendarHeatmap extends StatelessWidget {
  final Map<String, int> dailyCounts;
  final bool isDark;

  const _CalendarHeatmap({required this.dailyCounts, required this.isDark});

  String _dateKey(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    const totalDays = 35;
    final days = <_DayCell>[];

    for (int i = totalDays - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = _dateKey(date);
      final count = dailyCounts[key] ?? 0;
      final dayName = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1];
      days.add(_DayCell(
        dayName: dayName,
        day: date.day,
        count: count,
        isToday: i == 0,
      ));
    }

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
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) => days[index],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final String dayName;
  final int day;
  final int count;
  final bool isToday;

  const _DayCell({
    required this.dayName,
    required this.day,
    required this.count,
    required this.isToday,
  });

  Color get _cellColor {
    if (count == 0) return AppColors.darkBorder.withOpacity(0.5);
    if (count <= 5) return AppColors.primary.withOpacity(0.3);
    if (count <= 10) return AppColors.primary.withOpacity(0.5);
    if (count <= 15) return AppColors.primary.withOpacity(0.7);
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dayName,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 9,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w400,
            color: isToday ? AppColors.primary : AppColors.darkTextTertiary,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _cellColor,
            borderRadius: BorderRadius.circular(8),
            border: isToday
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: count > 10 ? Colors.white : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
