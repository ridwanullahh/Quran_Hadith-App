import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════
// Chain Narrator Data
// ═══════════════════════════════════════════════════════════════════

class ChainNarrator {
  final String name;
  final String nameArabic;
  final String title;
  final String era;
  final int hadithCount;
  final String reliability;
  final String? students;
  final String? teachers;
  final String? biography;
  final List<String> collections;

  const ChainNarrator({
    required this.name,
    required this.nameArabic,
    required this.title,
    required this.era,
    required this.hadithCount,
    required this.reliability,
    this.students,
    this.teachers,
    this.biography,
    required this.collections,
  });

  String get slug => name.toLowerCase().replaceAll(RegExp(r"[^a-z0-9]+"), '-');

  Color get reliabilityColor {
    final r = reliability.toLowerCase();
    if (r.contains('thiqah') || r.contains('trustworthy') || r.contains('hafiz'))
      return AppColors.hifdhGreen;
    if (r.contains('saduq') || r.contains('truthful'))
      return AppColors.primary;
    if (r.contains('maqbul') || r.contains('acceptable'))
      return AppColors.secondary;
    if (r.contains('daif') || r.contains('weak'))
      return AppColors.error;
    return AppColors.darkTextTertiary;
  }
}

// ═══════════════════════════════════════════════════════════════════
// Hardcoded Narrators
// ═══════════════════════════════════════════════════════════════════

