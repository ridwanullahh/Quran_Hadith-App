import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/hifdh_providers.dart';

class HifdhTestScreen extends ConsumerWidget {
  const HifdhTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testState = ref.watch(hifdhTestProvider);
    final surahsAsync = ref.watch(surahListForHifdhProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          testState.phase == HifdhTestPhase.setup
              ? 'Test Mode'
              : testState.phase == HifdhTestPhase.testing
                  ? 'Testing...'
                  : 'Results',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (testState.phase == HifdhTestPhase.testing) {
              _showExitConfirmDialog(context, ref);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: testState.phase == HifdhTestPhase.setup
          ? _SetupPhase(
              surahsAsync: surahsAsync,
              testState: testState,
              ref: ref,
            )
          : testState.phase == HifdhTestPhase.testing
              ? _TestingPhase(testState: testState, ref: ref)
              : _ResultsPhase(
                  testState: testState,
                  result: testState.finalResult!,
                  ref: ref,
                ),
    );
  }

  void _showExitConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Test?'),
        content: const Text(
          'Your progress will be lost. Are you sure you want to exit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(hifdhTestProvider.notifier).reset();
              context.pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Setup Phase
// ═══════════════════════════════════════════════════════════════════

class _SetupPhase extends StatefulWidget {
  final AsyncValue<List<dynamic>> surahsAsync;
  final HifdhTestState testState;
  final WidgetRef ref;

  const _SetupPhase({
    required this.surahsAsync,
    required this.testState,
    required this.ref,
  });

  @override
  State<_SetupPhase> createState() => _SetupPhaseState();
}

class _SetupPhaseState extends State<_SetupPhase> {
  final _surahSearchController = TextEditingController();
  String _searchQuery = '';
  int _startAyah = 1;
  int _endAyah = 7;

  @override
  void dispose() {
    _surahSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifier = widget.ref.read(hifdhTestProvider.notifier);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Mode selector
        Text(
          'Test Mode',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: HifdhTestMode.values.map((mode) {
            final isSelected = widget.testState.mode == mode;
            final label = switch (mode) {
              HifdhTestMode.listen => 'Listen',
              HifdhTestMode.read => 'Read',
              HifdhTestMode.hideReveal => 'Hide/Reveal',
            };
            final icon = switch (mode) {
              HifdhTestMode.listen => Icons.headphones_rounded,
              HifdhTestMode.read => Icons.visibility_rounded,
              HifdhTestMode.hideReveal => Icons.touch_app_rounded,
            };
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => notifier.setMode(mode),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: 250.ms,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.12)
                            : (isDark
                                ? AppColors.darkSurface
                                : AppColors.lightSurface),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                          width: isSelected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            icon,
                            size: 24,
                            color: isSelected
                                ? AppColors.primary
                                : theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),

        // Surah selector
        Text(
          'Select Surah',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _surahSearchController,
          onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
          decoration: InputDecoration(
            hintText: 'Search surah...',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: widget.surahsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator.adaptive()),
            error: (_, __) => const Center(child: Text('Failed to load surahs')),
            data: (surahs) {
              final filtered = _searchQuery.isEmpty
                  ? surahs
                  : surahs.where((s) {
                      final nameEn = s.nameEnglish.toLowerCase();
                      final nameAr = s.nameArabic;
                      final num = s.number.toString();
                      return nameEn.contains(_searchQuery) ||
                          nameAr.contains(_searchQuery) ||
                          num.contains(_searchQuery);
                    }).toList();

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final surah = filtered[index];
                  final isSelected = widget.testState.selectedSurah == surah.number;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    selected: isSelected,
                    selectedTileColor: AppColors.primary.withOpacity(0.08),
                    selectedColor: AppColors.primary,
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.15)
                            : (isDark
                                ? AppColors.darkSurfaceVariant
                                : AppColors.lightSurfaceVariant),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${surah.number}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.primary
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      surah.nameEnglish,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      surah.nameArabic,
                      style: AppTheme.arabicQuranText.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                    trailing: Text(
                      '${surah.totalAyahs} ayahs',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                    onTap: () {
                      notifier.setSurah(surah.number);
                      setState(() {
                        _startAyah = 1;
                        _endAyah = surah.totalAyahs.clamp(1, 10);
                      });
                    },
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Ayah range
        if (widget.testState.selectedSurah != null) ...[
          Text(
            'Ayah Range',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _RangeField(
                  label: 'From',
                  value: _startAyah,
                  onChanged: (v) {
                    setState(() => _startAyah = v.clamp(1, _endAyah));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '—',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
              ),
              Expanded(
                child: _RangeField(
                  label: 'To',
                  value: _endAyah,
                  onChanged: (v) {
                    setState(() => _endAyah = v.clamp(_startAyah, 286));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Start button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () {
                notifier.setAyahRange(_startAyah, _endAyah);
                notifier.startTest();
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                'Start Test (${_endAyah - _startAyah + 1} ayahs)',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RangeField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _RangeField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_rounded, size: 18),
                onPressed: () => onChanged(value - 1),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$value',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_rounded, size: 18),
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Testing Phase
// ═══════════════════════════════════════════════════════════════════

class _TestingPhase extends StatelessWidget {
  final HifdhTestState testState;
  final WidgetRef ref;

  const _TestingPhase({required this.testState, required this.ref});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notifier = ref.read(hifdhTestProvider.notifier);

    if (testState.ayahs.isEmpty) {
      return const Center(child: Text('No ayahs to test'));
    }

    final currentAyah = testState.ayahs[testState.currentAyahIndex];

    // Split ayah into words for hide/reveal mode
    final words = currentAyah.textUthmani.split(' ');

    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ayah ${testState.currentAyahIndex + 1} of ${testState.ayahs.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(testState.progress * 100).round()}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: testState.progress.clamp(0.0, 1.0),
                  backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  color: AppColors.primary,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),

        // Ayah display
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: switch (testState.mode) {
                HifdhTestMode.hideReveal => _HideRevealContent(
                    words: words,
                    isRevealed: testState.isRevealed,
                    onReveal: notifier.revealAyah,
                  ),
                HifdhTestMode.read => _ReadContent(
                    text: currentAyah.textUthmani,
                  ),
                HifdhTestMode.listen => _ListenContent(
                    text: currentAyah.textUthmani,
                    isRevealed: testState.isRevealed,
                    onReveal: notifier.revealAyah,
                  ),
              },
            ),
          ),
        ),

        // Action buttons
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 0.5,
              ),
            ),
          ),
          child: testState.isRevealed
              ? Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => notifier.markMistake(mistakes: ['minor_error']),
                        icon: const Icon(Icons.close_rounded, size: 20),
                        label: const Text('Mistake'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: notifier.markCorrect,
                        icon: const Icon(Icons.check_rounded, size: 20),
                        label: const Text('Correct'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.hifdhGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: notifier.skipAyah,
                        icon: const Icon(Icons.skip_next_rounded, size: 20),
                        label: const Text('Skip'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: notifier.revealAyah,
                        icon: const Icon(Icons.visibility_rounded, size: 20),
                        label: const Text('Reveal'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

// ── Hide / Reveal Content ──────────────────────────────────────

class _HideRevealContent extends StatelessWidget {
  final List<String> words;
  final bool isRevealed;
  final VoidCallback onReveal;

  const _HideRevealContent({
    required this.words,
    required this.isRevealed,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isRevealed) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Text(
          words.join(' '),
          style: AppTheme.arabicQuranText.copyWith(
            fontSize: 28,
            height: 2.2,
            color: theme.colorScheme.onSurface,
          ),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 300.ms),
      );
    }

    // Show words with some hidden
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 12,
        children: words.asMap().entries.map((entry) {
          final isHidden = entry.key % 3 == 1; // Hide every 3rd word
          if (isHidden) {
            return Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBorder.withOpacity(0.5)
                    : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '???',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }
          return Text(
            entry.value,
            style: AppTheme.arabicQuranText.copyWith(
              fontSize: 28,
              height: 1.6,
              color: theme.colorScheme.onSurface,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Read Content ──────────────────────────────────────────────

class _ReadContent extends StatelessWidget {
  final String text;

  const _ReadContent({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: AppTheme.arabicQuranText.copyWith(
          fontSize: 30,
          height: 2.2,
          color: theme.colorScheme.onSurface,
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}

// ── Listen Content ─────────────────────────────────────────────

class _ListenContent extends StatelessWidget {
  final String text;
  final bool isRevealed;
  final VoidCallback onReveal;

  const _ListenContent({
    required this.text,
    required this.isRevealed,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!isRevealed) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.headphones_rounded,
              size: 48,
              color: AppColors.primary,
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 1500.ms,
          ),
          const SizedBox(height: 24),
          Text(
            'Listen to the ayah and try to recite it',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Tap "Reveal" when ready to check',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: AppTheme.arabicQuranText.copyWith(
          fontSize: 28,
          height: 2.2,
          color: theme.colorScheme.onSurface,
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Results Phase
// ═══════════════════════════════════════════════════════════════════

class _ResultsPhase extends StatelessWidget {
  final HifdhTestState testState;
  final HifdhTestResult result;
  final WidgetRef ref;

  const _ResultsPhase({
    required this.testState,
    required this.result,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notifier = ref.read(hifdhTestProvider.notifier);

    final gradeColor = result.score >= 80
        ? AppColors.hifdhGreen
        : result.score >= 60
            ? AppColors.warning
            : AppColors.error;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Score circle
        Center(
          child: Column(
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      gradeColor.withOpacity(0.15),
                      gradeColor.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(color: gradeColor, width: 3),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${result.score.round()}%',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: gradeColor,
                        ),
                      ),
                      Text(
                        result.gradeLetter,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: gradeColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text(
                result.performanceMessage,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Stats grid
        Container(
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
              _ResultRow(
                icon: Icons.check_circle_rounded,
                label: 'Correct',
                value: '${result.correctCount}',
                color: AppColors.hifdhGreen,
                theme: theme,
              ),
              const Divider(height: 24),
              _ResultRow(
                icon: Icons.cancel_rounded,
                label: 'Mistakes',
                value: '${result.mistakeCount}',
                color: AppColors.error,
                theme: theme,
              ),
              const Divider(height: 24),
              _ResultRow(
                icon: Icons.skip_next_rounded,
                label: 'Skipped',
                value: '${result.skippedCount}',
                color: AppColors.warning,
                theme: theme,
              ),
              const Divider(height: 24),
              _ResultRow(
                icon: Icons.timer_rounded,
                label: 'Duration',
                value: _formatDuration(result.testDuration),
                color: AppColors.info,
                theme: theme,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Ayah-by-ayah results
        Text(
          'Ayah Breakdown',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ...result.ayahResults.map((ar) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ar.isCorrect
                      ? AppColors.hifdhGreen.withOpacity(0.3)
                      : AppColors.error.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    ar.wasSkipped
                        ? Icons.remove_circle_outline_rounded
                        : ar.isCorrect
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                    size: 20,
                    color: ar.wasSkipped
                        ? AppColors.warning
                        : ar.isCorrect
                            ? AppColors.hifdhGreen
                            : AppColors.error,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      ar.textArabic,
                      style: AppTheme.arabicQuranText.copyWith(
                        fontSize: 18,
                        height: 1.6,
                        color: theme.colorScheme.onSurface.withOpacity(
                            ar.isCorrect ? 1.0 : 0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${ar.ayahNumber}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 24),

        // Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: notifier.reset,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('New Test'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  notifier.reset();
                  context.pop();
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m}m ${s}s';
  }
}

class _ResultRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final ThemeData theme;

  const _ResultRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
