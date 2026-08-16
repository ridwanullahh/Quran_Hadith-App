import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════
// Random Hadith Data
// ═══════════════════════════════════════════════════════════════════

class RandomHadithEntry {
  final String arabic;
  final String english;
  final String narrator;
  final String source;
  final String reference;
  final String? grade;
  final String topic;

  const RandomHadithEntry({
    required this.arabic,
    required this.english,
    required this.narrator,
    required this.source,
    required this.reference,
    this.grade,
    required this.topic,
  });
}

const List<RandomHadithEntry> _randomHadithPool = [
  RandomHadithEntry(
    arabic: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
    english: 'Actions are judged by intentions, and every person will get the reward according to what they intended.',
    narrator: 'Umar ibn al-Khattab',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 1',
    grade: 'Sahih',
    topic: 'Intentions',
  ),
  RandomHadithEntry(
    arabic: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
    english: 'Whoever believes in Allah and the Last Day should speak good or remain silent.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6018',
    grade: 'Sahih',
    topic: 'Speech',
  ),
  RandomHadithEntry(
    arabic: 'لا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
    english: 'None of you truly believes until he loves for his brother what he loves for himself.',
    narrator: 'Anas ibn Malik',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 13',
    grade: 'Sahih',
    topic: 'Brotherhood',
  ),
  RandomHadithEntry(
    arabic: 'الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ',
    english: 'A Muslim is the one from whose tongue and hands other Muslims are safe.',
    narrator: 'Abdullah ibn Amr',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 10',
    grade: 'Sahih',
    topic: 'Character',
  ),
  RandomHadithEntry(
    arabic: 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
    english: 'The best among you are those who learn the Quran and teach it.',
    narrator: 'Uthman ibn Affan',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 5027',
    grade: 'Sahih',
    topic: 'Knowledge',
  ),
  RandomHadithEntry(
    arabic: 'لا تَحَاسَدُوا وَلا تَنَاجَشُوا وَلا تَبَاغَضُوا وَلا تَدَابَرُوا وَكُونُوا عِبَادَ اللَّهِ إِخْوَانًا',
    english: 'Do not envy one another, do not hate one another, do not turn your backs on one another. Be, O servants of Allah, brothers.',
    narrator: 'Abu Hurairah',
    source: 'Sahih Muslim',
    reference: 'Hadith 2563',
    grade: 'Sahih',
    topic: 'Brotherhood',
  ),
  RandomHadithEntry(
    arabic: 'الطُّهُورُ شَطْرُ الإِيمَانِ وَالْحَمْدُ لِلَّهِ تَمْلأُ الْمِيزَانَ',
    english: 'Purity is half of faith and Alhamdulillah fills the scales.',
    narrator: 'Abu Hurairah',
    source: 'Sahih Muslim',
    reference: 'Hadith 223',
    grade: 'Sahih',
    topic: 'Purity',
  ),
  RandomHadithEntry(
    arabic: 'مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ طَرِيقًا إِلَى الْجَنَّةِ',
    english: 'Whoever treads a path in search of knowledge, Allah will make easy for him a path to Paradise.',
    narrator: 'Abu Hurairah',
    source: 'Sahih Muslim',
    reference: 'Hadith 2699',
    grade: 'Sahih',
    topic: 'Knowledge',
  ),
  RandomHadithEntry(
    arabic: 'إِنَّ اللَّهَ لاَ يَنْظُرُ إِلَى صُوَرِكُمْ وَأَمْوَالِكُمْ وَلَكِنْ يَنْظُرُ إِلَى قُلُوبِكُمْ وَأَعْمَالِكُمْ',
    english: 'Allah does not look at your outward appearance or your wealth, but He looks at your hearts and your deeds.',
    narrator: 'Abu Hurairah',
    source: 'Sahih Muslim',
    reference: 'Hadith 2564',
    grade: 'Sahih',
    topic: 'Heart',
  ),
  RandomHadithEntry(
    arabic: 'الصَّدَقَةُ بُرْهَانٌ',
    english: 'Charity is a proof.',
    narrator: 'Abu Hurairah',
    source: 'Sunan Ibn Majah',
    reference: 'Hadith 1836',
    grade: 'Sahih',
    topic: 'Charity',
  ),
  RandomHadithEntry(
    arabic: 'الدُّعَاءُ هُوَ الْعِبَادَةُ',
    english: 'Supplication is the essence of worship.',
    narrator: 'An-Nu\'man ibn Bashir',
    source: 'Sunan al-Tirmidhi',
    reference: 'Hadith 3372',
    grade: 'Hasan',
    topic: 'Dua',
  ),
  RandomHadithEntry(
    arabic: 'الْمُؤْمِنُ الْقَوِيُّ خَيْرٌ وَأَحَبُّ إِلَى اللَّهِ مِنَ الْمُؤْمِنِ الضَّعِيفِ',
    english: 'The strong believer is better and more beloved to Allah than the weak believer, while there is good in both.',
    narrator: 'Abu Hurairah',
    source: 'Sahih Muslim',
    reference: 'Hadith 2664',
    grade: 'Sahih',
    topic: 'Strength',
  ),
  RandomHadithEntry(
    arabic: 'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ صَدَقَةٌ',
    english: 'Your smiling in the face of your brother is charity.',
    narrator: 'Abu Dharr',
    source: 'Sunan al-Tirmidhi',
    reference: 'Hadith 1956',
    grade: 'Hasan',
    topic: 'Character',
  ),
  RandomHadithEntry(
    arabic: 'لا يُلْدَغُ الْمُؤْمِنُ مِنْ جُحْرٍ وَاحِدٍ مَرَّتَيْنِ',
    english: 'A believer is not stung from the same hole twice.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6133',
    grade: 'Sahih',
    topic: 'Wisdom',
  ),
  RandomHadithEntry(
    arabic: 'كَلِمَتَانِ خَفِيفَتَانِ عَلَى اللِّسَانِ ثَقِيلَتَانِ فِي الْمِيزَانِ حَبِيبَتَانِ إِلَى الرَّحْمَنِ سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ',
    english: 'Two words which are light on the tongue, heavy on the scale, and beloved to the Most Merciful: SubhanAllahi wa biHamdihi, SubhanAllahil Adheem.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6405',
    grade: 'Sahih',
    topic: 'Dhikr',
  ),
  RandomHadithEntry(
    arabic: 'مَنْ صَلَّى عَلَيَّ صَلاَةً وَاحِدَةً صَلَّى اللَّهُ عَلَيْهِ عَشْرًا',
    english: 'Whoever sends salah upon me once, Allah will send salah upon him tenfold.',
    narrator: 'Anas ibn Malik',
    source: 'Sahih Muslim',
    reference: 'Hadith 408',
    grade: 'Sahih',
    topic: 'Dhikr',
  ),
  RandomHadithEntry(
    arabic: 'إِذَا مَاتَ الإِنْسَانُ انْقَطَعَ عَمَلُهُ إِلاَّ مِنْ ثَلاَثَةٍ صَدَقَةٍ جَارِيَةٍ أَوْ عِلْمٍ يُنْتَفَعُ بِهِ أَوْ وَلَدٍ صَالِحٍ يَدْعُو لَهُ',
    english: 'When a person dies, his deeds cease except for three: ongoing charity, beneficial knowledge, or a righteous child who prays for him.',
    narrator: 'Abu Hurairah',
    source: 'Sahih Muslim',
    reference: 'Hadith 1631',
    grade: 'Sahih',
    topic: 'Death',
  ),
  RandomHadithEntry(
    arabic: 'الْحَلاَلُ بَيِّنٌ وَالْحَرَامُ بَيِّنٌ وَبَيْنَهُمَا أُمُورٌ مُشْتَبِهَاتٌ',
    english: 'The lawful is clear and the unlawful is clear, and between them are doubtful matters which many people do not know.',
    narrator: 'An-Nu\'man ibn Bashir',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 52',
    grade: 'Sahih',
    topic: 'Halal & Haram',
  ),
  RandomHadithEntry(
    arabic: 'مَنْ قَامَ لَيْلَةَ الْقَدْرِ إِيمَانًا وَاحْتِسَابًا غُفِرَ لَهُ مَا تَقَدَّمَ مِنْ ذَنْبِهِ',
    english: 'Whoever stands in prayer on the Night of Decree out of faith and seeking reward, his previous sins will be forgiven.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 1901',
    grade: 'Sahih',
    topic: 'Ramadan',
  ),
  RandomHadithEntry(
    arabic: 'آيَةُ الْمُنَافِقِ ثَلاَثٌ إِذَا حَدَّثَ كَذَبَ وَإِذَا وَعَدَ أَخْلَفَ وَإِذَا اؤْتُمِنَ خَانَ',
    english: 'The signs of a hypocrite are three: when he speaks he lies, when he makes a promise he breaks it, and when he is trusted he betrays.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 33',
    grade: 'Sahih',
    topic: 'Character',
  ),
];

