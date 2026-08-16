import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════
// Collection Overview Data
// ═══════════════════════════════════════════════════════════════════

class CollectionOverview {
  final String id;
  final String name;
  final String nameArabic;
  final String author;
  final String authorArabic;
  final String birthYear;
  final String deathYear;
  final String birthPlace;
  final int totalHadiths;
  final int totalBooks;
  final int? totalVolumes;
  final String description;
  final List<String> keyTopics;
  final List<QuickStat> stats;

  const CollectionOverview({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.author,
    required this.authorArabic,
    required this.birthYear,
    required this.deathYear,
    required this.birthPlace,
    required this.totalHadiths,
    required this.totalBooks,
    this.totalVolumes,
    required this.description,
    required this.keyTopics,
    required this.stats,
  });
}

class QuickStat {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const QuickStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

// ═══════════════════════════════════════════════════════════════════
// Hardcoded Collection Data
// ═══════════════════════════════════════════════════════════════════

const List<CollectionOverview> collectionOverviews = [
  CollectionOverview(
    id: 'bukhari',
    name: 'Sahih al-Bukhari',
    nameArabic: 'صحيح البخاري',
    author: 'Imam Muhammad ibn Ismail al-Bukhari',
    authorArabic: 'محمد بن إسماعيل البخاري',
    birthYear: '194 AH / 810 CE',
    deathYear: '256 AH / 870 CE',
    birthPlace: 'Bukhara, Uzbekistan',
    totalHadiths: 7275,
    totalBooks: 97,
    totalVolumes: 3,
    description: 'The most authentic book of hadith after the Quran. Imam al-Bukhari spent 16 years compiling this work, selecting from 600,000 narrations and including only those that met the most stringent authenticity criteria. Every hadith has a continuous, unbroken chain of trustworthy narrators.',
    keyTopics: ['Tawheed', 'Prayer', 'Zakat', 'Fasting', 'Hajj', 'Jihad', 'Knowledge', 'Virtues', 'Companions', 'Medicine'],
    stats: [
      QuickStat(label: 'Uniques', value: '2,602', icon: Icons.filter_1_rounded, color: AppColors.hifdhGreen),
      QuickStat(label: 'Repetitions', value: '4,673', icon: Icons.repeat_rounded, color: AppColors.secondary),
      QuickStat(label: 'Narrators', value: '2,000+', icon: Icons.people_rounded, color: const Color(0xFF7C3AED)),
      QuickStat(label: 'Duration', value: '16 years', icon: Icons.schedule_rounded, color: AppColors.primary),
    ],
  ),
  CollectionOverview(
    id: 'muslim',
    name: 'Sahih Muslim',
    nameArabic: 'صحيح مسلم',
    author: 'Imam Muslim ibn al-Hajjaj',
    authorArabic: 'مسلم بن الحجاج',
    birthYear: '204 AH / 821 CE',
    deathYear: '261 AH / 875 CE',
    birthPlace: 'Nishapur, Iran',
    totalHadiths: 3033,
    totalBooks: 56,
    description: 'The second most authentic hadith collection. Imam Muslim organized his collection with great precision, grouping related hadiths together and avoiding unnecessary repetitions. He selected from 300,000 narrations.',
    keyTopics: ['Faith', 'Purification', 'Prayer', 'Funerals', 'Zakat', 'Fasting', 'Marriage', 'Trade', 'Jihad', 'Leadership'],
    stats: [
      QuickStat(label: 'Uniques', value: '4,000+', icon: Icons.filter_1_rounded, color: AppColors.hifdhGreen),
      QuickStat(label: 'Without repetition', value: '3,033', icon: Icons.repeat_rounded, color: AppColors.secondary),
      QuickStat(label: 'Narrators', value: '620+', icon: Icons.people_rounded, color: const Color(0xFF7C3AED)),
      QuickStat(label: 'Student of', value: 'Al-Bukhari', icon: Icons.school_rounded, color: AppColors.primary),
    ],
  ),
  CollectionOverview(
    id: 'tirmidhi',
    name: 'Sunan al-Tirmidhi',
    nameArabic: 'سنن الترمذي',
    author: 'Imam Abu Isa al-Tirmidhi',
    authorArabic: 'أبو عيسى الترمذي',
    birthYear: '209 AH / 824 CE',
    deathYear: '279 AH / 892 CE',
    birthPlace: 'Tirmiz, Uzbekistan',
    totalHadiths: 3956,
    totalBooks: 49,
    description: 'Known as "Al-Jami" (The Comprehensive). Unique among the six books for including the grading of each hadith and the views of different scholars. Many hadiths are classified as Sahih, Hasan, or Da\'if.',
    keyTopics: ['Prayer', 'Purification', 'Funerals', 'Zakat', 'Fasting', 'Hajj', 'Marriage', 'Jihad', 'Virtues', 'Trials'],
    stats: [
      QuickStat(label: 'Sahih', value: '~2,700', icon: Icons.verified_rounded, color: AppColors.hifdhGreen),
      QuickStat(label: 'Hasan', value: '~850', icon: Icons.check_circle_rounded, color: AppColors.primary),
      QuickStat(label: 'Da\'if', value: '~400', icon: Icons.warning_rounded, color: AppColors.error),
      QuickStat(label: 'Unique feature', value: 'Gradings', icon: Icons.grade_rounded, color: AppColors.secondary),
    ],
  ),
  CollectionOverview(
    id: 'abudawud',
    name: 'Sunan Abu Dawud',
    nameArabic: 'سنن أبي داود',
    author: 'Imam Abu Dawud al-Sijistani',
    authorArabic: 'أبو داود السجستاني',
    birthYear: '202 AH / 817 CE',
    deathYear: '275 AH / 889 CE',
    birthPlace: 'Sistan, Afghanistan',
    totalHadiths: 5274,
    totalBooks: 43,
    description: 'Organized primarily by fiqh (jurisprudence) topics. Imam Abu Dawud selected from 500,000 narrations, focusing on hadiths that contain legal rulings. Many scholars consider it the most comprehensive of the four Sunan collections for fiqh.',
    keyTopics: ['Purification', 'Prayer', 'Funerals', 'Zakat', 'Fasting', 'Pilgrimage', 'Marriage', 'Food', 'Clothing', 'Medicine'],
    stats: [
      QuickStat(label: 'Selected from', value: '500,000', icon: Icons.filter_list_rounded, color: AppColors.secondary),
      QuickStat(label: 'Included', value: '5,274', icon: Icons.auto_stories_rounded, color: AppColors.primary),
      QuickStat(label: 'Focus', value: 'Fiqh', icon: Icons.gavel_rounded, color: const Color(0xFF7C3AED)),
      QuickStat(label: 'Mursal count', value: '~300', icon: Icons.link_off_rounded, color: AppColors.warning),
    ],
  ),
  CollectionOverview(
    id: 'nasai',
    name: "Sunan an-Nasa'i",
    nameArabic: 'سنن النسائي',
    author: 'Imam Ahmad ibn Shu\'ayb al-Nasa\'i',
    authorArabic: 'أحمد بن شعيب النسائي',
    birthYear: '215 AH / 830 CE',
    deathYear: '303 AH / 915 CE',
    birthPlace: 'Nasa, Turkmenistan',
    totalHadiths: 5758,
    totalBooks: 51,
    description: 'Known for its detailed coverage of the rituals of prayer and purification. Imam al-Nasa\'i was a student of both Bukhari and Muslim. His collection is considered one of the most rigorous in terms of narrator verification.',
    keyTopics: ['Purification', 'Prayer', 'Funerals', 'Zakat', 'Fasting', 'Pilgrimage', 'Marriage', 'Jihad', 'Food', 'Clothing'],
    stats: [
      QuickStat(label: 'Total', value: '5,758', icon: Icons.auto_stories_rounded, color: AppColors.primary),
      QuickStat(label: 'Uniques', value: '~3,700', icon: Icons.filter_1_rounded, color: AppColors.hifdhGreen),
      QuickStat(label: 'Specialty', value: 'Rituals', icon: Icons.mosque_rounded, color: const Color(0xFF7C3AED)),
      QuickStat(label: 'Sunan status', value: '5th of 6', icon: Icons.format_list_numbered_rounded, color: AppColors.secondary),
    ],
  ),
  CollectionOverview(
    id: 'ibnmajah',
    name: 'Sunan Ibn Majah',
    nameArabic: 'سنن ابن ماجة',
    author: 'Imam Muhammad ibn Yazid Ibn Majah',
    authorArabic: 'محمد بن يزيد ابن ماجة',
    birthYear: '209 AH / 824 CE',
    deathYear: '273 AH / 887 CE',
    birthPlace: 'Qazwin, Iran',
    totalHadiths: 4341,
    totalBooks: 37,
    description: 'The sixth and final book of the Kutub al-Sittah. It contains some hadiths not found in the other five books. Scholars debated its inclusion in the six canonical books, but it was ultimately accepted due to its value.',
    keyTopics: ['Sunnah', 'Prayer', 'Funerals', 'Zakat', 'Fasting', 'Hajj', 'Marriage', 'Jihad', 'Virtues', 'Trials'],
    stats: [
      QuickStat(label: 'Total', value: '4,341', icon: Icons.auto_stories_rounded, color: AppColors.primary),
      QuickStat(label: 'Uniques', value: '~4,000', icon: Icons.filter_1_rounded, color: AppColors.hifdhGreen),
      QuickStat(label: 'Exclusive', value: '~1,300', icon: Icons.star_rounded, color: AppColors.secondary),
      QuickStat(label: 'Accepted in', value: 'Kutub 6', icon: Icons.checklist_rounded, color: const Color(0xFF7C3AED)),
    ],
  ),
];

// ═══════════════════════════════════════════════════════════════════
// Collection Overview Screen
// ═══════════════════════════════════════════════════════════════════

class HadithCollectionOverviewScreen extends StatelessWidget {
  const HadithCollectionOverviewScreen({super.key});

