import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../screens/hadith_of_day_screen.dart';

// ═══════════════════════════════════════════════════════════════════
// Hadith Favorites Screen
// ═══════════════════════════════════════════════════════════════════

class HadithFavoritesScreen extends ConsumerStatefulWidget {
  const HadithFavoritesScreen({super.key});

  @override
  ConsumerState<HadithFavoritesScreen> createState() => _HadithFavoritesScreenState();
}

class _HadithFavoritesScreenState extends ConsumerState<HadithFavoritesScreen> {
  String _filter = 'All';

  final _collections = ['All', 'Sahih al-Bukhari', 'Sahih Muslim', 'Sunan al-Tirmidhi', 'Sunan Abu Dawud'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final favorites = ref.watch(hadithFavoritesProvider);

    final filtered = _filter == 'All'
        ? favorites
        : favorites.where((h) => h.source == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Hadiths'),
        actions: [
          if (favorites.isNotEmpty)
            IconButton(
              icon: Icon(Icons.filter_list_rounded, color: _filter != 'All' ? AppColors.primary : null),
              onPressed: () => _showFilterSheet(context),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          if (_filter != 'All')
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Filtering: $_filter',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _filter = 'All'),
                    child: Icon(Icons.close_rounded, size: 16, color: AppColors.primary),
                  ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(theme, isDark, favorites)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _FavoriteHadithCard(
                        hadith: filtered[index],
                        index: index,
                        isDark: isDark,
                        onTap: () => _showHadithDetail(context, filtered[index]),
                        onDismissed: () {
                          ref.read(hadithFavoritesProvider.notifier).toggleFavorite(filtered[index]);
                        },
                        onShare: () {
                          final h = filtered[index];
                          Share.share(
                            '${h.arabic}\n\n${h.english}\n\n— ${h.source}, ${h.reference}',
                            subject: 'Hadith Share',
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark, List<DailyHadith> allFavorites) {
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
                _filter != 'All' ? Icons.filter_list_rounded : Icons.bookmark_border_rounded,
                size: 36,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _filter != 'All'
                  ? 'No favorites from $_filter'
                  : 'No Favorite Hadiths Yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _filter != 'All'
                  ? 'Try removing the filter to see all favorites.'
                  : 'Bookmark hadiths from the Hadith of the Day to find them here.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            if (_filter != 'All') ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _filter = 'All'),
                child: const Text('Show All'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Filter by Collection',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                ..._collections.map((collection) {
                  final isSelected = _filter == collection;
                  final count = collection == 'All'
                      ? ref.read(hadithFavoritesProvider).length
                      : ref
                          .read(hadithFavoritesProvider)
                          .where((h) => h.source == collection)
                          .length;
                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: isSelected ? AppColors.primary : AppColors.darkTextTertiary,
                    ),
                    title: Text(collection),
                    trailing: Text(
                      '$count',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.darkTextTertiary,
                          ),
                    ),
                    onTap: () {
                      setState(() => _filter = collection);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showHadithDetail(BuildContext context, DailyHadith hadith) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.darkBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        hadith.arabic,
                        style: AppTheme.arabicQuranText.copyWith(
                          fontSize: 24,
                          height: 2.0,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        hadith.english,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.7,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Divider(color: AppColors.darkBorder),
                      const SizedBox(height: 12),
                      Text(
                        'Narrated by ${hadith.narrator}',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        '${hadith.source} — ${hadith.reference}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: () {
                    Share.share(
                      '${hadith.arabic}\n\n${hadith.english}\n\n— ${hadith.source}, ${hadith.reference}',
                    );
                  },
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text('Share Hadith'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Favorite Hadith Card with swipe to dismiss
// ═══════════════════════════════════════════════════════════════════

class _FavoriteHadithCard extends StatelessWidget {
  final DailyHadith hadith;
  final int index;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDismissed;
  final VoidCallback onShare;

  const _FavoriteHadithCard({
    required this.hadith,
    required this.index,
    required this.isDark,
    required this.onTap,
    required this.onDismissed,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(hadith.reference),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
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
            padding: const EdgeInsets.all(16),
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
                const SizedBox(width: 14),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hadith.arabic,
                        style: AppTheme.arabicQuranText.copyWith(
                          fontSize: 16,
                          height: 1.6,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hadith.english,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${hadith.source} — ${hadith.reference}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Share button
                IconButton(
                  icon: const Icon(Icons.share_rounded, size: 18),
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  onPressed: onShare,
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: (index * 50).ms, duration: 300.ms).slideY(begin: 0.05, end: 0),
    );
  }
}
