import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Models ──────────────────────────────────────────────────────────

class TopicVerse {
  final int surahNumber;
  final int ayahNumber;
  final String arabicText;
  final String description;

  const TopicVerse({
    required this.surahNumber,
    required this.ayahNumber,
    required this.arabicText,
    required this.description,
  });

  String get reference => '$surahNumber:$ayahNumber';
}

class QuranTopic {
  final String id;
  final String arabicName;
  final String englishName;
  final String description;
  final IconData icon;
  final Color color;
  final List<TopicVerse> verses;

  const QuranTopic({
    required this.id,
    required this.arabicName,
    required this.englishName,
    required this.description,
    required this.icon,
    required this.color,
    required this.verses,
  });
}

// ════════════════════════════════════════════════════════════════════
// Hardcoded topic data – 18 categories with 5–10 verses each
// ════════════════════════════════════════════════════════════════════

final List<QuranTopic> kQuranTopics = [
  // 1 ── Tawhid (Monotheism) ──────────────────────────────────────────
  QuranTopic(
    id: 'tawhid',
    arabicName: 'التوحيد',
    englishName: 'Tawhid (Monotheism)',
    description: 'The oneness of Allah and the foundation of Islamic belief',
    icon: Icons.stars_rounded,
    color: const Color(0xFF0D6E5B),
    verses: const [
      TopicVerse(surahNumber: 112, ayahNumber: 1, arabicText: 'قُلْ هُوَ ٱللَّهُ أَحَدٌ', description: 'Allah is One \u2013 the essence of monotheism'),
      TopicVerse(surahNumber: 2, ayahNumber: 255, arabicText: 'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلْحَىُّ ٱلْقَيُّومُ', description: 'Ayat al-Kursi \u2013 Allah alone is worthy of worship'),
      TopicVerse(surahNumber: 3, ayahNumber: 18, arabicText: 'شَهِدَ ٱللَّهُ أَنَّهُۥ لَآ إِلَٰهَ إِلَّا هُوَ', description: 'Allah bears witness that there is no deity but Him'),
      TopicVerse(surahNumber: 4, ayahNumber: 171, arabicText: 'يَٰٓأَهْلَ ٱلْكِتَٰبِ لَا تَغْلُوا۟ فِى دِينِكُمْ', description: 'Do not exceed limits regarding Allah \u2013 say He is One'),
      TopicVerse(surahNumber: 6, ayahNumber: 103, arabicText: 'لَا تُدْرِكُهُ ٱلْأَبْصَٰرُ وَهُوَ يُدْرِكُ ٱلْأَبْصَٰرَ', description: 'Vision cannot grasp Him, but He grasps all vision'),
      TopicVerse(surahNumber: 112, ayahNumber: 4, arabicText: 'وَلَمْ يَكُن لَّهُۥ كُفُوًا أَحَدٌ', description: 'There is nothing comparable to Him'),
      TopicVerse(surahNumber: 20, ayahNumber: 14, arabicText: 'إِنَّنِىٓ أَنَا ٱللَّهُ لَآ إِلَٰهَ إِلَّآ أَنَا۟', description: 'Indeed I am Allah, there is no deity except Me'),
    ],
  ),

  // 2 ── Salah (Prayer) ─────────────────────────────────────────────
  QuranTopic(
    id: 'salah',
    arabicName: 'الصلاة',
    englishName: 'Salah (Prayer)',
    description: 'The five daily prayers and their importance',
    icon: Icons.mosque_rounded,
    color: const Color(0xFF7C3AED),
    verses: const [
      TopicVerse(surahNumber: 2, ayahNumber: 43, arabicText: 'وَأَقِيمُوا۟ ٱلصَّلَوٰةَ وَءَاتُوا۟ ٱلزَّكَوٰةَ', description: 'Establish prayer and pay zakah'),
      TopicVerse(surahNumber: 29, ayahNumber: 45, arabicText: 'إِنَّ ٱلصَّلَوٰةَ تَنْهَىٰ عَنِ ٱلْفَحْشَآءِ وَٱلْمُنكَرِ', description: 'Prayer restrains from shameful and evil deeds'),
      TopicVerse(surahNumber: 11, ayahNumber: 114, arabicText: 'وَأَقِمِ ٱلصَّلَوٰةَ طَرَفَىِ ٱلنَّهَارِ وَزُلَفًا مِّنَ ٱللَّيْلِ', description: 'Establish prayer at the two ends of the day and at night'),
      TopicVerse(surahNumber: 2, ayahNumber: 238, arabicText: 'حَـٰفِظُوا۟ عَلَى ٱلصَّلَوَٰتِ وَٱلصَّلَوٰةِ ٱلْوُسْطَىٰ', description: 'Guard strictly the prayers, especially the middle one'),
      TopicVerse(surahNumber: 4, ayahNumber: 103, arabicText: 'إِنَّ ٱلصَّلَوٰةَ كَانَتْ عَلَى ٱلْمُؤْمِنِينَ كِتَٰبًا مَّوْقُوتًا', description: 'Prayer is prescribed at specific times for believers'),
      TopicVerse(surahNumber: 75, ayahNumber: 31, arabicText: 'فَلَا صَدَّقَ وَلَا صَلَّىٰ', description: 'He neither believed nor prayed \u2013 a warning'),
      TopicVerse(surahNumber: 107, ayahNumber: 4, arabicText: 'فَوَيْلٌ لِّلْمُصَلِّينَ', description: 'Woe to those who pray but are heedless'),
    ],
  ),

  // 3 ── Fasting ────────────────────────────────────────────────────
  QuranTopic(
    id: 'fasting',
    arabicName: 'الصيام',
    englishName: 'Fasting',
    description: 'Fasting in Ramadan and its spiritual benefits',
    icon: Icons.nights_stay_rounded,
    color: const Color(0xFF1D4ED8),
    verses: const [
      TopicVerse(surahNumber: 2, ayahNumber: 183, arabicText: 'يَٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ كُتِبَ عَلَيْكُمُ ٱلصِّيَامُ', description: 'Fasting is prescribed for you as it was for those before'),
      TopicVerse(surahNumber: 2, ayahNumber: 185, arabicText: 'شَهْرُ رَمَضَانَ ٱلَّذِىٓ أُنزِلَ فِيهِ ٱلْقُرْءَانُ', description: 'Ramadan \u2013 the month the Quran was revealed'),
      TopicVerse(surahNumber: 2, ayahNumber: 187, arabicText: 'أُحِلَّ لَكُمْ لَيْلَةَ ٱلصِّيَامِ ٱلرَّفَثُ', description: 'Permitted for you on the nights of fasting is intimacy'),
      TopicVerse(surahNumber: 2, ayahNumber: 184, arabicText: 'وَعَلَى ٱلَّذِينَ يُطِيقُونَهُۥ فِدْيَةٌ طَعَامُ مِسْكِينٍ', description: 'Those who cannot fast may feed a poor person instead'),
      TopicVerse(surahNumber: 33, ayahNumber: 35, arabicText: 'وَٱلصَّـٰٓئِمِينَ وَٱلصَّـٰٓئِمَـٰتِ', description: 'Fasting men and fasting women \u2013 Allah has prepared forgiveness'),
      TopicVerse(surahNumber: 97, ayahNumber: 1, arabicText: 'إِنَّآ أَنزَلْنَٰهُ فِى لَيْلَةِ ٱلْقَدْرِ', description: 'Laylat al-Qadr \u2013 the Night of Decree in Ramadan'),
    ],
  ),

  // 4 ── Zakat ──────────────────────────────────────────────────────
  QuranTopic(
    id: 'zakat',
    arabicName: 'الزكاة',
    englishName: 'Zakat (Almsgiving)',
    description: 'Obligatory charity and purification of wealth',
    icon: Icons.volunteer_activism_rounded,
    color: const Color(0xFF059669),
    verses: const [
      TopicVerse(surahNumber: 2, ayahNumber: 177, arabicText: 'وَءَاتُوا۟ ٱلزَّكَوٰةَ', description: 'Righteousness includes giving zakah'),
      TopicVerse(surahNumber: 9, ayahNumber: 103, arabicText: 'خُذْ مِنْ أَمْوَٰلِهِمْ صَدَقَةً تُطَهِّرُهُمْ وَتُزَكِّيهِم بِهَا', description: 'Take from their wealth charity to purify and cleanse them'),
      TopicVerse(surahNumber: 9, ayahNumber: 60, arabicText: 'إِنَّمَا ٱلصَّدَقَـٰتُ لِلْفُقَرَآءِ', description: 'The categories of people entitled to receive zakah'),
      TopicVerse(surahNumber: 2, ayahNumber: 110, arabicText: 'وَأَقِيمُوا۟ ٱلصَّلَوٰةَ وَءَاتُوا۟ ٱلزَّكَوٰةَ', description: 'Establish prayer and give zakah'),
      TopicVerse(surahNumber: 3, ayahNumber: 180, arabicText: 'وَلَا يَحْسَبَنَّ ٱلَّذِينَ يَبْخَلُونَ بِمَآ ءَاتَىٰهُمُ ٱللَّهُ', description: 'Let not those who hoard Allah\'s bounty think it is good for them'),
      TopicVerse(surahNumber: 30, ayahNumber: 39, arabicText: 'وَمَآ ءَاتَيْتُم مِّن رِّبًا لِّيَرْبُوَ فِىٓ أَمْوَٰلِ ٱلنَّاسِ', description: 'Usury does not increase with Allah, but zakah does'),
      TopicVerse(surahNumber: 2, ayahNumber: 267, arabicText: 'يَـٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوٓا۟ أَنفِقُوا۟ مِن طَيِّبَـٰتِ مَا كَسَبْتُمْ', description: 'Spend from the good things you have earned'),
    ],
  ),

  // 5 ── Hajj ───────────────────────────────────────────────────────
  QuranTopic(
    id: 'hajj',
    arabicName: 'الحج',
    englishName: 'Hajj (Pilgrimage)',
    description: 'The pilgrimage to Makkah and its rites',
    icon: Icons.airplane_ticket_rounded,
    color: const Color(0xFFB45309),
    verses: const [
      TopicVerse(surahNumber: 22, ayahNumber: 27, arabicText: 'وَأَذِّن فِى ٱلنَّاسِ بِٱلْحَجِّ يَأْتُوكَ رِجَالًا', description: 'Proclaim the Hajj to the people \u2013 they will come to you'),
      TopicVerse(surahNumber: 3, ayahNumber: 97, arabicText: 'وَلِلَّهِ عَلَى ٱلنَّاسِ حِجُّ ٱلْبَيْتِ مَنِ ٱسْتَطَاعَ إِلَيْهِ سَبِيلًا', description: 'Hajj is a duty owed to Allah for those who can find a way'),
      TopicVerse(surahNumber: 2, ayahNumber: 196, arabicText: 'وَأَتِمُّوا۟ ٱلْحَجَّ وَٱلْعُمْرَةَ لِلَّهِ', description: 'Complete the Hajj and Umrah for Allah'),
      TopicVerse(surahNumber: 22, ayahNumber: 36, arabicText: 'وَٱلْبُدْنَ جَعَلْنَٰهَا لَكُم مِّن شَعَـٰٓئِرِ ٱللَّهِ', description: 'The sacrificial camels are a sign of Allah'),
      TopicVerse(surahNumber: 5, ayahNumber: 3, arabicText: 'ٱلْيَوْمَ أَكْمَلْتُ لَكُمْ دِينَكُمْ', description: 'This day I have perfected your religion \u2013 revealed at Arafah'),
      TopicVerse(surahNumber: 2, ayahNumber: 158, arabicText: 'إِنَّ ٱلصَّفَا وَٱلْمَرْوَةَ مِن شَعَـٰٓئِرِ ٱللَّهِ', description: 'Safa and Marwah are among the symbols of Allah'),
    ],
  ),

  // 6 ── Paradise ───────────────────────────────────────────────────
  QuranTopic(
    id: 'paradise',
    arabicName: 'الجنة',
    englishName: 'Paradise (Jannah)',
    description: 'The eternal abode of bliss for the righteous',
    icon: Icons.park_rounded,
    color: const Color(0xFF16A34A),
    verses: const [
      TopicVerse(surahNumber: 9, ayahNumber: 72, arabicText: 'وَعَدَ ٱللَّهُ ٱلْمُؤْمِنِينَ وَٱلْمُؤْمِنَـٰتِ جَنَّـٰتٍ تَجْرِى مِن تَحْتِهَا ٱلْأَنْهَٰرُ', description: 'Allah has promised the believers gardens with rivers flowing beneath'),
      TopicVerse(surahNumber: 55, ayahNumber: 46, arabicText: 'وَلِمَنْ خَافَ مَقَامَ رَبِّهِۦ جَنَّتَانِ', description: 'For whoever fears standing before their Lord \u2013 two gardens'),
      TopicVerse(surahNumber: 41, ayahNumber: 30, arabicText: 'إِنَّ ٱلَّذِينَ قَالُوا۟ رَبُّنَا ٱللَّهُ ثُمَّ ٱسْتَقَـٰمُوا۟', description: 'Those who say our Lord is Allah then remain steadfast'),
      TopicVerse(surahNumber: 18, ayahNumber: 31, arabicText: 'أُو۟لَـٰٓئِكَ لَهُمْ جَنَّـٰتُ عَدْنٍ تَجْرِى مِن تَحْتِهِمُ ٱلْأَنْهَٰرُ', description: 'Gardens of Eternity beneath which rivers flow'),
      TopicVerse(surahNumber: 3, ayahNumber: 133, arabicText: 'وَسَارِعُوٓا۟ إِلَىٰ مَغْفِرَةٍ مِّن رَّبِّكُمْ وَجَنَّةٍ عَرْضُهَا ٱلسَّمَـٰوَٰتُ وَٱلْأَرْضُ', description: 'Race toward a Paradise as wide as the heavens and earth'),
      TopicVerse(surahNumber: 57, ayahNumber: 21, arabicText: 'سَابِقُوٓا۟ إِلَىٰ مَغْفِرَةٍ مِّن رَّبِّكُمْ', description: 'Strive for forgiveness and Paradise'),
      TopicVerse(surahNumber: 76, ayahNumber: 12, arabicText: 'وَيُكَفِّرُ عَنكُمْ سَيِّـَٔاتِكُمْ', description: 'He forgives your sins and admits you to gardens'),
    ],
  ),

  // 7 ── Hellfire ───────────────────────────────────────────────────
  QuranTopic(
    id: 'hellfire',
    arabicName: 'النار',
    englishName: 'Hellfire (Jahannam)',
    description: 'Warning of the punishment of the Hereafter',
    icon: Icons.local_fire_department_rounded,
    color: const Color(0xFFDC2626),
    verses: const [
      TopicVerse(surahNumber: 104, ayahNumber: 5, arabicText: 'وَمَآ أَدْرَىٰكَ مَا حُطَمَةٌ', description: 'What will make you know what the Crushing Fire is?'),
      TopicVerse(surahNumber: 2, ayahNumber: 39, arabicText: 'وَٱلَّذِينَ كَفَرُوا۟ أُو۟لَـٰٓئِكَ أَصْحَـٰبُ ٱلنَّارِ هُمْ فِيهَا خَـٰلِدُونَ', description: 'Those who disbelieve are companions of the Fire, abiding therein'),
      TopicVerse(surahNumber: 4, ayahNumber: 56, arabicText: 'كُلَّمَا نَضِجَتْ جُلُودُهُمْ بَدَّلْنَٰهُمْ جُلُودًا غَيْرَهَا', description: 'Whenever their skins are burned, We replace them with new skins'),
      TopicVerse(surahNumber: 67, ayahNumber: 6, arabicText: 'وَلِلَّذِينَ كَفَرُوا۟ بِرَبِّهِمْ عَذَابُ جَهَنَّمَ وَبِئْسَ ٱلْمَصِيرُ', description: 'For those who disbelieve is the punishment of Jahannam'),
      TopicVerse(surahNumber: 14, ayahNumber: 49, arabicText: 'وَتَرَى ٱلْمُجْرِمِينَ يَوْمَئِذٍ مُّقَرَّنِينَ فِى ٱلْأَصْفَادِ', description: 'On that Day the criminals will be bound in chains'),
      TopicVerse(surahNumber: 70, ayahNumber: 15, arabicText: 'كَلَّآ إِنَّهَا لَظَىٰ', description: 'No! It is a blazing Fire'),
    ],
  ),

  // 8 ── Patience ───────────────────────────────────────────────────
  QuranTopic(
    id: 'patience',
    arabicName: 'الصبر',
    englishName: 'Patience (Sabr)',
    description: 'Steadfastness through trials and hardships',
    icon: Icons.self_improvement_rounded,
    color: const Color(0xFF6366F1),
    verses: const [
      TopicVerse(surahNumber: 2, ayahNumber: 155, arabicText: 'وَلَنَبْلُوَنَّكُم بِشَىْءٍ مِّنَ ٱلْخَوْفِ وَٱلْجُوعِ', description: 'We will surely test you with fear and hunger'),
      TopicVerse(surahNumber: 2, ayahNumber: 156, arabicText: 'وَبَشِّرِ ٱلصَّـٰبِرِينَ', description: 'Give good tidings to those who are patient'),
      TopicVerse(surahNumber: 2, ayahNumber: 153, arabicText: 'يَـٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ ٱسْتَعِينُوا۟ بِٱلصَّبْرِ وَٱلصَّلَوٰةِ', description: 'Seek help through patience and prayer'),
      TopicVerse(surahNumber: 3, ayahNumber: 200, arabicText: 'يَـٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ ٱصْبِرُوا۟ وَصَابِرُوا۟', description: 'Be patient, persevere, and remain steadfast'),
      TopicVerse(surahNumber: 103, ayahNumber: 3, arabicText: 'وَتَوَاصَوْا۟ بِٱلصَّبْرِ', description: 'Advise each other to patience'),
      TopicVerse(surahNumber: 14, ayahNumber: 12, arabicText: 'رَبَّنَا ٱفْرِغْ عَلَيْنَا صَبْرًا وَتَوَفَّنَا مُسْلِمِينَ', description: 'Our Lord, pour upon us patience and let us die as Muslims'),
    ],
  ),

  // 9 ── Gratitude ──────────────────────────────────────────────────
  QuranTopic(
    id: 'gratitude',
    arabicName: 'الشكر',
    englishName: 'Gratitude (Shukr)',
    description: 'Thankfulness to Allah for His countless blessings',
    icon: Icons.favorite_rounded,
    color: const Color(0xFFEC4899),
    verses: const [
      TopicVerse(surahNumber: 2, ayahNumber: 152, arabicText: 'فَٱذْكُرُونِىٓ أَذْكُرْكُمْ وَٱشْكُرُوا۟ لِى وَلَا تَكْفُرُونِ', description: 'Remember Me and I will remember you \u2013 be grateful to Me'),
      TopicVerse(surahNumber: 14, ayahNumber: 7, arabicText: 'لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ', description: 'If you are grateful, I will give you more'),
      TopicVerse(surahNumber: 31, ayahNumber: 12, arabicText: 'وَلَقَدْ ءَاتَيْنَا لُقْمَٰنَ ٱلْحِكْمَةَ', description: 'We gave Luqman wisdom \u2013 be grateful to Allah'),
      TopicVerse(surahNumber: 16, ayahNumber: 18, arabicText: 'وَإِن تَعُدُّوا۟ نِعْمَةَ ٱللَّهِ لَا تُحْصُوهَآ', description: 'If you count the blessings of Allah, you could not enumerate them'),
      TopicVerse(surahNumber: 34, ayahNumber: 13, arabicText: 'ٱعْمَلُوا۟ ءَالَ دَاوُۥدَ شُكْرًا', description: 'Work, O family of David, in gratitude'),
      TopicVerse(surahNumber: 55, ayahNumber: 13, arabicText: 'فَبِأَىِّ ءَالَآءِ رَبِّكُمَا تُكَذِّبَانِ', description: 'So which of the favors of your Lord would you deny?'),
    ],
  ),

  // 10 ── Knowledge ─────────────────────────────────────────────────
  QuranTopic(
    id: 'knowledge',
    arabicName: 'العلم',
    englishName: 'Knowledge (Ilm)',
    description: 'The importance of seeking knowledge and wisdom',
    icon: Icons.school_rounded,
    color: const Color(0xFF0891B2),
    verses: const [
      TopicVerse(surahNumber: 96, ayahNumber: 1, arabicText: 'ٱقْرَأْ بِٱسْمِ رَبِّكَ ٱلَّذِى خَلَقَ', description: 'Read in the name of your Lord who created \u2013 first revelation'),
      TopicVerse(surahNumber: 2, ayahNumber: 31, arabicText: 'وَعَلَّمَ ءَادَمَ ٱلْأَسْمَآءَ كُلَّهَا', description: 'He taught Adam the names \u2013 all of them'),
      TopicVerse(surahNumber: 58, ayahNumber: 11, arabicText: 'يَـٰرَفَعِ ٱللَّهُ ٱلَّذِينَ ءَامَنُوا۟ مِنكُمْ وَٱلَّذِينَ أُوتُوا۟ ٱلْعِلْمَ دَرَجَـٰتٍ', description: 'Allah will raise those who have believed and given knowledge by degrees'),
      TopicVerse(surahNumber: 20, ayahNumber: 114, arabicText: 'فَسَأَلُوا۟ أَهْلَ ٱلذِّكْرِ إِن كُنتُمْ لَا تَعْلَمُونَ', description: 'Ask the people of knowledge if you do not know'),
      TopicVerse(surahNumber: 39, ayahNumber: 9, arabicText: 'قُلْ هَلْ يَسْتَوِى ٱلَّذِينَ يَعْلَمُونَ وَٱلَّذِينَ لَا يَعْلَمُونَ', description: 'Are those who know equal to those who do not know?'),
      TopicVerse(surahNumber: 35, ayahNumber: 28, arabicText: 'إِنَّمَا يَخْشَى ٱللَّهَ مِنْ عِبَادِهِ ٱلْعُلَمَـٰٓؤُا۟', description: 'Only those among His servants who have knowledge fear Allah'),
      TopicVerse(surahNumber: 3, ayahNumber: 18, arabicText: 'وَأُو۟لُوا۟ ٱلْعِلْمِ شَهِدَ ٱللَّهُ', description: 'Those of knowledge bear witness to His Oneness'),
    ],
  ),

  // 11 ── Family & Marriage ─────────────────────────────────────────
  QuranTopic(
    id: 'family',
    arabicName: 'الأسرة والزواج',
    englishName: 'Family & Marriage',
    description: 'Marriage, family rights, and household harmony',
    icon: Icons.family_restroom_rounded,
    color: const Color(0xFFD946EF),
    verses: const [
      TopicVerse(surahNumber: 30, ayahNumber: 21, arabicText: 'وَمِنْ ءَايَـٰتِهِۦٓ أَنْ خَلَقَ لَكُم مِّنْ أَنفُسِكُمْ أَزْوَٰجًا', description: 'Among His signs is that He created spouses for you'),
      TopicVerse(surahNumber: 4, ayahNumber: 1, arabicText: 'يَـٰٓأَيُّهَا ٱلنَّاسُ ٱتَّقُوا۟ رَبَّكُمُ ٱلَّذِى خَلَقَكُم مِّن نَّفْسٍ وَٰحِدَةٍ', description: 'Fear your Lord who created you from a single soul'),
      TopicVerse(surahNumber: 2, ayahNumber: 187, arabicText: 'هُنَّ لِبَاسٌ لَّكُمْ وَأَنتُمْ لِبَاسٌ لَّهُنَّ', description: 'They are clothing for you and you are clothing for them'),
      TopicVerse(surahNumber: 17, ayahNumber: 23, arabicText: 'وَبِٱلْوَٰلِدَيْنِ إِحْسَـٰنًا', description: 'Be kind to parents'),
      TopicVerse(surahNumber: 31, ayahNumber: 14, arabicText: 'وَوَصَّيْنَا ٱلْإِنسَـٰنَ بِوَٰلِدَيْهِ حَمَلَتْهُ أُمُّهُۥ وَهْنًا عَلَىٰ وَهْنٍ', description: 'We instructed man to be kind to parents'),
      TopicVerse(surahNumber: 25, ayahNumber: 74, arabicText: 'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَٰجِنَا وَذُرِّيَّـٰتِنَا قُرَّةَ أَعْيُنٍ', description: 'Grant us comfort in our spouses and children'),
    ],
  ),

  // 12 ── Justice ───────────────────────────────────────────────────
  QuranTopic(
    id: 'justice',
    arabicName: 'العدل',
    englishName: 'Justice (Adl)',
    description: 'Fairness, equity, and upholding right',
    icon: Icons.balance_rounded,
    color: const Color(0xFF0F766E),
    verses: const [
      TopicVerse(surahNumber: 4, ayahNumber: 135, arabicText: 'يَـٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ كُونُوا۟ قَوَّٰمِينَ بِٱلْقِسْطِ', description: 'Be persistently standing firm in justice'),
      TopicVerse(surahNumber: 5, ayahNumber: 8, arabicText: 'وَلَا يَجْرِمَنَّكُمْ شَنَـَٔانُ قَوْمٍ عَلَىٰٓ أَلَّا تَعْدِلُوا۟', description: 'Do not let hatred prevent you from being just'),
      TopicVerse(surahNumber: 16, ayahNumber: 90, arabicText: 'إِنَّ ٱللَّهَ يَأْمُرُ بِٱلْعَدْلِ وَٱلْإِحْسَانِ', description: 'Allah orders justice and good conduct'),
      TopicVerse(surahNumber: 7, ayahNumber: 29, arabicText: 'قُلْ أَمَرَ رَبِّى بِٱلْقِسْطِ', description: 'My Lord has commanded justice'),
      TopicVerse(surahNumber: 55, ayahNumber: 9, arabicText: 'وَأَقِيمُوا۟ ٱلْوَزْنَ بِٱلْقِسْطِ وَلَا تُخْسِرُوا۟ ٱلْمِيزَانَ', description: 'Establish weight in justice and do not skimp the balance'),
      TopicVerse(surahNumber: 42, ayahNumber: 15, arabicText: 'فَلِذَٰلِكَ فَٱدْعُ وَٱسْتَقِمْ كَمَآ أُمِرْتَ', description: 'Invite to justice and remain on a straight course'),
    ],
  ),

  // 13 ── Mercy ─────────────────────────────────────────────────────
  QuranTopic(
    id: 'mercy',
    arabicName: 'الرحمة',
    englishName: 'Mercy (Rahmah)',
    description: 'Allah\'s mercy and the command to be merciful',
    icon: Icons.handshake_rounded,
    color: const Color(0xFF2563EB),
    verses: const [
      TopicVerse(surahNumber: 1, ayahNumber: 1, arabicText: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ', description: 'In the name of Allah, the Most Gracious, the Most Merciful'),
      TopicVerse(surahNumber: 7, ayahNumber: 156, arabicText: 'وَرَحْمَتِى وَسِعَتْ كُلَّ شَىْءٍ', description: 'My mercy encompasses all things'),
      TopicVerse(surahNumber: 21, ayahNumber: 107, arabicText: 'وَمَآ أَرْسَلْنَـٰكَ إِلَّا رَحْمَةً لِّلْعَـٰلَمِينَ', description: 'We sent you only as a mercy to the worlds'),
      TopicVerse(surahNumber: 6, ayahNumber: 12, arabicText: 'وَكَتَبَ رَبُّكُمْ عَلَىٰ نَفْسِهِ ٱلرَّحْمَةَ', description: 'Your Lord has written Mercy upon Himself'),
      TopicVerse(surahNumber: 39, ayahNumber: 53, arabicText: 'لَا تَقْنَطُوا۟ مِن رَّحْمَةِ ٱللَّهِ', description: 'Do not despair of Allah\'s mercy'),
      TopicVerse(surahNumber: 17, ayahNumber: 54, arabicText: 'وَرَبُّكَ ٱلْغَنِىُّ ذُو ٱلْرَّحْمَةِ', description: 'Your Lord is the Rich, the Possessor of Mercy'),
      TopicVerse(surahNumber: 18, ayahNumber: 58, arabicText: 'وَرَبُّكَ ٱلْغَفُورُ ذُو ٱلرَّحْمَةِ', description: 'Your Lord is the Forgiving, the Lord of Mercy'),
    ],
  ),

  // 14 ── Angels ────────────────────────────────────────────────────
  QuranTopic(
    id: 'angels',
    arabicName: 'الملائكة',
    englishName: 'Angels (Mala\'ikah)',
    description: 'The noble angels and their roles in creation',
    icon: Icons.wb_twilight_rounded,
    color: const Color(0xFF7DD3FC),
    verses: const [
      TopicVerse(surahNumber: 2, ayahNumber: 32, arabicText: 'قَالُوا۟ سُبْحَانَكَ لَا عِلْمَ لَنَآ إِلَّا مَا عَلَّمْتَنَا', description: 'They said: Glory to You, we have no knowledge except what You taught us'),
      TopicVerse(surahNumber: 66, ayahNumber: 6, arabicText: 'يَـٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ قُوٓا۟ أَنفُسَكُمْ وَأَهْلِيكُمْ نَارًا', description: 'Protect yourselves and your families from a Fire'),
      TopicVerse(surahNumber: 70, ayahNumber: 4, arabicText: 'تَعْرُجُ ٱلْمَلَـٰٓئِكَةُ وَٱلرُّوحُ إِلَيْهِ', description: 'The angels and the Spirit ascend to Him'),
      TopicVerse(surahNumber: 16, ayahNumber: 2, arabicText: 'يُنَزِّلُ ٱلْمَلَـٰٓئِكَةَ بِٱلرُّوحِ مِنْ أَمْرِهِۦ', description: 'He sends down the angels with revelation by His command'),
      TopicVerse(surahNumber: 8, ayahNumber: 9, arabicText: 'إِذْ تَسْتَغِيثُونَ رَبَّكُمْ فَٱسْتَجَابَ لَكُمْ أَنِّى مُمِدُّكُم بِأَلْفٍ مِّنَ ٱلْمَلَـٰٓئِكَةِ', description: 'Allah reinforced you with a thousand angels at Badr'),
      TopicVerse(surahNumber: 82, ayahNumber: 10, arabicText: 'وَإِنَّ عَلَيْكُمْ لَحَـٰفِظِينَ', description: 'Indeed over you are guardians \u2013 noble recording angels'),
    ],
  ),

  // 15 ── Prophets ──────────────────────────────────────────────────
  QuranTopic(
    id: 'prophets',
    arabicName: 'الأنبياء',
    englishName: 'Prophets (Anbiya)',
    description: 'Stories and lessons from the Prophets of Allah',
    icon: Icons.auto_stories_rounded,
    color: const Color(0xFF92400E),
    verses: const [
      TopicVerse(surahNumber: 21, ayahNumber: 107, arabicText: 'وَمَآ أَرْسَلْنَـٰكَ إِلَّا رَحْمَةً لِّلْعَـٰلَمِينَ', description: 'Prophet Muhammad (SAW) sent as a mercy to the worlds'),
      TopicVerse(surahNumber: 33, ayahNumber: 21, arabicText: 'لَّقَدْ كَانَ لَكُمْ فِى رَسُولِ ٱللَّهِ أُسْوَةٌ حَسَنَةٌ', description: 'In the Messenger of Allah is an excellent example'),
      TopicVerse(surahNumber: 6, ayahNumber: 84, arabicText: 'وَوَهَبْنَا لَهُۥٓ إِسْحَـٰقَ وَيَعْقُوبَ', description: 'Prophets Ibrahim, Ishaq, Yaqub \u2013 guided to the right path'),
      TopicVerse(surahNumber: 12, ayahNumber: 6, arabicText: 'وَكَذَٰلِكَ يَجْتَبِيكَ رَبُّكَ', description: 'Allah chose Yusuf as a prophet with wisdom'),
      TopicVerse(surahNumber: 19, ayahNumber: 30, arabicText: 'قَالَ إِنِّى عَبْدُ ٱللَّهِ ءَاتَىٰنِىَ ٱلْكِتَـٰبَ', description: 'Prophet Isa said: I am a servant of Allah, He gave me the Scripture'),
      TopicVerse(surahNumber: 26, ayahNumber: 178, arabicText: 'إِنَّمَآ أَنَا۟ لَكُمْ رَسُولٌ أَمِينٌ', description: 'Prophet Hud said: I am a trustworthy messenger to you'),
      TopicVerse(surahNumber: 28, ayahNumber: 30, arabicText: 'فَأَرْسِلْ مَعِىَ بَنِىٓ إِسْرَٰٓئِيلَ', description: 'Prophet Musa\'s mission to Pharaoh'),
      TopicVerse(surahNumber: 38, ayahNumber: 30, arabicText: 'وَوَهَبْنَا لِدَاوُۥدَ سُلَيْمَـٰنَ', description: 'Allah gave Dawud Sulayman as a prophet \u2013 an excellent servant'),
    ],
  ),

  // 16 ── Day of Judgment ──────────────────────────────────────────
  QuranTopic(
    id: 'day_of_judgment',
    arabicName: 'يوم القيامة',
    englishName: 'Day of Judgment',
    description: 'The Last Day, resurrection, and divine reckoning',
    icon: Icons.gavel_rounded,
    color: const Color(0xFF4C1D95),
    verses: const [
      TopicVerse(surahNumber: 1, ayahNumber: 4, arabicText: 'مَـٰلِكِ يَوْمِ ٱلدِّينِ', description: 'Master of the Day of Judgment'),
      TopicVerse(surahNumber: 99, ayahNumber: 1, arabicText: 'إِذَا زُلْزِلَتِ ٱلْأَرْضُ زِلْزَالَهَا', description: 'When the earth is shaken with its final earthquake'),
      TopicVerse(surahNumber: 69, ayahNumber: 1, arabicText: 'ٱلْحَاقَّةُ', description: 'The Inevitable Reality \u2013 the Day of Judgment'),
      TopicVerse(surahNumber: 75, ayahNumber: 3, arabicText: 'أَيَحْسَبُ ٱلْإِنسَـٰنُ أَلَّن نَّجْمَعَ عِظَامَهُۥ', description: 'Does man think We will not assemble his bones?'),
      TopicVerse(surahNumber: 81, ayahNumber: 1, arabicText: 'إِذَا ٱلشَّمْسُ كُوِّرَتْ', description: 'When the sun is wrapped up \u2013 signs of the Last Day'),
      TopicVerse(surahNumber: 82, ayahNumber: 1, arabicText: 'إِذَا ٱلسَّمَآءُ ٱنفَطَرَتْ', description: 'When the sky breaks apart'),
      TopicVerse(surahNumber: 102, ayahNumber: 1, arabicText: 'أَلْهَىٰكُمُ ٱلتَّكَاثُرُ', description: 'Competition in worldly increase distracts you from the Hereafter'),
    ],
  ),

  // 17 ── Wisdom ────────────────────────────────────────────────────
  QuranTopic(
    id: 'wisdom',
    arabicName: 'الحكمة',
    englishName: 'Wisdom (Hikmah)',
    description: 'Divine wisdom, reflection, and deep understanding',
    icon: Icons.lightbulb_rounded,
    color: const Color(0xFFCA8A04),
    verses: const [
      TopicVerse(surahNumber: 2, ayahNumber: 269, arabicText: 'يُؤْتِى ٱلْحِكْمَةَ مَن يَشَآءُ وَمَن يُؤْتَ ٱلْحِكْمَةَ فَقَدْ أُوتِىَ خَيْرًا كَثِيرًا', description: 'He grants wisdom to whom He wills, and whoever is granted wisdom has been given much good'),
      TopicVerse(surahNumber: 31, ayahNumber: 12, arabicText: 'وَلَقَدْ ءَاتَيْنَا لُقْمَٰنَ ٱلْحِكْمَةَ', description: 'We certainly gave Luqman wisdom'),
      TopicVerse(surahNumber: 18, ayahNumber: 109, arabicText: 'قُل لَّوْ كَانَ ٱلْبَحْرُ مِدَادًا لِّكَلِمَـٰتِ رَبِّى', description: 'If the sea were ink for the words of my Lord, it would be exhausted'),
      TopicVerse(surahNumber: 3, ayahNumber: 7, arabicText: 'وَمَا يَعْلَمُ تَأْوِيلَهُۥٓ إِلَّا ٱللَّهُ وَٱلرَّٰسِخُونَ فِى ٱلْعِلْمِ', description: 'No one knows its true meaning except Allah and those firm in knowledge'),
      TopicVerse(surahNumber: 59, ayahNumber: 21, arabicText: 'لَوْ أَنزَلْنَا هَٰذَا ٱلْقُرْءَانَ عَلَىٰ جَبَلٍ لَّرَأَيْتَهُۥ خَـٰشِعًا مُّتَصَدِّعًا', description: 'If We had sent this Quran upon a mountain, you would see it humbled'),
      TopicVerse(surahNumber: 13, ayahNumber: 19, arabicText: 'أَفَمَن يَعْلَمُ أَنَّمَآ أُنزِلَ إِلَيْكَ مِن رَبِّكَ ٱلْحَقُّ', description: 'Is one who knows that what is revealed to you is the truth like one who is blind?'),
    ],
  ),

  // 18 ── Charity ───────────────────────────────────────────────────
  QuranTopic(
    id: 'charity',
    arabicName: 'الصدقة',
    englishName: 'Charity (Sadaqah)',
    description: 'Voluntary giving and generosity in Islam',
    icon: Icons.card_giftcard_rounded,
    color: const Color(0xFFE11D48),
    verses: const [
      TopicVerse(surahNumber: 2, ayahNumber: 261, arabicText: 'مَّثَلُ ٱلَّذِينَ يُنفِقُونَ أَمْوَٰلَهُمْ فِى سَبِيلِ ٱللَّهِ كَمَثَلِ حَبَّةٍ أَنبَتَتْ سَبْعَ سَنَابِلَ', description: 'The example of those who spend in Allah\'s way is like a seed that produces seven ears'),
      TopicVerse(surahNumber: 3, ayahNumber: 92, arabicText: 'لَن تَنَالُوا۟ ٱلْبِرَّ حَتَّىٰ تُنفِقُوا۟ مِمَّا تُحِبُّونَ', description: 'You will never attain righteousness until you spend from that which you love'),
      TopicVerse(surahNumber: 2, ayahNumber: 263, arabicText: 'كَلِمَةٌ طَيِّبَةٌ كَشَجَرَةٍ طَيِّبَةٍ', description: 'A good word is like a good tree'),
      TopicVerse(surahNumber: 2, ayahNumber: 274, arabicText: 'الَّذِينَ يُنفِقُونَ أَمْوَٰلَهُم بِٱلَّيْلِ وَٱلنَّهَارِ سِرًّا وَعَلَانِيَةً', description: 'Those who spend by night and day, secretly and publicly'),
      TopicVerse(surahNumber: 57, ayahNumber: 7, arabicText: 'ءَامِنُوا۟ بِٱللَّهِ وَرَسُولِهِۦ وَأَنفِقُوا۟ مِمَّا جَعَلَكُم مُّسْتَخْلَفِينَ فِيهِ', description: 'Believe in Allah and His Messenger and spend from that which He made you trustees over'),
      TopicVerse(surahNumber: 64, ayahNumber: 16, arabicText: 'فَٱتَّقُوا۟ ٱللَّهَ مَا ٱسْتَطَعْتُمْ وَأَسْمِعُوا۟ وَأَطِيعُوا۟ وَأَنفِقُوا۟ خَيْرًا لِّأَنفُسِكُمْ', description: 'Fear Allah as much as you can, listen, obey, and spend for your own good'),
    ],
  ),
];

// ── State ──────────────────────────────────────────────────────────

class TopicState {
  final String searchQuery;
  final String? selectedTopicId;

  const TopicState({
    this.searchQuery = '',
    this.selectedTopicId,
  });

  TopicState copyWith({
    String? searchQuery,
    String? selectedTopicId,
    bool clearTopic = false,
  }) {
    return TopicState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTopicId: clearTopic ? null : (selectedTopicId ?? this.selectedTopicId),
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────────

class TopicNotifier extends StateNotifier<TopicState> {
  TopicNotifier() : super(const TopicState());

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectTopic(String topicId) {
    state = state.copyWith(
      selectedTopicId: topicId == state.selectedTopicId ? null : topicId,
    );
  }

  void clearSelection() {
    state = state.copyWith(clearTopic: true);
  }
}

// ── Providers ──────────────────────────────────────────────────────

final topicProvider = StateNotifierProvider<TopicNotifier, TopicState>(
  (ref) => TopicNotifier(),
);

final filteredTopicsProvider = Provider<List<QuranTopic>>((ref) {
  final state = ref.watch(topicProvider);
  final query = state.searchQuery.toLowerCase().trim();

  if (query.isEmpty) return kQuranTopics;

  return kQuranTopics.where((topic) {
    final matchesTopic =
        topic.englishName.toLowerCase().contains(query) ||
        topic.arabicName.contains(query) ||
        topic.description.toLowerCase().contains(query);
    final matchesVerse = topic.verses.any((v) =>
        v.description.toLowerCase().contains(query) ||
        v.arabicText.contains(query));
    return matchesTopic || matchesVerse;
  }).toList();
});
