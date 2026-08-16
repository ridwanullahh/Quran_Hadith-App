import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../data/models/quran/word_data.dart';
import '../providers/quran_providers.dart';

class WordDetailSheet extends ConsumerWidget {
  final int absoluteAyahNumber;
  final int surahNumber;
  final int ayahNumberInSurah;

  const WordDetailSheet({
    super.key,
    required this.absoluteAyahNumber,
    required this.surahNumber,
    required this.ayahNumberInSurah,
  });

  static Future<void> show({
    required BuildContext context,
    required int absoluteAyahNumber,
    required int surahNumber,
    required int ayahNumberInSurah,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        overrides: [],
        child: WordDetailSheet(
          absoluteAyahNumber: absoluteAyahNumber,
          surahNumber: surahNumber,
          ayahNumberInSurah: ayahNumberInSurah,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wordAnalysisAsync = ref.watch(wordAnalysisProvider(absoluteAyahNumber));

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Surah $surahNumber : $ayahNumberInSurah',
                      style: TextStyle(
                        fontFamily: AppTheme.latinFontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: wordAnalysisAsync.when(
                  data: (analysis) => _WordList(
                    analysis: analysis,
                    scrollController: scrollController,
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 40,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Word analysis unavailable',
                            style: AppTheme.surahNameEnglish.copyWith(
                              fontSize: 15,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            style: AppTheme.surahMeta.copyWith(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WordList extends StatefulWidget {
  final AyahWordAnalysis analysis;
  final ScrollController scrollController;

  const _WordList({
    required this.analysis,
    required this.scrollController,
  });

  @override
  State<_WordList> createState() => _WordListState();
}

class _WordListState extends State<_WordList> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: widget.analysis.words.length,
      itemBuilder: (context, index) {
        final word = widget.analysis.words[index];
        final isExpanded = _expandedIndex == index;
        return _WordCard(
          word: word,
          wordIndex: index,
          isExpanded: isExpanded,
          onTap: () {
            setState(() {
              _expandedIndex = isExpanded ? null : index;
            });
          },
        );
      },
    );
  }
}

class _WordCard extends StatelessWidget {
  final WordData word;
  final int wordIndex;
  final bool isExpanded;
  final VoidCallback onTap;

  const _WordCard({
    required this.word,
    required this.wordIndex,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isExpanded
              ? (isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightSurfaceVariant)
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isExpanded
                ? AppColors.primary.withOpacity(0.4)
                : (isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWordHeader(isDark),
                  if (isExpanded) ...[
                    const SizedBox(height: 14),
                    _buildTransliteration(isDark),
                    if (word.translation != null &&
                        word.translation!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildTranslation(isDark),
                    ],
                    if (word.hasRootAnalysis) ...[
                      const SizedBox(height: 10),
                      _buildRootLetters(isDark),
                    ],
                    if (word.partOfSpeech != null &&
                        word.partOfSpeech!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildPartOfSpeech(isDark),
                    ],
                    if (word.hasMorphology) ...[
                      const SizedBox(height: 10),
                      _buildMorphology(isDark),
                    ],
                    if (word.grammarNote != null &&
                        word.grammarNote!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildGrammarNote(isDark),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      )
          .animate(target: isExpanded ? 1 : 0)
          .fadeIn(duration: 150.ms),
    );
  }

  Widget _buildWordHeader(bool isDark) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${wordIndex + 1}',
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              word.textArabic,
              style: AppTheme.arabicQuranTextLarge.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                fontSize: 30,
                height: 1.6,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          isExpanded
              ? Icons.expand_less_rounded
              : Icons.expand_more_rounded,
          size: 20,
          color: isDark
              ? AppColors.darkTextTertiary
              : AppColors.lightTextTertiary,
        ),
      ],
    );
  }

  Widget _buildTransliteration(bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.record_voice_over_rounded,
          size: 14,
          color: AppColors.primary.withOpacity(0.7),
        ),
        const SizedBox(width: 6),
        Text(
          word.textTransliteration,
          style: TextStyle(
            fontFamily: AppTheme.latinFontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildTranslation(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant.withOpacity(0.5)
            : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Translation',
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            word.translation!,
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRootLetters(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(isDark ? 0.08 : 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_tree_rounded,
                size: 14,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                'Root Letters',
                style: TextStyle(
                  fontFamily: AppTheme.latinFontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              word.rootLetters ?? '',
              style: AppTheme.arabicHeaderSmall.copyWith(
                color: AppColors.secondary,
                fontSize: 22,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          if (word.rootWords != null && word.rootWords!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Related words from same root:',
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: word.rootWords!.map((rootWord) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      rootWord,
                      style: AppTheme.arabicBodySmall.copyWith(
                        color: AppColors.secondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPartOfSpeech(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _capitalizeFirst(word.partOfSpeech!),
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMorphology(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant.withOpacity(0.5)
            : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Morphology',
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            word.morphology!,
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrammarNote(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.info.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 14,
                color: AppColors.info,
              ),
              const SizedBox(width: 6),
              Text(
                'Grammar Note',
                style: TextStyle(
                  fontFamily: AppTheme.latinFontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            word.grammarNote!,
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
