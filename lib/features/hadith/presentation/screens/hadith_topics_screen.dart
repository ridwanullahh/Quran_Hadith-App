import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════
// Hadith Topic Reference
// ═══════════════════════════════════════════════════════════════════

class HadithTopicReference {
  final String collectionId;
  final int bookNumber;
  final int hadithNumber;
  final String title;
  final String narrator;
  final String? grade;

  const HadithTopicReference({
    required this.collectionId,
    required this.bookNumber,
    required this.hadithNumber,
    required this.title,
    required this.narrator,
    this.grade,
  });

  String get bookId => '${collectionId}_$bookNumber';
}

// ═══════════════════════════════════════════════════════════════════
// Hadith Topic
// ═══════════════════════════════════════════════════════════════════

class HadithTopic {
  final String id;
  final String name;
  final String nameArabic;
  final String description;
  final IconData icon;
  final Color color;
  final List<HadithTopicReference> references;

  const HadithTopic({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.description,
    required this.icon,
    required this.color,
    required this.references,
  });
}

// ═══════════════════════════════════════════════════════════════════
// Hardcoded Topic Data (10+ topics, 5+ references each)
// ═══════════════════════════════════════════════════════════════════

final List<HadithTopic> hadithTopics = [
  HadithTopic(
    id: 'faith',
    name: 'Faith (Iman)',
    nameArabic: 'الإيمان',
    description: 'Hadiths about the pillars of faith, belief in Allah, angels, books, prophets, and the Last Day.',
    icon: Icons.star_rounded,
    color: AppColors.primary,
    references: const [
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 1, hadithNumber: 1, title: 'Actions are judged by intentions', narrator: 'Umar ibn al-Khattab', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 2, hadithNumber: 50, title: 'The Pillars of Islam', narrator: 'Abdullah ibn Umar', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'muslim', bookNumber: 1, hadithNumber: 8, title: 'Islam is built on five pillars', narrator: 'Ibn Umar', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 2, hadithNumber: 33, title: 'Love for the Prophet', narrator: 'Anas ibn Malik', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'muslim', bookNumber: 1, hadithNumber: 1, title: 'The definition of Ihsan', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 3, hadithNumber: 97, title: 'Signs of a hypocrite', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'nasai', bookNumber: 1, hadithNumber: 10, title: 'The best of deeds', narrator: 'Abdullah ibn Masud', grade: 'Sahih'),
    ],
  ),
  HadithTopic(
    id: 'prayer',
    name: 'Prayer (Salah)',
    nameArabic: 'الصلاة',
    description: 'Hadiths about the obligatory prayers, their virtues, conditions, and the importance of congregation.',
    icon: Icons.mosque_rounded,
    color: const Color(0xFF7C3AED),
    references: const [
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 10, hadithNumber: 527, title: 'Prayer is the pillar of religion', narrator: 'Muadh ibn Jabal', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 11, hadithNumber: 620, title: 'The merit of praying in congregation', narrator: 'Abdullah ibn Umar', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'muslim', bookNumber: 4, hadithNumber: 475, title: 'The first thing judged on Day of Judgment', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'tirmidhi', bookNumber: 2, hadithNumber: 213, title: 'Prayer is the coolness of my eyes', narrator: 'Anas ibn Malik', grade: 'Hasan'),
      HadithTopicReference(collectionId: 'abudawud', bookNumber: 2, hadithNumber: 491, title: 'Praying on time', narrator: 'Abdullah ibn Masud', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 11, hadithNumber: 641, title: 'Walking to the mosque', narrator: 'Abu Hurairah', grade: 'Sahih'),
    ],
  ),
  HadithTopic(
    id: 'fasting',
    name: 'Fasting (Siyam)',
    nameArabic: 'الصيام',
    description: 'Hadiths about Ramadan, voluntary fasting, the virtues of fasting, and its spiritual benefits.',
    icon: Icons.nights_stay_rounded,
    color: const Color(0xFFEC4899),
    references: const [
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 30, hadithNumber: 1891, title: 'Whoever fasts Ramadan with faith', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 30, hadithNumber: 1904, title: 'Fasting is a shield', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'muslim', bookNumber: 13, hadithNumber: 2526, title: 'Every good deed is multiplied in Ramadan', narrator: 'Salman al-Farisi', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'tirmidhi', bookNumber: 6, hadithNumber: 682, title: 'Fasting on the Day of Arafah', narrator: 'Abu Qatadah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'abudawud', bookNumber: 7, hadithNumber: 2346, title: 'The fasting person has two joys', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'nasai', bookNumber: 22, hadithNumber: 2106, title: 'Do not fast on Fridays alone', narrator: 'Abu Hurairah', grade: 'Sahih'),
    ],
  ),
  HadithTopic(
    id: 'charity',
    name: 'Charity (Zakat & Sadaqah)',
    nameArabic: 'الزكاة والصدقة',
    description: 'Hadiths about obligatory charity, voluntary giving, the rewards of generosity, and helping the poor.',
    icon: Icons.volunteer_activism_rounded,
    color: AppColors.secondary,
    references: const [
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 24, hadithNumber: 1473, title: 'Seven are shaded on the Day of Judgment', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 24, hadithNumber: 1417, title: 'The believer\'s shade on Day of Judgment', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'muslim', bookNumber: 5, hadithNumber: 1009, title: 'Charity does not decrease wealth', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'tirmidhi', bookNumber: 4, hadithNumber: 614, title: 'The best charity is from surplus wealth', narrator: 'Aisha', grade: 'Hasan'),
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 24, hadithNumber: 1445, title: 'Save yourself from Hell even with half a date', narrator: 'Adi ibn Hatim', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'muslim', bookNumber: 5, hadithNumber: 2245, title: 'The upper hand is better than the lower hand', narrator: 'Abdullah ibn Umar', grade: 'Sahih'),
    ],
  ),
  HadithTopic(
    id: 'pilgrimage',
    name: 'Pilgrimage (Hajj)',
    nameArabic: 'الحج',
    description: 'Hadiths about the obligatory pilgrimage, Umrah, their virtues, and the rites of Hajj.',
    icon: Icons.place_rounded,
    color: const Color(0xFFF97316),
    references: const [
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 25, hadithNumber: 1515, title: 'Hajj is one of the pillars of Islam', narrator: 'Abdullah ibn Umar', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 25, hadithNumber: 1521, title: 'Whoever performs Hajj without obscenity', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'muslim', bookNumber: 11, hadithNumber: 1349, title: 'The reward of an accepted Hajj', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 26, hadithNumber: 1586, title: 'Umrah to Umrah expiates sins', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'tirmidhi', bookNumber: 8, hadithNumber: 810, title: 'The pilgrim is in a state of response', narrator: 'Abu Hurairah', grade: 'Sahih'),
    ],
  ),
  HadithTopic(
    id: 'character',
    name: 'Character & Ethics',
    nameArabic: 'الأخلاق',
    description: 'Hadiths about good character, truthfulness, patience, humility, and treating others well.',
    icon: Icons.favorite_rounded,
    color: AppColors.hifdhGreen,
    references: const [
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 73, hadithNumber: 6029, title: 'The best among you are those with best manners', narrator: 'Abdullah ibn Amr', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 56, hadithNumber: 3314, title: 'None of you truly believes until...', narrator: 'Anas ibn Malik', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'muslim', bookNumber: 45, hadithNumber: 2586, title: 'The complete believer has the best character', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'tirmidhi', bookNumber: 37, hadithNumber: 2624, title: 'Patience is half of faith', narrator: 'Abu Hurairah', grade: 'Hasan'),
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 73, hadithNumber: 6035, title: 'The strongest among you is not by strength', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'abudawud', bookNumber: 40, hadithNumber: 4785, title: 'Speak good or remain silent', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'muslim', bookNumber: 1, hadithNumber: 45, title: 'Do not be angry', narrator: 'Abu Hurairah', grade: 'Sahih'),
    ],
  ),
  HadithTopic(
    id: 'paradise-hell',
    name: 'Paradise & Hell',
    nameArabic: 'الجنة والنار',
    description: 'Hadiths describing Paradise and Hellfire, their rewards and punishments, and the path to each.',
    icon: Icons.local_fire_department_rounded,
    color: AppColors.error,
    references: const [
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 81, hadithNumber: 6571, title: 'The smallest reward in Paradise', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'muslim', bookNumber: 39, hadithNumber: 6785, title: 'A space in Paradise equal to a bow', narrator: 'Anas ibn Malik', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 76, hadithNumber: 6162, title: 'The Fire is surrounded by desires', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'muslim', bookNumber: 40, hadithNumber: 6838, title: 'Paradise and Hell argued', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'tirmidhi', bookNumber: 37, hadithNumber: 2562, title: 'The last to enter Paradise', narrator: 'Abu Sa\'id al-Khudri', grade: 'Hasan'),
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 81, hadithNumber: 6554, title: 'Allah has prepared for the righteous', narrator: 'Abu Hurairah', grade: 'Sahih'),
    ],
  ),
  HadithTopic(
    id: 'knowledge',
    name: 'Knowledge',
    nameArabic: 'العلم',
    description: 'Hadiths about seeking knowledge, the virtue of scholars, and the importance of teaching.',
    icon: Icons.school_rounded,
    color: AppColors.info,
    references: const [
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 3, hadithNumber: 71, title: 'Whoever treads a path seeking knowledge', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'tirmidhi', bookNumber: 39, hadithNumber: 2645, title: 'Seeking knowledge is an obligation', narrator: 'Anas ibn Malik', grade: 'Hasan'),
      HadithTopicReference(collectionId: 'abudawud', bookNumber: 24, hadithNumber: 3641, title: 'Angels lower their wings for the seeker of knowledge', narrator: 'Abu Hurairah', grade: 'Hasan'),
      HadithTopicReference(collectionId: 'muslim', bookNumber: 42, hadithNumber: 7175, title: 'The superiority of the learned over the worshipper', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 34, hadithNumber: 2132, title: 'A word of wisdom is the lost property', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'nasai', bookNumber: 45, hadithNumber: 5378, title: 'The scholar and the warrior', narrator: 'Abu Hurairah', grade: 'Sahih'),
    ],
  ),
  HadithTopic(
    id: 'food-drink',
    name: 'Food & Drink',
    nameArabic: 'الطعام والشراب',
    description: 'Hadiths about eating etiquette, halal food, the Prophet\'s diet, and supplications before/after eating.',
    icon: Icons.restaurant_rounded,
    color: const Color(0xFF10B981),
    references: const [
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 70, hadithNumber: 5376, title: 'Eat with your right hand', narrator: 'Umar ibn Abi Salamah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'muslim', bookNumber: 36, hadithNumber: 2022, title: 'What is lawful and what is unlawful', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 70, hadithNumber: 5381, title: 'Do not criticize food', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'tirmidhi', bookNumber: 43, hadithNumber: 1814, title: 'The blessing of food is in eating together', narrator: 'Wahshi ibn Harb', grade: 'Hasan'),
      HadithTopicReference(collectionId: 'abudawud', bookNumber: 27, hadithNumber: 3760, title: 'Mention the name of Allah before eating', narrator: 'Aisha', grade: 'Sahih'),
    ],
  ),
  HadithTopic(
    id: 'family',
    name: 'Family & Marriage',
    nameArabic: 'الأسرة والزواج',
    description: 'Hadiths about marriage, rights of spouses, children, parents, and family bonds in Islam.',
    icon: Icons.family_restroom_rounded,
    color: const Color(0xFF8B5CF6),
    references: const [
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 67, hadithNumber: 5063, title: 'Marriage is half of the religion', narrator: 'Anas ibn Malik', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'muslim', bookNumber: 8, hadithNumber: 1028, title: 'The best of you are those best to their families', narrator: 'Aisha', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 77, hadithNumber: 5971, title: 'Be kind to your children', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'tirmidhi', bookNumber: 9, hadithNumber: 1089, title: 'The best women are those who please you', narrator: 'Abu Hurairah', grade: 'Hasan'),
      HadithTopicReference(collectionId: 'abudawud', bookNumber: 11, hadithNumber: 2046, title: 'Paradise lies beneath the feet of mothers', narrator: 'Anas ibn Malik', grade: 'Hasan'),
      HadithTopicReference(collectionId: 'muslim', bookNumber: 33, hadithNumber: 6465, title: 'The right of a child', narrator: 'Abdullah ibn Amr', grade: 'Sahih'),
    ],
  ),
  HadithTopic(
    id: 'death-afterlife',
    name: 'Death & Afterlife',
    nameArabic: 'الموت والآخرة',
    description: 'Hadiths about death, the grave, the Day of Judgment, the Intercession, and the Hereafter.',
    icon: Icons.nightlight_rounded,
    color: const Color(0xFF6366F1),
    references: const [
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 23, hadithNumber: 1379, title: 'Remember often the destroyer of pleasures', narrator: 'Anas ibn Malik', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'muslim', bookNumber: 42, hadithNumber: 7050, title: 'The grave is the first stage of the Hereafter', narrator: 'Uthman ibn Affan', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 76, hadithNumber: 6161, title: 'The questioning in the grave', narrator: 'Anas ibn Malik', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'tirmidhi', bookNumber: 38, hadithNumber: 2423, title: 'The people will be gathered barefoot', narrator: 'Aisha', grade: 'Hasan'),
      HadithTopicReference(collectionId: 'muslim', bookNumber: 1, hadithNumber: 164, title: 'Intercession for the major sinners', narrator: 'Abu Hurairah', grade: 'Sahih'),
      HadithTopicReference(collectionId: 'bukhari', bookNumber: 81, hadithNumber: 6570, title: 'A person will be with those whom they love', narrator: 'Anas ibn Malik', grade: 'Sahih'),
    ],
  ),
];

