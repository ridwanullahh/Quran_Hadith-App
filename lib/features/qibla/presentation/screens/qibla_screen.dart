import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../prayer/presentation/providers/prayer_provider.dart';
import '../providers/qibla_provider.dart';

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(prayerSettingsProvider);
    final qibla = ref.watch(qiblaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Compass'),
        actions: [
          TextButton.icon(
            onPressed: () => _showCityPicker(context, ref),
            icon: const Icon(Icons.location_on_rounded, size: 18),
            label: Text(
              settings.location.name,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          children: [
            // ── Compass ──────────────────────────────────────────────
            _CompassWidget(bearing: qibla.bearing, isDark: isDark)
                .animate().fadeIn(duration: 500.ms),
            const SizedBox(height: 24),

            // ── Info Cards ──────────────────────────────────────────
            _InfoGrid(qibla: qibla, isDark: isDark),
            const SizedBox(height: 16),

            // ── Location Details ────────────────────────────────────
            _LocationCard(location: settings.location, isDark: isDark),
            const SizedBox(height: 16),

            // ── Note ────────────────────────────────────────────────
            _NoteCard(isDark: isDark),
          ],
        ),
      ),
    );
  }

  void _showCityPicker(BuildContext context, WidgetRef ref) {
    final settings = ref.read(prayerSettingsProvider);
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
                  final isSelected = city.name == settings.location.name;
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
                      ref.read(prayerSettingsProvider.notifier).state =
                          settings.copyWith(location: city);
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

// ═══════════════════════════════════════════════════════════════════
// Compass Widget
// ═══════════════════════════════════════════════════════════════════

class _CompassWidget extends StatelessWidget {
  final double bearing;
  final bool isDark;

  const _CompassWidget({required this.bearing, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.72;
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CustomPaint(
                size: Size(size, size),
                painter: _CompassRingPainter(isDark: isDark),
              ),
            ),

            // Inner circle background
            Container(
              width: size * 0.85,
              height: size * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              ),
            ),

            // Qibla arrow (rotated to point to Qibla)
            Transform.rotate(
              angle: _degToRad(bearing),
              child: SizedBox(
                width: size * 0.65,
                height: size * 0.65,
                child: CustomPaint(
                  size: Size(size * 0.65, size * 0.65),
                  painter: _QiblaArrowPainter(),
                ),
              ),
            ),

            // Center Kaaba icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.mosque_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),

            // Bearing text at bottom
            Positioned(
              bottom: size * 0.06,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${bearing.toStringAsFixed(1)}°',
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _degToRad(double deg) => deg * math.pi / 180.0;
}

// ═══════════════════════════════════════════════════════════════════
// Custom Painters
// ═══════════════════════════════════════════════════════════════════

class _CompassRingPainter extends CustomPainter {
  final bool isDark;
  _CompassRingPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final textStyle = TextStyle(
      fontFamily: AppTheme.latinFontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );

    final directions = [
      ('N', 0, AppColors.error),
      ('NE', 45, isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
      ('E', 90, isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      ('SE', 135, isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
      ('S', 180, isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      ('SW', 225, isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
      ('W', 270, isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      ('NW', 315, isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
    ];

    // Tick marks
    for (int deg = 0; deg < 360; deg += 5) {
      final rad = math.pi / 180.0 * (deg - 90);
      final isMajor = deg % 45 == 0;
      final isMid = deg % 15 == 0;
      final innerR = radius - (isMajor ? 22 : (isMid ? 14 : 8));
      final paint = Paint()
        ..color = isMajor
            ? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
            : (isDark ? AppColors.darkBorder : AppColors.lightBorder)
        ..strokeWidth = isMajor ? 2 : 1;

      canvas.drawLine(
        Offset(center.dx + innerR * math.cos(rad), center.dy + innerR * math.sin(rad)),
        Offset(center.dx + (radius - 3) * math.cos(rad), center.dy + (radius - 3) * math.sin(rad)),
        paint,
      );
    }

    // Direction labels
    for (final (label, deg, color) in directions) {
      final rad = math.pi / 180.0 * (deg - 90);
      final labelR = radius - 34;
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: textStyle.copyWith(color: color),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(
          center.dx + labelR * math.cos(rad) - tp.width / 2,
          center.dy + labelR * math.sin(rad) - tp.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CompassRingPainter old) => old.isDark != isDark;
}

class _QiblaArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final arrowLen = size.height * 0.4;

    // Arrow pointing up (north) – will be rotated by Transform.rotate
    final arrowPath = Path()
      ..moveTo(center.dx, center.dy - arrowLen) // tip
      ..lineTo(center.dx - 10, center.dy - arrowLen + 28)
      ..lineTo(center.dx - 4, center.dy - arrowLen + 24)
      ..lineTo(center.dx - 4, center.dy + arrowLen * 0.15)
      ..lineTo(center.dx + 4, center.dy + arrowLen * 0.15)
      ..lineTo(center.dx + 4, center.dy - arrowLen + 24)
      ..lineTo(center.dx + 10, center.dy - arrowLen + 28)
      ..close();

    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.fill,
    );

    // Arrow outline
    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = AppColors.primaryDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Kaaba symbol at tip
    const kaabaSymbol = '🕋';
    final tp = TextPainter(
      text: const TextSpan(
        text: kaabaSymbol,
        style: TextStyle(fontSize: 18),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(
        center.dx - tp.width / 2,
        center.dy - arrowLen - tp.height - 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _QiblaArrowPainter old) => false;
}

// ═══════════════════════════════════════════════════════════════════
// Info Widgets
// ═══════════════════════════════════════════════════════════════════

class _InfoGrid extends StatelessWidget {
  final QiblaResult qibla;
  final bool isDark;

  const _InfoGrid({required this.qibla, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            icon: Icons.explore_rounded,
            iconColor: AppColors.primary,
            label: 'Bearing',
            value: qibla.bearingText,
            subtitle: qibla.cardinalDirection,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoCard(
            icon: Icons.straighten_rounded,
            iconColor: AppColors.secondary,
            label: 'Distance',
            value: qibla.distanceText,
            subtitle: '${qibla.distanceKm.toStringAsFixed(1)} km',
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtitle;
  final bool isDark;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final PrayerLocation location;
  final bool isDark;

  const _LocationCard({required this.location, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.nameAr,
                  style: TextStyle(
                    fontFamily: AppTheme.arabicFontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${location.name} · ${location.latitude.toStringAsFixed(4)}°, ${location.longitude.toStringAsFixed(4)}°',
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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

class _NoteCard extends StatelessWidget {
  final bool isDark;
  const _NoteCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'The compass shows the calculated Qibla direction based on your selected city. For live compass using device sensors, enable location services in a future update.',
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 12,
                height: 1.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
