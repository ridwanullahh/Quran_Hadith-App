import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/hijri_provider.dart';

class HijriCalendarScreen extends ConsumerWidget {
  const HijriCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final currentHijri = ref.watch(currentHijriDateProvider);
    final monthData = ref.watch(hijriMonthProvider);
    final nav = ref.watch(calendarNavigationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hijri Calendar'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // ── Current Hijri Date Header ─────────────────────────────
          _CurrentDateHeader(currentHijri: currentHijri, isDark: isDark)
              .animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 16),

          // ── Month Navigator ───────────────────────────────────────
          _MonthNavigator(nav: nav, monthData: monthData)
              .animate().fadeIn(duration: 350.ms, delay: 100.ms),
          const SizedBox(height: 16),

          // ── Calendar Grid ─────────────────────────────────────────
          _CalendarGrid(monthData: monthData, isDark: isDark)
              .animate().fadeIn(duration: 400.ms, delay: 200.ms),
          const SizedBox(height: 16),

          // ── Upcoming Events ───────────────────────────────────────
          _UpcomingEvents(monthData: monthData, isDark: isDark)
              .animate().fadeIn(duration: 350.ms, delay: 300.ms),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Current Date Header
// ═══════════════════════════════════════════════════════════════════

class _CurrentDateHeader extends StatelessWidget {
  final HijriDate currentHijri;
  final bool isDark;

  const _CurrentDateHeader({required this.currentHijri, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkSurfaceVariant, AppColors.darkSurface]
              : [AppColors.primary.withValues(alpha: 0.08), AppColors.primary.withValues(alpha: 0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.secondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today',
                      style: TextStyle(
                        fontFamily: AppTheme.latinFontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${currentHijri.day} ${currentHijri.monthNameAr} ${currentHijri.year} هـ',
                      style: TextStyle(
                        fontFamily: AppTheme.arabicHeaderFontFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${currentHijri.day} ${currentHijri.monthNameEn} ${currentHijri.year} AH',
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
            ),
          ),
          if (currentHijri.gregorianEquivalent != null) ...[
            const SizedBox(height: 4),
            Text(
              _gregorianFormatted(currentHijri.gregorianEquivalent!),
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _gregorianFormatted(DateTime d) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[d.month]} ${d.day}, ${d.year}';
  }
}

// ═══════════════════════════════════════════════════════════════════
// Month Navigator
// ═══════════════════════════════════════════════════════════════════

class _MonthNavigator extends ConsumerWidget {
  final CalendarNavigation nav;
  final HijriMonth monthData;

  const _MonthNavigator({required this.nav, required this.monthData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () => _navigate(ref, -1),
            color: AppColors.primary,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  monthData.monthNameAr,
                  style: TextStyle(
                    fontFamily: AppTheme.arabicHeaderFontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  '${monthData.monthNameEn} ${monthData.year} AH',
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () => _navigate(ref, 1),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  void _navigate(WidgetRef ref, int delta) {
    final nav = ref.read(calendarNavigationProvider);
    var month = nav.hijriMonth + delta;
    var year = nav.hijriYear;
    if (month > 12) { month = 1; year++; }
    if (month < 1) { month = 12; year--; }
    ref.read(calendarNavigationProvider.notifier).state =
        CalendarNavigation(hijriYear: year, hijriMonth: month);
  }
}

// ═══════════════════════════════════════════════════════════════════
// Calendar Grid
// ═══════════════════════════════════════════════════════════════════

class _CalendarGrid extends StatelessWidget {
  final HijriMonth monthData;
  final bool isDark;

  const _CalendarGrid({required this.monthData, required this.isDark});

  @override
  Widget build(BuildContext context) {
    const weekdaysAr = ['إثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت', 'أحد'];
    const weekdaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Weekday headers
          Row(
            children: List.generate(7, (i) {
              final isFriday = i == 4;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Text(
                        weekdaysAr[i],
                        style: TextStyle(
                          fontFamily: AppTheme.arabicFontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isFriday
                              ? AppColors.primary
                              : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        weekdaysEn[i],
                        style: TextStyle(
                          fontFamily: AppTheme.latinFontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: isFriday
                              ? AppColors.primary
                              : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const Divider(height: 1),

          // Day cells (6 rows)
          for (int row = 0; row < 6; row++)
            Row(
              children: List.generate(7, (col) {
                final idx = row * 7 + col;
                if (idx >= monthData.days.length) {
                  return const Expanded(child: SizedBox(height: 48));
                }
                final day = monthData.days[idx];
                return Expanded(
                  child: _DayCell(day: day, isDark: isDark),
                );
              }),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Day Cell
// ═══════════════════════════════════════════════════════════════════

class _DayCell extends StatelessWidget {
  final HijriDay day;
  final bool isDark;

  const _DayCell({required this.day, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isFriday = day.gregorianDate.weekday == 5;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: AspectRatio(
        aspectRatio: 1,
        child: GestureDetector(
          onTap: day.isCurrentMonth
              ? () => _showDayDetail(context, day)
              : null,
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: day.isToday
                  ? AppColors.primary
                  : day.eventColor != null && day.isCurrentMonth
                      ? day.eventColor!.withValues(alpha: 0.15)
                      : null,
              border: day.isToday
                  ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2)
                  : null,
              boxShadow: day.isToday
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.hijriDay}',
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 14,
                    fontWeight: day.isToday || (day.isCurrentMonth && day.eventColor != null)
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: day.isToday
                        ? Colors.white
                        : !day.isCurrentMonth
                            ? (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary)
                            : isFriday
                                ? AppColors.primary
                                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                ),
                if (day.eventColor != null && day.isCurrentMonth && !day.isToday)
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: day.eventColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDayDetail(BuildContext context, HijriDay day) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '${day.hijriDay}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: AppTheme.latinFontFamily, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _gregorianFormatted(day.gregorianDate),
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (day.eventName != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: (day.eventColor ?? AppColors.primary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: day.eventColor),
                    const SizedBox(width: 6),
                    Text(
                      day.eventName!,
                      style: TextStyle(
                        fontFamily: AppTheme.latinFontFamily,
                        fontWeight: FontWeight.w600,
                        color: day.eventColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _gregorianFormatted(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month]} ${d.day}, ${d.year}';
  }
}

// ═══════════════════════════════════════════════════════════════════
// Upcoming Events
// ═══════════════════════════════════════════════════════════════════

class _UpcomingEvents extends StatelessWidget {
  final HijriMonth monthData;
  final bool isDark;

  const _UpcomingEvents({required this.monthData, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final events = monthData.days
        .where((d) => d.eventName != null && d.isCurrentMonth)
        .toList();

    if (events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.event_available_rounded,
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'No special events this month',
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 13,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(Icons.star_rounded, size: 16, color: AppColors.secondary),
              const SizedBox(width: 6),
              Text(
                'Important Dates',
                style: TextStyle(
                  fontFamily: AppTheme.latinFontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        ...events.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _EventCard(day: e, isDark: isDark),
        )),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final HijriDay day;
  final bool isDark;

  const _EventCard({required this.day, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (day.eventColor ?? AppColors.primary).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (day.eventColor ?? AppColors.primary).withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (day.eventColor ?? AppColors.primary).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '${day.hijriDay}',
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: day.eventColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.eventName ?? '',
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _gregorianShort(day.gregorianDate),
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            size: 18,
          ),
        ],
      ),
    );
  }

  String _gregorianShort(DateTime d) {
    const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
               'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${m[d.month]} ${d.day}, ${d.year}';
  }
}