// ═══════════════════════════════════════════════════════════════════
// Hadith Topics Screen
// ═══════════════════════════════════════════════════════════════════

class HadithTopicsScreen extends StatefulWidget {
  const HadithTopicsScreen({super.key});

  @override
  State<HadithTopicsScreen> createState() => _HadithTopicsScreenState();
}

class _HadithTopicsScreenState extends State<HadithTopicsScreen> {
  HadithTopic? _expandedTopic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadith Topics'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: hadithTopics.length,
        itemBuilder: (context, index) {
          final topic = hadithTopics[index];
          final isExpanded = _expandedTopic == topic;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
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
                  // Topic header
                  InkWell(
                    onTap: () {
                      setState(() {
                        _expandedTopic = isExpanded ? null : topic;
                      });
                    },
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: topic.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(topic.icon, size: 22, color: topic.color),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  topic.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  topic.nameArabic,
                                  style: AppTheme.arabicQuranText.copyWith(
                                    fontSize: 14,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${topic.references.length} hadiths',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (index * 40).ms, duration: 300.ms).slideY(begin: 0.02, end: 0),

                  // Expanded references
                  if (isExpanded) ...[
                    const Divider(height: 1, color: AppColors.darkBorder),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: Text(
                        topic.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ...topic.references.asMap().entries.map((entry) {
                      final ref = entry.value;
                      final gradeColor = ref.grade != null && ref.grade!.toLowerCase().contains('sahih')
                          ? AppColors.hifdhGreen
                          : ref.grade != null && ref.grade!.toLowerCase().contains('hasan')
                              ? AppColors.primary
                              : AppColors.darkTextTertiary;

                      return ListTile(
                        dense: true,
                        leading: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: topic.color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Center(
                            child: Text(
                              '#${entry.key + 1}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: topic.color,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          ref.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${ref.narrator} · ${ref.collectionId.toUpperCase()} #${ref.hadithNumber}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: gradeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            ref.grade ?? '',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: gradeColor),
                          ),
                        ),
                        onTap: () {
                          context.push('/hadith/book/${ref.bookId}');
                        },
                      );
                    }),
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
