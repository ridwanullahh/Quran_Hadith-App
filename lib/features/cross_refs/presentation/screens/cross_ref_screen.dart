import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/cross_ref_provider.dart';

class CrossRefScreen extends ConsumerWidget {
  const CrossRefScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crossRefProvider);
    final refs = ref.watch(filteredCrossRefsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran-Hadith Cross-References'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SearchBar(
              hintText: 'Search verse or hadith...',
              leading: const Icon(Icons.search_rounded, size: 20),
              trailing: [
                if (state.searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => ref.read(crossRefProvider.notifier).updateSearch(''),
                  ),
                if (state.searchQuery.isNotEmpty || state.selectedTopic != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: ActionChip(
                      label: const Text('Clear', style: TextStyle(fontSize: 12)),
                      onPressed: () => ref.read(crossRefProvider.notifier).clearFilters(),
                    ),
                  ),
              ],
              onChanged: (v) => ref.read(crossRefProvider.notifier).updateSearch(v),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Topic filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                FilterChip(
                  label: const Text('All', style: TextStyle(fontSize: 12)),
                  selected: state.selectedTopic == null,
                  onSelected: (_) => ref.read(crossRefProvider.notifier).setTopic(null),
                  showCheckmark: false,
                  side: BorderSide(
                    color: state.selectedTopic == null ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  selectedColor: AppColors.primary.withValues(alpha: 0.12),
                  labelStyle: TextStyle(
                    color: state.selectedTopic == null ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    fontWeight: state.selectedTopic == null ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 6),
                ...kCrossRefTopics.map((topic) {
                  final selected = state.selectedTopic == topic;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(topic, style: const TextStyle(fontSize: 12)),
                      selected: selected,
                      onSelected: (_) => ref.read(crossRefProvider.notifier).setTopic(topic),
                      showCheckmark: false,
                      side: BorderSide(
                        color: selected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      selectedColor: AppColors.primary.withValues(alpha: 0.12),
                      labelStyle: TextStyle(
                        color: selected ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${refs.length} reference${refs.length != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.darkTextTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Cross-reference list
          Expanded(
            child: refs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.link_off_rounded, size: 64, color: AppColors.darkTextTertiary),
                        const SizedBox(height: 12),
                        Text(
                          'No cross-references found',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: refs.length,
                    itemBuilder: (context, index) {
                      final entry = refs[index];
                      return _CrossRefCard(
                        entry: entry,
                        isDark: isDark,
                        index: index,
                      )
                          .animate(delay: (index * 40).ms)
                          .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                          .slideY(begin: 0.06, end: 0, duration: 300.ms);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Cross-Reference Card ──────────────────────────────────────────

class _CrossRefCard extends StatelessWidget {
  final CrossRefEntry entry;
  final bool isDark;
  final int index;

  const _CrossRefCard({
    required this.entry,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => context.push('/quran/${entry.surahNumber}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Surah ${entry.surahNumber}:${entry.ayahNumber}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      entry.topic,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_outward_rounded, size: 16, color: AppColors.darkTextTertiary),
                ],
              ),
              const SizedBox(height: 10),

              // Quran verse
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.quranArabic,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: AppTheme.arabicFontFamily,
                        fontSize: 18,
                        height: 1.8,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.quranEnglish,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Link icon
              Row(
                children: [
                  Icon(Icons.link_rounded, size: 14, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Text(
                    'Related Hadith',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Hadith text
              Text(
                entry.hadithText,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),

              // Source
              Row(
                children: [
                  Icon(Icons.menu_book_rounded, size: 12, color: AppColors.darkTextTertiary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      entry.hadithSource,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.darkTextTertiary,
                      ),
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
}
