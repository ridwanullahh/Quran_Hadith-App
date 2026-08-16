import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../providers/hadith_providers.dart';
import '../widgets/hadith_card.dart';

class HadithListScreen extends ConsumerStatefulWidget {
  final String bookId;

  const HadithListScreen({super.key, required this.bookId});

  @override
  ConsumerState<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends ConsumerState<HadithListScreen> {
  bool _showFullText = false;
  final Set<int> _expandedHadiths = {};

  String get _collectionId {
    final parts = widget.bookId.split('_');
    return parts.first;
  }

  int get _bookNumber {
    final parts = widget.bookId.split('_');
    return int.tryParse(parts.length > 1 ? parts.sublist(1).join('_') : '1') ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final key = BookIdKey(collectionId: _collectionId, bookNumber: _bookNumber);
    final hadithsAsync = ref.watch(hadithsInBookProvider(key));

    return Scaffold(
      appBar: AppBar(
        title: Text('Book $_bookNumber'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showFullText ? Icons.short_text_rounded : Icons.notes_rounded,
            ),
            onPressed: () => setState(() => _showFullText = !_showFullText),
            tooltip: _showFullText ? 'Show previews' : 'Show full text',
          ),
        ],
      ),
      body: hadithsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Failed to load hadiths', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.toString(),
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        data: (hadiths) {
          if (hadiths.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    size: 48,
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hadiths found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 12, bottom: 24),
            itemCount: hadiths.length,
            itemBuilder: (context, index) {
              final hadith = hadiths[index];
              final isExpanded = _expandedHadiths.contains(hadith.hadithNumber);

              return HadithCard(
                hadith: hadith,
                collectionName: _collectionId,
                bookName: 'Book $_bookNumber',
                showFullText: _showFullText || isExpanded,
                showNarratorChain: isExpanded,
                onTap: () {
                  setState(() {
                    if (isExpanded) {
                      _expandedHadiths.remove(hadith.hadithNumber);
                    } else {
                      _expandedHadiths.add(hadith.hadithNumber);
                    }
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