const List<ChainNarrator> chainNarrators = [
  ChainNarrator(
    name: 'Abu Hurairah',
    nameArabic: 'أبو هريرة',
    title: 'Abd al-Rahman ibn Sakhr al-Dawsi',
    era: 'Companion (Sahabi)',
    hadithCount: 5374,
    reliability: 'Sahabi — Infallible',
    students: 'Over 800 students including Hasan al-Basri, Ibn Sirin, Sa\'id al-Musayyab',
    teachers: 'Prophet Muhammad (peace be upon him)',
    biography: 'The most prolific narrator of hadith among the Companions. He accompanied the Prophet for approximately 3 years. Known for his remarkable memory. The Prophet made dua for him to never forget what he heard.',
    collections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud', 'Nasa\'i', 'Ibn Majah'],
  ),
  ChainNarrator(
    name: 'Aisha bint Abu Bakr',
    nameArabic: 'عائشة بنت أبي بكر',
    title: 'Mother of the Believers',
    era: 'Companion (Sahabiyyah)',
    hadithCount: 2210,
    reliability: 'Sahabiyyah — Infallible',
    students: 'Urwa ibn al-Zubayr, Amra bint Abd al-Rahman, Al-Qasim ibn Muhammad',
    teachers: 'Prophet Muhammad (peace be upon him), her father Abu Bakr',
    biography: 'Wife of the Prophet and daughter of Abu Bakr al-Siddiq. She was known for her deep knowledge of Quran, hadith, fiqh, and medicine. Narrated many hadiths about the Prophet\'s private life and rulings.',
    collections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud', 'Nasa\'i', 'Ibn Majah'],
  ),
  ChainNarrator(
    name: 'Abdullah ibn Umar',
    nameArabic: 'عبد الله بن عمر',
    title: 'Ibn Umar',
    era: 'Companion (Sahabi)',
    hadithCount: 2630,
    reliability: 'Sahabi — Infallible',
    students: 'Nafi\' the Mawla, Salim ibn Abdullah, Sa\'id ibn al-Musayyab',
    teachers: 'Prophet Muhammad, his father Umar ibn al-Khattab',
    biography: 'Son of the second Caliph Umar. Known for his strict adherence to the Sunnah and his piety. One of the most knowledgeable Companions in matters of fiqh.',
    collections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud', 'Nasa\'i', 'Ibn Majah'],
  ),
  ChainNarrator(
    name: 'Anas ibn Malik',
    nameArabic: 'أنس بن مالك',
    title: 'Anas ibn Malik al-Ansari al-Khazraji',
    era: 'Companion (Sahabi)',
    hadithCount: 2286,
    reliability: 'Sahabi — Infallible',
    students: 'Thabit al-Bunani, Qatadah, Ayyub al-Sakhtiyani',
    teachers: 'Prophet Muhammad (served him for 10 years)',
    biography: 'Served the Prophet for approximately 10 years starting from age 10. He was blessed with a long life (over 100 years) and was one of the last Companions to die in Basra.',
    collections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud', 'Nasa\'i', 'Ibn Majah'],
  ),
  ChainNarrator(
    name: 'Malik ibn Anas',
    nameArabic: 'مالك بن أنس',
    title: 'Imam of Dar al-Hijrah',
    era: 'Tabi\' al-Tabi\'in (93–179 AH)',
    hadithCount: 848,
    reliability: 'Thiqah (Trustworthy) — Imam',
    students: 'Al-Shafi\'i, Ibn al-Qasim, Ashhab, Ibn Wahb',
    teachers: 'Nafi\' ibn Abd al-Rahman, Hisham ibn Urwa, Ibn Shihab al-Zuhri',
    biography: 'Founder of the Maliki school of Islamic jurisprudence. Compiled the Muwatta, one of the earliest hadith collections. Known for his immense knowledge of the practice of the people of Medina.',
    collections: ['Bukhari', 'Muslim', 'Muwatta'],
  ),
  ChainNarrator(
    name: 'Abdullah ibn Abbas',
    nameArabic: 'عبد الله بن عباس',
    title: 'The Interpreter of the Quran (Turjuman al-Quran)',
    era: 'Companion (Sahabi)',
    hadithCount: 1660,
    reliability: 'Sahabi — Infallible',
    students: 'Mujahid ibn Jabr, Ikrimah, Ata ibn Abi Rabah, Tawus',
    teachers: 'Prophet Muhammad, Umar ibn al-Khattab, Ali ibn Abi Talib',
    biography: 'Cousin of the Prophet. Known for his deep knowledge of Quranic interpretation (tafseer). The Prophet made dua for him: "O Allah, teach him the Book (Quran) and the wisdom."',
    collections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud', 'Nasa\'i'],
  ),
  ChainNarrator(
    name: 'Sufyan al-Thawri',
    nameArabic: 'سفيان الثوري',
    title: 'Amir al-Mu\'minin fil Hadith',
    era: 'Tabi\' al-Tabi\'in (97–161 AH)',
    hadithCount: 600,
    reliability: 'Thiqah Hafiz (Trustworthy, Memorizer)',
    students: 'Yahya ibn Sa\'id al-Qattan, Waki\' ibn al-Jarrah, Abd al-Rahman ibn Mahdi',
    teachers: 'Amir al-Sha\'bi, Mansur ibn al-Mu\'tamir, Al-Zuhri',
    biography: 'Known as "Commander of the Faithful in Hadith" due to his unparalleled mastery. He was also a renowned scholar of fiqh. Fled from authorities and lived in hiding for much of his life.',
    collections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud'],
  ),
  ChainNarrator(
    name: 'Shu\'bah ibn al-Hajjaj',
    nameArabic: 'شعبة بن الحجاج',
    title: 'Amir al-Mu\'minin fil Hadith (of Basra)',
    era: 'Tabi\' al-Tabi\'in (82–160 AH)',
    hadithCount: 1100,
    reliability: 'Thiqah Hafiz (Trustworthy, Memorizer)',
    students: 'Sufyan ibn Uyaynah, Waki\' ibn al-Jarrah, Abd al-Razzaq',
    teachers: 'Qatadah, Amr ibn Murrah, Hisham ibn Urwa',
    biography: 'One of the greatest hadith scholars of Basra. Known for his extremely rigorous verification of narrators. He said: "Every hadith I do not know is not a hadith."',
    collections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud', 'Nasa\'i'],
  ),
  ChainNarrator(
    name: 'Abdullah ibn al-Mubarak',
    nameArabic: 'عبد الله بن المبارك',
    title: 'Shaykh al-Islam',
    era: 'Tabi\' al-Tabi\'in (118–181 AH)',
    hadithCount: 750,
    reliability: 'Thiqah Thabt (Trustworthy, Firm)',
    students: 'Al-Bukhari, Muslim, Abu Dawud, al-Tirmidhi',
    teachers: 'Sufyan al-Thawri, Hammad ibn Salamah, Al-Awza\'i',
    biography: 'Known as "Shaykh al-Islam" for his comprehensive knowledge of hadith, fiqh, and jihad. He was a wealthy merchant who financed scholarly pursuits and military expeditions.',
    collections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud'],
  ),
  ChainNarrator(
    name: 'Yahya ibn Sa\'id al-Qattan',
    nameArabic: 'يحيى بن سعيد القطان',
    title: 'Shaykh of the Hadith Scholars',
    era: 'Tabi\' al-Tabi\'in (120–198 AH)',
    hadithCount: 800,
    reliability: 'Thiqah Hafiz (Trustworthy, Memorizer)',
    students: 'Imam al-Bukhari, Muslim, Abu Dawud',
    teachers: 'Shu\'bah, Sufyan al-Thawri, Hammad ibn Salamah',
    biography: 'A leading hadith master of Basra and Kufa. Imam al-Bukhari said of him: "I never saw anyone more knowledgeable about hadith than Yahya al-Qattan." He was also a judge.',
    collections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud'],
  ),
  ChainNarrator(
    name: 'Ibn Shihab al-Zuhri',
    nameArabic: 'محمد بن مسلم بن شهاب الزهري',
    title: 'The First to Systematically Record Hadith',
    era: 'Tabi\'i (50–124 AH)',
    hadithCount: 950,
    reliability: 'Thiqah (Trustworthy)',
    students: 'Malik ibn Anas, Al-Awza\'i, Sufyan ibn Uyaynah, Ibn Ishaq',
    teachers: 'Urwah ibn al-Zubayr, Sa\'id ibn al-Musayyab, Abu Salamah ibn Abd al-Rahman',
    biography: 'Credited with being the first to systematically compile hadith in writing at the request of Caliph Umar ibn Abd al-Aziz. His students became the leading hadith scholars of the next generation.',
    collections: ['Bukhari', 'Muslim', 'Muwatta', 'Abu Dawud'],
  ),
  ChainNarrator(
    name: 'Imam al-Bukhari',
    nameArabic: 'محمد بن إسماعيل البخاري',
    title: 'Compiler of Sahih al-Bukhari',
    era: 'Imam (194–256 AH)',
    hadithCount: 7275,
    reliability: 'Hafiz al-Dunya (Memorizer of the World)',
    students: 'Muslim, al-Tirmidhi, al-Nasa\'i, and hundreds more',
    teachers: 'Over 1000 shuyukh including Ahmad ibn Hanbal, Yahya al-Qattan',
    biography: 'Compiler of Sahih al-Bukhari, the most authentic book after the Quran. He memorized over 600,000 hadiths of which he selected only 7,275. Began studying hadith at age 10 and went blind as a child but was cured through his mother\'s prayers.',
    collections: ['Sahih al-Bukhari'],
  ),
];

