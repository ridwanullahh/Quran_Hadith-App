import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/services/database/database.dart';

// ═══════════════════════════════════════════════════════════════════
// Providers
// ═══════════════════════════════════════════════════════════════════

final bookmarkDbProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final bookmarksStreamProvider = StreamProvider<List<Bookmark>>((ref) {
  final db = ref.watch(bookmarkDbProvider);
  return db.bookmarkDao.watchAllBookmarks();
});

// ═══════════════════════════════════════════════════════════════════
// Screen
// ═══════════════════════════════════════════════════════════════════

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookmarksAsync = ref.watch(bookmarksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Quran'),
            Tab(text: 'Hadith'),
          ],
        ),
      ),
      body: bookmarksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Failed to load bookmarks', style: theme.textTheme.titleMedium),
            ],
          ),
        ),
        data: (bookmarks) {
          final filtered = _filterBookmarks(bookmarks);
          final displayBookmarks = _searchBookmarks(filtered);

          if (displayBookmarks.isEmpty) {
            return _EmptyState(
              message: bookmarks.isEmpty
                  ? 'No bookmarks yet'
                  : 'No bookmarks match your search',
              subMessage: bookmarks.isEmpty
                  ? 'Bookmark ayahs while reading to find them here.'
                  : 'Try a different search term.',
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(displayBookmarks),
              _buildList(
                displayBookmarks.where((b) => b.category == 'quran' || b.category == 'general').toList(),
              ),
              _buildList(
                displayBookmarks.where((b) => b.category == 'hadith').toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Bookmark> _filterBookmarks(List<Bookmark> bookmarks) {
    return switch (_tabController.index) {
      0 => bookmarks,
      1 => bookmarks.where((b) => b.category == 'quran' || b.category == 'general').toList(),
      2 => bookmarks.where((b) => b.category == 'hadith').toList(),
      _ => bookmarks,
    };
  }

  List<Bookmark> _searchBookmarks(List<Bookmark> bookmarks) {
    if (_searchQuery.isEmpty) return bookmarks;
    final q = _searchQuery.toLowerCase();
    return bookmarks.where((b) {
      return b.surahName.toLowerCase().contains(q) ||
          b.ayahText.toLowerCase().contains(q) ||
          b.surahNumber.toString().contains(q) ||
          b.ayahNumber.toString().contains(q);
    }).toList();
  }

  Widget _buildList(List<Bookmark> bookmarks) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return _BookmarkItem(
          bookmark: bookmark,
          onDelete: () => _deleteBookmark(bookmark),
        );
      },
    );
  }

  void _deleteBookmark(Bookmark bookmark) {
    final db = ref.read(bookmarkDbProvider);
    db.bookmarkDao.removeBookmarkById(bookmark.id);
  }
}

// ═══════════════════════════════════════════════════════════════════
// Bookmark Item
// ═══════════════════════════════════════════════════════════════════

class _BookmarkItem extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback onDelete;

  const _BookmarkItem({
    required this.bookmark,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: ValueKey(bookmark.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Remove Bookmark?'),
            content: Text(
              'Remove bookmark for ${bookmark.surahName}:${bookmark.ayahNumber}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: InkWell(
            onTap: () => context.push('/quran/${bookmark.surahNumber}'),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Bookmark icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.bookmarkGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.bookmark_rounded,
                      size: 20,
                      color: AppColors.bookmarkGold,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Surah & ayah info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${bookmark.surahName} : ${bookmark.ayahNumber}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (bookmark.ayahText.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            bookmark.ayahText,
                            style: AppTheme.arabicQuranText.copyWith(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Category badge & date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          bookmark.category,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(bookmark.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.35),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideX(begin: -0.02, end: 0);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ═══════════════════════════════════════════════════════════════════
// Empty State
// ═══════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final String message;
  final String subMessage;

  const _EmptyState({required this.message, required this.subMessage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_outline_rounded,
              size: 56,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subMessage,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
