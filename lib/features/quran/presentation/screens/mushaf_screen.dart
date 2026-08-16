import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/quran/surah_info.dart';
import '../providers/mushaf_provider.dart';
import '../providers/quran_providers.dart';
import '../widgets/tajweed_overlay.dart';
import '../widgets/sajdah_indicator.dart';
import '../widgets/juz_hizb_navigation.dart';

// ═══════════════════════════════════════════════════════════════════
// Mushaf Screen
// A full-screen Mushaf-style reading mode with page swiping,
// tajweed overlay, sajda markers, and juz navigation.
// ═══════════════════════════════════════════════════════════════════

class MushafScreen extends ConsumerStatefulWidget {
  final int initialPage;

  const MushafScreen({super.key, this.initialPage = 1});

  @override
  ConsumerState<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends ConsumerState<MushafScreen> {
  late PageController _pageController;
  bool _showControls = true;
  bool _showTajweedLegend = false;

  @override
  void initState() {
    super.initState();
    final startPage =
        (widget.initialPage >= 1 && widget.initialPage <= AppConstants.totalPages)
            ? widget.initialPage - 1
            : 0;
    _pageController = PageController(initialPage: startPage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mushafPageProvider.notifier).state = widget.initialPage;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    final target =
        (page >= 1 && page <= AppConstants.totalPages) ? page - 1 : 0;
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      _showTajweedLegend = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mushafAsync = ref.watch(mushafDataProvider);
    final currentPage = ref.watch(mushafPageProvider);
    final tajweedEnabled = ref.watch(mushafTajweedEnabledProvider);
    final surahsAsync = ref.watch(surahListProvider);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A1628) : const Color(0xFFF5F0E1),
      body: SafeArea(
        child: mushafAsync.when(
          data: (mushafData) {
            final safePage =
                (currentPage >= 1 && currentPage <= mushafData.totalPages)
                    ? currentPage
                    : 1;
            final pageData = mushafData.pages[safePage - 1];
            final juz = juzForPage(safePage);

            SurahInfo? surahInfo;
            if (pageData.hasSurahStart &&
                pageData.surahStartNumber != null) {
              surahsAsync.whenData((surahs) {
                surahInfo = surahs
                    .where((s) => s.number == pageData.surahStartNumber)
                    .firstOrNull;
              });
            }

            return Stack(
              children: [
                // Main page content
                GestureDetector(
                  onTap: _toggleControls,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: mushafData.totalPages,
                    onPageChanged: (page) {
                      ref.read(mushafPageProvider.notifier).state = page + 1;
                      HapticFeedback.selectionClick();
                    },
                    itemBuilder: (context, index) {
                      final page = index + 1;
                      final data = mushafData.pages[index];
                      SurahInfo? pageSurahInfo;
                      if (data.hasSurahStart &&
                          data.surahStartNumber != null) {
                        surahsAsync.whenData((surahs) {
                          pageSurahInfo = surahs
                              .where((s) => s.number == data.surahStartNumber)
                              .firstOrNull;
                        });
                      }
                      return _MushafPageView(
                        pageData: data,
                        surahInfo: pageSurahInfo,
                        tajweedEnabled: tajweedEnabled,
                        isDark: isDark,
                      );
                    },
                  ),
                ),

                // Top controls
                if (_showControls)
                  _TopControlsBar(
                    currentPage: safePage,
                    totalPages: mushafData.totalPages,
                    juzNumber: juz,
                    isDark: isDark,
                    onJuzTap: () {
                      showJuzHizbNavigation(
                        context: context,
                        currentPage: safePage,
                        onJuzTap: _goToPage,
                        onHizbTap: _goToPage,
                      );
                    },
                    onBack: () => context.go('/quran'),
                  ),

                // Bottom bar
                if (_showControls)
                  _BottomBar(
                    currentPage: safePage,
                    totalPages: mushafData.totalPages,
                    tajweedEnabled: tajweedEnabled,
                    isDark: isDark,
                    onToggleTajweed: () {
                      ref
                          .read(mushafTajweedEnabledProvider.notifier)
                          .state = !tajweedEnabled;
                    },
                    onToggleLegend: () {
                      setState(() => _showTajweedLegend = !_showTajweedLegend);
                    },
                    onGoToPage: _goToPage,
                  ),

                // Tajweed legend popup
                if (_showTajweedLegend && _showControls)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 80,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const TajweedLegend(),
                    ),
                  ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.2, end: 0),

                // Juz side marker
                _JuzSideMarker(
                  juzNumber: juz,
                  isDark: isDark,
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Failed to load Mushaf data',
                  style:
                      AppTheme.surahNameEnglish.copyWith(color: AppColors.error),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: AppTheme.surahMeta,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      // Floating action button: toggle Learning (Tajweed) mode
      floatingActionButton: AnimatedSlide(
        offset: _showControls ? Offset.zero : const Offset(0, 2),
        duration: const Duration(milliseconds: 300),
        child: AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: FloatingActionButton.extended(
            onPressed: () {
              ref.read(mushafTajweedEnabledProvider.notifier).state =
                  !ref.read(mushafTajweedEnabledProvider);
            },
            backgroundColor: tajweedEnabled
                ? AppColors.primary
                : AppColors.darkSurfaceVariant,
            foregroundColor: tajweedEnabled
                ? Colors.white
                : AppColors.primaryLight,
            icon: Icon(
              tajweedEnabled
                  ? Icons.color_lens_rounded
                  : Icons.school_rounded,
            ),
            label: Text(
              tajweedEnabled ? 'Tajweed ON' : 'Learning Mode',
              style: const TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Mushaf Page View
// ═══════════════════════════════════════════════════════════════════

class _MushafPageView extends StatelessWidget {
  final MushafPage pageData;
  final SurahInfo? surahInfo;
  final bool tajweedEnabled;
  final bool isDark;

  const _MushafPageView({
    required this.pageData,
    this.surahInfo,
    required this.tajweedEnabled,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? const Color(0xFFE8E6E1) : const Color(0xFF1A1A2E);
    final backgroundColor =
        isDark ? const Color(0xFF0D1520) : const Color(0xFFF5F0E1);

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Surah header if a new surah starts on this page
          if (pageData.hasSurahStart && surahInfo != null)
            _SurahHeader(surahInfo: surahInfo!, isDark: isDark),

          const Spacer(flex: 1),

          // Main ayah text
          Expanded(
            flex: 15,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _buildAyahWidgets(textColor),
                ),
              ),
            ),
          ),

          const Spacer(flex: 1),

          // Page number
          _PageNumberIndicator(
            pageNumber: pageData.pageNumber,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  List<Widget> _buildAyahWidgets(Color textColor) {
    final widgets = <Widget>[];
    for (final ayah in pageData.ayahs) {
      // Bismillah before a new surah (except Al-Fatihah and At-Tawbah)
      if (ayah.ayahNumber == 1 &&
          ayah.surahNumber != 1 &&
          ayah.surahNumber != 9) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Center(
              child: Text(
                AppConstants.bismillahArabic,
                style: AppTheme.bismillahStyle.copyWith(
                  color: isDark
                      ? AppColors.secondaryLight
                      : AppColors.secondaryDark,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            textDirection: TextDirection.rtl,
            children: [
              // Arabic text with optional tajweed coloring
              Expanded(
                child: TajweedOverlay(
                  text: ayah.text,
                  enabled: tajweedEnabled,
                  style: AppTheme.arabicQuranText.copyWith(
                    color: textColor,
                    fontSize: 24,
                    height: 2.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Ayah number badge
              _AyahNumberBadge(
                ayahNumber: ayah.ayahNumber,
                isDark: isDark,
              ),
              // Sajdah indicator
              if (ayah.isSajdah)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: SajdahIndicator(
                    surahNumber: ayah.surahNumber,
                    ayahNumber: ayah.ayahNumber,
                    sajdaType: ayah.sajdaType,
                    iconSize: 14,
                  ),
                ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }
}

// ═══════════════════════════════════════════════════════════════════
// Surah Header (displayed when a new surah starts on a page)
// ═══════════════════════════════════════════════════════════════════

class _SurahHeader extends StatelessWidget {
  final SurahInfo surahInfo;
  final bool isDark;

  const _SurahHeader({required this.surahInfo, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Column(
        children: [
          // Decorative divider with surah number
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: (isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary)
                      .withValues(alpha: 0.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? AppColors.secondaryLight
                          : AppColors.secondaryDark,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${surahInfo.number}',
                      style: AppTheme.ayahNumberStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.secondaryLight
                            : AppColors.secondaryDark,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: (isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary)
                      .withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Arabic surah name
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              surahInfo.nameArabic,
              style: AppTheme.arabicHeader.copyWith(
                color: isDark
                    ? AppColors.secondaryLight
                    : AppColors.secondaryDark,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          // English name and metadata
          Text(
            '${surahInfo.nameEnglish}  \u2022  ${surahInfo.totalAyahs} Ayahs  \u2022  ${surahInfo.revelationType}',
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Ayah Number Badge
// ═══════════════════════════════════════════════════════════════════

class _AyahNumberBadge extends StatelessWidget {
  final int ayahNumber;
  final bool isDark;

  const _AyahNumberBadge({
    required this.ayahNumber,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Center(
        child: Text(
          '$ayahNumber',
          style: TextStyle(
            fontFamily: AppTheme.latinFontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Page Number Indicator
// ═══════════════════════════════════════════════════════════════════

class _PageNumberIndicator extends StatelessWidget {
  final int pageNumber;
  final bool isDark;

  const _PageNumberIndicator({
    required this.pageNumber,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 1,
          height: 16,
          color: (isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary)
              .withValues(alpha: 0.4),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '$pageNumber',
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
          ),
        ),
        Container(
          width: 1,
          height: 16,
          color: (isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary)
              .withValues(alpha: 0.4),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Top Controls Bar
// ═══════════════════════════════════════════════════════════════════

class _TopControlsBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int juzNumber;
  final bool isDark;
  final VoidCallback onJuzTap;
  final VoidCallback onBack;

  const _TopControlsBar({
    required this.currentPage,
    required this.totalPages,
    required this.juzNumber,
    required this.isDark,
    required this.onJuzTap,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              (isDark ? const Color(0xFF0A1628) : const Color(0xFFF5F0E1))
                  .withValues(alpha: 0.95),
              (isDark ? const Color(0xFF0A1628) : const Color(0xFFF5F0E1))
                  .withValues(alpha: 0.0),
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(8, 8, 12, 24),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              onPressed: onBack,
            ),
            const Spacer(),
            // Juz indicator
            GestureDetector(
              onTap: onJuzTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.crop_free_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Juz $juzNumber',
                      style: const TextStyle(
                        fontFamily: AppTheme.latinFontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

// ═══════════════════════════════════════════════════════════════════
// Bottom Bar
// ═══════════════════════════════════════════════════════════════════

class _BottomBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool tajweedEnabled;
  final bool isDark;
  final VoidCallback onToggleTajweed;
  final VoidCallback onToggleLegend;
  final void Function(int page) onGoToPage;

  const _BottomBar({
    required this.currentPage,
    required this.totalPages,
    required this.tajweedEnabled,
    required this.isDark,
    required this.onToggleTajweed,
    required this.onToggleLegend,
    required this.onGoToPage,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              (isDark ? const Color(0xFF0A1628) : const Color(0xFFF5F0E1))
                  .withValues(alpha: 0.95),
              (isDark ? const Color(0xFF0A1628) : const Color(0xFFF5F0E1))
                  .withValues(alpha: 0.0),
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Page slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Text(
                    '$currentPage',
                    style: TextStyle(
                      fontFamily: AppTheme.latinFontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 16),
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor:
                            isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        thumbColor: AppColors.primary,
                      ),
                      child: Slider(
                        value: currentPage.toDouble(),
                        min: 1,
                        max: totalPages.toDouble(),
                        onChanged: (value) {
                          onGoToPage(value.round());
                        },
                      ),
                    ),
                  ),
                  Text(
                    '$totalPages',
                    style: TextStyle(
                      fontFamily: AppTheme.latinFontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  icon: tajweedEnabled
                      ? Icons.color_lens_rounded
                      : Icons.color_lens_outlined,
                  label: 'Tajweed',
                  isActive: tajweedEnabled,
                  isDark: isDark,
                  onTap: onToggleTajweed,
                ),
                const SizedBox(width: 16),
                if (tajweedEnabled)
                  _ActionButton(
                    icon: Icons.info_outline_rounded,
                    label: 'Legend',
                    isActive: false,
                    isDark: isDark,
                    onTap: onToggleLegend,
                  ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

// ═══════════════════════════════════════════════════════════════════
// Action Button
// ═══════════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isActive
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Juz Side Marker
// ═══════════════════════════════════════════════════════════════════

class _JuzSideMarker extends StatelessWidget {
  final int juzNumber;
  final bool isDark;

  const _JuzSideMarker({required this.juzNumber, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Center(
        child: RotatedBox(
          quarterTurns: 3,
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Text(
              '\u062C$juzNumber',
              style: TextStyle(
                fontFamily: AppTheme.arabicFontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