// ═══════════════════════════════════════════════════════════════════
// Chain Narrators Screen
// ═══════════════════════════════════════════════════════════════════

class HadithChainNarratorsScreen extends StatefulWidget {
  const HadithChainNarratorsScreen({super.key});

  @override
  State<HadithChainNarratorsScreen> createState() => _HadithChainNarratorsScreenState();
}

class _HadithChainNarratorsScreenState extends State<HadithChainNarratorsScreen> {
  String _searchQuery = '';
  String _filterEra = 'All';

  List<String> get _eras {
    final eras = chainNarrators.map((n) {
      if (n.era.contains('Companion')) return 'Companions';
      if (n.era.contains('Tabi\'i') && !n.era.contains('Tabi\' al-')) return 'Successors';
      if (n.era.contains('Tabi\' al-')) return 'Successors of Successors';
      if (n.era.contains('Imam')) return 'Imams';
      return 'Other';
    }).toSet().toList()..sort();
    return ['All', ...eras];
  }

  List<ChainNarrator> get _filtered {
    return chainNarrators.where((n) {
      final matchesEra = _filterEra == 'All' || _getEraLabel(n) == _filterEra;
      final matchesSearch = _searchQuery.isEmpty ||
          n.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          n.nameArabic.contains(_searchQuery) ||
          n.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesEra && matchesSearch;
    }).toList()
      ..sort((a, b) => b.hadithCount.compareTo(a.hadithCount));
  }

