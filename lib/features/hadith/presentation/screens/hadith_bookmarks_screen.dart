import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/hadith_bookmark_provider.dart';

// ═══════════════════════════════════════════════════════════════════
// Hadith Bookmarks Screen
// ═══════════════════════════════════════════════════════════════════

class HadithBookmarksScreen extends ConsumerWidget {
  const HadithBookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookmarks = ref.watch(hadithBookmarkProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadith Bookmarks'),
        actions: [
          if (bookmarks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 16),
              child: Text(
                '${bookmarks.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: bookmarks.isEmpty
          ? _buildEmptyState(theme, isDark)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = bookmarks[index];
                return _BookmarkCard(
                  bookmark: bookmark,
                  index: index,
                  isDark: isDark,
                  onTap: () {
                    context.push('/hadith/book/${bookmark.collectionId}_${bookmark.bookNumber}');
                  },
                  onRemove: () {
                    ref.read(hadithBookmarkProvider.notifier).removeBookmark(
                      collectionId: bookmark.collectionId,
                      bookNumber: bookmark.bookNumber,
                      hadithNumber: bookmark.hadithNumber,
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkBorder : AppColors.lightBorder).withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.bookmark_border_rounded,
                size: 36,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Bookmarked Hadiths',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bookmark hadiths while reading to find them here.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Bookmark Card
// ═══════════════════════════════════════════════════════════════════

class _BookmarkCard extends StatelessWidget {
  final HadithBookmark bookmark;
  final int index;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _BookmarkCard({
    required this.bookmark,
    required this.index,
    required this.isDark,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(bookmark.uniqueId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
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
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bookmark icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bookmark_rounded, size: 18, color: AppColors.secondary),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Arabic preview
                      if (bookmark.hadithArabic != null && bookmark.hadithArabic!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            bookmark.hadithArabic!.length > 80
                                ? '${bookmark.hadithArabic!.substring(0, 80)}...'
                                : bookmark.hadithArabic!,
                            style: AppTheme.arabicQuranText.copyWith(
                              fontSize: 16,
                              height: 1.6,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                            textDirection: TextDirection.rtl,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      // English text
                      Text(
                        bookmark.hadithText.length > 120
                            ? '${bookmark.hadithText.substring(0, 120)}...'
                            : bookmark.hadithText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Metadata
                      Row(
                        children: [
                          if (bookmark.collectionName != null) ...[
                            Icon(Icons.menu_book_rounded, size: 12, color: AppColors.secondary.withOpacity(0.7)),
                            const SizedBox(width: 4),
                            Text(
                              bookmark.collectionName!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            'Hadith #${bookmark.hadithNumber}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: (index * 50).ms, duration: 300.ms).slideY(begin: 0.03, end: 0),
    );
  }
}
