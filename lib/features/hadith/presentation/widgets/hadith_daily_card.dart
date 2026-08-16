import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../screens/hadith_of_day_screen.dart';
import '../providers/hadith_bookmark_provider.dart';

// ═══════════════════════════════════════════════════════════════════
// Hadith Daily Card
// A beautiful card widget showing today's hadith. Can be embedded
// in the More screen or shown as a popup.
// ═══════════════════════════════════════════════════════════════════

class HadithDailyCard extends ConsumerWidget {
  final VoidCallback? onReadMore;
  final bool compact;

  const HadithDailyCard({
    super.key,
    this.onReadMore,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final todayHadith = ref.watch(hadithOfDayProvider);
    final isBookmarked = ref.watch(hadithBookmarkProvider).any(
      (b) => b.hadithText == todayHadith.english,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkSurface,
                  AppColors.darkSurfaceVariant,
                ],
              )
            : null,
        color: isDark ? null : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Hadith of the Day',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              // Favorite button
              _CircleButton(
                icon: isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: isBookmarked ? AppColors.secondary : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                onTap: () {
                  if (isBookmarked) {
                    // Remove bookmark - find and remove
                    final existing = ref.read(hadithBookmarkProvider).firstWhere(
                      (b) => b.hadithText == todayHadith.english,
                      orElse: () => const HadithBookmark(
                        collectionId: '',
                        bookNumber: 0,
                        hadithNumber: 0,
                        hadithText: '',
                        bookmarkedAt: DateTime.now(),
                      ),
                    );
                    if (existing.collectionId.isNotEmpty) {
                      ref.read(hadithBookmarkProvider.notifier).removeBookmark(
                        collectionId: existing.collectionId,
                        bookNumber: existing.bookNumber,
                        hadithNumber: existing.hadithNumber,
                      );
                    }
                  } else {
                    ref.read(hadithBookmarkProvider.notifier).addBookmark(
                      collectionId: 'daily',
                      bookNumber: 0,
                      hadithNumber: 0,
                      hadithText: todayHadith.english,
                      hadithArabic: todayHadith.arabic,
                      collectionName: todayHadith.source,
                      narrator: todayHadith.narrator,
                    );
                  }
                },
              ),
              const SizedBox(width: 6),
              // Share button
              _CircleButton(
                icon: Icons.share_rounded,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                onTap: () {
                  Share.share(
                    '${todayHadith.arabic}\n\n${todayHadith.english}\n\n— ${todayHadith.source}, ${todayHadith.reference}',
                    subject: 'Hadith of the Day',
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Arabic text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.12),
                width: 0.5,
              ),
            ),
            child: Text(
              todayHadith.arabic,
              style: AppTheme.arabicQuranText.copyWith(
                fontSize: compact ? 18 : 22,
                height: 2.0,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              maxLines: compact ? 3 : null,
              overflow: compact ? TextOverflow.ellipsis : null,
            ),
          ),

          const SizedBox(height: 14),

          // English text
          Text(
            todayHadith.english,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              fontStyle: FontStyle.italic,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
            maxLines: compact ? 3 : null,
            overflow: compact ? TextOverflow.ellipsis : null,
          ),

          const SizedBox(height: 12),

          // Divider
          Divider(
            color: (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                .withOpacity(0.5),
          ),
          const SizedBox(height: 10),

          // Metadata
          Row(
            children: [
              Icon(
                Icons.person_rounded,
                size: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                todayHadith.narrator,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.menu_book_rounded, size: 13, color: AppColors.secondary),
              const SizedBox(width: 5),
              Text(
                '${todayHadith.source} — ${todayHadith.reference}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Read More button
          if (onReadMore != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onReadMore,
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('Read More'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(
      begin: const Offset(0.98, 0.98),
      end: const Offset(1.0, 1.0),
      duration: 400.ms,
    );
  }

  /// Show the daily hadith as a popup dialog.
  static void showAsPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: HadithDailyCard(
            onReadMore: () {
              Navigator.of(ctx).pop();
              context.push('/hadith/daily');
            },
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Circle Button Helper
// ═══════════════════════════════════════════════════════════════════

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1),
        ),
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }
}
