import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Model ─────────────────────────────────────────────────────────

class AsmaName {
  final int number;
  final String arabicName;
  final String englishMeaning;
  final String explanation;
  final String relatedVerse; // format "SurahName Ayah:Num"
  final String verseText;

  const AsmaName({
    required this.number,
    required this.arabicName,
    required this.englishMeaning,
    required this.explanation,
    required this.relatedVerse,
    required this.verseText,
  });
}

// ── All 99 Names ─────────────────────────────────────────────────

const List<AsmaName> kAllAsmaNames = [
  // 1
  AsmaName(
    number: 1,
    arabicName: 'الرَّحْمَٰنُ',
    englishMeaning: 'The Most Merciful',
    explanation: 'The One who has absolute mercy on all creation. His mercy encompasses everything and everyone.',
    relatedVerse: 'Al-Fatiha 1:1',
    verseText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
  ),
  // 2
  AsmaName(
    number: 2,
    arabicName: 'الرَّحِيمُ',
    englishMeaning: 'The Especially Merciful',
    explanation: 'The One who has special mercy for the believers. His special mercy is specific to those who believe and do good deeds.',
    relatedVerse: 'Al-Fatiha 1:1',
    verseText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
  ),
  // 3
  AsmaName(
    number: 3,
    arabicName: 'الْمَلِكُ',
    englishMeaning: 'The King',
    explanation: 'The Sovereign Lord, the One with supreme authority and ruling power over all existence.',
    relatedVerse: 'Al-Hashr 59:23',
    verseText: 'هُوَ اللَّهُ الَّذِي لَا إِلَٰهَ إِلَّا هُوَ الْمَلِكُ الْقُدُّوسُ السَّلَامُ',
  ),
  // 4
  AsmaName(
    number: 4,
    arabicName: 'الْقُدُّوسُ',
    englishMeaning: 'The Most Holy',
    explanation: 'The One who is free from all imperfections and deficiencies. He is absolutely pure and perfect.',
    relatedVerse: 'Al-Hashr 59:23',
    verseText: 'هُوَ اللَّهُ الَّذِي لَا إِلَٰهَ إِلَّا هُوَ الْمَلِكُ الْقُدُّوسُ السَّلَامُ',
  ),
  // 5
  AsmaName(
    number: 5,
    arabicName: 'السَّلَامُ',
    englishMeaning: 'The Source of Peace',
    explanation: 'The One who is the source of all peace and safety. From Him comes all security and tranquility.',
    relatedVerse: 'Al-Hashr 59:23',
    verseText: 'هُوَ اللَّهُ الَّذِي لَا إِلَٰهَ إِلَّا هُوَ الْمَلِكُ الْقُدُّوسُ السَّلَامُ',
  ),
  // 6
  AsmaName(
    number: 6,
    arabicName: 'الْمُؤْمِنُ',
    englishMeaning: 'The Granter of Security',
    explanation: 'The One who grants faith and security to His creation. He confirms His promises and gives assurance.',
    relatedVerse: 'Al-Hashr 59:23',
    verseText: 'الْمُؤْمِنُ الْمُهَيْمِنُ الْعَزِيزُ الْجَبَّارُ الْمُتَكَبِّرُ',
  ),
  // 7
  AsmaName(
    number: 7,
    arabicName: 'الْمُهَيْمِنُ',
    englishMeaning: 'The Guardian',
    explanation: 'The One who watches over and protects all creation. He is the witness over everything.',
    relatedVerse: 'Al-Hashr 59:23',
    verseText: 'الْمُؤْمِنُ الْمُهَيْمِنُ الْعَزِيزُ الْجَبَّارُ الْمُتَكَبِّرُ',
  ),
  // 8
  AsmaName(
    number: 8,
    arabicName: 'الْعَزِيزُ',
    englishMeaning: 'The Almighty',
    explanation: 'The One who is incomparably mighty and powerful. None can overpower Him.',
    relatedVerse: 'Al-Hashr 59:23',
    verseText: 'الْمُؤْمِنُ الْمُهَيْمِنُ الْعَزِيزُ الْجَبَّارُ الْمُتَكَبِّرُ',
  ),
  // 9
  AsmaName(
    number: 9,
    arabicName: 'الْجَبَّارُ',
    englishMeaning: 'The Compeller',
    explanation: 'The One who compels and restores all creation according to His will. He is the Supreme who cannot be resisted.',
    relatedVerse: 'Al-Hashr 59:23',
    verseText: 'الْمُؤْمِنُ الْمُهَيْمِنُ الْعَزِيزُ الْجَبَّارُ الْمُتَكَبِّرُ',
  ),
  // 10
  AsmaName(
    number: 10,
    arabicName: 'الْمُتَكَبِّرُ',
    englishMeaning: 'The Supreme',
    explanation: 'The One who is above all creation, great and magnificent beyond comprehension.',
    relatedVerse: 'Al-Hashr 59:23',
    verseText: 'سُبْحَانَ اللَّهِ عَمَّا يُشْرِكُونَ',
  ),
  // 11
  AsmaName(
    number: 11,
    arabicName: 'الْخَالِقُ',
    englishMeaning: 'The Creator',
    explanation: 'The One who creates everything from nothing and measures the creation perfectly.',
    relatedVerse: 'Al-Hashr 59:24',
    verseText: 'هُوَ اللَّهُ الْخَالِقُ الْبَارِئُ الْمُصَوِّرُ',
  ),
  // 12
  AsmaName(
    number: 12,
    arabicName: 'الْبَارِئُ',
    englishMeaning: 'The Originator',
    explanation: 'The One who creates without any prior example or model. He originates creation uniquely.',
    relatedVerse: 'Al-Hashr 59:24',
    verseText: 'هُوَ اللَّهُ الْخَالِقُ الْبَارِئُ الْمُصَوِّرُ',
  ),
  // 13
  AsmaName(
    number: 13,
    arabicName: 'الْمُصَوِّرُ',
    englishMeaning: 'The Fashioner',
    explanation: 'The One who designs and shapes all forms of creation with perfect wisdom and beauty.',
    relatedVerse: 'Al-Hashr 59:24',
    verseText: 'لَهُ الْأَسْمَاءُ الْحُسْنَىٰ',
  ),
  // 14
  AsmaName(
    number: 14,
    arabicName: 'الْغَفَّارُ',
    englishMeaning: 'The Forgiver',
    explanation: 'The One who forgives repeatedly and abundantly. He covers sins and pardons endlessly.',
    relatedVerse: 'Ta-Ha 20:82',
    verseText: 'إِنِّي أَنَا الْغَفَّارُ لِمَنْ تَابَ وَآمَنَ وَعَمِلَ صَالِحًا ثُمَّ اهْتَدَىٰ',
  ),
  // 15
  AsmaName(
    number: 15,
    arabicName: 'الْقَهَّارُ',
    englishMeaning: 'The Subduer',
    explanation: 'The One who subdues and overpowers all things. He dominates and nothing can escape His control.',
    relatedVerse: 'Al-Zumar 39:4',
    verseText: 'لَوْ أَرَادَ اللَّهُ أَنْ يَتَّخِذَ وَلَدًا لَّاصْطَفَىٰ مِمَّا يَخْلُقُ مَا يَشَاءُ سُبْحَانَهُ هُوَ اللَّهُ الْوَاحِدُ الْقَهَّارُ',
  ),
  // 16
  AsmaName(
    number: 16,
    arabicName: 'الْوَهَّابُ',
    englishMeaning: 'The Bestower',
    explanation: 'The One who gives freely and generously without expecting anything in return.',
    relatedVerse: 'Al-Imran 3:8',
    verseText: 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً',
  ),
  // 17
  AsmaName(
    number: 17,
    arabicName: 'الرَّزَّاقُ',
    englishMeaning: 'The Provider',
    explanation: 'The One who provides sustenance for all His creation. He is the ultimate source of all provisions.',
    relatedVerse: 'Adh-Dhariyat 51:58',
    verseText: 'إِنَّ اللَّهَ هُوَ الرَّزَّاقُ ذُو الْقُوَّةِ الْمَتِينُ',
  ),
  // 18
  AsmaName(
    number: 18,
    arabicName: 'الْفَتَّاحُ',
    englishMeaning: 'The Opener',
    explanation: 'The One who opens the gates of mercy, success, and guidance for His servants.',
    relatedVerse: 'Al-Araf 7:96',
    verseText: 'لَوْ أَنَّ أَهْلَ الْقُرَىٰ آمَنُوا وَاتَّقَوْا لَفَتَحْنَا عَلَيْهِم بَرَكَاتٍ مِّنَ السَّمَاءِ وَالْأَرْضِ',
  ),
  // 19
  AsmaName(
    number: 19,
    arabicName: 'الْعَلِيمُ',
    englishMeaning: 'The All-Knowing',
    explanation: 'The One whose knowledge encompasses all things—past, present, and future. Nothing is hidden from Him.',
    relatedVerse: 'Al-Baqarah 2:29',
    verseText: 'هُوَ الَّذِي خَلَقَ لَكُم مَّا فِي الْأَرْضِ جَمِيعًا ثُمَّ اسْتَوَىٰ إِلَى السَّمَاءِ فَسَوَّاهُنَّ سَبْعَ سَمَاوَاتٍ وَهُوَ بِكُلِّ شَيْءٍ عَلِيمٌ',
  ),
  // 20
  AsmaName(
    number: 20,
    arabicName: 'الْقَابِضُ',
    englishMeaning: 'The Withholder',
    explanation: 'The One who withholds sustenance and provisions according to His infinite wisdom.',
    relatedVerse: 'Al-Baqarah 2:245',
    verseText: 'وَمَن ذَا الَّذِي يُقْرِضُ اللَّهَ قَرْضًا حَسَنًا فَيُضَاعِفَهُ لَهُ أَضْعَافًا كَثِيرَةً',
  ),
  // 21
  AsmaName(
    number: 21,
    arabicName: 'الْبَاسِطُ',
    englishMeaning: 'The Extender',
    explanation: 'The One who extends and spreads His mercy, provision, and blessings widely.',
    relatedVerse: 'Al-Baqarah 2:245',
    verseText: 'وَاللَّهُ يَقْبِضُ وَيَبْسُطُ وَإِلَيْهِ تُرْجَعُونَ',
  ),
  // 22
  AsmaName(
    number: 22,
    arabicName: 'الْخَافِضُ',
    englishMeaning: 'The Humiliator',
    explanation: 'The One who lowers and humbles the arrogant and the tyrants.',
    relatedVerse: 'Al-Waqi`ah 56:3',
    verseText: 'خَافِضَةٌ رَّافِعَةٌ',
  ),
  // 23
  AsmaName(
    number: 23,
    arabicName: 'الرَّافِعُ',
    englishMeaning: 'The Exalter',
    explanation: 'The One who raises the status and rank of those He wills among His servants.',
    relatedVerse: 'Al-Waqi`ah 56:3',
    verseText: 'خَافِضَةٌ رَّافِعَةٌ',
  ),
  // 24
  AsmaName(
    number: 24,
    arabicName: 'الْمُعِزُّ',
    englishMeaning: 'The Honorer',
    explanation: 'The One who grants honor and dignity to whom He wills among His servants.',
    relatedVerse: 'Al-Imran 3:26',
    verseText: 'قُلِ اللَّهُمَّ مَالِكَ الْمُلْكِ تُؤْتِي الْمُلْكَ مَن تَشَاءُ وَتَنزِعُ الْمُلْكَ مِمَّن تَشَاءُ',
  ),
  // 25
  AsmaName(
    number: 25,
    arabicName: 'الْمُذِلُّ',
    englishMeaning: 'The Dishonorer',
    explanation: 'The One who abases and disgraces those who reject His signs and act arrogantly.',
    relatedVerse: 'Al-Imran 3:26',
    verseText: 'تُعِزُّ مَن تَشَاءُ وَتُذِلُّ مَن تَشَاءُ',
  ),
  // 26
  AsmaName(
    number: 26,
    arabicName: 'السَّمِيعُ',
    englishMeaning: 'The All-Hearing',
    explanation: 'The One who hears all sounds and voices, no matter how faint or hidden.',
    relatedVerse: 'Al-Baqarah 2:127',
    verseText: 'رَبَّنَا تَقَبَّلْ مِنَّا إِنَّكَ أَنتَ السَّمِيعُ الْعَلِيمُ',
  ),
  // 27
  AsmaName(
    number: 27,
    arabicName: 'الْبَصِيرُ',
    englishMeaning: 'The All-Seeing',
    explanation: 'The One who sees all things, seen and unseen. Nothing escapes His sight.',
    relatedVerse: 'Al-Imran 3:15',
    verseText: 'قُلْ أَذَٰلِكَ خَيْرٌ أَمْ جَنَّةُ الْخُلْدِ الَّتِي وُعِدَ الْمُتَّقُونَ كَانَتْ لَهُمْ جَزَاءً وَمَصِيرًا',
  ),
  // 28
  AsmaName(
    number: 28,
    arabicName: 'الْحَكَمُ',
    englishMeaning: 'The Judge',
    explanation: 'The One who judges between His creation with absolute justice and wisdom.',
    relatedVerse: 'Al-An`am 6:114',
    verseText: 'قُلْ أَغَيْرَ اللَّهِ أَبْتَغِي حَكَمًا وَهُوَ الَّذِي أَنزَلَ إِلَيْكُمُ الْكِتَابَ مُفَصَّلًا',
  ),
  // 29
  AsmaName(
    number: 29,
    arabicName: 'الْعَدْلُ',
    englishMeaning: 'The Just',
    explanation: 'The One who is perfectly just in all His decrees and judgments. He never wrongs anyone.',
    relatedVerse: 'Al-An`am 6:115',
    verseText: 'وَتَمَّتْ كَلِمَتُ رَبِّكَ صِدْقًا وَعَدْلًا لَّا مُبَدِّلَ لِكَلِمَاتِهِ',
  ),
  // 30
  AsmaName(
    number: 30,
    arabicName: 'اللَّطِيفُ',
    englishMeaning: 'The Subtle One',
    explanation: 'The One who is kind and gentle with His servants. He knows the finest details of all things.',
    relatedVerse: 'Al-An`am 6:103',
    verseText: 'لَا تُدْرِكُهُ الْأَبْصَارُ وَهُوَ يُدْرِكُ الْأَبْصَارَ وَهُوَ اللَّطِيفُ الْخَبِيرُ',
  ),
  // 31
  AsmaName(
    number: 31,
    arabicName: 'الْخَبِيرُ',
    englishMeaning: 'The All-Aware',
    explanation: 'The One who is fully aware of all things, including the innermost thoughts and intentions.',
    relatedVerse: 'Al-An`am 6:103',
    verseText: 'لَا تُدْرِكُهُ الْأَبْصَارُ وَهُوَ يُدْرِكُ الْأَبْصَارَ وَهُوَ اللَّطِيفُ الْخَبِيرُ',
  ),
  // 32
  AsmaName(
    number: 32,
    arabicName: 'الْحَلِيمُ',
    englishMeaning: 'The Forbearing',
    explanation: 'The One who is patient and does not hasten to punish. He gives time and opportunity to repent.',
    relatedVerse: 'Al-Ahqaf 46:17',
    verseText: 'رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
  ),
  // 33
  AsmaName(
    number: 33,
    arabicName: 'الْعَظِيمُ',
    englishMeaning: 'The Magnificent',
    explanation: 'The One who is greater than anything in existence. His greatness is beyond measure.',
    relatedVerse: 'Al-Baqarah 2:255',
    verseText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
  ),
  // 34
  AsmaName(
    number: 34,
    arabicName: 'الْغَفُورُ',
    englishMeaning: 'The Forgiving',
    explanation: 'The One who covers and forgives sins. His forgiveness is vast and all-encompassing.',
    relatedVerse: 'An-Nisa 4:99',
    verseText: 'فَأُولَٰئِكَ عَسَى اللَّهُ أَن يَغْفِرَ لَهُمْ وَكَانَ اللَّهُ غَفُورًا رَّحِيمًا',
  ),
  // 35
  AsmaName(
    number: 35,
    arabicName: 'الشَّكُورُ',
    englishMeaning: 'The Appreciative',
    explanation: 'The One who appreciates even the smallest good deeds and rewards them generously.',
    relatedVerse: 'An-Nisa 4:147',
    verseText: 'مَا يَفْعَلُ اللَّهُ بِعَذَابِكُمْ إِن شَكَرْتُمْ وَآمَنتُمْ وَكَانَ اللَّهُ شَكُورًا عَلِيمًا',
  ),
  // 36
  AsmaName(
    number: 36,
    arabicName: 'الْعَلِيُّ',
    englishMeaning: 'The Most High',
    explanation: 'The One who is above all creation in His essence, attributes, and rank.',
    relatedVerse: 'Al-Baqarah 2:255',
    verseText: 'وَهُوَ الْعَلِيُّ الْعَظِيمُ',
  ),
  // 37
  AsmaName(
    number: 37,
    arabicName: 'الْكَبِيرُ',
    englishMeaning: 'The Great',
    explanation: 'The One who is greater than everything. His greatness is unmatched and incomparable.',
    relatedVerse: 'Al-Ahzab 33:45',
    verseText: 'يَا أَيُّهَا النَّبِيُّ إِنَّا أَرْسَلْنَاكَ شَاهِدًا وَمُبَشِّرًا وَنَذِيرًا',
  ),
  // 38
  AsmaName(
    number: 38,
    arabicName: 'الْحَفِيظُ',
    englishMeaning: 'The Preserver',
    explanation: 'The One who preserves and guards all creation from harm and extinction.',
    relatedVerse: 'Hud 11:57',
    verseText: 'إِنِّي جَعَلْتُ اللَّهَ شَهِيدًا عَلَيَّ وَاشْهَدُوا أَنِّي بَرِيءٌ مِّمَّا تُشْرِكُونَ',
  ),
  // 39
  AsmaName(
    number: 39,
    arabicName: 'المُقِيتُ',
    englishMeaning: 'The Nourisher',
    explanation: 'The One who sustains and nourishes all creation, providing them with what they need.',
    relatedVerse: 'An-Nisa 4:85',
    verseText: 'مَن يَشْفَعْ شَفَاعَةً حَسَنَةً يَكُن لَّهُ نَصِيبٌ مِّنْهَا',
  ),
  // 40
  AsmaName(
    number: 40,
    arabicName: 'الْحَسِيبُ',
    englishMeaning: 'The Reckoner',
    explanation: 'The One who takes account of all deeds and will call everyone to account on the Day of Judgment.',
    relatedVerse: 'An-Nisa 4:6',
    verseText: 'وَاخْشَوْا اللَّهَ وَقُولُوا قَوْلًا سَدِيدًا',
  ),
  // 41
  AsmaName(
    number: 41,
    arabicName: 'الْجَلِيلُ',
    englishMeaning: 'The Majestic',
    explanation: 'The One who possesses great majesty, glory, and splendor.',
    relatedVerse: 'Ar-Rahman 55:27',
    verseText: 'وَيَبْقَىٰ وَجْهُ رَبِّكَ ذُو الْجَلَالِ وَالْإِكْرَامِ',
  ),
  // 42
  AsmaName(
    number: 42,
    arabicName: 'الْكَرِيمُ',
    englishMeaning: 'The Generous',
    explanation: 'The One who is most generous, giving without limit and without expectation of return.',
    relatedVerse: 'An-Naml 27:40',
    verseText: 'قَالَ الَّذِي عِندَهُ عِلْمٌ مِّنَ الْكِتَابِ أَنَا آتِيكَ بِهِ قَبْلَ أَن يَرْتَدَّ إِلَيْكَ طَرْفُكَ',
  ),
  // 43
  AsmaName(
    number: 43,
    arabicName: 'الرَّقِيبُ',
    englishMeaning: 'The Watchful',
    explanation: 'The One who watches over all creation and nothing escapes His observation.',
    relatedVerse: 'Al-Ahzab 33:52',
    verseText: 'لَّسْتَنَّ مِنْ أَزْوَاجِهِنَّ وَلَئِنِ اسْتَعْجَلْتَ بِهَا فَإِنَّ مَوْعِدَهَا الْآخِرَةُ',
  ),
  // 44
  AsmaName(
    number: 44,
    arabicName: 'الْمُجِيبُ',
    englishMeaning: 'The Responder',
    explanation: 'The One who responds to the prayers and calls of His servants when they call upon Him.',
    relatedVerse: 'Al-Baqarah 2:186',
    verseText: 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ',
  ),
  // 45
  AsmaName(
    number: 45,
    arabicName: 'الْوَاسِعُ',
    englishMeaning: 'The Vast',
    explanation: 'The One whose mercy, knowledge, and power are vast and limitless.',
    relatedVerse: 'Al-Baqarah 2:261',
    verseText: 'وَاللَّهُ وَاسِعٌ عَلِيمٌ',
  ),
  // 46
  AsmaName(
    number: 46,
    arabicName: 'الْحَكِيمُ',
    englishMeaning: 'The Wise',
    explanation: 'The One who possesses perfect wisdom in all His actions, decrees, and laws.',
    relatedVerse: 'Al-Baqarah 2:129',
    verseText: 'رَبَّنَا وَابْعَثْ فِيهِمْ رَسُولًا مِّنْهُمْ يَتْلُو عَلَيْهِمْ آيَاتِكَ وَيُعَلِّمُهُمُ الْكِتَابَ وَالْحِكْمَةَ',
  ),
  // 47
  AsmaName(
    number: 47,
    arabicName: 'الْوَدُودُ',
    englishMeaning: 'The Most Loving',
    explanation: 'The One who loves His good servants and is loved by them. His love is pure and eternal.',
    relatedVerse: 'Hud 11:90',
    verseText: 'وَاسْتَغْفِرُوا رَبَّكُمْ ثُمَّ تُوبُوا إِلَيْهِ إِنَّ رَبِّي رَحِيمٌ وَدُودٌ',
  ),
  // 48
  AsmaName(
    number: 48,
    arabicName: 'الْمَجِيدُ',
    englishMeaning: 'The Glorious',
    explanation: 'The One who is glorious, honorable, and noble in the highest degree.',
    relatedVerse: 'Al-Buruj 85:14',
    verseText: 'هُوَ الْغَفُورُ الْوَدُودُ ذُو الْعَرْشِ الْمَجِيدُ',
  ),
  // 49
  AsmaName(
    number: 49,
    arabicName: 'الْبَاعِثُ',
    englishMeaning: 'The Resurrector',
    explanation: 'The One who will resurrect all creation on the Day of Judgment.',
    relatedVerse: 'Al-Hajj 22:7',
    verseText: 'وَأَنَّ اللَّهَ يَبْعَثُ مَن فِي الْقُبُورِ',
  ),
  // 50
  AsmaName(
    number: 50,
    arabicName: 'الشَّهِيدُ',
    englishMeaning: 'The Witness',
    explanation: 'The One who is a witness over all things. Nothing is hidden from His knowledge.',
    relatedVerse: 'An-Nisa 4:166',
    verseText: 'لَّكِنِ اللَّهُ يَشْهَدُ بِمَا أَنزَلَ إِلَيْكَ أَنزَلَهُ بِعِلْمِهِ',
  ),
  // 51
  AsmaName(
    number: 51,
    arabicName: 'الْحَقُّ',
    englishMeaning: 'The Truth',
    explanation: 'The One who is the absolute truth. His existence, divinity, and attributes are all true.',
    relatedVerse: 'Al-Hajj 22:6',
    verseText: 'ذَٰلِكَ بِأَنَّ اللَّهَ هُوَ الْحَقُّ وَأَنَّ مَا يَدْعُونَ مِن دُونِهِ هُوَ الْبَاطِلُ',
  ),
  // 52
  AsmaName(
    number: 52,
    arabicName: 'الْوَكِيلُ',
    englishMeaning: 'The Trustee',
    explanation: 'The One who is the ultimate trustee and disposer of all affairs. Sufficient for those who rely on Him.',
    relatedVerse: 'Al-Imran 3:173',
    verseText: 'الَّذِينَ قَالَ لَهُمُ النَّاسُ إِنَّ النَّاسَ قَدْ جَمَعُوا لَكُمْ فَاخْشَوْهُمْ فَزَادَهُمْ إِيمَانًا وَقَالُوا حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
  ),
  // 53
  AsmaName(
    number: 53,
    arabicName: 'الْقَوِيُّ',
    englishMeaning: 'The All-Strong',
    explanation: 'The One who possesses perfect strength and power. Nothing can weaken Him.',
    relatedVerse: 'Al-Hajj 22:40',
    verseText: 'الَّذِينَ أُخْرِجُوا مِن دِيَارِهِمْ بِغَيْرِ حَقٍّ إِلَّا أَن يَقُولُوا رَبُّنَا اللَّهُ',
  ),
  // 54
  AsmaName(
    number: 54,
    arabicName: 'الْمَتِينُ',
    englishMeaning: 'The Firm',
    explanation: 'The One who is extraordinarily strong. His power is perfect and unyielding.',
    relatedVerse: 'Adh-Dhariyat 51:58',
    verseText: 'إِنَّ اللَّهَ هُوَ الرَّزَّاقُ ذُو الْقُوَّةِ الْمَتِينُ',
  ),
  // 55
  AsmaName(
    number: 55,
    arabicName: 'الْوَلِيُّ',
    englishMeaning: 'The Protector',
    explanation: 'The One who is the protecting friend and guardian of the believers.',
    relatedVerse: 'Al-Baqarah 2:257',
    verseText: 'اللَّهُ وَلِيُّ الَّذِينَ آمَنُوا يُخْرِجُهُم مِّنَ الظُّلُمَاتِ إِلَى النُّورِ',
  ),
  // 56
  AsmaName(
    number: 56,
    arabicName: 'الْحَمِيدُ',
    englishMeaning: 'The Praiseworthy',
    explanation: 'The One who is worthy of all praise. He is praised for His perfect attributes and deeds.',
    relatedVerse: 'Ibrahim 14:1',
    verseText: 'الْحَمْدُ لِلَّهِ الَّذِي لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ',
  ),
  // 57
  AsmaName(
    number: 57,
    arabicName: 'الْمُحْصِي',
    englishMeaning: 'The Counter',
    explanation: 'The One who counts and records everything. Nothing escapes His enumeration.',
    relatedVerse: 'An-Naba 78:29',
    verseText: 'وَأَحْصَىٰ كُلَّ شَيْءٍ عَدَدًا',
  ),
  // 58
  AsmaName(
    number: 58,
    arabicName: 'الْمُبْدِئُ',
    englishMeaning: 'The Originator',
    explanation: 'The One who originated creation without any prior model or example.',
    relatedVerse: 'Al-Baqarah 2:117',
    verseText: 'بَدِيعُ السَّمَاوَاتِ وَالْأَرْضِ وَإِذَا قَضَىٰ أَمْرًا فَإِنَّمَا يَقُولُ لَهُ كُن فَيَكُونُ',
  ),
  // 59
  AsmaName(
    number: 59,
    arabicName: 'الْمُعِيدُ',
    englishMeaning: 'The Restorer',
    explanation: 'The One who will restore and repeat creation after its death on the Day of Resurrection.',
    relatedVerse: 'Al-Baqarah 2:117',
    verseText: 'بَدِيعُ السَّمَاوَاتِ وَالْأَرْضِ',
  ),
  // 60
  AsmaName(
    number: 60,
    arabicName: 'الْمُحْيِي',
    englishMeaning: 'The Giver of Life',
    explanation: 'The One who gives life to creation and will resurrect the dead.',
    relatedVerse: 'Al-Baqarah 2:285',
    verseText: 'آمَنَ الرَّسُولُ بِمَا أُنزِلَ إِلَيْهِ مِن رَّبِّهِ وَالْمُؤْمِنُونَ',
  ),
  // 61
  AsmaName(
    number: 61,
    arabicName: 'الْمُمِيتُ',
    englishMeaning: 'The Bringer of Death',
    explanation: 'The One who causes death. He is the only one who can give death to any living being.',
    relatedVerse: 'Al-A`raf 7:25',
    verseText: 'قَالَ فِيهَا تَحْيَوْنَ وَفِيهَا تَمُوتُونَ وَمِنْهَا تُخْرَجُونَ',
  ),
  // 62
  AsmaName(
    number: 62,
    arabicName: 'الْحَيُّ',
    englishMeaning: 'The Ever-Living',
    explanation: 'The One who is eternally alive and never dies. All life derives from Him.',
    relatedVerse: 'Al-Baqarah 2:255',
    verseText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
  ),
  // 63
  AsmaName(
    number: 63,
    arabicName: 'الْقَيُّومُ',
    englishMeaning: 'The Self-Sustaining',
    explanation: 'The One who sustains all of existence. He is self-subsisting and all creation depends on Him.',
    relatedVerse: 'Al-Baqarah 2:255',
    verseText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
  ),
  // 64
  AsmaName(
    number: 64,
    arabicName: 'الْوَاجِدُ',
    englishMeaning: 'The Perceiver',
    explanation: 'The One who finds and provides for all needs. Nothing is lost or absent from His knowledge.',
    relatedVerse: 'Al-Baqarah 2:130',
    verseText: 'وَمَن يَرْغَبُ عَن مِّلَّةِ إِبْرَاهِيمَ إِلَّا مَن سَفِهَ نَفْسَهُ',
  ),
  // 65
  AsmaName(
    number: 65,
    arabicName: 'الْمَاجِدُ',
    englishMeaning: 'The Illustrious',
    explanation: 'The One who is magnificent, noble, and generous in His actions and attributes.',
    relatedVerse: 'Al-Buruj 85:15',
    verseText: 'ذُو الْعَرْشِ الْمَجِيدُ',
  ),
  // 66
  AsmaName(
    number: 66,
    arabicName: 'الْوَاحِدُ',
    englishMeaning: 'The One',
    explanation: 'The One who is unique and without equal or partner in His essence, attributes, and actions.',
    relatedVerse: 'Al-Ikhlas 112:4',
    verseText: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
  ),
  // 67
  AsmaName(
    number: 67,
    arabicName: 'الصَّمَدُ',
    englishMeaning: 'The Self-Sufficient',
    explanation: 'The One who is sought by all, but He has no need of anyone. All creation depends on Him.',
    relatedVerse: 'Al-Ikhlas 112:2',
    verseText: 'اللَّهُ الصَّمَدُ',
  ),
  // 68
  AsmaName(
    number: 68,
    arabicName: 'الْقَادِرُ',
    englishMeaning: 'The All-Powerful',
    explanation: 'The One who has absolute power over all things. Nothing is beyond His ability.',
    relatedVerse: 'Al-An`am 6:65',
    verseText: 'قُلْ هُوَ الْقَادِرُ عَلَىٰ أَن يَبْعَثَ عَلَيْكُمْ عَذَابًا مِّن فَوْقِكُمْ',
  ),
  // 69
  AsmaName(
    number: 69,
    arabicName: 'الْمُقْتَدِرُ',
    englishMeaning: 'The Omnipotent',
    explanation: 'The One whose power is absolute and irresistible. He does whatever He wills.',
    relatedVerse: 'Al-Qamar 54:42',
    verseText: 'بَلِ اللَّهُ يَقْضِي بِالْحَقِّ وَهُوَ خَيْرُ الْفَاصِلِينَ',
  ),
  // 70
  AsmaName(
    number: 70,
    arabicName: 'الْمُقَدِّمُ',
    englishMeaning: 'The Advancer',
    explanation: 'The One who advances and elevates whom He wills among His creation.',
    relatedVerse: 'Al-Ra`d 13:11',
    verseText: 'لَهُ مُعَقِّبَاتٌ مِّن بَيْنِ يَدَيْهِ وَمِنْ خَلْفِهِ يَحْفَظُونَهُ مِنْ أَمْرِ اللَّهِ',
  ),
  // 71
  AsmaName(
    number: 71,
    arabicName: 'الْمُؤَخِّرُ',
    englishMeaning: 'The Delayer',
    explanation: 'The One who delays and holds back whom He wills according to His wisdom.',
    relatedVerse: 'Al-Ra`d 13:11',
    verseText: 'إِنَّ اللَّهَ لَا يُغَيِّرُ مَا بِقَوْمٍ حَتَّىٰ يُغَيِّرُوا مَا بِأَنفُسِهِمْ',
  ),
  // 72
  AsmaName(
    number: 72,
    arabicName: 'الْأَوَّلُ',
    englishMeaning: 'The First',
    explanation: 'The One who existed before everything. There is nothing before Him.',
    relatedVerse: 'Al-Hadid 57:3',
    verseText: 'هُوَ الْأَوَّلُ وَالْآخِرُ وَالظَّاهِرُ وَالْبَاطِنُ وَهُوَ بِكُلِّ شَيْءٍ عَلِيمٌ',
  ),
  // 73
  AsmaName(
    number: 73,
    arabicName: 'الْآخِرُ',
    englishMeaning: 'The Last',
    explanation: 'The One who will remain after everything. There is nothing after Him.',
    relatedVerse: 'Al-Hadid 57:3',
    verseText: 'هُوَ الْأَوَّلُ وَالْآخِرُ وَالظَّاهِرُ وَالْبَاطِنُ وَهُوَ بِكُلِّ شَيْءٍ عَلِيمٌ',
  ),
  // 74
  AsmaName(
    number: 74,
    arabicName: 'الظَّاهِرُ',
    englishMeaning: 'The Manifest',
    explanation: 'The One whose existence and signs are evident and clear throughout all creation.',
    relatedVerse: 'Al-Hadid 57:3',
    verseText: 'هُوَ الْأَوَّلُ وَالْآخِرُ وَالظَّاهِرُ وَالْبَاطِنُ',
  ),
  // 75
  AsmaName(
    number: 75,
    arabicName: 'الْبَاطِنُ',
    englishMeaning: 'The Hidden',
    explanation: 'The One whose reality is hidden and beyond the comprehension of creation.',
    relatedVerse: 'Al-Hadid 57:3',
    verseText: 'هُوَ الْأَوَّلُ وَالْآخِرُ وَالظَّاهِرُ وَالْبَاطِنُ',
  ),
  // 76
  AsmaName(
    number: 76,
    arabicName: 'الْوَالِي',
    englishMeaning: 'The Governor',
    explanation: 'The One who governs and manages all affairs of creation with perfect wisdom.',
    relatedVerse: 'An-Nisa 4:59',
    verseText: 'يَا أَيُّهَا الَّذِينَ آمَنُوا أَطِيعُوا اللَّهَ وَأَطِيعُوا الرَّسُولَ وَأُولِي الْأَمْرِ مِنكُمْ',
  ),
  // 77
  AsmaName(
    number: 77,
    arabicName: 'الْمُتَعَالِي',
    englishMeaning: 'The Most Exalted',
    explanation: 'The One who is far above any imperfection, weakness, or resemblance to creation.',
    relatedVerse: 'Ar-Ra`d 13:9',
    verseText: 'عَالِمُ الْغَيْبِ وَالشَّهَادَةِ الْكَبِيرُ الْمُتَعَالِ',
  ),
  // 78
  AsmaName(
    number: 78,
    arabicName: 'الْبَرُّ',
    englishMeaning: 'The Source of Goodness',
    explanation: 'The One who is the source of all goodness, righteousness, and benevolence.',
    relatedVerse: 'At-Tur 52:28',
    verseText: 'إِنَّا كُنَّا قَبْلُ فِي أَهْلِنَا مُشْفِقِينَ فَمَنَّ اللَّهُ عَلَيْنَا وَوَقَانَا عَذَابَ السَّمُومِ',
  ),
  // 79
  AsmaName(
    number: 79,
    arabicName: 'التَّوَّابُ',
    englishMeaning: 'The Acceptor of Repentance',
    explanation: 'The One who repeatedly accepts the repentance of His servants and turns to them with mercy.',
    relatedVerse: 'At-Tawbah 9:104',
    verseText: 'أَلَمْ يَعْلَمُوا أَنَّ اللَّهَ هُوَ يَقْبَلُ التَّوْبَةَ عَنْ عِبَادِهِ',
  ),
  // 80
  AsmaName(
    number: 80,
    arabicName: 'الْمُنْتَقِمُ',
    englishMeaning: 'The Avenger',
    explanation: 'The One who punishes the wrongdoers and takes vengeance against the oppressors.',
    relatedVerse: 'As-Sajdah 32:22',
    verseText: 'وَمَنْ يَظْلِم مِّنكُمْ نُذِقْهُ عَذَابًا كَبِيرًا',
  ),
  // 81
  AsmaName(
    number: 81,
    arabicName: 'الْعَفُوُّ',
    englishMeaning: 'The Pardoner',
    explanation: 'The One who pardons and overlooks sins, wiping them out completely.',
    relatedVerse: 'An-Nisa 4:43',
    verseText: 'إِن يَكُنْ غَنِيًّا أَوْ فَقِيرًا فَاللَّهُ أَوْلَىٰ بِهِمَا',
  ),
  // 82
  AsmaName(
    number: 82,
    arabicName: 'الرَّؤُوفُ',
    englishMeaning: 'The Kind',
    explanation: 'The One who is exceedingly kind and compassionate toward His servants.',
    relatedVerse: 'At-Tawbah 9:117',
    verseText: 'لَقَد تَابَ اللَّهُ عَلَى النَّبِيِّ وَالْمُهَاجِرِينَ وَالْأَنصَارِ',
  ),
  // 83
  AsmaName(
    number: 83,
    arabicName: 'مَالِكُ الْمُلْكُ',
    englishMeaning: 'Owner of All Sovereignty',
    explanation: 'The One who owns and controls all sovereignty, dominion, and authority.',
    relatedVerse: 'Al-Imran 3:26',
    verseText: 'قُلِ اللَّهُمَّ مَالِكَ الْمُلْكِ تُؤْتِي الْمُلْكَ مَن تَشَاءُ',
  ),
  // 84
  AsmaName(
    number: 84,
    arabicName: 'ذُو الْجَلَالِ وَالْإِكْرَامِ',
    englishMeaning: 'Lord of Majesty and Generosity',
    explanation: 'The One who possesses ultimate majesty and unparalleled generosity.',
    relatedVerse: 'Ar-Rahman 55:27',
    verseText: 'وَيَبْقَىٰ وَجْهُ رَبِّكَ ذُو الْجَلَالِ وَالْإِكْرَامِ',
  ),
  // 85
  AsmaName(
    number: 85,
    arabicName: 'الْمُقْسِطُ',
    englishMeaning: 'The Equitable',
    explanation: 'The One who is perfectly fair and just in all His decisions and judgments.',
    relatedVerse: 'Al-An`am 6:82',
    verseText: 'الَّذِينَ آمَنُوا وَلَمْ يَلْبِسُوا إِيمَانَهُم بِظُلْمٍ أُولَٰئِكَ لَهُمُ الْأَمْنُ وَهُم مُّهْتَدُونَ',
  ),
  // 86
  AsmaName(
    number: 86,
    arabicName: 'الْجَامِعُ',
    englishMeaning: 'The Gatherer',
    explanation: 'The One who will gather all creation on the Day of Judgment for accountability.',
    relatedVerse: 'Al-Imran 3:9',
    verseText: 'رَبَّنَا إِنَّكَ جَامِعُ النَّاسِ لِيَوْمٍ لَّا رَيْبَ فِيهِ',
  ),
  // 87
  AsmaName(
    number: 87,
    arabicName: 'الْغَنِيُّ',
    englishMeaning: 'The Self-Sufficient',
    explanation: 'The One who is free from all needs. All creation is in need of Him while He needs nothing.',
    relatedVerse: 'Al-Imran 3:97',
    verseText: 'وَمَن كَفَرَ فَإِنَّ اللَّهَ غَنِيٌّ عَنِ الْعَالَمِينَ',
  ),
  // 88
  AsmaName(
    number: 88,
    arabicName: 'الْمُغْنِي',
    englishMeaning: 'The Enricher',
    explanation: 'The One who enriches whom He wills from His bounty. He makes people free of want.',
    relatedVerse: 'An-Nur 24:32',
    verseText: 'وَأَنكِحُوا الْأَيَامَىٰ مِنكُمْ وَالصَّالِحِينَ مِنْ عِبَادِكُمْ وَإِمَائِكُمْ',
  ),
  // 89
  AsmaName(
    number: 89,
    arabicName: 'الْمَانِعُ',
    englishMeaning: 'The Withholder',
    explanation: 'The One who withholds harm and adversity from His servants, and withholds provisions as He wills.',
    relatedVerse: 'Al-Mu`minun 23:98',
    verseText: 'وَأَعُوذُ بِكَ رَبِّي أَن يَحْضُرُونِ',
  ),
  // 90
  AsmaName(
    number: 90,
    arabicName: 'الضَّارُّ',
    englishMeaning: 'The Distresser',
    explanation: 'The One who can cause harm and distress. All benefit and harm are in His hands.',
    relatedVerse: 'Al-An`am 6:17',
    verseText: 'وَإِن يَمْسَسْكَ اللَّهُ بِضُرٍّ فَلَا كَاشِفَ لَهُ إِلَّا هُوَ',
  ),
  // 91
  AsmaName(
    number: 91,
    arabicName: 'النَّافِعُ',
    englishMeaning: 'The Benefactor',
    explanation: 'The One who grants benefit and good to whom He wills. All good comes from Him.',
    relatedVerse: 'Al-An`am 6:17',
    verseText: 'وَإِن يَمْسَسْكَ اللَّهُ بِضُرٍّ فَلَا كَاشِفَ لَهُ إِلَّا هُوَ وَإِن يَمْسَسْكَ بِخَيْرٍ فَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
  ),
  // 92
  AsmaName(
    number: 92,
    arabicName: 'النُّورُ',
    englishMeaning: 'The Light',
    explanation: 'The One who is the light of the heavens and the earth. He guides and illuminates.',
    relatedVerse: 'An-Nur 24:35',
    verseText: 'اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ',
  ),
  // 93
  AsmaName(
    number: 93,
    arabicName: 'الْهَادِي',
    englishMeaning: 'The Guide',
    explanation: 'The One who guides His servants to the truth and the straight path.',
    relatedVerse: 'Al-Furqan 25:31',
    verseText: 'وَكَذَٰلِكَ جَعَلْنَا لِكُلِّ نَبِيٍّ عَدُوًّا شَيَاطِينَ الْإِنسِ وَالْجِنِّ',
  ),
  // 94
  AsmaName(
    number: 94,
    arabicName: 'الْبَدِيعُ',
    englishMeaning: 'The Inventor',
    explanation: 'The One who creates in ways that have no precedent and are beyond human imagination.',
    relatedVerse: 'Al-Baqarah 2:117',
    verseText: 'بَدِيعُ السَّمَاوَاتِ وَالْأَرْضِ',
  ),
  // 95
  AsmaName(
    number: 95,
    arabicName: 'الْبَاقِي',
    englishMeaning: 'The Everlasting',
    explanation: 'The One who remains and never perishes. All creation will perish but He remains forever.',
    relatedVerse: 'Ar-Rahman 55:26-27',
    verseText: 'كُلُّ مَنْ عَلَيْهَا فَانٍ وَيَبْقَىٰ وَجْهُ رَبِّكَ ذُو الْجَلَالِ وَالْإِكْرَامِ',
  ),
  // 96
  AsmaName(
    number: 96,
    arabicName: 'الْوَارِثُ',
    englishMeaning: 'The Inheritor',
    explanation: 'The One who inherits all things after their destruction. He is the ultimate heir of everything.',
    relatedVerse: 'Al-Hijr 15:23',
    verseText: 'وَإِنَّا لَنَحْنُ نُحْيِي وَنُمِيتُ وَنَحْنُ الْوَارِثُونَ',
  ),
  // 97
  AsmaName(
    number: 97,
    arabicName: 'الرَّشِيدُ',
    englishMeaning: 'The Guide to the Right Path',
    explanation: 'The One who guides and directs all creation to that which benefits them.',
    relatedVerse: 'Al-Kahf 18:17',
    verseText: 'وَتَرَى الشَّمْسَ إِذَا طَلَعَت تَّزَاوَرُ عَن كَهْفِهِمْ ذَاتَ الْيَمِينِ',
  ),
  // 98
  AsmaName(
    number: 98,
    arabicName: 'الصَّبُورُ',
    englishMeaning: 'The Patient',
    explanation: 'The One who is patient with those who disobey Him and does not hasten their punishment.',
    relatedVerse: 'Al-Imran 3:200',
    verseText: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اصْبِرُوا وَصَابِرُوا وَرَابِطُوا',
  ),
  // 99
  AsmaName(
    number: 99,
    arabicName: 'الْأَسْمَاءُ الْحُسْنَىٰ',
    englishMeaning: 'The Most Beautiful Names',
    explanation: 'Allah has the most beautiful and perfect names. The Prophet ﷺ said: "Allah has ninety-nine names, one hundred less one; whoever enumerates them will enter Paradise." (Sahih al-Bukhari)',
    relatedVerse: 'Al-A`raf 7:180',
    verseText: 'وَلِلَّهِ الْأَسْمَاءُ الْحُسْنَىٰ فَادْعُوهُ بِهَا',
  ),
];

