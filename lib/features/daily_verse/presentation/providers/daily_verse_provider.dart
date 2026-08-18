import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Model ─────────────────────────────────────────────────────────

class DailyVerseData {
 final String arabicText;
 final String englishTranslation;
 final int surahNumber;
 final String surahName;
 final int ayahNumber;

 const DailyVerseData({
 required this.arabicText,
 required this.englishTranslation,
 required this.surahNumber,
 required this.surahName,
 required this.ayahNumber,
 });
}

// ── Curated Verses (one per day cycles through these) ─────────────
// A carefully selected set of 365 verses — enough for every day of the year.
// For brevity and quality, we include 60 representative verses from across the Quran.

const List<DailyVerseData> kDailyVerses = [
 DailyVerseData(
 arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
 englishTranslation: 'In the name of Allah, the Most Merciful, the Especially Merciful. All praise is for Allah—Lord of all worlds.',
 surahNumber: 1,
 surahName: 'Al-Fatiha',
 ayahNumber: 1,
 ),
 DailyVerseData(
 arabicText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ',
 englishTranslation: 'Allah! There is no god except Him, the Ever-Living, All-Sustaining. Neither drowsiness nor sleep overtakes Him.',
 surahNumber: 2,
 surahName: 'Al-Baqarah',
 ayahNumber: 255,
 ),
 DailyVerseData(
 arabicText: 'وَإِذْ قَالَ رَبُّكَ لِلْمَلَائِكَةِ إِنِّي جَاعِلٌ فِي الْأَرْضِ خَلِيفَةً',
 englishTranslation: 'And when your Lord said to the angels, "I am going to place a successive authority on the earth."',
 surahNumber: 2,
 surahName: 'Al-Baqarah',
 ayahNumber: 30,
 ),
 DailyVerseData(
 arabicText: 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا ۝ وَيَرْزُقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ',
 englishTranslation: 'And whoever fears Allah—He will make for them a way out, and will provide for them from where they do not expect.',
 surahNumber: 65,
 surahName: 'At-Talaq',
 ayahNumber: 2,
 ),
 DailyVerseData(
 arabicText: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۝ إِنَّ مَعَ الْعُسْرِ يُسْرًا',
 englishTranslation: 'Indeed, with hardship comes ease. Indeed, with hardship comes ease.',
 surahNumber: 94,
 surahName: 'Ash-Sharh',
 ayahNumber: 5,
 ),
 DailyVerseData(
 arabicText: 'وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ',
 englishTranslation: 'And your Lord is going to give you, and you will be satisfied.',
 surahNumber: 93,
 surahName: 'Ad-Duha',
 ayahNumber: 5,
 ),
 DailyVerseData(
 arabicText: 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
 englishTranslation: 'And whoever relies upon Allah—then He is sufficient for them.',
 surahNumber: 65,
 surahName: 'At-Talaq',
 ayahNumber: 3,
 ),
 DailyVerseData(
 arabicText: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
 englishTranslation: 'Our Lord, give us good in this world and good in the Hereafter, and protect us from the punishment of the Fire.',
 surahNumber: 2,
 surahName: 'Al-Baqarah',
 ayahNumber: 201,
 ),
 DailyVerseData(
 arabicText: 'وَنَحْنُ أَقْرَبُ إِلَيْهِ مِنْ حَبْلِ الْوَرِيدِ',
 englishTranslation: 'And We are closer to him than his jugular vein.',
 surahNumber: 50,
 surahName: 'Qaf',
 ayahNumber: 16,
 ),
 DailyVerseData(
 arabicText: 'وَلَا تَهِنُوا وَلَا تَحْزَنُوا وَأَنتُمُ الْأَعْلَوْنَ إِن كُنتُم مُّؤْمِنِينَ',
 englishTranslation: 'Do not lose heart or grieve, for you will have the upper hand, if you are believers.',
 surahNumber: 3,
 surahName: 'Al-Imran',
 ayahNumber: 139,
 ),
 DailyVerseData(
 arabicText: 'قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ',
 englishTranslation: 'Say: "O My servants who have transgressed against themselves, do not despair of Allah\'s mercy."',
 surahNumber: 39,
 surahName: 'Az-Zumar',
 ayahNumber: 53,
 ),
 DailyVerseData(
 arabicText: 'إِنَّ اللَّهَ وَمَلَائِكَتَهُ يُصَلُّونَ عَلَى النَّبِيِّ ۚ يَا أَيُّهَا الَّذِينَ آمَنُوا صَلُّوا عَلَيْهِ وَسَلِّمُوا تَسْلِيمًا',
 englishTranslation: 'Indeed, Allah and His angels send blessings upon the Prophet. O you who believe, send blessings upon him and greet him with peace.',
 surahNumber: 33,
 surahName: 'Al-Ahzab',
 ayahNumber: 56,
 ),
 DailyVerseData(
 arabicText: 'وَاسْتَغْفِرُوا رَبَّكُمْ ثُمَّ تُوبُوا إِلَيْهِ',
 englishTranslation: 'And seek forgiveness of your Lord and repent to Him.',
 surahNumber: 11,
 surahName: 'Hud',
 ayahNumber: 3,
 ),
 DailyVerseData(
 arabicText: 'وَقُل رَّبِّ زِدْنِي عِلْمًا',
 englishTranslation: 'And say: "My Lord, increase me in knowledge."',
 surahNumber: 20,
 surahName: 'Ta-Ha',
 ayahNumber: 114,
 ),
 DailyVerseData(
 arabicText: 'وَمَن يُوقَ شُحَّ نَفْسِهِ فَأُولَٰئِكَ هُمُ الْمُفْلِحُونَ',
 englishTranslation: 'And whoever is protected from the stinginess of their soul—it is they who are the successful.',
 surahNumber: 59,
 surahName: 'Al-Hashr',
 ayahNumber: 9,
 ),
 DailyVerseData(
 arabicText: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
 englishTranslation: 'So remember Me; I will remember you. And be grateful to Me and do not deny Me.',
 surahNumber: 2,
 surahName: 'Al-Baqarah',
 ayahNumber: 152,
 ),
 DailyVerseData(
 arabicText: 'اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ',
 englishTranslation: 'Allah is the Light of the heavens and the earth.',
 surahNumber: 24,
 surahName: 'An-Nur',
 ayahNumber: 35,
 ),
 DailyVerseData(
 arabicText: 'وَلَقَدْ يَسَّرْنَا الْقُرْآنَ لِلذِّكْرِ فَهَلْ مِن مُّدَّكِرٍ',
 englishTranslation: 'And We have certainly made the Quran easy for remembrance, so is there any who will remember?',
 surahNumber: 54,
 surahName: 'Al-Qamar',
 ayahNumber: 17,
 ),
 DailyVerseData(
 arabicText: 'وَمَا خَلَقْتُ الْجِنَّ وَالْإِنسَ إِلَّا لِيَعْبُدُونِ',
 englishTranslation: 'And I did not create the jinn and mankind except to worship Me.',
 surahNumber: 51,
 surahName: 'Adh-Dhariyat',
 ayahNumber: 56,
 ),
 DailyVerseData(
 arabicText: 'إِنَّ الصَّلَاةَ تَنْهَىٰ عَنِ الْفَحْشَاءِ وَالْمُنكَرِ',
 englishTranslation: 'Indeed, prayer prohibits immorality and wrongdoing.',
 surahNumber: 29,
 surahName: 'Al-Ankabut',
 ayahNumber: 45,
 ),
 DailyVerseData(
 arabicText: 'وَأَحْسِنُوا ۛ إِنَّ اللَّهَ يُحِبُّ الْمُحْسِنِينَ',
 englishTranslation: 'And do good; indeed, Allah loves the doers of good.',
 surahNumber: 2,
 surahName: 'Al-Baqarah',
 ayahNumber: 195,
 ),
 DailyVerseData(
 arabicText: 'ادْعُونِي أَسْتَجِبْ لَكُمْ',
 englishTranslation: 'Call upon Me; I will respond to you.',
 surahNumber: 40,
 surahName: 'Ghafir',
 ayahNumber: 60,
 ),
 DailyVerseData(
 arabicText: 'وَلَا تَيْأَسُوا مِن رَّوْحِ اللَّهِ ۖ إِنَّهُ لَا يَيْأَسُ مِن رَّوْحِ اللَّهِ إِلَّا الْقَوْمُ الْكَافِرُونَ',
 englishTranslation: 'And do not despair of the mercy of Allah. Indeed, no one despairs of the mercy of Allah except the disbelieving people.',
 surahNumber: 12,
 surahName: 'Yusuf',
 ayahNumber: 87,
 ),
 DailyVerseData(
 arabicText: 'وَتَوَكَّلْ عَلَى الْحَيِّ الَّذِي لَا يَمُوتُ',
 englishTranslation: 'And rely upon the Ever-Living who never dies.',
 surahNumber: 25,
 surahName: 'Al-Furqan',
 ayahNumber: 58,
 ),
 DailyVerseData(
 arabicText: 'رَبِّ اشْرَحْ لِي صَدْرِي ۝ وَيَسِّرْ لِي أَمْرِي',
 englishTranslation: 'My Lord, expand for me my breast with ease and ease for me my task.',
 surahNumber: 20,
 surahName: 'Ta-Ha',
 ayahNumber: 25,
 ),
 DailyVerseData(
 arabicText: 'وَإِنَّ جَهَنَّمَ لَمَوْعِدُهُمْ أَجْمَعِينَ',
 englishTranslation: 'And indeed, Hell is the promised place for them all.',
 surahNumber: 15,
 surahName: 'Al-Hijr',
 ayahNumber: 43,
 ),
 DailyVerseData(
 arabicText: 'وَلِلَّهِ الْمَشْرِقُ وَالْمَغْرِبُ فَأَيْنَمَا تُوَلُّوا فَثَمَّ وَجْهُ اللَّهِ',
 englishTranslation: 'And to Allah belongs the east and the west. So wherever you turn, there is the Face of Allah.',
 surahNumber: 2,
 surahName: 'Al-Baqarah',
 ayahNumber: 115,
 ),
 DailyVerseData(
 arabicText: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
 englishTranslation: 'Indeed, with hardship comes ease.',
 surahNumber: 94,
 surahName: 'Ash-Sharh',
 ayahNumber: 6,
 ),
 DailyVerseData(
 arabicText: 'وَهُوَ الَّذِي جَعَلَكُمْ خَلَائِفَ الْأَرْضِ وَرَفَعَ بَعْضَكُمْ فَوْقَ بَعْضٍ دَرَجَاتٍ لِّيَبْلُوَكُمْ فِي مَا آتَاكُمْ',
 englishTranslation: 'And it is He who has made you successors upon the earth and has raised some of you in ranks over others that He may test you through what He has given you.',
 surahNumber: 6,
 surahName: 'Al-An\'am',
 ayahNumber: 165,
 ),
 DailyVerseData(
 arabicText: 'كُلُّ نَفْسٍ ذَائِقَةُ الْمَوْتِ ثُمَّ إِلَيْنَا تُرْجَعُونَ',
 englishTranslation: 'Every soul will taste death. Then to Us you will be returned.',
 surahNumber: 29,
 surahName: 'Al-Ankabut',
 ayahNumber: 57,
 ),
 DailyVerseData(
 arabicText: 'وَمَا تَدْرِي نَفْسٌ مَّاذَا تَكْسِبُ غَدًا وَمَا تَدْرِي نَفْسٌ بِأَيِّ أَرْضٍ تَمُوتُ',
 englishTranslation: 'And no soul knows what it will earn tomorrow, and no soul knows in what land it will die.',
 surahNumber: 31,
 surahName: 'Luqman',
 ayahNumber: 34,
 ),
 DailyVerseData(
 arabicText: 'إِنَّ الْإِنسَانَ لَفِي خُسْرٍ ۝ إِلَّا الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ وَتَوَاصَوْا بِالْحَقِّ وَتَوَاصَوْا بِالصَّبْرِ',
 englishTranslation: 'Indeed, mankind is in loss, except for those who believe, do righteous deeds, and advise each other to truth and patience.',
 surahNumber: 103,
 surahName: 'Al-Asr',
 ayahNumber: 1,
 ),
 
 DailyVerseData(
 arabicText: 'إِنَّمَا الْمُؤْمِنُونَ إِخْوَةٌ',
 englishTranslation: 'The believers are but brothers.',
 surahNumber: 49,
 surahName: 'Al-Hujurat',
 ayahNumber: 10,
 ),
 DailyVerseData(
 arabicText: 'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
 englishTranslation: 'Say: He is Allah, the One. Allah, the Eternal Refuge. He neither begets nor is born, nor is there to Him any equivalent.',
 surahNumber: 112,
 surahName: 'Al-Ikhlas',
 ayahNumber: 1,
 ),
 DailyVerseData(
 arabicText: 'وَنَفْسٍ وَمَا سَوَّاهَا ۝ فَأَلْهَمَهَا فُجُورَهَا وَتَقْوَاهَا ۝ قَدْ أَفْلَحَ مَن زَكَّاهَا ۝ وَقَدْ خَابَ مَن دَسَّاهَا',
 englishTranslation: 'And the soul and He who proportioned it, and inspired it with its wickedness and righteousness. He has succeeded who purifies it, and he has failed who instills it with corruption.',
 surahNumber: 91,
 surahName: 'Ash-Shams',
 ayahNumber: 7,
 ),
 DailyVerseData(
 arabicText: 'وَلَا تَسْتَوِي الْحَسَنَةُ وَلَا السَّيِّئَةُ ۚ ادْفَعْ بِالَّتِي هِيَ أَحْسَنُ',
 englishTranslation: 'And not equal are the good deed and the bad. Repel evil by that which is better.',
 surahNumber: 41,
 surahName: 'Fussilat',
 ayahNumber: 34,
 ),
 DailyVerseData(
 arabicText: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا',
 englishTranslation: 'Allah does not burden a soul beyond that it can bear.',
 surahNumber: 2,
 surahName: 'Al-Baqarah',
 ayahNumber: 286,
 ),
 DailyVerseData(
 arabicText: 'فَإِنَّ مَعَ الصَّبْرِ صَبْرًا',
 englishTranslation: 'Indeed, with hardship comes ease.',
 surahNumber: 2,
 surahName: 'Al-Baqarah',
 ayahNumber: 155,
 ),
 DailyVerseData(
 arabicText: 'حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ',
 englishTranslation: 'Guard strictly the prayers, especially the middle prayer.',
 surahNumber: 2,
 surahName: 'Al-Baqarah',
 ayahNumber: 238,
 ),
 DailyVerseData(
 arabicText: 'وَاصْبِرْ فَإِنَّ اللَّهَ لَا يُضِيعُ أَجْرَ الْمُحْسِنِينَ',
 englishTranslation: 'And be patient, for indeed, Allah does not allow to be lost the reward of those who do good.',
 surahNumber: 11,
 surahName: 'Hud',
 ayahNumber: 115,
 ),
 DailyVerseData(
 arabicText: 'إِنَّ رَبِّي لَسَمِيعُ الدُّعَاءِ',
 englishTranslation: 'Indeed, my Lord is near and responsive.',
 surahNumber: 11,
 surahName: 'Hud',
 ayahNumber: 61,
 ),
 DailyVerseData(
 arabicText: 'وَأَلْقِ عَصَاكَ ۖ فَلَمَّا رَآهَا تَهْتَزُّ كَأَنَّهَا جَانٌّ وَلَّىٰ مُدْبِرًا وَلَمْ يُعَقِّبْ',
 englishTranslation: 'And throw down your staff. But when he saw it writhing as if it were a snake, he turned in flight and did not return.',
 surahNumber: 28,
 surahName: 'Al-Qasas',
 ayahNumber: 31,
 ),
 DailyVerseData(
 arabicText: 'وَلَقَدْ كَرَّمْنَا بَنِي آدَمَ',
 englishTranslation: 'And We have certainly honored the children of Adam.',
 surahNumber: 17,
 surahName: 'Al-Isra',
 ayahNumber: 70,
 ),
 DailyVerseData(
 arabicText: 'وَقُل رَّبِّ أَعُوذُ بِكَ مِنْ هَمَزَاتِ الشَّيَاطِينِ',
 englishTranslation: 'And say: "My Lord, I seek refuge in You from the incitements of the devils."',
 surahNumber: 23,
 surahName: 'Al-Mu\'minun',
 ayahNumber: 97,
 ),
 DailyVerseData(
 arabicText: 'إِنَّ الَّذِينَ قَالُوا رَبُّنَا اللَّهُ ثُمَّ اسْتَقَامُوا',
 englishTranslation: 'Indeed, those who have said, "Our Lord is Allah," and then remained on a right course—the angels will descend upon them.',
 surahNumber: 41,
 surahName: 'Fussilat',
 ayahNumber: 30,
 ),
 DailyVerseData(
 arabicText: 'وَسَارِعُوا إِلَىٰ مَغْفِرَةٍ مِّن رَّبِّكُمْ وَجَنَّةٍ عَرْضُهَا السَّمَاوَاتُ وَالْأَرْضُ أُعِدَّتْ لِلْمُتَّقِينَ',
 englishTranslation: 'And hasten to forgiveness from your Lord and a garden as wide as the heavens and earth, prepared for the righteous.',
 surahNumber: 3,
 surahName: 'Al-Imran',
 ayahNumber: 133,
 ),
 DailyVerseData(
 arabicText: 'إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا',
 englishTranslation: 'Indeed, prayer has been decreed upon the believers at specified times.',
 surahNumber: 4,
 surahName: 'An-Nisa',
 ayahNumber: 103,
 ),
 DailyVerseData(
 arabicText: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اتَّقُوا اللَّهَ وَقُولُوا قَوْلًا سَدِيدًا',
 englishTranslation: 'O you who have believed, fear Allah and speak words of appropriate justice.',
 surahNumber: 33,
 surahName: 'Al-Ahzab',
 ayahNumber: 70,
 ),
 DailyVerseData(
 arabicText: 'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ',
 englishTranslation: 'This is the Book about which there is no doubt, a guidance for those conscious of Allah.',
 surahNumber: 2,
 surahName: 'Al-Baqarah',
 ayahNumber: 2,
 ),
 DailyVerseData(
 arabicText: 'شَهْرُ رَمَضَانَ الَّذِي أُنزِلَ فِيهِ الْقُرْآنُ هُدًى لِّلنَّاسِ وَبَيِّنَاتٍ مِّنَ الْهُدَىٰ وَالْفُرْقَانِ',
 englishTranslation: 'The month of Ramadan in which the Quran was revealed, a guidance for the people and clear proofs of guidance and criterion.',
 surahNumber: 2,
 surahName: 'Al-Baqarah',
 ayahNumber: 185,
 ),
 DailyVerseData(
 arabicText: 'هُوَ اللَّهُ الَّذِي لَا إِلَٰهَ إِلَّا هُوَ ۖ عَالِمُ الْغَيْبِ وَالشَّهَادَةِ',
 englishTranslation: 'He is Allah, other than whom there is no deity, Knower of the unseen and the witnessed.',
 surahNumber: 59,
 surahName: 'Al-Hashr',
 ayahNumber: 22,
 ),
 DailyVerseData(
 arabicText: 'وَلَا تَيْأَسُوا مِن رَّوْحِ اللَّهِ',
 englishTranslation: 'And do not despair of the mercy of Allah.',
 surahNumber: 12,
 surahName: 'Yusuf',
 ayahNumber: 87,
 ),
 DailyVerseData(
 arabicText: 'وَلِلَّهِ غَيْبُ السَّمَاوَاتِ وَالْأَرْضِ وَإِلَيْهِ يُرْجَعُ الْأَمْرُ كُلُّهُ',
 englishTranslation: 'And to Allah belongs the unseen of the heavens and the earth, and to Him will be returned all matters.',
 surahNumber: 11,
 surahName: 'Hud',
 ayahNumber: 123,
 ),
 DailyVerseData(
 arabicText: 'إِنَّ رَحْمَتَ اللَّهِ قَرِيبٌ مِّنَ الْمُحْسِنِينَ',
 englishTranslation: 'Indeed, the mercy of Allah is near to the doers of good.',
 surahNumber: 7,
 surahName: 'Al-A\'raf',
 ayahNumber: 56,
 ),
 DailyVerseData(
 arabicText: 'وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ',
 englishTranslation: 'And my success is not but through Allah.',
 surahNumber: 11,
 surahName: 'Hud',
 ayahNumber: 88,
 ),
 DailyVerseData(
 arabicText: 'قُلْ سَوًىٰ عَلَيْهِمْ ۖ أَأَنذَرْتَهُمْ أَمْ لَمْ تُنذِرْهُمْ لَا يُؤْمِنُونَ',
 englishTranslation: 'Whether you warn them or do not warn them, it is the same for them; they will not believe.',
 surahNumber: 2,
 surahName: 'Al-Baqarah',
 ayahNumber: 6,
 ),
 DailyVerseData(
 arabicText: 'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ',
 englishTranslation: 'And when My servants ask you concerning Me, indeed I am near.',
 surahNumber: 2,
 surahName: 'Al-Baqarah',
 ayahNumber: 186,
 ),
 DailyVerseData(
 arabicText: 'وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ',
 englishTranslation: 'And your Lord is going to give you, and you will be satisfied.',
 surahNumber: 93,
 surahName: 'Ad-Duha',
 ayahNumber: 5,
 ),
 DailyVerseData(
 arabicText: 'وَأَطِيعُوا اللَّهَ وَالرَّسُولَ لَعَلَّكُمْ تُرْحَمُونَ',
 englishTranslation: 'And obey Allah and the Messenger that you may obtain mercy.',
 surahNumber: 3,
 surahName: 'Al-Imran',
 ayahNumber: 132,
 ),
 DailyVerseData(
 arabicText: 'إِنَّا كُلَّ شَيْءٍ خَلَقْنَاهُ بِقَدَرٍ',
 englishTranslation: 'Indeed, all things We created with predestination.',
 surahNumber: 54,
 surahName: 'Al-Qamar',
 ayahNumber: 49,
 ),
 DailyVerseData(
 arabicText: 'قَالَ رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
 englishTranslation: 'He said: "My Lord, expand for me my breast with ease and ease for me my task."',
 surahNumber: 20,
 surahName: 'Ta-Ha',
 ayahNumber: 25,
 ),
 DailyVerseData(
 arabicText: 'إِنَّ فِي خَلْقِ السَّمَاوَاتِ وَالْأَرْضِ وَاخْتِلَافِ اللَّيْلِ وَالنَّهَارِ لَآيَاتٍ لِّأُولِي الْأَلْبَابِ',
 englishTranslation: 'Indeed, in the creation of the heavens and the earth and the alternation of the night and day are signs for those of understanding.',
 surahNumber: 3,
 surahName: 'Al-Imran',
 ayahNumber: 190,
 ),
 DailyVerseData(
 arabicText: 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا',
 englishTranslation: 'Our Lord, let not our hearts deviate after You have guided us.',
 surahNumber: 3,
 surahName: 'Al-Imran',
 ayahNumber: 8,
 ),
 DailyVerseData(
 arabicText: 'تَبَارَكَ الَّذِي بِيَدِهِ الْمُلْكُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
 englishTranslation: 'Blessed is He in whose hand is the dominion, and He is over all things competent.',
 surahNumber: 67,
 surahName: 'Al-Mulk',
 ayahNumber: 1,
 ),
 DailyVerseData(
 arabicText: 'الَّذِينَ يَذْكُرُونَ اللَّهَ قِيَامًا وَقُعُودًا وَعَلَىٰ جُنُوبِهِمْ',
 englishTranslation: 'Those who remember Allah while standing, sitting, and lying on their sides.',
 surahNumber: 3,
 surahName: 'Al-Imran',
 ayahNumber: 191,
 ),
];

// ── Provider ──────────────────────────────────────────────────────

final dailyVerseProvider = Provider<((DailyVerseData, DateTime), DailyVerseData)>((ref) {
 final now = DateTime.now();
 final today = DateTime(now.year, now.month, now.day);
 final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
 final index = dayOfYear % kDailyVerses.length;
 final verse = kDailyVerses[index];
 return ((verse, today), verse);
});

final todayVerseProvider = Provider<DailyVerseData>((ref) {
 return ref.watch(dailyVerseProvider).$2;
});

final todayDateProvider = Provider<DateTime>((ref) {
 return ref.watch(dailyVerseProvider).$1.$2;
});

final verseDayIndexProvider = Provider<int>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
  return dayOfYear % kDailyVerses.length;
});
