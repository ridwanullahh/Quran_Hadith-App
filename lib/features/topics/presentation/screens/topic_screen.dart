import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/topic_provider.dart';

class TopicScreen extends ConsumerWidget {
  const TopicScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(topicProvider);
    final topics = ref.watch(filteredTopicsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expandedTopic = state.selectedTopicId != null
        ? topics.where((t) => t.id == state.selectedTopicId).firstOrNull
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quran Topics'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SearchBar(
              hintText: 'Search topics or verses...',
              leading: const Icon(Icons.search_rounded, size: 20),
              trailing: state.searchQuery.isNotEmpty
                  ? [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => ref.read(topicProvider.notifier).updateSearch(''),
                      ),
                    ]
                  : null,
              onChanged: (v) => ref.read(topicProvider.notifier).updateSearch(v),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
      body: topics.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off_rounded, size: 64, color: AppColors.darkTextTertiary),
                  const SizedBox(height: 12),
                  Text(
                    'No topics found for "${state.searchQuery}"',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
            )
          : expandedTopic != null
              ? _TopicDetail(
                  topic: expandedTopic,
                  onBack: () => ref.read(topicProvider.notifier).clearSelection(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final topic = topics[index];
                    return _TopicCard(
                      topic: topic,
                      onTap: () => ref.read(topicProvider.notifier).selectTopic(topic.id),
                      isDark: isDark,
                    )
                        .animate(delay: (index * 40).ms)
                        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                        .slideY(begin: 0.08, end: 0, duration: 300.ms, curve: Curves.easeOut);
                  },
                ),
    );
  }
}

// ── Topic Card ─────────────────────────────────────────────────────

class _TopicCard extends StatelessWidget {
  final QuranTopic topic;
  final VoidCallback onTap;
  final bool isDark;

  const _TopicCard({required this.topic, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
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
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: topic.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(topic.icon, color: topic.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.englishName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        topic.arabicName,
                        style: TextStyle(
                          fontFamily: AppTheme.arabicFontFamily,
                          fontSize: 16,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${topic.verses.length} verses',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.darkTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.darkTextTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Topic Detail ──────────────────────────────────────────────────

class _TopicDetail extends StatelessWidget {
  final QuranTopic topic;
  final VoidCallback onBack;

  const _TopicDetail({required this.topic, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [topic.color, topic.color.withOpacity(0.7)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: onBack,
                  ),
                  const Spacer(),
                  Icon(topic.icon, color: Colors.white.withOpacity(0.8), size: 32),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                topic.englishName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                topic.arabicName,
                style: TextStyle(
                  fontFamily: AppTheme.arabicHeaderFontFamily,
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                topic.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 250.ms),

        // Verse count chip
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: topic.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${topic.verses.length} verses',
                  style: TextStyle(
                    color: topic.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Verses list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: topic.verses.length,
            itemBuilder: (context, index) {
              final verse = topic.verses[index];
              return _VerseCard(
                verse: verse,
                topicColor: topic.color,
                index: index,
                isDark: isDark,
              )
                  .animate(delay: (index * 50).ms)
                  .fadeIn(duration: 250.ms)
                  .slideY(begin: 0.06, end: 0, duration: 250.ms);
            },
          ),
        ),
      ],
    );
  }
}

// ── Verse Card ─────────────────────────────────────────────────────

class _VerseCard extends StatelessWidget {
  final TopicVerse verse;
  final Color topicColor;
  final int index;
  final bool isDark;

  const _VerseCard({
    required this.verse,
    required this.topicColor,
    required this.index,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/quran/${verse.surahNumber}'),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 0.5,
              ),
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: topicColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${verse.surahNumber}:${verse.ayahNumber}',
                        style: TextStyle(
                          color: topicColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_outward_rounded,
                      size: 16,
                      color: AppColors.darkTextTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  verse.arabicText,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: AppTheme.arabicFontFamily,
                    fontSize: 20,
                    height: 1.8,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  verse.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
