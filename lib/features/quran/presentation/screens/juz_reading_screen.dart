import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/quran/surah_info.dart';

// ═══════════════════════════════════════════════════════════════════
// Providers
// ═══════════════════════════════════════════════════════════════════

final juzSurahsProvider = FutureProvider<List<SurahInfo>>((ref) async {
  final jsonString = await rootBundle.loadString(AppConstants.surahInfoAssetPath);
  return parseSurahList(jsonString);
});

final juzAyahsProvider = FutureProvider.family<List<_JuzAyah>, int>((ref, juzNumber) async {
  final surahs = await ref.watch(juzSurahsProvider.future);
  final start = AppConstants.juzBreakdown[juzNumber - 1];
  final end = juzNumber < 30 ? AppConstants.juzBreakdown[juzNumber] : null;

  final uthmaniString = await rootBundle.loadString(AppConstants.quranUthmaniAssetPath);
  final uthmani = json.decode(uthmaniString) as Map<String, dynamic>;
  final translationString = await rootBundle.loadString('assets/data/quran_en_translation.json');
  final translations = json.decode(translationString) as Map<String, dynamic>;

  final ayahs = <_JuzAyah>[];

  for (int surahNum = start['surah']!; surahNum <= 114; surahNum++) {
    final surahAyahs = uthmani['$surahNum'] as List<dynamic>?;
    final surahTranslations = translations['$surahNum'] as List<dynamic>?;
    if (surahAyahs == null) continue;

    final startAyah = surahNum == start['surah'] ? start['ayah']! : 1;
    int? endAyah;
    if (end != null && surahNum == end['surah']!) {
      endAyah = end['ayah']! - 1;
    }
    if (end == null && surahNum == 114) {
      endAyah = surahAyahs.length;
    }

    for (int i = startAyah - 1; i < surahAyahs.length; i++) {
      if (endAyah != null && i >= endAyah) break;
      final ayahNum = i + 1;
      ayahs.add(_JuzAyah(
        surahNumber: surahNum,
        ayahNumber: ayahNum,
        textArabic: surahAyahs[i] as String,
        textTranslation: surahTranslations != null && i < surahTranslations.length
            ? surahTranslations[i] as String
            : '',
        surahInfo: surahs.firstWhere((s) => s.number == surahNum),
        isFirstInSurah: ayahNum == startAyah && surahNum != start['surah'] ||
            (ayahNum == 1 && surahNum != start['surah']),
        isLastInSurah: endAyah != null && ayahNum == endAyah,
        isStartOfJuz: surahNum == start['surah'] && ayahNum == start['ayah'],
      ));
    }
    if (endAyah != null && end != null && surahNum == end['surah']!) break;
  }
  return ayahs;
});

// ═══════════════════════════════════════════════════════════════════
// Models
// ═══════════════════════════════════════════════════════════════════

class _JuzAyah {
  final int surahNumber;
  final int ayahNumber;
  final String textArabic;
  final String textTranslation;
  final SurahInfo surahInfo;
  final bool isFirstInSurah;
  final bool isLastInSurah;
  final bool isStartOfJuz;

  const _JuzAyah({
    required this.surahNumber,
    required this.ayahNumber,
    required this.textArabic,
    required this.textTranslation,
    required this.surahInfo,
    this.isFirstInSurah = false,
    this.isLastInSurah = false,
    this.isStartOfJuz = false,
  });
}

// ═══════════════════════════════════════════════════════════════════
// Screen
// ═══════════════════════════════════════════════════════════════════

class JuzReadingScreen extends ConsumerStatefulWidget {
  final int juzNumber;
  const JuzReadingScreen({super.key, this.juzNumber = 1});

  @override
  ConsumerState<JuzReadingScreen> createState() => _JuzReadingScreenState();
}

