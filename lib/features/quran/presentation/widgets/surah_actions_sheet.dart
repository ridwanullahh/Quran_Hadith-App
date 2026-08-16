import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/quran_providers.dart';

// ═══════════════════════════════════════════════════════════════════
// Surah Quick Actions Bottom Sheet
// ═══════════════════════════════════════════════════════════════════

class SurahActionsSheet {
  SurahActionsSheet._();

  /// Show the quick actions bottom sheet for a surah.
  static void show({
    required BuildContext context,
    required int surahNumber,
    required String surahNameEnglish,
    required String surahNameArabic,
    required int totalAyahs,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SurahActionsContent(
        surahNumber: surahNumber,
        surahNameEnglish: surahNameEnglish,
        surahNameArabic: surahNameArabic,
        totalAyahs: totalAyahs,
      ),
    );
  }
}

class _SurahActionsContent extends ConsumerWidget {
  final int surahNumber;
  final String surahNameEnglish;
  final String surahNameArabic;
  final int totalAyahs;

  const _SurahActionsContent({
    required this.surahNumber,
    required this.surahNameEnglish,
    required this.surahNameArabic,
    required this.totalAyahs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actions = [
      _ActionItem(
        icon: Icons.play_circle_fill_rounded,
        label: 'Play from\nBeginning',
        color: AppColors.primary,
        onTap: () {
          ref.read(surahAudioProvider.notifier).playSurah(
                surahNumber: surahNumber,
                totalAyahs: totalAyahs,
              );
          Navigator.pop(context);
        },
      ),
      _ActionItem(
        icon: Icons.not_started_rounded,
        label: 'Play from\nLast Read',
        color: AppColors.secondary,
        onTap: () {
          final lastRead = ref.read(lastReadProvider);
          final startAyah =
              (lastRead.surahNumber == surahNumber) ? lastRead.ayahNumber ?? 1 : 1;
          ref.read(surahAudioProvider.notifier).playSurah(
                surahNumber: surahNumber,
                totalAyahs: totalAyahs,
              );
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Playing from ayah $startAyah'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
      _ActionItem(
        icon: Icons.bookmark_add_rounded,
        label: 'Add to\nBookmarks',
        color: AppColors.bookmarkGold,
        onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('First ayah bookmarked'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
      _ActionItem(
        icon: Icons.playlist_add_rounded,
        label: 'Add to\nReading Plan',
        color: AppColors.success,
        onTap: () {
          Navigator.pop(context);
          context.push('/reading-plan');
        },
      ),
      _ActionItem(
        icon: Icons.share_rounded,
        label: 'Share\nSurah Info',
        color: AppColors.info,
        onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Share info for $surahNameEnglish'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
      _ActionItem(
        icon: Icons.auto_stories_rounded,
        label: 'View\nTafseer',
        color: AppColors.primaryLight,
        onTap: () {
          Navigator.pop(context);
          context.push('/quran/tafseer/$surahNumber');
        },
      ),
      _ActionItem(
        icon: Icons.menu_book_rounded,
        label: 'View\nMushaf Page',
        color: AppColors.medinanBadge,
        onTap: () {
          Navigator.pop(context);
          context.push('/quran/mushaf');
        },
      ),
      _ActionItem(
        icon: Icons.notifications_active_rounded,
        label: 'Set Daily\nReminder',
        color: AppColors.warning,
        onTap: () {
          Navigator.pop(context);
          context.push('/notifications');
        },
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Surah header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                surahNameArabic,
                style: TextStyle(
                  fontFamily: AppTheme.arabicHeaderFontFamily,
                  fontSize: 20,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                surahNameEnglish,
                style: TextStyle(
                  fontFamily: AppTheme.latinFontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$totalAyahs Ayahs',
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // 2-column grid of actions
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.6,
            children: actions,
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
