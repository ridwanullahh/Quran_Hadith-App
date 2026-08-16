import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════
// Glossary Entry
// ═══════════════════════════════════════════════════════════════════

class GlossaryEntry {
  final String term;
  final String termArabic;
  final String category;
  final String definition;
  final String? example;

  const GlossaryEntry({
    required this.term,
    required this.termArabic,
    required this.category,
    required this.definition,
    this.example,
  });
}

// ═══════════════════════════════════════════════════════════════════
// Glossary Data
// ═══════════════════════════════════════════════════════════════════

const List<GlossaryEntry> _glossaryEntries = [
  // Hadith Science
  GlossaryEntry(
    term: 'Hadith',
    termArabic: 'حديث',
    category: 'Hadith Science',
    definition: 'A report of the words, actions, or approvals of the Prophet Muhammad (peace be upon him). Plural: Ahadith.',
    example: '"Actions are judged by intentions" is a famous hadith.',
  ),
  GlossaryEntry(
    term: 'Isnad',
    termArabic: 'إسناد',
    category: 'Hadith Science',
    definition: 'The chain of narrators (transmitters) through which a hadith has been transmitted. The isnad is crucial for determining authenticity.',
    example: 'The isnad of this hadith goes: Al-Bukhari → Yahya → Muhammad → Umar → Prophet.',
  ),
  GlossaryEntry(
    term: 'Matn',
    termArabic: 'متن',
    category: 'Hadith Science',
    definition: 'The actual text/content of the hadith — the words attributed to the Prophet, as opposed to the chain of narrators.',
  ),
  GlossaryEntry(
    term: 'Sanad',
    termArabic: 'سند',
    category: 'Hadith Science',
    definition: 'Another term for Isnad. The chain of people who transmitted the hadith from one person to the next.',
  ),
  GlossaryEntry(
    term: 'Muhaddith',
    termArabic: 'محدث',
    category: 'Hadith Science',
    definition: 'A scholar who specializes in the study of hadith — its narration, authentication, and classification.',
    example: 'Imam al-Bukhari was one of the greatest muhaddithun in Islamic history.',
  ),
  GlossaryEntry(
    term: 'Musnad',
    termArabic: 'مسند',
    category: 'Hadith Science',
    definition: 'A collection of hadiths organized by the narrator (Companion) who reported them, rather than by topic.',
    example: 'Musnad Ahmad ibn Hanbal contains hadiths organized by Companion.',
  ),

  // Authenticity
  GlossaryEntry(
    term: 'Sahih',
    termArabic: 'صحيح',
    category: 'Authenticity',
    definition: 'Authentic. A hadith that meets all the conditions of authenticity: continuous chain, trustworthy narrators, and absence of hidden defects (illah).',
    example: 'Sahih al-Bukhari contains only sahih hadiths.',
  ),
  GlossaryEntry(
    term: 'Hasan',
    termArabic: 'حسن',
    category: 'Authenticity',
    definition: 'Good. A hadith whose narrators are of good character but not reaching the highest level of memorization precision required for Sahih.',
  ),
  GlossaryEntry(
    term: "Da'if",
    termArabic: 'ضعيف',
    category: 'Authenticity',
    definition: 'Weak. A hadith that does not meet the criteria for Sahih or Hasan due to a break in the chain or a problem with a narrator.',
  ),
  GlossaryEntry(
    term: 'Mawdu\' (Fabricated)',
    termArabic: 'موضوع',
    category: 'Authenticity',
    definition: 'Fabricated. A hadith that has been falsely attributed to the Prophet. It is the lowest grade of inauthenticity.',
  ),
  GlossaryEntry(
    term: 'Mursal',
    termArabic: 'مرسل',
    category: 'Authenticity',
    definition: 'A hadith where a Tabi\'i (successor) narrates directly from the Prophet without mentioning the Companion in between.',
  ),
  GlossaryEntry(
    term: 'Munqati\'',
    termArabic: 'منقطع',
    category: 'Authenticity',
    definition: 'Broken. A hadith with a discontinuity in its chain of narration — at least one narrator is missing between two others.',
  ),
  GlossaryEntry(
    term: 'Mutawatir',
    termArabic: 'متواتر',
    category: 'Authenticity',
    definition: 'Mass-transmitted. A hadith reported by such a large number of narrators that it is impossible for them to have conspired to fabricate it.',
  ),
  GlossaryEntry(
    term: 'Ahad',
    termArabic: 'آحاد',
    category: 'Authenticity',
    definition: 'Singular. A hadith that does not reach the level of Tawatur — reported by one or a few narrators in each generation.',
  ),

  // Narrators
  GlossaryEntry(
    term: 'Rawi',
    termArabic: 'راوي',
    category: 'Narrators',
    definition: 'A narrator/transmitter of hadith. Each link in the isnad is a rawi.',
  ),
  GlossaryEntry(
    term: 'Sahabi (Companion)',
    termArabic: 'صحابي',
    category: 'Narrators',
    definition: 'A person who met the Prophet Muhammad, believed in him, and died as a Muslim. Companions are the most trustworthy narrators.',
    example: 'Abu Hurairah, Aisha, and Umar ibn al-Khattab were Sahabah.',
  ),
  GlossaryEntry(
    term: "Tabi'i (Successor)",
    termArabic: 'تابعي',
    category: 'Narrators',
    definition: 'A Muslim who met at least one Companion of the Prophet but did not meet the Prophet himself.',
  ),
  GlossaryEntry(
    term: 'Thiqah',
    termArabic: 'ثقة',
    category: 'Narrators',
    definition: 'Trustworthy/Reliable. The highest grade of narrator reliability — precise in memory and upright in character.',
  ),
  GlossaryEntry(
    term: 'Saduq',
    termArabic: 'صدوق',
    category: 'Narrators',
    definition: 'Truthful. A narrator who is honest but may have minor lapses in precision or memory.',
  ),
  GlossaryEntry(
    term: 'Majhul',
    termArabic: 'مجهول',
    category: 'Narrators',
    definition: 'Unknown. A narrator about whom scholars have insufficient information to determine their reliability.',
  ),

  // Collections
  GlossaryEntry(
    term: 'Kutub al-Sittah',
    termArabic: 'الكتب الستة',
    category: 'Collections',
    definition: 'The Six Books — the six canonical hadith collections: Sahih al-Bukhari, Sahih Muslim, Sunan al-Tirmidhi, Sunan Abu Dawud, Sunan an-Nasa\'i, and Sunan Ibn Majah.',
  ),
  GlossaryEntry(
    term: 'Juz\'',
    termArabic: 'جزء',
    category: 'Collections',
    definition: 'A section or portion of a hadith collection, often dedicated to a specific topic or narrator.',
  ),
  GlossaryEntry(
    term: 'Kitab',
    termArabic: 'كتاب',
    category: 'Collections',
    definition: 'Book/chapter within a hadith collection. Major collections are divided into multiple kitabs by topic.',
    example: 'Sahih al-Bukhari has 97 kitabs covering various topics.',
  ),
];

