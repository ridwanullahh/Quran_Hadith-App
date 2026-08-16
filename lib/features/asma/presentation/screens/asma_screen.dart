import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/asma_provider.dart';

class AsmaScreen extends ConsumerStatefulWidget {
  const AsmaScreen({super.key});

  @override
  ConsumerState<AsmaScreen> createState() => _AsmaScreenState;
}

class _AsmaScreenState extends ConsumerState<AsmaScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asmaState = ref.watch(asmaProvider);
    final dailyName = ref.watch(dailyNameProvider);
    final names = ref.watch(filteredAsmaNamesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asma ul Husna'),
        actions: [
          IconButton(
            icon: Icon(
              asmaState.showFavoritesOnly
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: asmaState.showFavoritesOnly
                  ? AppColors.bookmarkGold
                  : null,
            ),
            tooltip: 'Show Favorites',
            onPressed: () => ref.read(asmaProvider.notifier).toggleShowFavorites(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Daily name banner
          _DailyNameBanner(name: dailyName, isDark: isDark),

          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: (v) =>
                  ref.read(asmaProvider.notifier).setSearchQuery(v),
              decoration: InputDecoration(
                hintText: 'Search by name or meaning...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: asmaState.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () =>
                            ref.read(asmaProvider.notifier).setSearchQuery(''),
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
          const SizedBox(height: 4),

          // Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${names.length} name${names.length != 1 ? "s" : ""}',
                style: TextStyle(
                  fontFamily: AppTheme.latinFontFamily,
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Grid
          Expanded(
            child: names.isEmpty
                ? Center(
                    child: Text(
                      asmaState.showFavoritesOnly
                          ? 'No favorites yet'
                          : 'No names found',
                      style: TextStyle(
                        fontFamily: AppTheme.latinFontFamily,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: names.length,
                    itemBuilder: (context, index) {
                      return _NameCard(name: names[index])
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: index * 15),
                            duration: 250.ms,
                          );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Daily Name Banner ─────────────────────────────────────────────

class _DailyNameBanner extends ConsumerWidget {
  final AsmaName name;
  final bool isDark;
  const _DailyNameBanner({required this.name, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  size: 16, color: AppColors.secondaryLight),
              const SizedBox(width: 6),
              Text(
                'Name of the Day',
                style: TextStyle(
                  fontFamily: AppTheme.latinFontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryLight,
                ),
              ),
              const Spacer(),
              Text(
                '#${name.number}',
                style: TextStyle(
                  fontFamily: AppTheme.latinFontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name.arabicName,
            style: const TextStyle(
              fontFamily: AppTheme.arabicHeaderFontFamily,
              fontSize: 36,
              color: Colors.white,
              height: 1.4,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          Text(
            name.englishMeaning,
            style: const TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0, duration: 400.ms);
  }
}

// ── Name Card ─────────────────────────────────────────────────────

class _NameCard extends ConsumerWidget {
  final AsmaName name;
  const _NameCard({required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asmaState = ref.watch(asmaProvider);
    final isFav = asmaState.favoriteIds.contains(name.number);

    return InkWell(
      onTap: () => _showDetail(context, ref),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Number
              Text(
                '${name.number}',
                style: TextStyle(
                  fontFamily: AppTheme.latinFontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              // Arabic name
              Expanded(
                child: Center(
                  child: FittedBox(
                    child: Text(
                      name.arabicName,
                      style: TextStyle(
                        fontFamily: AppTheme.arabicFontFamily,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // English meaning
              Text(
                name.englishMeaning,
                style: TextStyle(
                  fontFamily: AppTheme.latinFontFamily,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // Favorite indicator
              if (isFav)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.bookmark_rounded,
                    size: 12,
                    color: AppColors.bookmarkGold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asmaState = ref.read(asmaProvider);
    final isFav = asmaState.favoriteIds.contains(name.number);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: ListView(
          shrinkWrap: true,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.darkBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Arabic name large
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.08),
                    AppColors.secondary.withValues(alpha: 0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    '#${name.number} of 99',
                    style: TextStyle(
                      fontFamily: AppTheme.latinFontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name.arabicName,
                    style: TextStyle(
                      fontFamily: AppTheme.arabicHeaderFontFamily,
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name.englishMeaning,
                    style: TextStyle(
                      fontFamily: AppTheme.latinFontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Explanation
            Text(
              'Explanation',
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
              name.explanation,
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 15,
                height: 1.7,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Related verse
            Text(
              'Related Quranic Verse',
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name.relatedVerse,
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryDark,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                name.verseText,
                style: TextStyle(
                  fontFamily: AppTheme.arabicFontFamily,
                  fontSize: 20,
                  height: 2.0,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(height: 24),

            // Favorite button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  ref.read(asmaProvider.notifier).toggleFavorite(name.number);
                  HapticFeedback.selectionClick();
                  Navigator.pop(context);
                },
                icon: Icon(
                  isFav
                      ? Icons.bookmark_remove_rounded
                      : Icons.bookmark_add_rounded,
                ),
                label: Text(isFav ? 'Remove from Favorites' : 'Add to Favorites'),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      isFav ? AppColors.error : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
