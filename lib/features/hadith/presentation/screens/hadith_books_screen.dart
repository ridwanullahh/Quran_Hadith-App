import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../data/models/hadith/hadith_models.dart';
import '../providers/hadith_providers.dart';

class HadithBooksScreen extends ConsumerWidget {
  final String collectionId;

  const HadithBooksScreen({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final booksAsync = ref.watch(hadithBooksProvider(collectionId));
    final collectionAsync = ref.watch(hadithCollectionProvider(collectionId));

    return Scaffold(
      appBar: AppBar(
        title: collectionAsync.whenOrNull(
              data: (c) => Text(c.name),
            ) ??
            const Text('Books'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: booksAsync.when(
        loading: () => _ShimmerLoading(isDark: isDark),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Failed to load books', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(error.toString(), style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
        data: (books) => ListView.builder(
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return _BookCard(
              book: book,
              collectionId: collectionId,
              index: index,
              isDark: isDark,
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Book Card
// ═══════════════════════════════════════════════════════════════════

class _BookCard extends StatelessWidget {
  final HadithBook book;
  final String collectionId;
  final int index;
  final bool isDark;

  const _BookCard({
    required this.book,
    required this.collectionId,
    required this.index,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
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
          onTap: () {
            final bookId = '${collectionId}_${book.bookNumber}';
            context.push('/hadith/book/$bookId');
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Book number
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${book.bookNumber}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Book info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.bookName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (book.bookNameArabic != null &&
                          book.bookNameArabic!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          book.bookNameArabic!,
                          style: AppTheme.arabicQuranText.copyWith(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          textDirection: TextDirection.rtl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Hadith count
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${book.totalHadiths}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      'hadiths',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 40).ms, duration: 350.ms).slideY(begin: 0.02, end: 0);
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
      itemCount: 8,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: LinearProgressIndicator(
          backgroundColor: baseColor,
          borderRadius: BorderRadius.circular(14),
          minHeight: 72,
        ),
      ),
    );
  }
}
