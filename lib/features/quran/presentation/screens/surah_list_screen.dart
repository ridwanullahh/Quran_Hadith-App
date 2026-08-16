import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arabic_numbers/arabic_numbers.dart';

import '../providers/quran_providers.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/quran/surah_info.dart';
import '../../../../data/models/quran/ayah_data.dart';

class SurahListScreen extends ConsumerStatefulWidget {
  const SurahListScreen({super.key});

  @override
  ConsumerState<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends ConsumerState<SurahListScreen> {
  @override
  Widget build(BuildContext context) {
    final surahsAsync = ref.watch(surahListProvider);
    final selectedJuz = ref.watch(juzFilterProvider);
    final revelationFilter = ref.watch(revelationFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, isDark),
            _buildJuzFilterChips(selectedJuz, isDark),
            _buildRevelationFilter(isDark),
            const SliverPadding(padding: EdgeInsets.only(top: 8)),
            surahsAsync.when(
              data: (surahs) {
                final filtered = _filterSurahs(
                    surahs, selectedJuz, revelationFilter);
                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No surahs found',
                            style: AppTheme.surahNameEnglish.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _SurahCard(
                      surah: filtered[index],
                      index: index,
                    ),
                    childCount: filtered.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load surahs',
                        style: AppTheme.surahNameEnglish,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          error.toString(),
                          style: AppTheme.surahMeta.copyWith(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  List<SurahInfo> _filterSurahs(
      List<SurahInfo> surahs, int? selectedJuz, String revelationFilter) {
    var filtered = surahs;

    if (selectedJuz != null) {
      final juzStart = AppConstants.juzBreakdown[selectedJuz - 1];
      final startSurah = juzStart['surah']!;

      int? endSurah;
      if (selectedJuz < 30) {
        final nextJuzStart = AppConstants.juzBreakdown[selectedJuz];
        endSurah = nextJuzStart['surah']!;
      } else {
        endSurah = 114;
      }

      filtered = filtered.where((surah) {
        if (surah.number < startSurah || surah.number > endSurah!) {
          return false;
        }
        return true;
      }).toList();
    }

    if (revelationFilter == AppConstants.meccan) {
      filtered =
          filtered.where((s) => s.revelationType == AppConstants.meccan).toList();
    } else if (revelationFilter == AppConstants.medinan) {
      filtered = filtered
          .where((s) => s.revelationType == AppConstants.medinan)
          .toList();
    }

    return filtered;
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
        child: Row(
          children: [
            Text(
              'Qur\u02BEan',
              style: AppTheme.surahNameEnglish.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                Icons.auto_stories_rounded,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              tooltip: 'Mushaf Mode',
              onPressed: () {
                context.push('/quran/mushaf');
              },
            ),
            IconButton(
              icon: Icon(
                Icons.search_rounded,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: QuranSearchDelegate(ref),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJuzFilterChips(int? selectedJuz, bool isDark) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 48,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 31,
          itemBuilder: (context, index) {
            final juzNum = index == 0 ? null : index;
            final isSelected = selectedJuz == juzNum;
            final label = index == 0 ? 'All' : 'Juz $index';

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                onSelected: (selected) {
                  ref
                      .read(juzFilterProvider.notifier)
                      .state = selected ? juzNum : null;
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                checkmarkColor: AppColors.primary,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder),
                ),
                showCheckmark: false,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRevelationFilter(bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            _RevelationChip(
              label: 'All',
              isSelected: revelationFilter == 'All',
              color: AppColors.primary,
              onTap: () {
                ref.read(revelationFilterProvider.notifier).state = 'All';
              },
            ),
            const SizedBox(width: 8),
            _RevelationChip(
              label: 'Makki',
              isSelected: revelationFilter == AppConstants.meccan,
              color: AppColors.meccanBadge,
              onTap: () {
                ref
                    .read(revelationFilterProvider.notifier)
                    .state = AppConstants.meccan;
              },
            ),
            const SizedBox(width: 8),
            _RevelationChip(
              label: 'Madani',
              isSelected: revelationFilter == AppConstants.medinan,
              color: AppColors.medinanBadge,
              onTap: () {
                ref
                    .read(revelationFilterProvider.notifier)
                    .state = AppConstants.medinan;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RevelationChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _RevelationChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightSurfaceVariant),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.latinFontFamily,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }
}

class _SurahCard extends StatelessWidget {
  final SurahInfo surah;
  final int index;

  const _SurahCard({required this.surah, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final arabicNumber = ArabicNumbers().convert(surah.number);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.push('/quran/${surah.number}');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildNumberBadge(arabicNumber, isDark),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.nameEnglish,
                        style: AppTheme.surahNameEnglish.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: surah.isMeccan
                                  ? AppColors.meccanBadge
                                  : AppColors.medinanBadge,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              surah.revelationType,
                              style: const TextStyle(
                                fontFamily: AppTheme.latinFontFamily,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${surah.totalAyahs} Ayahs',
                            style: AppTheme.surahMeta.copyWith(
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        surah.nameArabic,
                        style: AppTheme.arabicHeaderSmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      surah.nameTransliteration,
                      style: AppTheme.surahMeta.copyWith(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      )
          .animate(delay: Duration(milliseconds: index * 30))
          .fadeIn(duration: 300.ms, curve: Curves.easeOut)
          .slideY(begin: 0.08, end: 0, duration: 300.ms, curve: Curves.easeOut),
    );
  }

  Widget _buildNumberBadge(String arabicNumber, bool isDark) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                    AppColors.primary,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: Center(
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                  ),
                  child: Center(
                    child: Text(
                      arabicNumber,
                      style: AppTheme.ayahNumberStyle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuranSearchDelegate extends SearchDelegate<QuranSearchResult?> {
  final WidgetRef ref;

  QuranSearchDelegate(this.ref);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Theme.of(context).copyWith(
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        foregroundColor: isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          fontFamily: AppTheme.latinFontFamily,
          color: isDark
              ? AppColors.darkTextTertiary
              : AppColors.lightTextTertiary,
        ),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    if (query.isEmpty) return [];
    return [
      IconButton(
        icon: const Icon(Icons.clear_rounded),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchBody(context, query);
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchBody(context, query);
  }

  Widget _buildSearchBody(BuildContext context, String searchQuery) {
    if (searchQuery.trim().length < 2) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              size: 48,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              'Search the Qur\u02BEan',
              style: AppTheme.surahNameEnglish.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Search by Arabic text or English translation',
              style: AppTheme.surahMeta.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<QuranSearchResult>>(
      future:
          ref.read(quranRepositoryProvider).searchQuran(searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Search failed',
              style: AppTheme.surahNameEnglish.copyWith(color: AppColors.error),
            ),
          );
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
                const SizedBox(height: 12),
                Text(
                  'No results found for "$searchQuery"',
                  style: AppTheme.surahNameEnglish.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return _SearchResultCard(
              result: result,
              query: searchQuery,
              onTap: () {
                close(context, result);
              },
            );
          },
        );
      },
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final QuranSearchResult result;
  final String query;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.result,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${result.surahName ?? "Surah ${result.surahNumber}"}:${result.ayahNumberInSurah}',
                        style: AppTheme.surahMeta.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text(
                    result.matchedArabic,
                    style: AppTheme.arabicBody.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      fontSize: 18,
                      height: 1.8,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (result.matchedTranslation != null &&
                    result.matchedTranslation!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    result.matchedTranslation!,
                    style: TextStyle(
                      fontFamily: AppTheme.latinFontFamily,
                      fontSize: 13,
                      height: 1.5,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 250.ms),
    );
  }
}
