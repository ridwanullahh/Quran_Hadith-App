import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/quran_providers.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════
// Expanded Tafseer Screen — full-screen per-surah tafseer viewer
// ═══════════════════════════════════════════════════════════════════

class TafseerScreen extends ConsumerStatefulWidget {
  final int surahNumber;
  const TafseerScreen({super.key, required this.surahNumber});

  @override
  ConsumerState<TafseerScreen> createState() => _TafseerScreenState();
}

class _TafseerScreenState extends ConsumerState<TafseerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const _sources = ['Ibn Kathir', "As-Sa'di"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _sources.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailAsync = ref.watch(surahDetailProvider(widget.surahNumber));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Failed to load tafseer', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        data: (detail) {
          final surah = detail.surahInfo;
          final tafseerMap = detail.tafseer;

          return Column(
            children: [
              // ── AppBar ──────────────────────────────────────────────
              AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_rounded,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  onPressed: () => context.pop(),
                ),
                title: Column(
                  children: [
                    Text(
                      surah.nameEnglish,
                      style: TextStyle(
                        fontFamily: AppTheme.latinFontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      surah.nameArabic,
                      style: TextStyle(
                        fontFamily: AppTheme.arabicHeaderFontFamily,
                        fontSize: 18,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                centerTitle: true,
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppColors.primary,
                  unselectedLabelColor:
                      isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  indicatorColor: AppColors.primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: _sources.map((s) => Tab(text: s)).toList(),
                ),
              ),

              // ── Tafseer Body ────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _sources.map((source) {
                    return _buildTafseerList(
                      tafseerMap: tafseerMap,
                      source: source,
                      surah: surah,
                      isDark: isDark,
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTafseerList({
    required Map<int, dynamic> tafseerMap,
    required String source,
    required dynamic surah,
    required bool isDark,
  }) {
    // Collect all ayah numbers from the tafseer map, filtering by source.
    // The tafseerMap values are AyahTafseer objects; the sourceName field
    // may match our tab label.
    final filteredEntries = <MapEntry<int, dynamic>>[];

    for (final entry in tafseerMap.entries) {
      final t = entry.value;
      if (t.sourceName == source) {
        filteredEntries.add(entry);
      }
    }

    if (filteredEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_rounded, size: 56,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
            const SizedBox(height: 16),
            Text(
              'No tafseer available',
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 15,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tafseer data for $source is not yet loaded for this surah.',
              textAlign: TextAlign.center,
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

    // Sort by ayah number
    filteredEntries.sort((a, b) => a.key.compareTo(b.key));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      itemCount: filteredEntries.length,
      itemBuilder: (context, index) {
        final ayahNum = filteredEntries[index].key;
        final tafseerObj = filteredEntries[index].value;

        return _TafseerAyahCard(
          ayahNumber: ayahNum,
          tafseerText: tafseerObj.text,
          source: source,
          isDark: isDark,
        ).animate().fadeIn(duration: 250.ms, delay: ((index % 15) * 30).ms);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tafseer Ayah Card
// ═══════════════════════════════════════════════════════════════════

class _TafseerAyahCard extends StatelessWidget {
  final int ayahNumber;
  final String tafseerText;
  final String source;
  final bool isDark;

  const _TafseerAyahCard({
    required this.ayahNumber,
    required this.tafseerText,
    required this.source,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ayah Number Header ──────────────────────────────────
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '$ayahNumber',
                      style: const TextStyle(
                        fontFamily: AppTheme.latinFontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Ayah $ayahNumber — $source',
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Tafseer Text ─────────────────────────────────────────
            Text(
              tafseerText,
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 14,
                height: 1.7,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
