import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../data/models/hadith/hadith_models.dart';
import '../providers/hadith_providers.dart';

// ═══════════════════════════════════════════════════════════════════
// Hadith Search Screen
// ═══════════════════════════════════════════════════════════════════

class HadithSearchScreen extends ConsumerStatefulWidget {
  const HadithSearchScreen({super.key});

  @override
  ConsumerState<HadithSearchScreen> createState() => _HadithSearchScreenState();
}

class _HadithSearchScreenState extends ConsumerState<HadithSearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _selectedCollection = 'All';
  List<String> _recentSearches = [];
  bool _showRecent = true;

  final _collections = [
    'All',
    'Sahih al-Bukhari',
    'Sahih Muslim',
    'Sunan al-Tirmidhi',
    'Sunan Abu Dawud',
    'Sunan an-Nasai',
    'Sunan Ibn Majah',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadRecentSearches() {
    try {
      final box = Hive.box('search_cache');
      final searches = box.get('hadith_recent', defaultValue: <String>[]) as List;
      _recentSearches = searches.cast<String>();
    } catch (_) {
      _recentSearches = [];
    }
  }

  void _saveSearch(String query) {
    if (query.trim().isEmpty) return;
    try {
      final box = Hive.box('search_cache');
      final searches = List<String>.from(
        box.get('hadith_recent', defaultValue: <String>[]) as List,
      );
      searches.remove(query);
      searches.insert(0, query);
      if (searches.length > 10) searches.removeRange(10, searches.length);
      box.put('hadith_recent', searches);
      setState(() => _recentSearches = searches);
    } catch (_) {}
  }

  void _clearRecentSearches() {
    try {
      final box = Hive.box('search_cache');
      box.delete('hadith_recent');
      setState(() => _recentSearches = []);
    } catch (_) {}
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) {
      ref.read(hadithSearchProvider.notifier).clear();
      setState(() => _showRecent = true);
      return;
    }
    setState(() => _showRecent = false);
    _saveSearch(query);
    ref.read(hadithSearchProvider.notifier).search(query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final searchState = ref.watch(hadithSearchProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Search hadith (Arabic or English)...',
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _onSearch,
          onChanged: (value) {
            if (value.isEmpty) {
              ref.read(hadithSearchProvider.notifier).clear();
              setState(() => _showRecent = true);
            }
          },
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () {
                _controller.clear();
                ref.read(hadithSearchProvider.notifier).clear();
                setState(() => _showRecent = true);
                _focusNode.requestFocus();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Collection filter chips
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _collections.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final collection = _collections[index];
                final isSelected = _selectedCollection == collection;
                return FilterChip(
                  label: Text(
                    collection,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: 0.5,
                  ),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  onSelected: (_) {
                    setState(() => _selectedCollection = collection);
                    if (_controller.text.isNotEmpty) {
                      _onSearch(_controller.text);
                    }
                  },
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.darkBorder),

          // Content
          Expanded(
            child: _showRecent
                ? _buildRecentSearches(theme, isDark)
                : _buildSearchResults(searchState, theme, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(ThemeData theme, bool isDark) {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 56, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            const SizedBox(height: 16),
            Text(
              'Search Hadith',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search in Arabic or English across all hadith collections',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            TextButton(
              onPressed: _clearRecentSearches,
              child: Text(
                'Clear',
                style: TextStyle(fontSize: 12, color: AppColors.error),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._recentSearches.asMap().entries.map((entry) {
          final index = entry.key;
          final search = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ListTile(
              dense: true,
              leading: Icon(
                Icons.history_rounded,
                size: 18,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
              title: Text(search),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onTap: () {
                _controller.text = search;
                _onSearch(search);
              },
              trailing: IconButton(
                icon: Icon(Icons.close_rounded, size: 16, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                onPressed: () {
                  try {
                    final box = Hive.box('search_cache');
                    final searches = List<String>.from(
                      box.get('hadith_recent', defaultValue: <String>[]) as List,
                    );
                    searches.remove(search);
                    box.put('hadith_recent', searches);
                    setState(() => _recentSearches = searches);
                  } catch (_) {}
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSearchResults(HadithSearchState searchState, ThemeData theme, bool isDark) {
    if (searchState.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Search failed', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              searchState.error!,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    var results = searchState.results;

    // Filter by collection if selected
    if (_selectedCollection != 'All' && results.isNotEmpty) {
      results = results
          .where((r) => r.collectionName == _selectedCollection ||
              r.hadith.collectionId == _selectedCollection.toLowerCase().replaceAll(' ', '-'))
          .toList();
    }

    if (results.isEmpty && searchState.query.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 56, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or remove the collection filter',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _SearchResultCard(
          result: result,
          index: index,
          isDark: isDark,
          onTap: () {
            // Navigate to the hadith's book
            context.push('/hadith/book/${result.hadith.collectionId}_${result.hadith.bookNumber}');
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Search Result Card
// ═══════════════════════════════════════════════════════════════════

class _SearchResultCard extends StatelessWidget {
  final HadithSearchResult result;
  final int index;
  final bool isDark;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.result,
    required this.index,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hadith = result.hadith;

    // Get the display text (English or Arabic)
    final displayText = result.highlightedEnglish ??
        (hadith.textEnglish != null && hadith.textEnglish!.length > 180
            ? '${hadith.textEnglish!.substring(0, 180)}...'
            : hadith.textEnglish) ??
        hadith.arabicPreview;

    final isArabic = hadith.textEnglish == null || hadith.textEnglish!.isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(
                        child: Text(
                          '${hadith.hadithNumber}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result.collectionName ?? hadith.collectionId,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hadith.narrator != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.person_rounded, size: 12, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          hadith.narrator!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),

                // Arabic preview (if available)
                if (hadith.textArabic.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      hadith.arabicPreview,
                      style: AppTheme.arabicQuranText.copyWith(
                        fontSize: 16,
                        height: 1.8,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      textDirection: TextDirection.rtl,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // English text
                Text(
                  displayText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    fontFamily: isArabic ? 'Amiri' : null,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                // Book name
                if (result.bookName != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.menu_book_rounded, size: 12, color: AppColors.secondary.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(
                        result.bookName!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.secondary.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: (index * 40).ms, duration: 300.ms).slideY(begin: 0.02, end: 0),
    );
  }
}
