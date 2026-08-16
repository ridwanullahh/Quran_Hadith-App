import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/daily_verse_provider.dart';

class DailyVerseScreen extends ConsumerWidget {
  const DailyVerseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verse = ref.watch(todayVerseProvider);
    final today = ref.watch(todayDateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dateStr = _formatDate(today);
    final surahPath = verse.surahNumber > 0 ? '/quran/${verse.surahNumber}' : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Verse'),
        actions: [
          // Share / Copy
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy to clipboard',
            onPressed: () {
              final text =
                  '${verse.arabicText}\n\n${verse.englishTranslation}\n\n— ${verse.surahName} ${verse.surahNumber > 0 ? ":${verse.ayahNumber}" : ""}';
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Verse copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          children: [
            // Date display
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Main verse card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.06),
                    AppColors.secondary.withValues(alpha: 0.04),
                    AppColors.primary.withValues(alpha: 0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                  width: 0.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Decorative header
                    Center(
                      child: Container(
                        width: 48,
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bismillah
                    Center(
                      child: Text(
                        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                        style: TextStyle(
                          fontFamily: AppTheme.arabicFontFamily,
                          fontSize: 18,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Arabic text
                    Text(
                      verse.arabicText,
                      style: TextStyle(
                        fontFamily: AppTheme.arabicFontFamily,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        height: 2.2,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                    const SizedBox(height: 32),

                    // Decorative divider
                    Center(
                      child: Container(
                        width: 80,
                        height: 1,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // English translation
                    Text(
                      verse.englishTranslation,
                      style: TextStyle(
                        fontFamily: AppTheme.latinFontFamily,
                        fontSize: 16,
                        height: 1.8,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                    const SizedBox(height: 32),

                    // Surah reference
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            verse.surahNumber > 0
                                ? '${verse.surahName} (${verse.surahNumber}:${verse.ayahNumber})'
                                : verse.surahName,
                            style: const TextStyle(
                              fontFamily: AppTheme.latinFontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 500.ms),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(
              begin: 0.05,
              end: 0,
              duration: 400.ms,
            ),

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final text =
                          '${verse.arabicText}\n\n${verse.englishTranslation}\n\n— ${verse.surahName} ${verse.surahNumber > 0 ? ":${verse.ayahNumber}" : ""}';
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verse copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copy'),
                  ),
                ),
                const SizedBox(width: 12),
                if (surahPath != null)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.push(surahPath),
                      icon: const Icon(Icons.menu_book_rounded, size: 18),
                      label: const Text('Read Surah'),
                    ),
                  )
                else
                  const Spacer(),
              ],
            ),

            const SizedBox(height: 40),

            // Day counter
            Text(
              'Verse ${ref.watch(verseDayIndexProvider) + 1} of ${kDailyVerses.length}',
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                value: (ref.watch(verseDayIndexProvider) + 1) / kDailyVerses.length,
                backgroundColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
