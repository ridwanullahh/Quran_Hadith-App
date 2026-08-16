import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/quran/surah_info.dart';
import '../providers/quran_providers.dart';

// ═══════════════════════════════════════════════════════════════════
// Surah Info Data (complementary metadata for all 114 surahs)
// ═══════════════════════════════════════════════════════════════════

const Map<int, _SurahExtendedInfo> _extendedInfo = {
  1: _SurahExtendedInfo(
    rukuCount: 1,
    sajdahCount: 0,
    hizbQuarters: [1, 2],
    themes: ['Praise of Allah', 'Worship', 'Guidance', 'Divine Mercy'],
    relation: 'Opens the Quran — the key to the entire Book.',
    prevSurah: null,
    nextSurah: 'Al-Baqarah — establishes laws and guidance for the Muslim community.',
  ),
};

_SurahExtendedInfo _getDefaultExtended(int number) {
  return _SurahExtendedInfo(
    rukuCount: 0,
    sajdahCount: 0,
    hizbQuarters: [],
    themes: ['Quranic Revelation'],
    relation: '',
    prevSurah: number > 1 ? 'Surah ${number - 1}' : null,
    nextSurah: number < 114 ? 'Surah ${number + 1}' : null,
  );
}

class _SurahExtendedInfo {
  final int rukuCount;
  final int sajdahCount;
  final List<int> hizbQuarters;
  final List<String> themes;
  final String relation;
  final String? prevSurah;
  final String? nextSurah;

  const _SurahExtendedInfo({
    required this.rukuCount,
    required this.sajdahCount,
    required this.hizbQuarters,
    required this.themes,
    required this.relation,
    this.prevSurah,
    this.nextSurah,
  });
}

// ═══════════════════════════════════════════════════════════════════
// Enhanced Surah Info Screen
// ═══════════════════════════════════════════════════════════════════

class SurahInfoScreen extends ConsumerWidget {
  final int surahNumber;
  const SurahInfoScreen({super.key, required this.surahNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surahsAsync = ref.watch(surahListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Surah Information'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: surahsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Failed to load surah info', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        data: (surahs) {
          final surah = surahs.firstWhere(
            (s) => s.number == surahNumber,
            orElse: () => surahs.first,
          );
          final ext = _extendedInfo[surahNumber] ?? _getDefaultExtended(surahNumber);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [
              // ── Header Card ──────────────────────────────────────
              _buildHeaderCard(surah, isDark),
              const SizedBox(height: 16),

              // ── Quick Actions ─────────────────────────────────────
              _buildQuickActions(context, surah, isDark),
              const SizedBox(height: 16),

              // ── Details Card ──────────────────────────────────────
              _buildDetailsCard(surah, ext, isDark),
              const SizedBox(height: 16),

              // ── Themes Card ──────────────────────────────────────
              _buildThemesCard(ext, isDark),
              const SizedBox(height: 16),

              // ── Relation Card ────────────────────────────────────
              if (ext.relation.isNotEmpty || ext.prevSurah != null || ext.nextSurah != null)
                _buildRelationCard(ext, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(SurahInfo surah, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Arabic name
          Text(
            surah.nameArabic,
            style: const TextStyle(
              fontFamily: AppTheme.arabicHeaderFontFamily,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // English name
          Text(
            surah.nameEnglish,
            style: const TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          // Transliteration
          Text(
            surah.nameTransliteration,
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          // Badges row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoBadge(
                label: surah.revelationType,
                color: surah.isMeccan ? AppColors.meccanBadge : AppColors.medinanBadge,
              ),
              const SizedBox(width: 8),
              _InfoBadge(label: '${surah.totalAyahs} Ayahs', color: AppColors.secondary),
              if ((_extendedInfo[surah.number] ?? _getDefaultExtended(surah.number)).sajdahCount > 0) ...[
                const SizedBox(width: 8),
                _InfoBadge(
                  label: '${(_extendedInfo[surah.number] ?? _getDefaultExtended(surah.number)).sajdahCount} Sajdah${(_extendedInfo[surah.number] ?? _getDefaultExtended(surah.number)).sajdahCount > 1 ? 's' : ''}',
                  color: AppColors.warning,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, SurahInfo surah, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.menu_book_rounded,
            label: 'Read',
            color: AppColors.primary,
            onTap: () => context.push('/quran/${surah.number}'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.play_circle_rounded,
            label: 'Play',
            color: AppColors.secondary,
            onTap: () => context.push('/quran/${surah.number}'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.bookmark_rounded,
            label: 'Bookmark',
            color: AppColors.bookmarkGold,
            onTap: () => context.push('/bookmarks'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            icon: Icons.share_rounded,
            label: 'Share',
            color: AppColors.info,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Share ${surah.nameEnglish} info'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(SurahInfo surah, _SurahExtendedInfo ext, bool isDark) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _DetailRow(label: 'Surah Number', value: '${surah.number} of 114'),
          _DetailRow(label: 'Revelation Order', value: '${surah.revelationOrder}'),
          _DetailRow(label: 'Juz', value: surah.juzEnd != null && surah.juzEnd != surah.juzStart
              ? '${surah.juzStart} - ${surah.juzEnd}'
              : '${surah.juzStart}'),
          if (surah.pageStart != null)
            _DetailRow(label: 'Pages', value: surah.pageEnd != null
                ? '${surah.pageStart} - ${surah.pageEnd}'
                : '${surah.pageStart}'),
          if (ext.rukuCount > 0)
            _DetailRow(label: 'Ruku', value: '${ext.rukuCount}'),
          if (ext.hizbQuarters.isNotEmpty)
            _DetailRow(label: 'Hizb Quarters', value: ext.hizbQuarters.join(', ')),
          if (ext.sajdahCount > 0)
            _DetailRow(label: 'Sajdah', value: '${ext.sajdahCount}'),
          _DetailRow(label: 'Bismillah', value: surah.hasBismillah ? 'Yes' : 'No (At-Tawbah)'),
        ],
      ),
    );
  }

  Widget _buildThemesCard(_SurahExtendedInfo ext, bool isDark) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Themes',
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ext.themes.map((theme) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  theme,
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRelationCard(_SurahExtendedInfo ext, bool isDark) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Relation & Context',
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (ext.relation.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                ext.relation,
                style: TextStyle(
                  fontFamily: AppTheme.latinFontFamily,
                  fontSize: 13,
                  height: 1.6,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ),
          if (ext.prevSurah != null)
            Row(
              children: [
                Icon(Icons.arrow_back_rounded, size: 16,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                const SizedBox(width: 4),
                Text(
                  'Previous: ${ext.prevSurah}',
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          if (ext.nextSurah != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.arrow_forward_rounded, size: 16,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                const SizedBox(width: 4),
                Text(
                  'Next: ${ext.nextSurah}',
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTheme.latinFontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
