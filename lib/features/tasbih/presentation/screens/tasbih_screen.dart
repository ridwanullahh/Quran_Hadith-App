import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/tasbih_provider.dart';

class TasbihScreen extends ConsumerWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasbihProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbih Counter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Session History',
            onPressed: () => _showSessionHistory(context, ref),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main counter area – full screen tap
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(tasbihProvider.notifier).increment();
            },
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Dhikr selector chips
                  _DhikrChips(state: state),
                  const SizedBox(height: 8),

                  // Presets button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () =>
                            ref.read(tasbihProvider.notifier).togglePresets(),
                        icon: const Icon(Icons.playlist_play_rounded, size: 16),
                        label: const Text('Presets'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.secondary,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Arabic dhikr name
                  Text(
                    state.isCustom ? state.customArabic : state.selectedDhikr.arabicText,
                    style: TextStyle(
                      fontFamily: AppTheme.arabicFontFamily,
                      fontSize: 32,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 8),

                  // English name
                  Text(
                    state.isCustom
                        ? state.customEnglish
                        : state.selectedDhikr.englishName,
                    style: TextStyle(
                      fontFamily: AppTheme.latinFontFamily,
                      fontSize: 16,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Circular progress with counter
                  _CircularCounter(state: state),
                  const SizedBox(height: 24),

                  // Target label
                  Text(
                    '${toArabicNumerals(state.currentCount)} / ${toArabicNumerals(state.target)}',
                    style: TextStyle(
                      fontFamily: AppTheme.latinFontFamily,
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),

                  const Spacer(),

                  // Bottom actions
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ActionButton(
                          icon: Icons.replay_rounded,
                          label: 'Reset',
                          color: AppColors.error,
                          onTap: () => ref.read(tasbihProvider.notifier).reset(),
                        ),
                        _ActionButton(
                          icon: Icons.swap_horiz_rounded,
                          label: 'Change',
                          color: AppColors.primary,
                          onTap: () =>
                              ref.read(tasbihProvider.notifier).toggleDhikrPicker(),
                        ),
                        _ActionButton(
                          icon: Icons.add_circle_outline_rounded,
                          label: 'Custom',
                          color: AppColors.secondary,
                          onTap: () => _showCustomDialog(context, ref),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Dhikr picker overlay
          if (state.showDhikrPicker)
            _DhikrPickerSheet(ref: ref, state: state),

          // Presets overlay
          if (state.showPresets)
            _PresetsSheet(ref: ref),

          // Celebration overlay
          if (state.showCelebration)
            _CelebrationOverlay(ref: ref),
        ],
      ),
    );
  }

  void _showSessionHistory(BuildContext context, WidgetRef ref) {
    final state = ref.read(tasbihProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SessionHistorySheet(state: state),
    );
  }

  void _showCustomDialog(BuildContext context, WidgetRef ref) {
    final arabicCtrl = TextEditingController();
    final englishCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '100');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Custom Dhikr'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: arabicCtrl,
              decoration: const InputDecoration(
                labelText: 'Arabic Text',
                hintText: 'e.g. سُبْحَانَ اللَّهِ',
              ),
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: AppTheme.arabicFontFamily,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: englishCtrl,
              decoration: const InputDecoration(
                labelText: 'English Name',
                hintText: 'e.g. SubhanAllah',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetCtrl,
              decoration: const InputDecoration(
                labelText: 'Target Count',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final arabic = arabicCtrl.text.trim();
              final english = englishCtrl.text.trim();
              final target = int.tryParse(targetCtrl.text.trim()) ?? 100;
              if (arabic.isNotEmpty && english.isNotEmpty) {
                ref.read(tasbihProvider.notifier).selectCustom(
                      arabic: arabic,
                      english: english,
                      target: target.clamp(1, 10000),
                    );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}

// ── Dhikr Chips ────────────────────────────────────────────────────

class _DhikrChips extends StatelessWidget {
  final TasbihState state;
  const _DhikrChips({required this.state});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: kDhikrOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final opt = kDhikrOptions[index];
          final selected = !state.isCustom &&
              state.selectedDhikr.id == opt.id;
          return ChoiceChip(
            label: Text(
              opt.englishName,
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            selected: selected,
            onSelected: (_) {}, // visual only; use Change button
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }
}

// ── Circular Counter ───────────────────────────────────────────────

class _CircularCounter extends StatelessWidget {
  final TasbihState state;
  const _CircularCounter({required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = state.progress;
    const size = 220.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightSurfaceVariant,
            ),
          ),
          // Progress ring
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _ProgressRingPainter(
                progress: progress,
                color: AppColors.primary,
                trackColor: isDark
                    ? AppColors.darkSurface
                    : AppColors.lightBorder,
              ),
            ),
          ),
          // Count number
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                toArabicNumerals(state.currentCount),
                style: TextStyle(
                  fontFamily: AppTheme.arabicFontFamily,
                  fontSize: 64,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ).animate(
                key: ValueKey(state.currentCount),
              ).scale(
                begin: const Offset(1.3, 1.3),
                end: const Offset(1, 1),
                duration: 120.ms,
                curve: Curves.easeOut,
              ),
              const SizedBox(height: 4),
              Text(
                'tap to count',
                style: TextStyle(
                  fontFamily: AppTheme.latinFontFamily,
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 8.0;
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter old) =>
      old.progress != progress;
}

// ── Action Button ──────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dhikr Picker Sheet ────────────────────────────────────────────

class _DhikrPickerSheet extends ConsumerWidget {
  final WidgetRef ref;
  final TasbihState state;
  const _DhikrPickerSheet({required this.ref, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(tasbihProvider.notifier).closeOverlays(),
      child: Container(
        color: Colors.black54,
        child: GestureDetector(
          onTap: () {}, // prevent closing when tapping the sheet itself
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.darkBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Select Dhikr',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: AppTheme.latinFontFamily,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...kDhikrOptions.map((opt) {
                    final selected =
                        !state.isCustom && state.selectedDhikr.id == opt.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: selected
                              ? const BorderSide(color: AppColors.primary, width: 2)
                              : BorderSide.none,
                        ),
                        tileColor: selected
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : null,
                        title: Text(
                          opt.arabicName,
                          style: const TextStyle(
                            fontFamily: AppTheme.arabicFontFamily,
                            fontSize: 22,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        subtitle: Text(
                          '${opt.englishName}  •  ${opt.targetCount}x',
                          style: TextStyle(
                            fontFamily: AppTheme.latinFontFamily,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        onTap: () =>
                            ref.read(tasbihProvider.notifier).selectDhikr(opt),
                      ),
                    );
                  }),
                ],
              ),
            ).animate().slideY(begin: 0.3, end: 0, duration: 300.ms, curve: Curves.easeOut),
          ),
        ),
      ),
    );
  }
}

