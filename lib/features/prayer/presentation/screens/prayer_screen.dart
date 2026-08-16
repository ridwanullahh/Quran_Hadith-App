import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/prayer_provider.dart';

class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final settings = ref.watch(prayerSettingsProvider);
    final times = ref.watch(prayerTimesProvider);
    final next = ref.watch(nextPrayerProvider);
    final now = ref.watch(currentTimeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Settings',
            onPressed: () => _showSettingsSheet(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(prayerTimesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            // ── Date Header ──────────────────────────────────────────
            _DateHeader(now: now),
            const SizedBox(height: 12),

            // ── Location Selector ───────────────────────────────────
            _LocationSelector(
              current: settings.location,
              onSelected: (loc) {
                ref.read(prayerSettingsProvider.notifier).updateLocation(loc);
              },
            ),
            const SizedBox(height: 16),

            // ── Next Prayer Highlight ───────────────────────────────
            if (next != null)
              _NextPrayerCard(
                next: next,
                isDark: isDark,
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            const SizedBox(height: 16),

            // ── Current Time ────────────────────────────────────────
            _CurrentTimeDisplay(
              now: now,
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // ── Prayer Times List ───────────────────────────────────
            ...times.list.asMap().entries.map((entry) {
              final idx = entry.key;
              final prayer = entry.value;
              final isNext = next != null && prayer.name == next.name;
              final isPassed = prayer.time.isBefore(now);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PrayerTimeCard(
                  prayer: prayer,
                  isNext: isNext,
                  isPassed: isPassed,
                  isDark: isDark,
                  index: idx,
                ),
              ).animate().fadeIn(
                duration: 350.ms,
                delay: (150 + idx * 60).ms,
              ).slideY(
                begin: 0.08,
                end: 0,
                duration: 350.ms,
                delay: (150 + idx * 60).ms,
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _PrayerSettingsSheet(ref: ref),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Sub-Widgets
// ═══════════════════════════════════════════════════════════════════

class _DateHeader extends ConsumerWidget {
  final DateTime now;
  const _DateHeader({required this.now});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hijri = ref.watch(hijriDateProvider(now));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkSurfaceVariant, AppColors.darkSurface]
              : [AppColors.primary.withOpacity(0.08), AppColors.primary.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_weekdayName(now.weekday)}, ${_monthName(now.month)} ${now.day}, ${now.year}',
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${hijri.day} ${hijri.monthNameAr} ${hijri.year} هـ',
                  style: TextStyle(
                    fontFamily: AppTheme.arabicFontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${hijri.day} ${hijri.monthNameEn} ${hijri.year} AH',
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.mosque_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  String _weekdayName(int day) {
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day - 1];
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}

class _LocationSelector extends StatelessWidget {
  final PrayerLocation current;
  final ValueChanged<PrayerLocation> onSelected;

  const _LocationSelector({required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showCityPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkBorder
                : AppColors.lightBorder,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    current.nameAr,
                  style: TextStyle(
                      fontFamily: AppTheme.arabicFontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${current.latitude.toStringAsFixed(2)}°N, ${current.longitude.toStringAsFixed(2)}°E',
                    style: TextStyle(
                      fontFamily: AppTheme.latinFontFamily,
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.unfold_more_rounded,
              size: 18,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  void _showCityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (ctx, scrollCtrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Select City',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: predefinedCities.length,
                itemBuilder: (ctx, i) {
                  final city = predefinedCities[i];
                  final isSelected = city.name == current.name;
                  return ListTile(
                    leading: Icon(
                      Icons.location_on_rounded,
                      color: isSelected ? AppColors.primary : null,
                    ),
                    title: Text(
                      city.name,
                      style: TextStyle(
                        fontFamily: AppTheme.latinFontFamily,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      city.nameAr,
                      style: TextStyle(
                        fontFamily: AppTheme.arabicFontFamily,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                        : null,
                    onTap: () {
                      onSelected(city);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextPrayerCard extends ConsumerWidget {
  final ({String name, String nameAr, DateTime time, Duration remaining}) next;
  final bool isDark;

  const _NextPrayerCard({required this.next, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(currentTimeProvider);
    final remaining = next.time.difference(now);
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'NEXT PRAYER',
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            next.nameAr,
            style: TextStyle(
              fontFamily: AppTheme.arabicHeaderFontFamily,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            next.name,
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CountdownBox(value: hours.toString().padLeft(2, '0'), label: 'HRS'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
              _CountdownBox(value: minutes.toString().padLeft(2, '0'), label: 'MIN'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
              _CountdownBox(value: seconds.toString().padLeft(2, '0'), label: 'SEC'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountdownBox extends StatelessWidget {
  final String value;
  final String label;
  const _CountdownBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.latinFontFamily,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _CurrentTimeDisplay extends ConsumerWidget {
  final DateTime now;
  final bool isDark;

  const _CurrentTimeDisplay({required this.now, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveNow = ref.watch(currentTimeProvider);
    return Center(
      child: Column(
        children: [
          Text(
            '${liveNow.hour.toString().padLeft(2, '0')}:${liveNow.minute.toString().padLeft(2, '0')}:${liveNow.second.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 36,
              fontWeight: FontWeight.w200,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              letterSpacing: 2,
            ),
          ),
          Text(
            _periodOfDay(liveNow.hour),
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _periodOfDay(int hour) {
    if (hour >= 5 && hour < 12) return 'Morning';
    if (hour >= 12 && hour < 17) return 'Afternoon';
    if (hour >= 17 && hour < 21) return 'Evening';
    return 'Night';
  }
}

class _PrayerTimeCard extends StatelessWidget {
  final ({String name, String nameAr, DateTime time}) prayer;
  final bool isNext;
  final bool isPassed;
  final bool isDark;
  final int index;

  const _PrayerTimeCard({
    required this.prayer,
    required this.isNext,
    required this.isPassed,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.nightlight_rounded,
      Icons.wb_twilight_rounded,
      Icons.wb_sunny_rounded,
      Icons.light_mode_rounded,
      Icons.nights_stay_rounded,
      Icons.bedtime_rounded,
    ];

    final color = isPassed
        ? (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary)
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isNext
            ? AppColors.primary.withOpacity(isDark ? 0.15 : 0.08)
            : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(14),
        border: isNext
            ? Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5)
            : Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 0.5,
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isNext
                  ? AppColors.primary
                  : (isDark ? AppColors.darkSurface : AppColors.lightSurfaceVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icons[index],
              size: 20,
              color: isNext
                  ? Colors.white
                  : (isDark ? AppColors.primaryLight : AppColors.primary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prayer.nameAr,
                  style: TextStyle(
                    fontFamily: AppTheme.arabicFontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isNext ? AppColors.primary : color,
                  ),
                ),
                Text(
                  prayer.name,
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
          Text(
            _formatTime(prayer.time),
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isNext ? AppColors.primary : color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:$m $ampm';
  }
}

// ═══════════════════════════════════════════════════════════════════
// Settings Bottom Sheet
// ═══════════════════════════════════════════════════════════════════

class _PrayerSettingsSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _PrayerSettingsSheet({required this.ref});

  @override
  ConsumerState<_PrayerSettingsSheet> createState() => _PrayerSettingsSheetState();
}

class _PrayerSettingsSheetState extends ConsumerState<_PrayerSettingsSheet> {
  late int _fajrAngle;
  late int _ishaAngle;
  late AsrMethod _asrMethod;
  late int _fajrOffset;
  late int _sunriseOffset;
  late int _dhuhrOffset;
  late int _asrOffset;
  late int _maghribOffset;
  late int _ishaOffset;

  @override
  void initState() {
    super.initState();
    final s = widget.ref.read(prayerSettingsProvider);
    _fajrAngle = s.fajrAngle;
    _ishaAngle = s.ishaAngle;
    _asrMethod = s.asrMethod;
    _fajrOffset = s.fajrOffset;
    _sunriseOffset = s.sunriseOffset;
    _dhuhrOffset = s.dhuhrOffset;
    _asrOffset = s.asrOffset;
    _maghribOffset = s.maghribOffset;
    _ishaOffset = s.ishaOffset;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Prayer Adjustments',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

            // Asr Method
            _SettingsRow(
              label: 'Asr Calculation',
              child: SegmentedButton<AsrMethod>(
                segments: const [
                  ButtonSegment(value: AsrMethod.shafii, label: Text('Shafi\'i', style: TextStyle(fontSize: 12))),
                  ButtonSegment(value: AsrMethod.hanafi, label: Text('Hanafi', style: TextStyle(fontSize: 12))),
                ],
                selected: {_asrMethod},
                onSelectionChanged: (v) => setState(() => _asrMethod = v.first),
              ),
            ),
            const SizedBox(height: 12),

            // Fajr Angle
            _SettingsRow(
              label: 'Fajr Angle: $_fajrAngle°',
              child: Slider(
                value: _fajrAngle.toDouble(),
                min: 15,
                max: 19.5,
                divisions: 9,
                label: '$_fajrAngle°',
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _fajrAngle = v.round()),
              ),
            ),

            // Isha Angle
            _SettingsRow(
              label: 'Isha Angle: $_ishaAngle°',
              child: Slider(
                value: _ishaAngle.toDouble(),
                min: 15,
                max: 19.5,
                divisions: 9,
                label: '$_ishaAngle°',
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _ishaAngle = v.round()),
              ),
            ),
            const SizedBox(height: 12),

            // Per-prayer offsets
            Text(
              'Manual Adjustments (minutes)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            _OffsetSlider('Fajr', _fajrOffset, (v) => setState(() => _fajrOffset = v)),
            _OffsetSlider('Sunrise', _sunriseOffset, (v) => setState(() => _sunriseOffset = v)),
            _OffsetSlider('Dhuhr', _dhuhrOffset, (v) => setState(() => _dhuhrOffset = v)),
            _OffsetSlider('Asr', _asrOffset, (v) => setState(() => _asrOffset = v)),
            _OffsetSlider('Maghrib', _maghribOffset, (v) => setState(() => _maghribOffset = v)),
            _OffsetSlider('Isha', _ishaOffset, (v) => setState(() => _ishaOffset = v)),

            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                final s = widget.ref.read(prayerSettingsProvider);
                widget.ref.read(prayerSettingsProvider.notifier).update(
                  s.copyWith(
                    asrMethod: _asrMethod,
                    fajrAngle: _fajrAngle,
                    ishaAngle: _ishaAngle,
                    fajrOffset: _fajrOffset,
                    sunriseOffset: _sunriseOffset,
                    dhuhrOffset: _dhuhrOffset,
                    asrOffset: _asrOffset,
                    maghribOffset: _maghribOffset,
                    ishaOffset: _ishaOffset,
                  ),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _SettingsRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.latinFontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _OffsetSlider extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _OffsetSlider(this.label, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: -30,
            max: 30,
            divisions: 60,
            label: '$value min',
            activeColor: AppColors.secondary,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(
          width: 48,
          child: Text(
            '${value > 0 ? '+' : ''}$value',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Hijri Date Provider (simple, shared with calendar feature)
// ═══════════════════════════════════════════════════════════════════

class HijriDate {
  final int day;
  final int month; // 1-12
  final int year;
  final String monthNameAr;
  final String monthNameEn;

  const HijriDate({
    required this.day,
    required this.month,
    required this.year,
    required this.monthNameAr,
    required this.monthNameEn,
  });
}

final hijriDateProvider = Provider.family<HijriDate, DateTime>((ref, date) {
  return HijriConverter.gregorianToHijri(date);
});

class HijriConverter {
  /// Tabular Islamic calendar epoch: July 16, 622 CE (Julian day)
  static const double _epoch = 1948439.5;
  static const double _synodicMonth = 29.530588853;

  static const _monthNamesAr = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني',
    'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
    'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
  ];

  static const _monthNamesEn = [
    'Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Thani",
    'Jumada al-Ula', 'Jumada al-Thani', 'Rajab', "Sha'ban",
    'Ramadan', 'Shawwal', "Dhul Qi'dah", 'Dhul Hijjah',
  ];

  static const _monthDays = [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29];

  static HijriDate gregorianToHijri(DateTime date) {
    final jd = _gregorianToJulianDay(date);
    final daysSinceEpoch = jd - _epoch;
    // Total complete lunar months
    final totalMonths = (daysSinceEpoch / _synodicMonth).floor();
    var year = (totalMonths / 12).floor() + 1;
    var month = totalMonths % 12 + 1;
    var day = (daysSinceEpoch - _floorMonthSum(totalMonths)).floor() + 1;

    // Day might exceed month length due to 30-day alternation
    final maxDay = _isLeapYear(year) && month == 12 ? 30 : _monthDays[month - 1];
    if (day > maxDay) {
      day -= maxDay;
      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
    }
    if (day < 1) {
      month--;
      if (month < 1) {
        month = 12;
        year--;
      }
      final prevMax = _isLeapYear(year) && month == 12 ? 30 : _monthDays[month - 1];
      day += prevMax;
    }

    return HijriDate(
      day: day,
      month: month,
      year: year,
      monthNameAr: _monthNamesAr[month - 1],
      monthNameEn: _monthNamesEn[month - 1],
    );
  }

  static double _gregorianToJulianDay(DateTime date) {
    final y = date.year;
    final m = date.month;
    final d = date.day + (date.hour + date.minute / 60.0 + date.second / 3600.0) / 24.0;
    final a = (14 - m) ~/ 12;
    final y1 = y + 4800 - a;
    final m1 = m + 12 * a - 3;
    return d + (153 * m1 + 2) ~/ 5 + 365 * y1 + y1 ~/ 4 - y1 ~/ 100 + y1 ~/ 400 - 32045.5;
  }

  static double _floorMonthSum(int totalMonths) {
    double sum = 0;
    for (int i = 0; i < totalMonths; i++) {
      sum += (i % 2 == 0) ? 30.0 : 29.0;
    }
    return sum;
  }

  static bool _isLeapYear(int year) {
    // Leap years in tabular Islamic calendar: years 2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29 in a 30-year cycle
    final cycle = year % 30;
    return [2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29].contains(cycle);
  }
}