  String _getEraLabel(ChainNarrator n) {
    if (n.era.contains('Companion')) return 'Companions';
    if (n.era.contains("Tabi'i") && !n.era.contains("Tabi' al-")) return 'Successors';
    if (n.era.contains("Tabi' al-")) return 'Successors of Successors';
    if (n.era.contains('Imam')) return 'Imams';
    return 'Other';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final narrators = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chain Narrators'),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search narrators...',
                hintStyle: TextStyle(color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                prefixIcon: Icon(Icons.search_rounded, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.close_rounded, size: 18), onPressed: () => setState(() => _searchQuery = ''))
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Era filter chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _eras.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final era = _eras[index];
                final isSelected = _filterEra == era;
                return FilterChip(
                  label: Text(
                    era,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    width: 0.5,
                  ),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  onSelected: (_) => setState(() => _filterEra = era),
                );
              },
            ),
          ),

          // Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${narrators.length} narrators',
                  style: theme.textTheme.labelSmall?.copyWith(color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: narrators.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        const SizedBox(height: 16),
                        Text('No narrators found', style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: narrators.length,
                    itemBuilder: (context, index) {
                      return _NarratorCard(
                        narrator: narrators[index],
                        index: index,
                        isDark: isDark,
                        onTap: () => _showNarratorDetail(context, narrators[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showNarratorDetail(BuildContext context, ChainNarrator narrator) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.78,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.darkBorder, borderRadius: BorderRadius.circular(2)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name
                      Text(narrator.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(narrator.nameArabic, style: AppTheme.arabicQuranText.copyWith(fontSize: 22, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary), textDirection: TextDirection.rtl),
                      const SizedBox(height: 4),
                      Text(narrator.title, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.secondary, fontStyle: FontStyle.italic)),

                      const SizedBox(height: 20),

                      // Stats row
                      Row(
                        children: [
                          _detailStat(context, Icons.auto_stories_rounded, '${narrator.hadithCount}', 'Hadiths', AppColors.primary),
                          const SizedBox(width: 12),
                          _detailStat(context, Icons.history_edu_rounded, narrator.era.split('(').first.trim(), 'Era', const Color(0xFF7C3AED)),
                        ],
                      ),

                      // Reliability
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: narrator.reliabilityColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: narrator.reliabilityColor.withOpacity(0.2), width: 0.5),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.verified_rounded, size: 18, color: narrator.reliabilityColor),
                            const SizedBox(width: 8),
                            Text(narrator.reliability, style: TextStyle(fontWeight: FontWeight.w700, color: narrator.reliabilityColor)),
                          ],
                        ),
                      ),

                      // Biography
                      if (narrator.biography != null) ...[
                        const SizedBox(height: 20),
                        Text('Biography', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                        const SizedBox(height: 8),
                        Text(narrator.biography!, style: theme.textTheme.bodyMedium?.copyWith(height: 1.7, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                      ],

                      // Teachers
                      if (narrator.teachers != null) ...[
                        const SizedBox(height: 16),
                        Text('Key Teachers', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                        const SizedBox(height: 6),
                        Text(narrator.teachers!, style: theme.textTheme.bodySmall?.copyWith(height: 1.5, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                      ],

                      // Students
                      if (narrator.students != null) ...[
                        const SizedBox(height: 16),
                        Text('Notable Students', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                        const SizedBox(height: 6),
                        Text(narrator.students!, style: theme.textTheme.bodySmall?.copyWith(height: 1.5, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                      ],

                      // Collections
                      const SizedBox(height: 16),
                      Text('Found In', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: narrator.collections.map((c) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.secondary.withOpacity(0.2), width: 0.5),
                            ),
                            child: Text(c, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailStat(BuildContext context, IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: color)),
                  Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.darkTextTertiary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Narrator Card
// ═══════════════════════════════════════════════════════════════════

class _NarratorCard extends StatelessWidget {
  final ChainNarrator narrator;
  final int index;
  final bool isDark;
  final VoidCallback onTap;

  const _NarratorCard({
    required this.narrator,
    required this.index,
    required this.isDark,
    required this.onTap,
  });

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
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: narrator.reliabilityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      narrator.nameArabic.substring(0, narrator.nameArabic.length.clamp(1, 2)),
                      style: AppTheme.arabicQuranText.copyWith(
                        fontSize: 20,
                        color: narrator.reliabilityColor,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(narrator.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        narrator.era.split('(').first.trim(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Hadith count
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${narrator.hadithCount}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'hadiths',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.darkTextTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 40).ms, duration: 300.ms).slideY(begin: 0.02, end: 0);
  }
}
