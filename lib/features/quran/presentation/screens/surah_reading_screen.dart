import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/quran_providers.dart';
import '../../../../app/shell/mini_audio_player_provider.dart';
import '../widgets/ayah_widget.dart';
import '../widgets/word_detail_sheet.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/quran/surah_info.dart';

class SurahReadingScreen extends ConsumerStatefulWidget {
  final int surahNumber;

  const SurahReadingScreen({super.key, required this.surahNumber});

  @override
  ConsumerState<SurahReadingScreen> createState() => _SurahReadingScreenState();
}

class _SurahReadingScreenState extends ConsumerState<SurahReadingScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final Map<int, GlobalKey> _ayahKeys = {};
  bool _showSearchField = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollToAyah(int ayahNumber) {
    final key = _ayahKeys[ayahNumber];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(surahDetailProvider(widget.surahNumber));
    final showTranslation = ref.watch(showTranslationProvider);
    final showTafseer = ref.watch(showTafseerProvider);
    final audioState = ref.watch(surahAudioProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(miniAudioPlayerProvider, (prev, next) {
      final nextVal = next.valueOrNull;
      final prevVal = prev?.valueOrNull;
      if (nextVal != null &&
          nextVal.isActive &&
          prevVal?.currentAyah != nextVal.currentAyah &&
          nextVal.currentAyah > 0) {
        _scrollToAyah(nextVal.currentAyah);
        ref.read(surahAudioProvider.notifier).updateCurrentAyah(nextVal.currentAyah);
      }
    });

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        bottom: false,
        child: detailAsync.when(
          data: (detail) {
            final surah = detail.surahInfo;
            return Column(
              children: [
                _buildAppBar(surah, isDark, showTranslation, showTafseer),
                if (_showSearchField) _buildSearchField(isDark),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 8, bottom: 120),
                    itemCount: detail.ayahs.length +
                        (surah.hasBismillah ? 2 : 1),
                    itemBuilder: (context, index) {
                      if (index == 0 && surah.hasBismillah) {
                        return _buildBismillah(isDark);
                      }
                      if (index == 0 && !surah.hasBismillah) {
                        return _buildSurahInfo(surah, isDark);
                      }
                      if (index == 1 && surah.hasBismillah) {
                        return _buildSurahInfo(surah, isDark);
                      }

                      final ayahListIndex = index - (surah.hasBismillah ? 2 : 1);
                      final ayah = detail.ayahs[ayahListIndex];
                      final translation =
                          detail.translations[ayah.ayahNumber];
                      final tafseer = detail.tafseer[ayah.ayahNumber];
                      final isCurrentAyah = audioState.isPlaying &&
                          audioState.currentAyah == ayah.ayahNumber;

                      if (!_ayahKeys.containsKey(ayah.ayahNumber)) {
                        _ayahKeys[ayah.ayahNumber] = GlobalKey();
                      }

                      return AyahWidget(
                        key: _ayahKeys[ayah.ayahNumber],
                        ayah: ayah,
                        surahNumber: widget.surahNumber,
                        translation: translation?.text,
                        tafseerText: tafseer?.text,
                        tafseerSourceName: tafseer?.sourceName,
                        showTranslation: showTranslation,
                        showTafseer: showTafseer,
                        isPlaying: isCurrentAyah,
                        isSajdah: ayah.sajda,
                        onTap: () {
                          WordDetailSheet.show(
                            context: context,
                            absoluteAyahNumber: ayah.number,
                            surahNumber: widget.surahNumber,
                            ayahNumberInSurah: ayah.ayahNumber,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading Surah ${widget.surahNumber}...',
                  style: AppTheme.surahNameEnglish.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load surah',
                    style: AppTheme.surahNameEnglish,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: AppTheme.surahMeta.copyWith(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: detailAsync.maybeWhen<Widget>(
        data: (detail) =>
            _buildFloatingActions(detail.surahInfo, audioState, isDark),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    SurahInfo surah,
    bool isDark,
    bool showTranslation,
    bool showTafseer,
  ) {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
        onPressed: () => context.pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            surah.nameEnglish,
            style: AppTheme.surahNameEnglish.copyWith(
              fontSize: 16,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 1),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              surah.nameArabic,
              style: AppTheme.arabicBodySmall.copyWith(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      actions: [
        _buildToggleChip(
          icon: Icons.translate_rounded,
          isActive: showTranslation,
          tooltip: 'Translation',
          isDark: isDark,
          onTap: () {
            ref.read(showTranslationProvider.notifier).state =
                !showTranslation;
          },
        ),
        _buildToggleChip(
          icon: Icons.menu_book_rounded,
          isActive: showTafseer,
          tooltip: 'Tafseer',
          isDark: isDark,
          onTap: () {
            ref.read(showTafseerProvider.notifier).state = !showTafseer;
          },
        ),
        _buildToggleChip(
          icon: Icons.search_rounded,
          isActive: _showSearchField,
          tooltip: 'Jump to Ayah',
          isDark: isDark,
          onTap: () {
            setState(() {
              _showSearchField = !_showSearchField;
              if (!_showSearchField) {
                _searchController.clear();
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildToggleChip({
    required IconData icon,
    required bool isActive,
    required String tooltip,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: IconButton(
        icon: Icon(
          icon,
          size: 22,
          color: isActive
              ? AppColors.primary
              : (isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary),
        ),
        tooltip: tooltip,
        onPressed: onTap,
        style: IconButton.styleFrom(
          backgroundColor:
              isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: StatefulBuilder(
        builder: (context, setInnerState) {
          return TextField(
            controller: _searchController,
            autofocus: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.go,
            onChanged: (_) => setInnerState(() {}),
            onSubmitted: (value) {
              final ayahNum = int.tryParse(value.trim());
              if (ayahNum != null && ayahNum > 0) {
                _scrollToAyah(ayahNum);
                FocusScope.of(context).unfocus();
              }
            },
            decoration: InputDecoration(
              hintText: 'Jump to ayah number...',
              hintStyle: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.arrow_downward_rounded,
                size: 20,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        size: 20,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setInnerState(() {});
                      },
                    )
                  : null,
              isDense: true,
              filled: true,
              fillColor: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightSurfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color:
                      isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color:
                      isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 15,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBismillah(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.secondary.withValues(alpha: 0.4),
                width: 1.5,
              ),
              bottom: BorderSide(
                color: AppColors.secondary.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              AppConstants.bismillahArabic,
              style: AppTheme.bismillahStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: 100.ms)
          .slideY(
              begin: -0.1,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOut),
    );
  }

  Widget _buildSurahInfo(SurahInfo surah, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoChip(
                icon: Icons.place_rounded,
                label: surah.revelationType,
                color: surah.revelationType == AppConstants.meccan
                    ? AppColors.meccanBadge
                    : AppColors.medinanBadge,
              ),
              const SizedBox(width: 12),
              _InfoChip(
                icon: Icons.format_list_numbered_rounded,
                label: '${surah.totalAyahs} Ayahs',
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              _InfoChip(
                icon: Icons.bookmark_border_rounded,
                label: 'Juz ${surah.juzStart}',
                color: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            surah.nameTransliteration,
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 350.ms)
        .slideX(
            begin: 0.05, end: 0, duration: 350.ms, curve: Curves.easeOut);
  }

  Widget _buildFloatingActions(
    SurahInfo surah,
    SurahAudioState audioState,
    bool isDark,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (audioState.isPlaying)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FloatingActionButton.small(
              heroTag: 'stop_audio',
              onPressed: () {
                ref.read(surahAudioProvider.notifier).stop();
              },
              backgroundColor: AppColors.error,
              child: const Icon(Icons.stop_rounded, size: 20),
            )
                .animate()
                .fadeIn(duration: 200.ms)
                .scale(
                    begin: const Offset(0.5, 0.5), duration: 200.ms),
          ),
        FloatingActionButton(
          heroTag: 'play_audio',
          onPressed: () {
            if (audioState.isPlaying) {
              ref.read(surahAudioProvider.notifier).pause();
            } else {
              ref.read(surahAudioProvider.notifier).playSurah(
                surahNumber: widget.surahNumber,
                totalAyahs: surah.totalAyahs,
              );
            }
          },
          backgroundColor:
              audioState.isPlaying ? AppColors.secondary : AppColors.primary,
          child: Icon(
            audioState.isPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            size: 28,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
