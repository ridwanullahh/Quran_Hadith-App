import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════
// Hadith Grading Explanation Screen
// ═══════════════════════════════════════════════════════════════════

class GradingScreen extends StatelessWidget {
  const GradingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadith Grading'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Introduction card
          _IntroCard(isDark: isDark)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.05, end: 0),

          const SizedBox(height: 20),

          // Chain of Narration explanation
          _IsnadCard(isDark: isDark)
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms),

          const SizedBox(height: 20),

          // Sahih
          _GradeCard(
            title: 'Sahih (Authentic)',
            titleArabic: 'صحيح',
            color: AppColors.hifdhGreen,
            icon: Icons.verified_rounded,
            criteria: [
              'The chain of narration (isnad) is continuous — every narrator directly heard from the next.',
              'Every narrator is of excellent character (adalah) — truthful, honest, and morally upright.',
              'Every narrator has perfect memory (dabt) — retains and accurately recalls what they heard.',
              'The hadith is free from any hidden defects (illah) or contradictions with more authentic narrations.',
              'The text (matn) does not contradict the Quran, other authentic hadiths, or established Islamic principles.',
            ],
            example: 'Example: "Actions are judged by intentions" — Narrated by Umar ibn al-Khattab, recorded in Sahih al-Bukhari (Hadith 1) and Sahih Muslim. The chain is unbroken, all narrators are trustworthy, and there are no defects.',
            isDark: isDark,
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms),

          const SizedBox(height: 16),

          // Hasan
          _GradeCard(
            title: 'Hasan (Good)',
            titleArabic: 'حسن',
            color: AppColors.secondary,
            icon: Icons.check_circle_rounded,
            criteria: [
              'The chain of narration is continuous like Sahih, but...',
              'One or more narrators may have slightly weaker memory — they are trustworthy but not perfect.',
              'The narrator may be known for occasional lapses in memory but is still considered honest.',
              'The hadith is still free from hidden defects and contradictions.',
              'Hasan hadiths are acceptable as proof in Islamic law (Shariah).',
            ],
            example: 'Example: "Be in this world as though you were a stranger or a traveler" — Recorded by al-Bukhari in Al-Adab al-Mufrad. The chain is good but one narrator\'s precision is rated below the level required for Sahih.',
            isDark: isDark,
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 300.ms),

          const SizedBox(height: 16),

          // Da'if
          _GradeCard(
            title: "Da'if (Weak)",
            titleArabic: 'ضعيف',
            color: AppColors.warning,
            icon: Icons.warning_rounded,
            criteria: [
              'There is a break in the chain of narration — one or more narrators are missing.',
              'One or more narrators lacks the required level of trustworthiness (adalah).',
              'One or more narrators has poor memory or is known for making mistakes (dabt defect).',
              'The narrator may be unknown (majhul) — their character or memory hasn\'t been sufficiently verified.',
              'Weak hadiths CANNOT be used as proof in Islamic law but may be cited for encouragement (targhib).',
            ],
            example: 'Example: Many fabricated hadiths fall under this category. A narrator who is known to have lied, or a chain with a gap of one or more generations, renders the hadith Da\'if.',
            isDark: isDark,
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 400.ms),

          const SizedBox(height: 16),

          // Maudu'
          _GradeCard(
            title: "Maudu' (Fabricated)",
            titleArabic: 'موضوع',
            color: AppColors.error,
            icon: Icons.cancel_rounded,
            criteria: [
              'The hadith was completely fabricated and falsely attributed to the Prophet Muhammad ﷺ.',
              'It was invented by liars, heretics, or ignorant people for political, sectarian, or personal motives.',
              'The chain includes a known fabricator (wadha\') or liar (kadhdhab).',
              'Fabricated hadiths are FORBIDDEN to be attributed to the Prophet under any circumstances.',
              'The Prophet warned: "Whoever intentionally attributes a lie to me, let him take his seat in the Hellfire." (Bukhari 109)',
            ],
            example: 'Example: "Seek knowledge even in China" — This hadith is considered Maudu\' by most scholars. The chain includes Muhammad ibn Abi Lubabah al-Basri, who was accused of fabrication. It contradicts the authenticated hadiths about seeking knowledge.',
            isDark: isDark,
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 500.ms),

          const SizedBox(height: 20),

          // Grading hierarchy
          _HierarchyCard(isDark: isDark)
              .animate()
              .fadeIn(duration: 400.ms, delay: 600.ms),

          const SizedBox(height: 20),

          // Famous scholars
          _ScholarsCard(isDark: isDark)
              .animate()
              .fadeIn(duration: 400.ms, delay: 700.ms),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Helper Widgets
// ═══════════════════════════════════════════════════════════════════

