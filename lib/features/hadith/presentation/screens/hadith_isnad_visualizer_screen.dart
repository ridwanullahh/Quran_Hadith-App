import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════
// Isnad (Chain of Narration) Node
// ═══════════════════════════════════════════════════════════════════

class IsnadNode {
  final String name;
  final String nameArabic;
  final String title;
  final String? deathYear;
  final String? reliability;
  final bool isCompanion;

  const IsnadNode({
    required this.name,
    required this.nameArabic,
    required this.title,
    this.deathYear,
    this.reliability,
    this.isCompanion = false,
  });
}

// ═══════════════════════════════════════════════════════════════════
// Sample Isnad Chains
// ═══════════════════════════════════════════════════════════════════

class SampleIsnad {
  final String title;
  final String hadithPreview;
  final String source;
  final List<IsnadNode> chain;

  const SampleIsnad({
    required this.title,
    required this.hadithPreview,
    required this.source,
    required this.chain,
  });
}

const List<SampleIsnad> _sampleIsnads = [
  SampleIsnad(
    title: 'Actions are Judged by Intentions',
    hadithPreview: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
    source: 'Sahih al-Bukhari 1',
    chain: [
      IsnadNode(
        name: 'Al-Bukhari',
        nameArabic: 'البخاري',
        title: 'Imam, Compiler of Sahih al-Bukhari',
        deathYear: '256 AH',
        reliability: 'Thiqah (Trustworthy)',
      ),
      IsnadNode(
        name: 'Yahya ibn Sa\'id al-Qattan',
        nameArabic: 'يحيى بن سعيد القطان',
        title: 'Leading Hafiz of Hadith',
        deathYear: '198 AH',
        reliability: 'Thiqah (Trustworthy)',
      ),
      IsnadNode(
        name: 'Muhammad ibn Ibrahim al-Taymi',
        nameArabic: 'محمد بن إبراهيم التيمي',
        title: 'Scholar of Kufa',
        deathYear: '120 AH',
        reliability: 'Thiqah (Trustworthy)',
      ),
      IsnadNode(
        name: '\'Alqamah ibn Waqqas al-Laythi',
        nameArabic: 'علقمة بن وقاص الليثي',
        title: 'Tabi\'i',
        deathYear: '~82 AH',
        reliability: 'Saduq (Truthful)',
      ),
      IsnadNode(
        name: 'Umar ibn al-Khattab',
        nameArabic: 'عمر بن الخطاب',
        title: 'Second Caliph of Islam',
        deathYear: '23 AH',
        reliability: 'Sahabi (Companion)',
        isCompanion: true,
      ),
      IsnadNode(
        name: 'Prophet Muhammad ﷺ',
        nameArabic: 'رسول الله ﷺ',
        title: 'The Final Messenger',
        deathYear: '11 AH',
        reliability: 'Infallible',
        isCompanion: true,
      ),
    ],
  ),
  SampleIsnad(
    title: 'Speak Good or Remain Silent',
    hadithPreview: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
    source: 'Sahih al-Bukhari 6018',
    chain: [
      IsnadNode(
        name: 'Al-Bukhari',
        nameArabic: 'البخاري',
        title: 'Imam, Compiler of Sahih al-Bukhari',
        deathYear: '256 AH',
        reliability: 'Thiqah (Trustworthy)',
      ),
      IsnadNode(
        name: 'Abdullah ibn Maslamah al-Qa\'nabi',
        nameArabic: 'عبد الله بن مسلمة القعنبي',
        title: 'Scholar of Medina',
        deathYear: '221 AH',
        reliability: 'Thiqah (Trustworthy)',
      ),
      IsnadNode(
        name: 'Malik ibn Anas',
        nameArabic: 'مالك بن أنس',
        title: 'Imam of Dar al-Hijrah',
        deathYear: '179 AH',
        reliability: 'Thiqah (Trustworthy)',
      ),
      IsnadNode(
        name: 'Abu Hazim Salamah ibn Dinar',
        nameArabic: 'أبو حازم سلمة بن دينار',
        title: 'Tabi\'i of Medina',
        deathYear: '~140 AH',
        reliability: 'Thiqah (Trustworthy)',
      ),
      IsnadNode(
        name: 'Abu Hurairah',
        nameArabic: 'أبو هريرة',
        title: 'Prophet\'s Companion, Most prolific narrator',
        deathYear: '57 AH',
        reliability: 'Sahabi (Companion)',
        isCompanion: true,
      ),
      IsnadNode(
        name: 'Prophet Muhammad ﷺ',
        nameArabic: 'رسول الله ﷺ',
        title: 'The Final Messenger',
        deathYear: '11 AH',
        reliability: 'Infallible',
        isCompanion: true,
      ),
    ],
  ),
  SampleIsnad(
    title: 'None of You Truly Believes Until...',
    hadithPreview: 'لا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
    source: 'Sahih al-Bukhari 13',
    chain: [
      IsnadNode(
        name: 'Al-Bukhari',
        nameArabic: 'البخاري',
        title: 'Imam, Compiler of Sahih al-Bukhari',
        deathYear: '256 AH',
        reliability: 'Thiqah (Trustworthy)',
      ),
      IsnadNode(
        name: 'Isma\'il ibn Abdullah ibn Abi Uways',
        nameArabic: 'إسماعيل بن عبد الله بن أبي أويس',
        title: 'Scholar of Medina',
        deathYear: '220 AH',
        reliability: 'Saduq (Truthful)',
      ),
      IsnadNode(
        name: 'Abdullah ibn Abi Uways',
        nameArabic: 'عبد الله بن أبي أويس',
        title: 'Scholar of Medina',
        deathYear: '~182 AH',
        reliability: 'Maqbul (Acceptable)',
      ),
      IsnadNode(
        name: 'Malik ibn Anas',
        nameArabic: 'مالك بن أنس',
        title: 'Imam of Dar al-Hijrah',
        deathYear: '179 AH',
        reliability: 'Thiqah (Trustworthy)',
      ),
      IsnadNode(
        name: 'Anas ibn Malik',
        nameArabic: 'أنس بن مالك',
        title: 'Prophet\'s servant for 10 years',
        deathYear: '93 AH',
        reliability: 'Sahabi (Companion)',
        isCompanion: true,
      ),
      IsnadNode(
        name: 'Prophet Muhammad ﷺ',
        nameArabic: 'رسول الله ﷺ',
        title: 'The Final Messenger',
        deathYear: '11 AH',
        reliability: 'Infallible',
        isCompanion: true,
      ),
    ],
  ),
  SampleIsnad(
    title: 'The Strong Believer is Better',
    hadithPreview: 'الْمُؤْمِنُ الْقَوِيُّ خَيْرٌ وَأَحَبُّ إِلَى اللَّهِ مِنَ الْمُؤْمِنِ الضَّعِيفِ',
    source: 'Sahih Muslim 2664',
    chain: [
      IsnadNode(
        name: 'Muslim ibn al-Hajjaj',
        nameArabic: 'مسلم بن الحجاج',
        title: 'Compiler of Sahih Muslim',
        deathYear: '261 AH',
        reliability: 'Thiqah (Trustworthy)',
      ),
      IsnadNode(
        name: 'Zuhayr ibn Harb',
        nameArabic: 'زهير بن حرب',
        title: 'Leading Muhaddith',
        deathYear: '234 AH',
        reliability: 'Thiqah (Trustworthy)',
      ),
      IsnadNode(
        name: 'Jarir ibn Abdullah',
        nameArabic: 'جريح بن عبد الحميد',
        title: 'Hafiz of Kufa',
        deathYear: '188 AH',
        reliability: 'Thiqah (Trustworthy)',
      ),
      IsnadNode(
        name: 'Mansur ibn al-Mu\'tamir',
        nameArabic: 'منصور بن المعتمر',
        title: 'Tabi\'i',
        deathYear: '132 AH',
        reliability: 'Thiqah (Trustworthy)',
      ),
      IsnadNode(
        name: 'Abu Hurairah',
        nameArabic: 'أبو هريرة',
        title: 'Prophet\'s Companion',
        deathYear: '57 AH',
        reliability: 'Sahabi (Companion)',
        isCompanion: true,
      ),
      IsnadNode(
        name: 'Prophet Muhammad ﷺ',
        nameArabic: 'رسول الله ﷺ',
        title: 'The Final Messenger',
        deathYear: '11 AH',
        reliability: 'Infallible',
        isCompanion: true,
      ),
    ],
  ),
];

