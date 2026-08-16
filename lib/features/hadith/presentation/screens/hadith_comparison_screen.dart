import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════
// Comparison Entry
// ═══════════════════════════════════════════════════════════════════

class HadithComparisonEntry {
  final String arabic;
  final String english;
  final String narrator;
  final String collection;
  final String reference;
  final String grade;
  final String? variationNote;

  const HadithComparisonEntry({
    required this.arabic,
    required this.english,
    required this.narrator,
    required this.collection,
    required this.reference,
    required this.grade,
    this.variationNote,
  });
}

class HadithComparisonGroup {
  final String topic;
  final String topicArabic;
  final String description;
  final List<HadithComparisonEntry> versions;

  const HadithComparisonGroup({
    required this.topic,
    required this.topicArabic,
    required this.description,
    required this.versions,
  });
}

// ═══════════════════════════════════════════════════════════════════
// Comparison Data
// ═══════════════════════════════════════════════════════════════════

const List<HadithComparisonGroup> _comparisonGroups = [
  HadithComparisonGroup(
    topic: 'Actions are Judged by Intentions',
    topicArabic: 'الأعمال بالنيات',
    description: 'This foundational hadith is recorded in multiple collections with slight variations in wording.',
    versions: [
      HadithComparisonEntry(
        arabic: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
        english: 'Actions are judged by intentions, and every person will get the reward according to what they intended.',
        narrator: 'Umar ibn al-Khattab',
        collection: 'Sahih al-Bukhari',
        reference: '1',
        grade: 'Sahih',
        variationNote: 'Most widely narrated version with full chain',
      ),
      HadithComparisonEntry(
        arabic: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى فَمَنْ كَانَتْ هِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ فَهِجْرَتُهُ إِلَى اللَّهِ وَرَسُولِهِ وَمَنْ كَانَتْ هِجْرَتُهُ لِدُنْيَا يُصِيبُهَا أَوِ امْرَأَةٍ يَنْكِحُهَا فَهِجْرَتُهُ إِلَى مَا هَاجَرَ إِلَيْهِ',
        english: 'Actions are judged by intentions, and every person will get the reward according to what they intended. So whoever emigrated for Allah and His Messenger, his emigration was for Allah and His Messenger. And whoever emigrated for worldly gain or to marry a woman, his emigration was for whatever he emigrated for.',
        narrator: 'Umar ibn al-Khattab',
        collection: 'Sahih Muslim',
        reference: '1907',
        grade: 'Sahih',
        variationNote: 'Includes the full example about migration',
      ),
      HadithComparisonEntry(
        arabic: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
        english: 'Actions are (judged) by intentions.',
        narrator: 'Umar ibn al-Khattab',
        collection: 'Sunan an-Nasa\'i',
        reference: '75',
        grade: 'Sahih',
        variationNote: 'Shorter wording, abridged narration',
      ),
    ],
  ),
  HadithComparisonGroup(
    topic: 'Speak Good or Remain Silent',
    topicArabic: 'قل خيراً أو أصمت',
    description: 'This hadith appears in both Bukhari and Muslim with nearly identical chains and wording.',
    versions: [
      HadithComparisonEntry(
        arabic: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
        english: 'Whoever believes in Allah and the Last Day should speak good or remain silent.',
        narrator: 'Abu Hurairah',
        collection: 'Sahih al-Bukhari',
        reference: '6018',
        grade: 'Sahih',
      ),
      HadithComparisonEntry(
        arabic: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ وَمَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيُكْرِمْ جَارَهُ',
        english: 'Whoever believes in Allah and the Last Day should speak good or remain silent. And whoever believes in Allah and the Last Day should honor his neighbor.',
        narrator: 'Abu Hurairah',
        collection: 'Sahih Muslim',
        reference: '47',
        grade: 'Sahih',
        variationNote: 'Includes the additional injunction about honoring neighbors',
      ),
      HadithComparisonEntry(
        arabic: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
        english: 'Whoever believes in Allah and the Last Day should speak good or remain silent.',
        narrator: 'Abu Hurairah',
        collection: 'Sunan al-Tirmidhi',
        reference: '2501',
        grade: 'Sahih',
        variationNote: 'Identical wording, different chain through Tirmidhi',
      ),
    ],
  ),
  HadithComparisonGroup(
    topic: 'The Strong Believer is Better',
    topicArabic: 'المؤمن القوي خير وأحب',
    description: 'Both Bukhari and Muslim record this hadith. Some scholars graded it differently based on the chain.',
    versions: [
      HadithComparisonEntry(
        arabic: 'الْمُؤْمِنُ الْقَوِيُّ خَيْرٌ وَأَحَبُّ إِلَى اللَّهِ مِنَ الْمُؤْمِنِ الضَّعِيفِ وَفِي كُلٍّ خَيْرٌ',
        english: 'The strong believer is better and more beloved to Allah than the weak believer, while there is good in both.',
        narrator: 'Abu Hurairah',
        collection: 'Sahih Muslim',
        reference: '2664',
        grade: 'Sahih',
      ),
      HadithComparisonEntry(
        arabic: 'الْمُؤْمِنُ الْقَوِيُّ خَيْرٌ وَأَحَبُّ إِلَى اللَّهِ مِنَ الْمُؤْمِنِ الضَّعِيفِ',
        english: 'The strong believer is better and more beloved to Allah than the weak believer.',
        narrator: 'Abu Hurairah',
        collection: 'Sunan Ibn Majah',
        reference: '79',
        grade: 'Hasan',
        variationNote: 'Omits "and in both is good" — shorter chain',
      ),
    ],
  ),
  HadithComparisonGroup(
    topic: 'None of You Truly Believes Until...',
    topicArabic: 'لا يؤمن أحدكم حتى...',
    description: 'A key hadith about brotherhood, narrated through Anas ibn Malik in multiple collections.',
    versions: [
      HadithComparisonEntry(
        arabic: 'لا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
        english: 'None of you truly believes until he loves for his brother what he loves for himself.',
        narrator: 'Anas ibn Malik',
        collection: 'Sahih al-Bukhari',
        reference: '13',
        grade: 'Sahih',
      ),
      HadithComparisonEntry(
        arabic: 'لا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
        english: 'None of you truly believes until he loves for his brother what he loves for himself.',
        narrator: 'Anas ibn Malik',
        collection: 'Sahih Muslim',
        reference: '45',
        grade: 'Sahih',
        variationNote: 'Same wording, different chain of narrators',
      ),
      HadithComparisonEntry(
        arabic: 'لا يُؤْمِنُ أَحَدُكُمْ حَتَّى أَكُونَ أَحَبَّ إِلَيْهِ مِنْ وَالِدِهِ وَوَلَدِهِ وَالنَّاسِ أَجْمَعِينَ',
        english: 'None of you truly believes until I am more beloved to him than his father, his child, and all of mankind.',
        narrator: 'Anas ibn Malik',
        collection: 'Sahih al-Bukhari',
        reference: '15',
        grade: 'Sahih',
        variationNote: 'Related hadith with additional condition about the Prophet',
      ),
    ],
  ),
  HadithComparisonGroup(
    topic: 'Charity Does Not Decrease Wealth',
    topicArabic: 'ما نقصت صدقة من مال',
    description: 'Both Bukhari and Muslim include this hadith with minor variations in the full text.',
    versions: [
      HadithComparisonEntry(
        arabic: 'مَا نَقَصَتْ صَدَقَةٌ مِنْ مَالٍ',
        english: 'Charity does not decrease wealth.',
        narrator: 'Abu Hurairah',
        collection: 'Sahih Muslim',
        reference: '2588',
        grade: 'Sahih',
        variationNote: 'Part of a longer hadith about seven things that continue after death',
      ),
      HadithComparisonEntry(
        arabic: 'مَا نَقَصَتْ صَدَقَةٌ مِنْ مَالٍ وَمَا زَادَ اللَّهُ عَبْدًا بِعَفْوٍ إِلا عِزًّا',
        english: 'Charity does not decrease wealth. Allah does not increase a servant who forgives except in honor.',
        narrator: 'Abu Hurairah',
        collection: 'Sahih Muslim',
        reference: '2588',
        grade: 'Sahih',
        variationNote: 'Fuller version with the additional statement about forgiveness',
      ),
    ],
  ),
];