  int get _totalHadithsAll => collectionOverviews.fold(0, (sum, c) => sum + c.totalHadiths);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections Overview'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Hero summary
          _HeroSummary(
            totalHadiths: _totalHadithsAll,
            totalCollections: collectionOverviews.length,
            isDark: isDark,
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 20),

          // Collection cards
          ...collectionOverviews.asMap().entries.map((entry) {
            final index = entry.key;
            final collection = entry.value;
            return _CollectionOverviewCard(
              collection: collection,
              index: index,
              isDark: isDark,
              onTap: () => context.push('/hadith/collection/${collection.id}'),
            );
          }),

          const SizedBox(height: 20),

          // Comparison note
          _ComparisonNote(isDark: isDark).animate().fadeIn(delay: 300.ms, duration: 400.ms),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Hero Summary
// ═══════════════════════════════════════════════════════════════════

class _HeroSummary extends StatelessWidget {
  final int totalHadiths;
  final int totalCollections;
  final bool isDark;

  const _HeroSummary({
    required this.totalHadiths,
    required this.totalCollections,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.library_books_rounded, size: 22, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                'Kutub al-Sittah',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'The Six Canonical Hadith Collections',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _heroStat(context, '$totalCollections', 'Collections'),
              Container(width: 1, height: 40, color: Colors.white24),
              _heroStat(context, '$totalHadiths', 'Total Hadiths'),
              Container(width: 1, height: 40, color: Colors.white24),
              _heroStat(context, '~400+', 'Books'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Collection Overview Card
// ═══════════════════════════════════════════════════════════════════

class _CollectionOverviewCard extends StatelessWidget {
  final CollectionOverview collection;
  final int index;
  final bool isDark;
  final VoidCallback onTap;

  const _CollectionOverviewCard({
    required this.collection,
    required this.index,
    required this.isDark,
    required this.onTap,
  });

  Color get _accentColor {
    const colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.hifdhGreen,
      const Color(0xFF7C3AED),
      const Color(0xFFEC4899),
      const Color(0xFFF97316),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          collection.nameArabic.substring(0, collection.nameArabic.length.clamp(1, 3)),
                          style: AppTheme.arabicQuranText.copyWith(
                            fontSize: 18,
                            color: _accentColor,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            collection.name,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            collection.authorArabic,
                            style: AppTheme.arabicQuranText.copyWith(
                              fontSize: 13,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                  ],
                ),

                const SizedBox(height: 14),

                // Stats grid
                Row(
                  children: [
                    _miniStat(context, Icons.auto_stories_rounded, '${collection.totalHadiths}', 'Hadiths'),
                    _miniStat(context, Icons.menu_book_rounded, '${collection.totalBooks}', 'Books'),
                    if (collection.totalVolumes != null)
                      _miniStat(context, Icons.collections_bookmark_rounded, '${collection.totalVolumes}', 'Volumes'),
                  ],
                ),

                const SizedBox(height: 14),

                // Description
                Text(
                  collection.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.6,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Author info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person_rounded, size: 14, color: _accentColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              collection.author,
                              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${collection.birthYear} → ${collection.deathYear} · ${collection.birthPlace}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.darkTextTertiary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Quick stats
                const SizedBox(height: 12),
                Row(
                  children: collection.stats.map((stat) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          children: [
                            Icon(stat.icon, size: 16, color: stat.color),
                            const SizedBox(height: 3),
                            Text(
                              stat.value,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: stat.color,
                              ),
                            ),
                            Text(
                              stat.label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.darkTextTertiary,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Key topics
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: collection.keyTopics.take(6).map((topic) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        topic,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 80).ms, duration: 400.ms).slideY(begin: 0.02, end: 0);
  }

  Widget _miniStat(BuildContext context, IconData icon, String value, String label) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.darkTextTertiary),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: _accentColor)),
              Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.darkTextTertiary, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Comparison Note
// ═══════════════════════════════════════════════════════════════════

class _ComparisonNote extends StatelessWidget {
  final bool isDark;

  const _ComparisonNote({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: AppColors.secondary.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text(
                  'Understanding the Numbers',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'The hadith counts above include repetitions (where the same hadith appears in different contexts/books within the collection). The actual number of unique hadith narrations is significantly lower. For example, Sahih al-Bukhari\'s 7,275 narrations contain approximately 2,602 unique hadiths.',
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.6,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