// ── State ─────────────────────────────────────────────────────────

class AsmaState {
  final String searchQuery;
  final Set<int> favoriteIds;
  final bool showFavoritesOnly;

  const AsmaState({
    this.searchQuery = '',
    this.favoriteIds = const {},
    this.showFavoritesOnly = false,
  });

  AsmaState copyWith({
    String? searchQuery,
    Set<int>? favoriteIds,
    bool? showFavoritesOnly,
  }) {
    return AsmaState(
      searchQuery: searchQuery ?? this.searchQuery,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      showFavoritesOnly: showFavoritesOnly ?? this.showFavoritesOnly,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────────

class AsmaNotifier extends StateNotifier<AsmaState> {
  AsmaNotifier() : super(const AsmaState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleFavorite(int number) {
    final updated = Set<int>.from(state.favoriteIds);
    if (updated.contains(number)) {
      updated.remove(number);
    } else {
      updated.add(number);
    }
    state = state.copyWith(favoriteIds: updated);
  }

  void toggleShowFavorites() {
    state = state.copyWith(showFavoritesOnly: !state.showFavoritesOnly);
  }
}

// ── Providers ──────────────────────────────────────────────────────

final asmaProvider = StateNotifierProvider<AsmaNotifier, AsmaState>(
  (ref) => AsmaNotifier(),
);

final allAsmaNamesProvider = Provider<List<AsmaName>>((ref) => kAllAsmaNames);

final filteredAsmaNamesProvider = Provider<List<AsmaName>>((ref) {
  final asmaState = ref.watch(asmaProvider);
  var names = kAllAsmaNames;

  if (asmaState.showFavoritesOnly) {
    names = names
        .where((n) => asmaState.favoriteIds.contains(n.number))
        .toList();
  }

  if (asmaState.searchQuery.isNotEmpty) {
    final q = asmaState.searchQuery.toLowerCase();
    names = names.where((n) {
      return n.arabicName.contains(q) ||
          n.englishMeaning.toLowerCase().contains(q);
    }).toList();
  }

  return names;
});

final dailyNameProvider = Provider<AsmaName>((ref) {
  final now = DateTime.now();
  final dayOfYear = _dayOfYear(now);
  final index = dayOfYear % 99; // 0-98
  return kAllAsmaNames[index];
});

int _dayOfYear(DateTime date) {
  return date.difference(DateTime(date.year, 1, 1)).inDays;
}
