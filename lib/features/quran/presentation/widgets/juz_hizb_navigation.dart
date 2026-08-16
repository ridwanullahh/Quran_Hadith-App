import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/mushaf_provider.dart';

// ═══════════════════════════════════════════════════════════════════
// Juz & Hizb Navigation Sheet
// Bottom sheet showing all 30 Juz, expandable to 60 Hizb,
// and optionally 240 quarters (Rub' al-Hizb).
// ═══════════════════════════════════════════════════════════════════

class JuzHizbNavigation extends StatefulWidget {
  /// Current page number (1-604) used to highlight the active juz/hizb.
  final int currentPage;

  /// Callback when a juz is tapped. Returns the page number to navigate to.
  final void Function(int pageNumber) onJuzTap;

  /// Callback when a hizb is tapped. Returns the page number to navigate to.
  final void Function(int pageNumber) onHizbTap;

  const JuzHizbNavigation({
    super.key,
    required this.currentPage,
    required this.onJuzTap,
    required this.onHizbTap,
  });

  @override
  State<JuzHizbNavigation> createState() => _JuzHizbNavigationState();
}

class _JuzHizbNavigationState extends State<JuzHizbNavigation>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentJuz = 1;
  int _currentHizb = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentJuz = juzForPage(widget.currentPage);
    _currentHizb = _hizbForPage(widget.currentPage);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _hizbForPage(int page) {
    // Each hizb covers roughly 10 pages (604/60 ≈ 10)
    // Use the hizb breakdown for accuracy.
    for (int h = AppConstants.hizbBreakdown.length - 1; h >= 0; h--) {
      final hStart = AppConstants.hizbBreakdown[h];
      final s = hStart['surah']!;
      final a = hStart['ayah']!;
      final startPage = getPageForAyah(s, a) ?? 1;
      if (page >= startPage) {
        return h + 1;
      }
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(
                  'Navigate',
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const Spacer(),
                _InfoChip(
                  label: 'Juz $_currentJuz',
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  label: 'Hizb $_currentHizb',
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark
                ? AppColors.darkTextTertiary
                : AppColors.lightTextTertiary,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Juz (30)'),
              Tab(text: 'Hizb (60)'),
              Tab(text: 'Rub\' (240)'),
            ],
          ),

          // Tab content
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildJuzList(isDark),
                _buildHizbList(isDark),
                _buildRubElHizbList(isDark),
              ],
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  // ── Juz List ──────────────────────────────────────────────────

  Widget _buildJuzList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: AppConstants.totalJuz,
      itemBuilder: (context, index) {
        final juzNum = index + 1;
        final juzStart = AppConstants.juzBreakdown[index];
        final startSurah = juzStart['surah']!;
        final startAyah = juzStart['ayah']!;
        final page = getPageForAyah(startSurah, startAyah) ?? 1;
        final isActive = juzNum == _currentJuz;

        return _JuzTile(
          number: juzNum,
          startSurah: startSurah,
          startAyah: startAyah,
          page: page,
          isActive: isActive,
          isDark: isDark,
          onTap: () {
            widget.onJuzTap(page);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  // ── Hizb List ─────────────────────────────────────────────────

  Widget _buildHizbList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: AppConstants.totalHizb,
      itemBuilder: (context, index) {
        final hizbNum = index + 1;
        final hizbStart = AppConstants.hizbBreakdown[index];
        final startSurah = hizbStart['surah']!;
        final startAyah = hizbStart['ayah']!;
        final page = getPageForAyah(startSurah, startAyah) ?? 1;
        final juzNum = (hizbNum ~/ 2) + (hizbNum % 2);
        final isActive = hizbNum == _currentHizb;

        return _HizbTile(
          hizbNumber: hizbNum,
          juzNumber: juzNum,
          startSurah: startSurah,
          startAyah: startAyah,
          page: page,
          isActive: isActive,
          isDark: isDark,
          onTap: () {
            widget.onHizbTap(page);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  // ── Rub' al-Hizb List (240 quarters) ──────────────────────────

  Widget _buildRubElHizbList(bool isDark) {
    // Each hizb has 4 quarters. Build the rub list from hizb data.
    // We compute quarter boundaries by distributing evenly within each hizb.
    final quarters = <_RubQuarter>[];

    for (int h = 0; h < AppConstants.totalHizb; h++) {
      final hizbStart = AppConstants.hizbBreakdown[h];
      final s1 = hizbStart['surah']!;
      final a1 = hizbStart['ayah']!;
      final p1 = getPageForAyah(s1, a1) ?? 1;

      int s2, a2, p2;
      if (h + 1 < AppConstants.totalHizb) {
        final nextHizb = AppConstants.hizbBreakdown[h + 1];
        s2 = nextHizb['surah']!;
        a2 = nextHizb['ayah']!;
        p2 = getPageForAyah(s2, a2) ?? p1 + 10;
      } else {
        p2 = AppConstants.totalPages;
        s2 = 114;
        a2 = 6;
      }

      // Split each hizb into 4 quarters roughly by page count.
      final totalPages = p2 - p1;
      for (int q = 0; q < 4; q++) {
        final quarterPage = p1 + ((totalPages * q) ~/ 4);
        quarters.add(_RubQuarter(
          number: h * 4 + q + 1,
          hizbNumber: h + 1,
          juzNumber: (h ~/ 2) + (h % 2),
          page: quarterPage,
          startSurah: s1,
          startAyah: a1,
        ));
      }
    }

    // Group by juz
    final grouped = <int, List<_RubQuarter>>{};
    for (final q in quarters) {
      grouped.putIfAbsent(q.juzNumber, () => []).add(q);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final juzNum = index + 1;
        final quarterItems = grouped[juzNum] ?? [];
        final isActiveJuz = juzNum == _currentJuz;

        return _JuzExpandableTile(
          juzNumber: juzNum,
          quarters: quarterItems,
          isActive: isActiveJuz,
          isDark: isDark,
          onQuarterTap: (page) {
            widget.onHizbTap(page);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Helper Widgets
// ═══════════════════════════════════════════════════════════════════

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTheme.latinFontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _JuzTile extends StatelessWidget {
  final int number;
  final int startSurah;
  final int startAyah;
  final int page;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _JuzTile({
    required this.number,
    required this.startSurah,
    required this.startAyah,
    required this.page,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withOpacity(0.1)
                  : (isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightSurfaceVariant),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive
                    ? AppColors.primary
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
            ),
            child: Row(
              children: [
                // Juz number badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface),
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: TextStyle(
                        fontFamily: AppTheme.latinFontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? Colors.white
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Juz $number',
                        style: TextStyle(
                          fontFamily: AppTheme.latinFontFamily,
                          fontSize: 15,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w600,
                          color: isActive
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Starts at $startSurah:$startAyah  •  Page $page',
                        style: TextStyle(
                          fontFamily: AppTheme.latinFontFamily,
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Rub el Hizb symbol
                Icon(
                  Icons.crop_free_rounded,
                  size: 20,
                  color: isActive
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary),
                ),
              ],
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 200.ms),
    );
  }
}

class _HizbTile extends StatelessWidget {
  final int hizbNumber;
  final int juzNumber;
  final int startSurah;
  final int startAyah;
  final int page;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _HizbTile({
    required this.hizbNumber,
    required this.juzNumber,
    required this.startSurah,
    required this.startAyah,
    required this.page,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.secondary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isActive
                  ? Border.all(color: AppColors.secondary.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? AppColors.secondary
                        : (isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightSurfaceVariant),
                  ),
                  child: Center(
                    child: Text(
                      '$hizbNumber',
                      style: TextStyle(
                        fontFamily: AppTheme.latinFontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? Colors.white
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Hizb $hizbNumber  (Juz $juzNumber)',
                    style: TextStyle(
                      fontFamily: AppTheme.latinFontFamily,
                      fontSize: 14,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? AppColors.secondaryDark
                          : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary),
                    ),
                  ),
                ),
                Text(
                  'p.$page',
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
          ),
        ),
      ),
    );
  }
}

class _RubQuarter {
  final int number;
  final int hizbNumber;
  final int juzNumber;
  final int page;
  final int startSurah;
  final int startAyah;

  const _RubQuarter({
    required this.number,
    required this.hizbNumber,
    required this.juzNumber,
    required this.page,
    required this.startSurah,
    required this.startAyah,
  });
}

class _JuzExpandableTile extends StatelessWidget {
  final int juzNumber;
  final List<_RubQuarter> quarters;
  final bool isActive;
  final bool isDark;
  final void Function(int page) onQuarterTap;

  const _JuzExpandableTile({
    required this.juzNumber,
    required this.quarters,
    required this.isActive,
    required this.isDark,
    required this.onQuarterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        childrenPadding: const EdgeInsets.only(left: 16, right: 8, bottom: 8),
        initiallyExpanded: isActive,
        leading: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.primary
                : (isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant),
          ),
          child: Center(
            child: Text(
              '$juzNumber',
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive
                    ? Colors.white
                    : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary),
              ),
            ),
          ),
        ),
        title: Text(
          'Juz $juzNumber',
          style: TextStyle(
            fontFamily: AppTheme.latinFontFamily,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            color: isActive
                ? AppColors.primary
                : (isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary),
          ),
        ),
        children: quarters
            .map((q) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => onQuarterTap(q.page),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.crop_square_rounded,
                              size: 16,
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Quarter ${q.number}',
                              style: TextStyle(
                                fontFamily: AppTheme.latinFontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Hizb ${q.hizbNumber} • p.${q.page}',
                              style: TextStyle(
                                fontFamily: AppTheme.latinFontFamily,
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.lightTextTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

/// Shows the Juz/Hizb navigation bottom sheet.
Future<void> showJuzHizbNavigation({
  required BuildContext context,
  required int currentPage,
  required void Function(int pageNumber) onJuzTap,
  required void Function(int pageNumber) onHizbTap,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) => JuzHizbNavigation(
        currentPage: currentPage,
        onJuzTap: onJuzTap,
        onHizbTap: onHizbTap,
      ),
    ),
  );
}