class _IntroCard extends StatelessWidget {
  final bool isDark;
  const _IntroCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.12),
            AppColors.secondary.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school_rounded, size: 22, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Understanding Hadith Grading',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'علم مصطلح الحديث',
                      style: AppTheme.arabicQuranText.copyWith(
                        fontSize: 18,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Hadith grading (Mustalah al-Hadith) is the science of evaluating the authenticity of Prophetic traditions. Scholars examine both the chain of narration (isnad) and the text (matn) to classify each hadith. This system was developed to preserve the purity of the Prophet\'s teachings and protect the Muslim Ummah from fabricated narrations.',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.7,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _IsnadCard extends StatelessWidget {
  final bool isDark;
  const _IsnadCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link_rounded, size: 20, color: AppColors.revisionBlue),
              const SizedBox(width: 10),
              Text(
                'Chain of Narration (Isnad / السند)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.revisionBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Every hadith consists of two parts: the chain of narrators (isnad) and the text (matn). The isnad is the unique feature of Islamic hadith scholarship — no other religious tradition developed such a rigorous chain-of-transmission verification system.',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.7,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          // Chain visualization
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.revisionBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.revisionBlue.withOpacity(0.15),
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                _ChainNode(label: 'Prophet Muhammad ﷺ', isStart: true, isEnd: false),
                Container(width: 2, height: 20, color: AppColors.revisionBlue, indent: 20),
                _ChainNode(label: 'Companion (Sahabi)', isStart: false, isEnd: false),
                Container(width: 2, height: 20, color: AppColors.revisionBlue, indent: 20),
                _ChainNode(label: 'Successor (Tabi\'i)', isStart: false, isEnd: false),
                Container(width: 2, height: 20, color: AppColors.revisionBlue, indent: 20),
                _ChainNode(label: 'Scholar (Muhaddith)', isStart: false, isEnd: false),
                Container(width: 2, height: 20, color: AppColors.revisionBlue, indent: 20),
                _ChainNode(label: 'Compiler (Imam)', isStart: false, isEnd: true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Scholars evaluate each narrator in the chain for: ① Trustworthiness (Adalah) ② Memory accuracy (Dabt) ③ Direct contact with the previous narrator (Ittisal)',
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.6,
              fontStyle: FontStyle.italic,
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChainNode extends StatelessWidget {
  final String label;
  final bool isStart;
  final bool isEnd;

  const _ChainNode({required this.label, this.isStart = false, this.isEnd = false});

  @override
  Widget build(BuildContext context) {
    final color = isStart
        ? AppColors.primary
        : isEnd
            ? AppColors.secondary
            : AppColors.revisionBlue;
    return Row(
      children: [
        const SizedBox(width: 12),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isStart || isEnd ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _GradeCard extends StatelessWidget {
  final String title;
  final String titleArabic;
  final Color color;
  final IconData icon;
  final List<String> criteria;
  final String example;
  final bool isDark;

  const _GradeCard({
    required this.title,
    required this.titleArabic,
    required this.color,
    required this.icon,
    required this.criteria,
    required this.example,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    Text(
                      titleArabic,
                      style: AppTheme.arabicQuranText.copyWith(
                        fontSize: 18,
                        color: color.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Criteria
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Criteria',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...criteria.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.5,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // Example
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.format_quote_rounded, size: 16, color: color),
                    const SizedBox(width: 6),
                    Text(
                      'Example',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  example,
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.6,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _HierarchyCard extends StatelessWidget {
  final bool isDark;
  const _HierarchyCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grading Hierarchy',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          // Visual hierarchy
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.hifdhGreen.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                _HierarchyBar(
                  label: 'Sahih (Authentic)',
                  labelAr: 'صحيح',
                  color: AppColors.hifdhGreen,
                  usage: 'Acceptable as proof',
                ),
                const SizedBox(height: 8),
                _HierarchyBar(
                  label: 'Hasan (Good)',
                  labelAr: 'حسن',
                  color: AppColors.secondary,
                  usage: 'Acceptable as proof',
                ),
                const SizedBox(height: 8),
                _HierarchyBar(
                  label: "Da'if (Weak)",
                  labelAr: 'ضعيف',
                  color: AppColors.warning,
                  usage: 'Not acceptable as proof',
                ),
                const SizedBox(height: 8),
                _HierarchyBar(
                  label: "Maudu' (Fabricated)",
                  labelAr: 'موضوع',
                  color: AppColors.error,
                  usage: 'Forbidden to attribute',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HierarchyBar extends StatelessWidget {
  final String label;
  final String labelAr;
  final Color color;
  final String usage;

  const _HierarchyBar({
    required this.label,
    required this.labelAr,
    required this.color,
    required this.usage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      labelAr,
                      style: AppTheme.arabicQuranText.copyWith(
                        fontSize: 14,
                        color: color.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                Text(
                  usage,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScholarsCard extends StatelessWidget {
  final bool isDark;
  const _ScholarsCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Renowned Hadith Scholars',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12),
          ...[
            ('Imam al-Bukhari (d. 256 AH)', 'Compiler of the most authentic hadith collection. Examined 600,000 narrations and selected 7,563.'),
            ('Imam Muslim (d. 261 AH)', 'Student of al-Bukhari. Compiled the second most authentic collection with unique arrangement methodology.'),
            ('Imam at-Tirmidhi (d. 279 AH)', 'First scholar to systematically grade hadiths as Sahih, Hasan, or Da\'if.'),
            ('Ibn Hajar al-Asqalani (d. 852 AH)', 'Author of Fath al-Bari, the most comprehensive commentary on Sahih al-Bukhari.'),
            ('Imam an-Nawawi (d. 676 AH)', 'Author of the renowned "40 Hadith" collection and commentary on Sahih Muslim.'),
            ('Imam adh-Dhahabi (d. 748 AH)', 'Expert in narrator biographical evaluation (al-Jarh wat-Ta\'dil).'),
          ].map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary,
                    ),
                    margin: const EdgeInsets.only(top: 8),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.$1,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          entry.$2,
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.5,
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