// ── Presets Sheet ──────────────────────────────────────────────────

class _PresetsSheet extends ConsumerWidget {
  final WidgetRef ref;
  const _PresetsSheet({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presets = ref.watch(presetCombinationsProvider);
    return GestureDetector(
      onTap: () => ref.read(tasbihProvider.notifier).closeOverlays(),
      child: Container(
        color: Colors.black54,
        child: GestureDetector(
          onTap: () {},
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.darkBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Preset Combinations',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: AppTheme.latinFontFamily,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...presets.map((preset) {
                    final dhikrNames = preset.dhikrs
                        .map((d) => d.englishName)
                        .join(' → ');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.lightBorder),
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.playlist_play_rounded,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          preset.name,
                          style: const TextStyle(
                            fontFamily: AppTheme.latinFontFamily,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          preset.description,
                          style: TextStyle(
                            fontFamily: AppTheme.latinFontFamily,
                            fontSize: 12,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        trailing: Text(
                          '${preset.dhikrs.length} dhikrs',
                          style: const TextStyle(
                            fontFamily: AppTheme.latinFontFamily,
                            fontSize: 11,
                            color: AppColors.primary,
                          ),
                        ),
                        onTap: () {
                          ref
                              .read(tasbihProvider.notifier)
                              .selectDhikr(preset.dhikrs.first);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ).animate().slideY(begin: 0.3, end: 0, duration: 300.ms, curve: Curves.easeOut),
          ),
        ),
      ),
    );
  }
}

// ── Celebration Overlay ────────────────────────────────────────────

class _CelebrationOverlay extends ConsumerWidget {
  final WidgetRef ref;
  const _CelebrationOverlay({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 80,
              color: AppColors.secondary,
            )
                .animate()
                .scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                ),
            const SizedBox(height: 16),
            const Text(
              'MashaAllah!',
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.secondary,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 8),
            Text(
              'Target completed',
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 16,
                color: AppColors.darkTextSecondary,
              ),
            ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(tasbihProvider.notifier).dismissCelebration(),
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Continue'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

// ── Session History Sheet ──────────────────────────────────────────

class _SessionHistorySheet extends StatelessWidget {
  final TasbihState state;
  const _SessionHistorySheet({required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summary = <String, int>{};
    for (final s in state.todaySessions) {
      summary[s.dhikrId] = (summary[s.dhikrId] ?? 0) + s.count;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.darkBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              Text(
                'Today's Sessions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: AppTheme.latinFontFamily,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                'Total: ${toArabicNumerals(state.todayTotal)}',
                style: TextStyle(
                  fontFamily: AppTheme.latinFontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (summary.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No sessions recorded today',
                style: TextStyle(
                  fontFamily: AppTheme.latinFontFamily,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
            )
          else
            ...summary.entries.map((entry) {
              final dhikr = kDhikrOptions.where((d) => d.id == entry.key).firstOrNull;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      toArabicNumerals(entry.value),
                      style: const TextStyle(
                        fontFamily: AppTheme.arabicFontFamily,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  title: Text(
                    dhikr?.englishName ?? entry.key,
                    style: const TextStyle(
                      fontFamily: AppTheme.latinFontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    dhikr?.arabicName ?? '',
                    style: const TextStyle(
                      fontFamily: AppTheme.arabicFontFamily,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