// ═══════════════════════════════════════════════════════════════════
// Hadith Glossary Screen
// ═══════════════════════════════════════════════════════════════════

class HadithGlossaryScreen extends StatefulWidget {
  const HadithGlossaryScreen({super.key});

  @override
  State<HadithGlossaryScreen> createState() => _HadithGlossaryScreenState();
}

class _HadithGlossaryScreenState extends State<HadithGlossaryScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<String> get _categories {
    final cats = _glossaryEntries.map((e) => e.category).toSet().toList()..sort();
    return ['All', ...cats];
  }

  List<GlossaryEntry> get _filteredEntries {
    return _glossaryEntries.where((e) {
      final matchesCategory = _selectedCategory == 'All' || e.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          e.term.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.termArabic.contains(_searchQuery) ||
          e.definition.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final entries = _filteredEntries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadith Glossary'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return FilterChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor:
                      isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: 0.5,
                  ),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  onSelected: (_) =>
                      setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search terms...',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${entries.length} terms',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Entries
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 48,
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        const SizedBox(height: 16),
                        Text(
                          'No terms found',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      return _GlossaryCard(
                        entry: entries[index],
                        index: index,
                        isDark: isDark,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Glossary Card
// ═══════════════════════════════════════════════════════════════════

class _GlossaryCard extends StatelessWidget {
  final GlossaryEntry entry;
  final int index;
  final bool isDark;

  const _GlossaryCard({
    required this.entry,
    required this.index,
    required this.isDark,
  });

  Color get _categoryColor {
    switch (entry.category) {
      case 'Hadith Science':
        return AppColors.primary;
      case 'Authenticity':
        return AppColors.hifdhGreen;
      case 'Narrators':
        return const Color(0xFF7C3AED);
      case 'Collections':
        return AppColors.secondary;
      default:
        return AppColors.darkTextTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Text(
                    entry.term,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    entry.termArabic,
                    style: AppTheme.arabicQuranText.copyWith(
                      fontSize: 16,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      entry.category,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _categoryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Definition
              Text(
                entry.definition,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),

              // Example
              if (entry.example != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.secondary.withOpacity(0.15),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.format_quote_rounded, size: 14, color: AppColors.secondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          entry.example!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.secondary,
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ).animate().fadeIn(delay: (index * 40).ms, duration: 300.ms).slideY(begin: 0.02, end: 0),
    );
  }
}
