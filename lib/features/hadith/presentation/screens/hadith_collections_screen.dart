import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../data/models/hadith/hadith_models.dart';
import '../providers/hadith_providers.dart';

class HadithCollectionsScreen extends ConsumerWidget {
  const HadithCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final collectionsAsync = ref.watch(hadithCollectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadith'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearchDialog(context, ref),
            tooltip: 'Search Hadith',
          ),
        ],
      ),
      body: collectionsAsync.when(
        loading: () => _ShimmerLoading(isDark: isDark),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Failed to load collections', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(error.toString(), style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
            ],
          ),
        ),
        data: (collections) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(hadithCollectionsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 12, bottom: 24),
            itemCount: collections.length,
            itemBuilder: (context, index) {
              final collection = collections[index];
              return _CollectionCard(
                collection: collection,
                index: index,
                isDark: isDark,
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Search Hadith'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search in Arabic or English...',
            prefixIcon: Icon(Icons.search_rounded, size: 20),
          ),
          onSubmitted: (query) {
            Navigator.pop(ctx);
            ref.read(hadithSearchProvider.notifier).search(query);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(hadithSearchProvider.notifier).search(controller.text);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Collection Card
// ═══════════════════════════════════════════════════════════════════

class _CollectionCard extends StatelessWidget {
  final HadithCollection collection;
  final int index;
  final bool isDark;

  const _CollectionCard({
    required this.collection,
    required this.index,
    required this.isDark,
  });

  String get _id => collection.id;
  String get _name => collection.name;
  String? get _nameArabic => collection.nameArabic;
  String? get _author => collection.author;
  int get _totalHadiths => collection.totalHadiths;
  int get _totalBooks => collection.totalBooks;

  Color get _accentColor {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.revisionBlue,
      const Color(0xFF7C3AED),
      const Color(0xFFEC4899),
      AppColors.hifdhGreen,
      const Color(0xFFF97316),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: InkWell(
          onTap: () => context.push('/hadith/collection/$_id'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      _nameArabic != null && _nameArabic!.isNotEmpty
                          ? _nameArabic!.substring(0, _nameArabic!.length.clamp(1, 2))
                          : _id.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'ScheherazadeNew',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _accentColor,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (_nameArabic != null)
                        Text(
                          _nameArabic!,
                          style: AppTheme.arabicQuranText.copyWith(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          textDirection: TextDirection.rtl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      if (_author != null)
                        Text(
                          _author!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Stats
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$_totalHadiths',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: _accentColor,
                      ),
                    ),
                    Text(
                      'hadiths',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_totalBooks books',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 60).ms, duration: 400.ms).slideX(begin: 0.03, end: 0);
  }
}

// ═══════════════════════════════════════════════════════════════════
// Shimmer Loading
// ═══════════════════════════════════════════════════════════════════

class _ShimmerLoading extends StatelessWidget {
  final bool isDark;
  const _ShimmerLoading({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: LinearProgressIndicator(
          backgroundColor: baseColor,
          borderRadius: BorderRadius.circular(16),
          minHeight: 90,
        ),
      ),
    );
  }
}