// ═══════════════════════════════════════════════════════════════════
// Isnad Visualizer Screen
// ═══════════════════════════════════════════════════════════════════

class HadithIsnadVisualizerScreen extends StatefulWidget {
  const HadithIsnadVisualizerScreen({super.key});

  @override
  State<HadithIsnadVisualizerScreen> createState() => _HadithIsnadVisualizerScreenState();
}

class _HadithIsnadVisualizerScreenState extends State<HadithIsnadVisualizerScreen> {
  int _selectedIsnad = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isnad = _sampleIsnads[_selectedIsnad];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Isnad Visualizer'),
      ),
      body: Column(
        children: [
          // Isnad selector tabs
          Container(
            height: 48,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(4),
              itemCount: _sampleIsnads.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final isSelected = _selectedIsnad == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIsnad = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '#${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hadith title & preview
                  Text(
                    isnad.title,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isnad.source,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Arabic preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      isnad.hadithPreview,
                      style: AppTheme.arabicQuranText.copyWith(
                        fontSize: 20,
                        height: 2.0,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Chain label
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'CHAIN OF NARRATION (ISNAD)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Chain visualization
                  ...isnad.chain.asMap().entries.map((entry) {
                    final index = entry.key;
                    final node = entry.value;
                    final isLast = index == isnad.chain.length - 1;
                    final isCompanion = node.isCompanion;

                    return _ChainNode(
                      node: node,
                      index: index,
                      isLast: isLast,
                      isCompanion: isCompanion,
                      isDark: isDark,
                    ).animate().fadeIn(delay: (index * 120).ms, duration: 400.ms).slideY(begin: 0.03, end: 0);
                  }),

                  // Legend
                  const SizedBox(height: 24),
                  _LegendCard(isDark: isDark),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Chain Node Widget
// ═══════════════════════════════════════════════════════════════════

class _ChainNode extends StatelessWidget {
  final IsnadNode node;
  final int index;
  final bool isLast;
  final bool isCompanion;
  final bool isDark;

  const _ChainNode({
    required this.node,
    required this.index,
    required this.isLast,
    required this.isCompanion,
    required this.isDark,
  });

  Color get _nodeColor {
    if (index == 0) return AppColors.primary;
    if (node.isCompanion && index == _getChainLength - 1) return AppColors.secondary;
    if (isCompanion) return const Color(0xFF7C3AED);
    return isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
  }

  int get _getChainLength => 6;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 52,
            child: Column(
              children: [
                // Step circle
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _nodeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _nodeColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      index == 0
                          ? '📋'
                          : isCompanion && index == _getChainLength - 1
                              ? ' Muhammad'
                              : isCompanion
                                  ? 'in'
                                  : '${index}',
                      style: TextStyle(
                        fontSize: index == 0 || (isCompanion && index == _getChainLength - 1) ? 14 : 13,
                        fontWeight: FontWeight.w700,
                        color: index == 0 || isCompanion ? Colors.white : AppColors.darkTextPrimary,
                      ),
                    ),
                  ),
                ),
                // Connector line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: isCompanion
                            ? const Color(0xFF7C3AED).withOpacity(0.3)
                            : AppColors.darkBorder,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Content card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: isCompanion
                        ? const Color(0xFF7C3AED).withOpacity(0.3)
                        : isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                    width: 0.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              node.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isCompanion ? const Color(0xFF7C3AED) : null,
                              ),
                            ),
                          ),
                          if (isCompanion)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C3AED).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Sahabi',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF7C3AED),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Arabic name
                      Text(
                        node.nameArabic,
                        style: AppTheme.arabicQuranText.copyWith(
                          fontSize: 16,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 6),

                      // Title
                      Text(
                        node.title,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          height: 1.4,
                        ),
                      ),

                      // Metadata row
                      if (node.deathYear != null || node.reliability != null) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            if (node.deathYear != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.darkTextTertiary),
                                  const SizedBox(width: 3),
                                  Text(
                                    node.deathYear!,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.darkTextTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            if (node.reliability != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded, size: 11, color: AppColors.hifdhGreen),
                                  const SizedBox(width: 3),
                                  Text(
                                    node.reliability!,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppColors.hifdhGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Legend Card
// ═══════════════════════════════════════════════════════════════════

class _LegendCard extends StatelessWidget {
  final bool isDark;

  const _LegendCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Legend',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _legendItem(context, AppColors.primary, 'Compiler (Muhaddith)'),
            _legendItem(context, const Color(0xFF7C3AED), 'Companion (Sahabi)'),
            _legendItem(context, AppColors.secondary, 'Prophet Muhammad \u{0649}'),
            _legendItem(context, AppColors.hifdhGreen, 'Reliability grading'),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(BuildContext context, Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