class _JuzReadingScreenState extends ConsumerState<JuzReadingScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ayahsAsync = ref.watch(juzAyahsProvider(widget.juzNumber));
    final surahsAsync = ref.watch(juzSurahsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Juz ${widget.juzNumber}'),
        actions: [
          if (widget.juzNumber > 1)
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              tooltip: 'Previous Juz',
              onPressed: () => context.push('/quran/juz/${widget.juzNumber - 1}'),
            ),
          if (widget.juzNumber < 30)
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              tooltip: 'Next Juz',
              onPressed: () => context.push('/quran/juz/${widget.juzNumber + 1}'),
            ),
        ],
      ),
      body: ayahsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Failed to load Juz ${widget.juzNumber}',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        data: (ayahs) {
          return Column(
            children: [
              // Progress bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceVariant,
                child: Row(
                  children: [
                    Text(
                      '${ayahs.length} ayahs',
                      style: TextStyle(
                        fontFamily: AppTheme.latinFontFamily,
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: 1.0,
                        backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBorder,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Juz ${widget.juzNumber} of 30',
                      style: TextStyle(
                        fontFamily: AppTheme.latinFontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // Ayah list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  itemCount: ayahs.length,
                  itemBuilder: (context, index) {
                    final ayah = ayahs[index];
                    return _JuzAyahCard(ayah: ayah).animate().fadeIn(
                      duration: 200.ms,
                      delay: (index % 20) * 20.ms,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Juz List Screen (Entry Point)
// ═══════════════════════════════════════════════════════════════════

class JuzListScreen extends ConsumerWidget {
  const JuzListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surahsAsync = ref.watch(juzSurahsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Juz Reading'),
      ),
      body: surahsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Failed to load', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        data: (surahs) {
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: 30,
            itemBuilder: (context, index) {
              final juzNum = index + 1;
              final breakdown = AppConstants.juzBreakdown[index];
              final surahNum = breakdown['surah']!;
              final ayahNum = breakdown['ayah']!;
              final surah = surahs.firstWhere((s) => s.number == surahNum);
              final nextJuzBreakdown = juzNum < 30 ? AppConstants.juzBreakdown[juzNum] : null;
              int totalAyahs = 0;
              // Approximate ayah count
              if (nextJuzBreakdown != null) {
                if (nextJuzBreakdown['surah'] == surahNum) {
                  totalAyahs = nextJuzBreakdown['ayah']! - ayahNum;
                } else {
                  totalAyahs = surah.totalAyahs - ayahNum + 1;
                  for (int s = surahNum + 1; s < nextJuzBreakdown['surah']!; s++) {
                    totalAyahs += surahs.firstWhere((sr) => sr.number == s).totalAyahs;
                  }
                  totalAyahs += nextJuzBreakdown['ayah']! - 1;
                }
              } else {
                totalAyahs = surah.totalAyahs - ayahNum + 1;
              }

              return _JuzCard(
                juzNumber: juzNum,
                surahNameArabic: surah.nameArabic,
                surahNameEnglish: surah.nameEnglish,
                startAyah: ayahNum,
                totalAyahs: totalAyahs,
                surahNumber: surahNum,
                onTap: () => context.push('/quran/juz/$juzNum'),
              ).animate().fadeIn(duration: 250.ms, delay: (index % 10) * 30.ms);
            },
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Juz Card
// ═══════════════════════════════════════════════════════════════════

class _JuzCard extends StatelessWidget {
  final int juzNumber;
  final String surahNameArabic;
  final String surahNameEnglish;
  final int startAyah;
  final int totalAyahs;
  final int surahNumber;
  final VoidCallback onTap;

  const _JuzCard({
    required this.juzNumber,
    required this.surahNameArabic,
    required this.surahNameEnglish,
    required this.startAyah,
    required this.totalAyahs,
    required this.surahNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Juz number badge
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '$juzNumber',
                      style: const TextStyle(
                        fontFamily: AppTheme.latinFontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Juz $juzNumber',
                            style: TextStyle(
                              fontFamily: AppTheme.latinFontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$totalAyahs ayahs',
                              style: const TextStyle(
                                fontFamily: AppTheme.latinFontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$surahNameEnglish : Ayah $startAyah',
                        style: TextStyle(
                          fontFamily: AppTheme.latinFontFamily,
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        surahNameArabic,
                        style: TextStyle(
                          fontFamily: AppTheme.arabicHeaderFontFamily,
                          fontSize: 18,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
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
// Juz Ayah Card
// ═══════════════════════════════════════════════════════════════════

class _JuzAyahCard extends StatelessWidget {
  final _JuzAyah ayah;
  const _JuzAyahCard({required this.ayah});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Column(
      children: [
        if (ayah.isFirstInSurah && !ayah.isStartOfJuz) ...[
          const SizedBox(height: 24),
          // Bismillah
          if (ayah.surahNumber != 9)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                AppConstants.bismillahArabic,
                style: TextStyle(
                  fontFamily: AppTheme.arabicFontFamily,
                  fontSize: 20,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  height: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          // Surah header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Surah ${ayah.surahNumber}',
                  style: const TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  ayah.surahInfo.nameEnglish,
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  ayah.surahInfo.nameArabic,
                  style: TextStyle(
                    fontFamily: AppTheme.arabicHeaderFontFamily,
                    fontSize: 18,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (ayah.isStartOfJuz) ...[
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'بداية الجزء ${_arabicNumber(ayah.surahInfo.juzStart)}',
                style: TextStyle(
                  fontFamily: AppTheme.arabicFontFamily,
                  fontSize: 16,
                  color: AppColors.secondaryDark,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Ayah text
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      ayah.textArabic,
                      style: TextStyle(
                        fontFamily: AppTheme.arabicFontFamily,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        height: 2.2,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 8),
                    if (ayah.textTranslation.isNotEmpty)
                      Text(
                        ayah.textTranslation,
                        style: TextStyle(
                          fontFamily: AppTheme.latinFontFamily,
                          fontSize: 14,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.left,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Ayah number
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    '${ayah.ayahNumber}',
                    style: const TextStyle(
                      fontFamily: AppTheme.latinFontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        if (ayah.isLastInSurah)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Container(
                width: 120,
                height: 1,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
      ],
    );
  }

  String _arabicNumber(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((d) => arabicDigits[int.parse(d)]).join();
  }
}