// ═══════════════════════════════════════════════════════════════════
// Hadith Comparison Screen
// ═══════════════════════════════════════════════════════════════════

class HadithComparisonScreen extends StatefulWidget {
  const HadithComparisonScreen({super.key});

  @override
  State<HadithComparisonScreen> createState() => _HadithComparisonScreenState();
}

class _HadithComparisonScreenState extends State<HadithComparisonScreen> {
  int _expandedGroup = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadith Comparison'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _comparisonGroups.length,
        itemBuilder: (context, index) {
          final group = _comparisonGroups[index];
          final isExpanded = _expandedGroup == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
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
              child: Column(
                children: [
                  // Group header
                  InkWell(
                    onTap: () => setState(() => _expandedGroup = isExpanded ? -1 : index),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.compare_arrows_rounded, size: 20, color: AppColors.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  group.topic,
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  group.topicArabic,
                                  style: AppTheme.arabicQuranText.copyWith(
                                    fontSize: 14,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${group.versions.length} versions across collections',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (index * 60).ms, duration: 300.ms).slideY(begin: 0.02, end: 0),

                  // Expanded versions
                  if (isExpanded) ...[
                    const Divider(height: 1, color: AppColors.darkBorder),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        group.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Column(
                        children: group.versions.asMap().entries.map((entry) {
                          final vIndex = entry.key;
                          final version = entry.value;
                          return _VersionCard(
                            version: version,
                            versionIndex: vIndex,
                            isDark: isDark,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Version Card
// ═══════════════════════════════════════════════════════════════════

class _VersionCard extends StatelessWidget {
  final HadithComparisonEntry version;
  final int versionIndex;
  final bool isDark;

  const _VersionCard({
    required this.version,
    required this.versionIndex,
    required this.isDark,
  });

  Color get _gradeColor {
    final g = version.grade.toLowerCase();
    if (g.contains('sahih')) return AppColors.hifdhGreen;
    if (g.contains('hasan')) return AppColors.primary;
    return AppColors.darkTextTertiary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder.withOpacity(0.5) : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _gradeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    version.grade,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _gradeColor),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${version.collection} #${version.reference}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Arabic text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                version.arabic,
                style: AppTheme.arabicQuranText.copyWith(
                  fontSize: 17,
                  height: 2.0,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 10),

            // English text
            Text(
              version.english,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),

            // Variation note
            if (version.variationNote != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.15), width: 0.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 14, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        version.variationNote!,
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

            const SizedBox(height: 6),
            Text(
              'Narrated by ${version.narrator}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
