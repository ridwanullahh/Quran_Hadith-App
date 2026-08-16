import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/dua_provider.dart';

class DuaScreen extends ConsumerStatefulWidget {
  const DuaScreen({super.key});

  @override
  ConsumerState<DuaScreen> createState() => _DuaScreenState;
}

class _DuaScreenState extends ConsumerState<DuaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Du'a Collection"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Du\'as'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AllDuasTab(isDark: isDark),
          _FavoritesTab(isDark: isDark),
        ],
      ),
    );
  }
}

// ── All Du'as Tab ─────────────────────────────────────────────────

class _AllDuasTab extends ConsumerWidget {
  final bool isDark;
  const _AllDuasTab({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duaState = ref.watch(duaProvider);
    final duas = ref.watch(filteredDuasProvider);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            onChanged: (v) => ref.read(duaProvider.notifier).setSearchQuery(v),
            decoration: InputDecoration(
              hintText: 'Search du\'as...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: duaState.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () =>
                          ref.read(duaProvider.notifier).setSearchQuery(''),
                    )
                  : null,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style: const TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Category filter chips
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: kDuaCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = kDuaCategories[index];
              final selected = duaState.selectedCategory == cat.$1;
              return FilterChip(
                label: Text(
                  cat.$2,
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                selected: selected,
                onSelected: (_) {
                  if (selected) {
                    ref.read(duaProvider.notifier).setCategory(null);
                  } else {
                    ref.read(duaProvider.notifier).setCategory(cat.$1);
                  }
                },
                visualDensity: VisualDensity.compact,
                showCheckmark: false,
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Results count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '${duas.length} du\'a${duas.length != 1 ? "'s" : ""}',
                style: TextStyle(
                  fontFamily: AppTheme.latinFontFamily,
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
              if (duaState.selectedCategory != null ||
                  duaState.searchQuery.isNotEmpty) ...[
                const Spacer(),
                GestureDetector(
                  onTap: () => ref.read(duaProvider.notifier).clearFilters(),
                  child: Text(
                    'Clear filters',
                    style: TextStyle(
                      fontFamily: AppTheme.latinFontFamily,
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Dua list
        Expanded(
          child: duas.isEmpty
              ? Center(
                  child: Text(
                    'No du\'as found',
                    style: TextStyle(
                      fontFamily: AppTheme.latinFontFamily,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: duas.length,
                  itemBuilder: (context, index) {
                    return _DuaCard(dua: duas[index])
                        .animate()
                        .fadeIn(
                          delay: Duration(milliseconds: index * 40),
                          duration: 300.ms,
                        )
                        .slideY(
                          begin: 0.08,
                          end: 0,
                          delay: Duration(milliseconds: index * 40),
                          duration: 300.ms,
                        );
                  },
                ),
        ),
      ],
    );
  }
}

// ── Favorites Tab ─────────────────────────────────────────────────

class _FavoritesTab extends ConsumerWidget {
  final bool isDark;
  const _FavoritesTab({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favs = ref.watch(favoriteDuasProvider);

    if (favs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 64,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 16,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap the bookmark icon on any du\'a to save it here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: favs.length,
      itemBuilder: (context, index) {
        return _DuaCard(dua: favs[index])
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: index * 40),
              duration: 300.ms,
            );
      },
    );
  }
}

// ── Du'a Card ─────────────────────────────────────────────────────

class _DuaCard extends ConsumerWidget {
  final Dua dua;
  const _DuaCard({required this.dua});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final duaState = ref.watch(duaProvider);
    final isFav = duaState.favoriteIds.contains(dua.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showDuaDetail(context, ref),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        dua.categoryName,
                        style: const TextStyle(
                          fontFamily: AppTheme.latinFontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Favorite
                    InkWell(
                      onTap: () {
                        ref.read(duaProvider.notifier).toggleFavorite(dua.id);
                        HapticFeedback.selectionClick();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          isFav
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 20,
                          color: isFav ? AppColors.bookmarkGold : (isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Share
                    InkWell(
                      onTap: () => _shareDua(context, ref),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.share_rounded,
                          size: 18,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Arabic text
                Text(
                  dua.arabicText,
                  style: TextStyle(
                    fontFamily: AppTheme.arabicFontFamily,
                    fontSize: 20,
                    height: 1.8,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // English translation
                Text(
                  dua.englishTranslation,
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 13,
                    height: 1.5,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Source
                Text(
                  dua.source,
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppColors.secondaryDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDuaDetail(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.darkBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dua.categoryName,
                  style: const TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Arabic
              Text(
                dua.arabicText,
                style: TextStyle(
                  fontFamily: AppTheme.arabicFontFamily,
                  fontSize: 26,
                  height: 2.0,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 24),

              const Divider(),
              const SizedBox(height: 16),

              // Translation
              Text(
                'Translation',
                style: TextStyle(
                  fontFamily: AppTheme.latinFontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dua.englishTranslation,
                style: TextStyle(
                  fontFamily: AppTheme.latinFontFamily,
                  fontSize: 15,
                  height: 1.7,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Source
              Row(
                children: [
                  Icon(Icons.menu_book_rounded,
                      size: 14, color: AppColors.secondaryDark),
                  const SizedBox(width: 6),
                  Text(
                    dua.source,
                    style: TextStyle(
                      fontFamily: AppTheme.latinFontFamily,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppColors.secondaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareDua(context, ref),
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Share'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                            text:
                                '${dua.arabicText}\n\n${dua.englishTranslation}\n\nSource: ${dua.source}',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Copy'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareDua(BuildContext context, WidgetRef ref) {
    final text =
        '${dua.arabicText}\n\n${dua.englishTranslation}\n\nSource: ${dua.source}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Du\'a text copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