// ═══════════════════════════════════════════════════════════════════
// Random Hadith Screen
// ═══════════════════════════════════════════════════════════════════

class HadithRandomScreen extends StatefulWidget {
  const HadithRandomScreen({super.key});

  @override
  State<HadithRandomScreen> createState() => _HadithRandomScreenState();
}

class _HadithRandomScreenState extends State<HadithRandomScreen>
    with SingleTickerProviderStateMixin {
  final _random = Random.secure();
  RandomHadithEntry? _current;
  final List<RandomHadithEntry> _history = [];
  bool _isAnimating = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _generate();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _generate() {
    if (_isAnimating) return;
    setState(() => _isAnimating = true);

    RandomHadithEntry? next;
    do {
      next = _randomHadithPool[_random.nextInt(_randomHadithPool.length)];
    } while (next == _current && _randomHadithPool.length > 1);

    _pulseController.forward(from: 0).then((_) {
      setState(() {
        if (_current != null) _history.insert(0, _current!);
        if (_history.length > 20) _history.removeLast();
        _current = next;
        _isAnimating = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Hadith'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.history_rounded),
              onPressed: () => _showHistorySheet(context),
              tooltip: 'History',
            ),
        ],
      ),
      body: _current == null
          ? const Center(child: CircularProgressIndicator.adaptive())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  // Generate button
                  ListenableBuilder(
                    listenable: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 + (_isAnimating ? 0.05 * _pulseController.value : 0.0);
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: GestureDetector(
                      onTap: _generate,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.casino_rounded,
                              size: 40,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap to Explore',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white.withOpacity(0.85),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Hadith card
                  if (!_isAnimating)
                    _HadithDisplayCard(
                      hadith: _current!,
                      isDark: isDark,
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.04, end: 0),

                  const SizedBox(height: 24),

                  // Action buttons
                  if (!_isAnimating)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ActionButton(
                          icon: Icons.share_rounded,
                          label: 'Share',
                          color: AppColors.primary,
                          onTap: () => Share.share(
                            '${_current!.arabic}\n\n${_current!.english}\n\n— ${_current!.source}, ${_current!.reference}',
                            subject: 'Random Hadith',
                          ),
                        ),
                        const SizedBox(width: 16),
                        _ActionButton(
                          icon: Icons.refresh_rounded,
                          label: 'New Hadith',
                          color: AppColors.secondary,
                          onTap: _generate,
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                ],
              ),
            ),
    );
  }

  void _showHistorySheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.3,
          expand: false,
          builder: (ctx, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Recent (${_history.length})',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() => _history.clear());
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          'Clear',
                          style: TextStyle(color: AppColors.error, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                const Divider(height: 1, color: AppColors.darkBorder),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final h = _history[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              width: 0.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  h.english,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    height: 1.4,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${h.source} · ${h.reference}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Hadith Display Card
// ═══════════════════════════════════════════════════════════════════

class _HadithDisplayCard extends StatelessWidget {
  final RandomHadithEntry hadith;
  final bool isDark;

  const _HadithDisplayCard({required this.hadith, required this.isDark});

  Color get _gradeColor {
    if (hadith.grade == null) return AppColors.darkTextTertiary;
    final g = hadith.grade!.toLowerCase();
    if (g.contains('sahih')) return AppColors.hifdhGreen;
    if (g.contains('hasan')) return AppColors.primary;
    return AppColors.darkTextTertiary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Topic chip + grade
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hadith.topic,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (hadith.grade != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _gradeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hadith.grade!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _gradeColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Arabic text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                hadith.arabic,
                style: AppTheme.arabicQuranText.copyWith(
                  fontSize: 24,
                  height: 2.2,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 18),

            // English text
            Text(
              hadith.english,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.7,
                fontStyle: FontStyle.italic,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Narrator & source
            Divider(color: AppColors.darkBorder.withOpacity(0.5)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_rounded, size: 14, color: AppColors.secondary.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text(
                  'Narrated by ${hadith.narrator}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.menu_book_rounded, size: 14, color: AppColors.secondary.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text(
                  '${hadith.source} — ${hadith.reference}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Action Button
// ═══════════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2), width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widget for AnimatedBuilder (Flutter 3.x compatible)
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
