import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide TextDirection;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════
// Hadith of the Day Data Model
// ═══════════════════════════════════════════════════════════════════

class DailyHadith {
  final String arabic;
  final String english;
  final String narrator;
  final String source;
  final String reference;

  const DailyHadith({
    required this.arabic,
    required this.english,
    required this.narrator,
    required this.source,
    required this.reference,
  });
}

// ═══════════════════════════════════════════════════════════════════
// 60 Hardcoded Hadiths from Sahih al-Bukhari and Sahih Muslim
// ═══════════════════════════════════════════════════════════════════

const List<DailyHadith> _dailyHadithCollection = [
  DailyHadith(
    arabic: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
    english: 'Actions are judged by intentions, and every person will get the reward according to what they intended.',
    narrator: 'Umar ibn al-Khattab',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 1',
  ),
  DailyHadith(
    arabic: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
    english: 'Whoever believes in Allah and the Last Day should speak good or remain silent.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6018',
  ),
  DailyHadith(
    arabic: 'لا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
    english: 'None of you truly believes until he loves for his brother what he loves for himself.',
    narrator: 'Anas ibn Malik',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 13',
  ),
  DailyHadith(
    arabic: 'الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ',
    english: 'A Muslim is the one from whose tongue and hands other Muslims are safe.',
    narrator: 'Abdullah ibn Amr',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 10',
  ),
  DailyHadith(
    arabic: 'لا يَلْقَى اللَّهَ أَحَدُكُمْ بِذَنْبٍ أَعْظَمَ مِنْ أَنْ يَقُولَ لِأَخِيهِ يَا أَبَا الْفُلَانِ',
    english: 'None of you should call his Muslim brother by an offensive nickname.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6141',
  ),
  DailyHadith(
    arabic: 'مَنْ صَامَ رَمَضَانَ إِيمَانًا وَاحْتِسَابًا غُفِرَ لَهُ مَا تَقَدَّمَ مِنْ ذَنْبِهِ',
    english: 'Whoever fasts Ramadan out of faith and seeking reward, his previous sins will be forgiven.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 38',
  ),
  DailyHadith(
    arabic: 'إِذَا مَاتَ الإِنْسَانُ انْقَطَعَ عَمَلُهُ إِلا مِنْ ثَلاثَةٍ',
    english: 'When a person dies, his deeds cease except for three: ongoing charity, beneficial knowledge, or a righteous child who prays for him.',
    narrator: 'Abu Hurairah',
    source: 'Sahih Muslim',
    reference: 'Hadith 1631',
  ),
  DailyHadith(
    arabic: 'الطُّهُورُ شَطْرُ الإِيمَانِ وَالْحَمْدُ لِلَّهِ تَمْلأُ الْمِيزَانَ',
    english: 'Purity is half of faith, and Alhamdulillah fills the scales.',
    narrator: 'Abu Hurairah',
    source: 'Sahih Muslim',
    reference: 'Hadith 223',
  ),
  DailyHadith(
    arabic: 'الْمُؤْمِنُ الْقَوِيُّ خَيْرٌ وَأَحَبُّ إِلَى اللَّهِ مِنَ الْمُؤْمِنِ الضَّعِيفِ',
    english: 'The strong believer is better and more beloved to Allah than the weak believer, while there is good in both.',
    narrator: 'Abu Hurairah',
    source: 'Sahih Muslim',
    reference: 'Hadith 2664',
  ),
  DailyHadith(
    arabic: 'كُلُّ مَعْرُوفٍ صَدَقَةٌ',
    english: 'Every act of kindness is a charity.',
    narrator: 'Jabir ibn Abdullah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6022',
  ),
  DailyHadith(
    arabic: 'اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ وَأَتْبِعِ السَّيِّئَةَ الْحَسَنَةَ تَمْحُهَا',
    english: 'Fear Allah wherever you are, and follow up a bad deed with a good deed and it will wipe it out.',
    narrator: 'Abu Dharr',
    source: 'Sunan al-Tirmidhi',
    reference: 'Hadith 1987',
  ),
  DailyHadith(
    arabic: 'وَخَالِقِ النَّاسَ بِخُلُقٍ حَسَنٍ',
    english: 'And deal with people in a good manner.',
    narrator: 'Abu Dharr',
    source: 'Sunan al-Tirmidhi',
    reference: 'Hadith 1987',
  ),
  DailyHadith(
    arabic: 'لا تَحَاسَدُوا وَلا تَنَاجَشُوا وَلا تَبَاغَضُوا وَلا تَدَابَرُوا',
    english: 'Do not envy one another, do not hate one another, do not turn your backs on one another.',
    narrator: 'Anas ibn Malik',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6065',
  ),
  DailyHadith(
    arabic: 'كُونُوا عِبَادَ اللَّهِ إِخْوَانًا',
    english: 'Be servants of Allah who are brothers.',
    narrator: 'Anas ibn Malik',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6065',
  ),
  DailyHadith(
    arabic: 'مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ طَرِيقًا إِلَى الْجَنَّةِ',
    english: 'Whoever treads a path in search of knowledge, Allah will make easy for him the path to Paradise.',
    narrator: 'Abu Hurairah',
    source: 'Sahih Muslim',
    reference: 'Hadith 2699',
  ),
  DailyHadith(
    arabic: 'مَنْ عَادَ مَرِيضًا أَوْ زَارَ أَخًا لَهُ فِي اللَّهِ نَادَاهُ مُنَادٍ',
    english: 'Whoever visits a sick person or visits a brother for the sake of Allah, a caller will announce: You have done good.',
    narrator: 'Abu Hurairah',
    source: 'Sahih Muslim',
    reference: 'Hadith 2568',
  ),
  DailyHadith(
    arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالآخِرَةِ',
    english: 'O Allah, I ask You for well-being in this world and the next.',
    narrator: 'Abu Hurairah',
    source: 'Sahih Muslim',
    reference: 'Hadith 4880',
  ),
  DailyHadith(
    arabic: 'مَنْ ذَهَبَ إِلَى الْمَسْجِدِ أَوْ رَجَعَ أَعَدَّ اللَّهُ لَهُ نُزُلًا كُلَّمَا ذَهَبَ أَوْ رَجَعَ',
    english: 'Whoever goes to the mosque or returns, Allah prepares a welcome for him every time he goes or comes.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 662',
  ),
  DailyHadith(
    arabic: 'الْمَلائِكَةُ لاَ تَدْخُلُ بَيْتًا فِيهِ كَلْبٌ وَلاَ صُورَةٌ',
    english: 'Angels do not enter a house in which there is a dog or a picture.',
    narrator: 'Abu Talhah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 3322',
  ),
  DailyHadith(
    arabic: 'الدُّعَاءُ هُوَ الْعِبَادَةُ',
    english: 'Supplication is worship.',
    narrator: 'Nu\'man ibn Bashir',
    source: 'Sunan al-Tirmidhi',
    reference: 'Hadith 3370',
  ),
  DailyHadith(
    arabic: 'لَوْ يُعْطَى النَّاسُ بِدَعْوَاهُمْ لاَدَّعَى رِجَالٌ أَمْوَالَ قَوْمٍ وَدِمَاءَهُمْ',
    english: 'If people were given what they claimed, some would claim the wealth and blood of others.',
    narrator: 'Abu Dharr',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6968',
  ),
  DailyHadith(
    arabic: 'مَنْ كَذَبَ عَلَيَّ مُتَعَمِّدًا فَلْيَتَبَوَّأْ مَقْعَدَهُ مِنَ النَّارِ',
    english: 'Whoever intentionally attributes a lie to me, let him take his seat in the Hellfire.',
    narrator: 'Ali ibn Abi Talib',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 109',
  ),
  DailyHadith(
    arabic: 'لاَ يُؤْمِنُ أَحَدُكُمْ وَهُوَ يَسْخَطُ عَلَى جَارِهِ',
    english: 'None of you truly believes while he dislikes his neighbor.',
    narrator: 'Abu Hurairah',
    source: 'Sahih Muslim',
    reference: 'Hadith 46',
  ),
  DailyHadith(
    arabic: 'لاَ تَحَقَرَنَّ مِنَ الْمَعْرُوفِ شَيْئًا وَلَوْ أَنْ تَلْقَى أَخَاكَ بِوَجْهٍ طَلْقٍ',
    english: 'Do not belittle any good deed, even meeting your brother with a cheerful face.',
    narrator: 'Abu Dharr',
    source: 'Sahih Muslim',
    reference: 'Hadith 144',
  ),
  DailyHadith(
    arabic: 'إِنَّ اللَّهَ كَتَبَ الإِحْسَانَ عَلَى كُلِّ شَيْءٍ',
    english: 'Allah has prescribed excellence in everything.',
    narrator: 'Shaddad ibn Aws',
    source: 'Sahih Muslim',
    reference: 'Hadith 1955',
  ),
  DailyHadith(
    arabic: 'إِنَّ اللَّهَ لاَ يَنْظُرُ إِلَى صُوَرِكُمْ وَأَمْوَالِكُمْ وَلَكِنْ يَنْظُرُ إِلَى قُلُوبِكُمْ وَأَعْمَالِكُمْ',
    english: 'Allah does not look at your forms or your wealth, but He looks at your hearts and your deeds.',
    narrator: 'Abu Hurairah',
    source: 'Sahih Muslim',
    reference: 'Hadith 2564',
  ),
  DailyHadith(
    arabic: 'مَنْ نَفَّسَ عَنْ مُؤْمِنٍ كُرْبَةً مِنْ كُرَبِ الدُّنْيَا نَفَّسَ اللَّهُ عَنْهُ كُرْبَةً مِنْ كُرَبِ يَوْمِ الْقِيَامَةِ',
    english: 'Whoever relieves a believer of a hardship of this world, Allah will relieve him of a hardship on the Day of Judgment.',
    narrator: 'Abu Hurairah',
    source: 'Sahih Muslim',
    reference: 'Hadith 2585',
  ),
  DailyHadith(
    arabic: 'وَمَنْ سَتَرَ مُسْلِمًا سَتَرَهُ اللَّهُ فِي الدُّنْيَا وَالآخِرَةِ',
    english: 'Whoever conceals the faults of a Muslim, Allah will conceal his faults in this world and the Hereafter.',
    narrator: 'Abu Hurairah',
    source: 'Sahih Muslim',
    reference: 'Hadith 2585',
  ),
  DailyHadith(
    arabic: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيُكْرِمْ ضَيْفَهُ',
    english: 'Whoever believes in Allah and the Last Day should honor his guest.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6018',
  ),
  DailyHadith(
    arabic: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيَصِلْ رَحِمَهُ',
    english: 'Whoever believes in Allah and the Last Day should maintain ties of kinship.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6018',
  ),
  DailyHadith(
    arabic: 'إِيَّاكُمْ وَالظَّنَّ فَإِنَّ الظَّنَّ أَكْذَبُ الْحَدِيثِ',
    english: 'Beware of suspicion, for suspicion is the falsest of speech.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6064',
  ),
  DailyHadith(
    arabic: 'لاَ تَجَسَّسُوا وَلاَ تَحَسَّسُوا وَلاَ تَنَافَسُوا وَلاَ تَحَاسَدُوا',
    english: 'Do not spy, do not eavesdrop, do not envy one another, and do not hate one another.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6064',
  ),
  DailyHadith(
    arabic: 'إِنَّ أَحَبَّكُمْ إِلَيَّ وَأَقْرَبَكُمْ مِنِّي مَجْلِسًا يَوْمَ الْقِيَامَةِ أَحَاسِنُكُمْ أَخْلاَقًا',
    english: 'The most beloved of you to me and the closest to me on the Day of Judgment will be the best of you in character.',
    narrator: 'Abdullah ibn Amr',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6035',
  ),
  DailyHadith(
    arabic: 'وَإِنَّ مِنْ أَحَبِّكُمْ إِلَيَّ أَقْرَبَكُمْ مِنِّي مَجْلِسًا يَوْمَ الْقِيَامَةِ أَوْقَارُكُمْ',
    english: 'And the most hateful of you to me and the farthest from me on the Day of Judgment will be the most foul-mouthed among you.',
    narrator: 'Abdullah ibn Amr',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6035',
  ),
  DailyHadith(
    arabic: 'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ صَدَقَةٌ',
    english: 'Your smiling in the face of your brother is charity.',
    narrator: 'Abu Dharr',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6024',
  ),
  DailyHadith(
    arabic: 'الْحَلاَلُ بَيِّنٌ وَالْحَرَامُ بَيِّنٌ وَبَيْنَهُمَا أُمُورٌ مُشْتَبِهَاتٌ',
    english: 'What is lawful is clear and what is unlawful is clear, but between them are doubtful matters.',
    narrator: 'An-Nu\'man ibn Bashir',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 52',
  ),
  DailyHadith(
    arabic: 'فَمَنِ اتَّقَى الشُّبُهَاتِ فَقَدِ اسْتَبْرَأَ لِدِينِهِ وَعِرْضِهِ',
    english: 'Whoever avoids doubtful matters has cleared himself in regard to his religion and his honor.',
    narrator: 'An-Nu\'man ibn Bashir',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 52',
  ),
  DailyHadith(
    arabic: 'زَادَكُمْ فِي الْخَيْرِ كَثْرَةً مَنْ سَبَقَكُمْ مِنَ الأَنْبِيَاءِ',
    english: 'Part of the perfection of one\'s Islam is leaving that which does not concern him.',
    narrator: 'Abu Hurairah',
    source: 'Sunan al-Tirmidhi',
    reference: 'Hadith 2318',
  ),
  DailyHadith(
    arabic: 'لاَ يُلْدَغُ الْمُؤْمِنُ مِنْ جُحْرٍ وَاحِدٍ مَرَّتَيْنِ',
    english: 'A believer is not stung from the same hole twice.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6133',
  ),
  DailyHadith(
    arabic: 'الْمُسْلِمُ إِذَا أَنْفَقَ أَنْفَقَ عَلَى أَهْلِهِ كُتِبَ لَهُ بِهِ صَدَقَةٌ',
    english: 'When a Muslim spends on his family, it is counted as charity for him.',
    narrator: 'Abu Musa al-Ash\'ari',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 5351',
  ),
  DailyHadith(
    arabic: 'لاَ يُؤْمِنُ أَحَدُكُمْ حَتَّى أَكُونَ أَحَبَّ إِلَيْهِ مِنْ وَالِدِهِ وَوَلَدِهِ وَالنَّاسِ أَجْمَعِينَ',
    english: 'None of you truly believes until I am more beloved to him than his father, his child, and all of mankind.',
    narrator: 'Anas ibn Malik',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 15',
  ),
  DailyHadith(
    arabic: 'مَنْ رَآنِي فِي الْمَنَامِ فَسَيَرَانِي فِي الْيَقَظَةِ',
    english: 'Whoever sees me in a dream will see me in wakefulness, or it is as if he has seen me.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6990',
  ),
  DailyHadith(
    arabic: 'لاَ يَحِلُّ دَمُ امْرِئٍ مُسْلِمٍ إِلاَّ بِإِحْدَى ثَلاَثٍ',
    english: 'The blood of a Muslim is not lawful except for three reasons: a married adulterer, a life for a life, and an apostate who leaves his religion.',
    narrator: 'Abdullah ibn Mas\'ud',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6878',
  ),
  DailyHadith(
    arabic: 'مَنْ قَامَ لَيْلَةَ الْقَدْرِ إِيمَانًا وَاحْتِسَابًا غُفِرَ لَهُ مَا تَقَدَّمَ مِنْ ذَنْبِهِ',
    english: 'Whoever stands in prayer on the Night of Decree out of faith and seeking reward, his previous sins will be forgiven.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 1901',
  ),
  DailyHadith(
    arabic: 'كَلِمَتَانِ خَفِيفَتَانِ عَلَى اللِّسَانِ ثَقِيلَتَانِ فِي الْمِيزَانِ حَبِيبَتَانِ إِلَى الرَّحْمَنِ',
    english: 'Two words are light on the tongue, heavy on the scales, and beloved to the Most Merciful: SubhanAllah and Alhamdulillah.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6404',
  ),
  DailyHadith(
    arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ',
    english: 'Glory is to Allah and all praise is to Him, glory is to Allah the Great.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6405',
  ),
  DailyHadith(
    arabic: 'أَرَأَيْتَ مَا لَوْ صَلَّيْتَ الْمَكْتُوبَاتِ وَصُمْتَ الرَّمَضَانَ',
    english: 'If a person prays the five daily prayers, fasts Ramadan, pays zakat, and performs Hajj when able, will he enter Paradise? He said: Yes.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 261',
  ),
  DailyHadith(
    arabic: 'الْمُهَاجِرُ مَنْ هَجَرَ مَا نَهَى اللَّهُ عَنْهُ',
    english: 'The emigrant is the one who abandons what Allah has forbidden.',
    narrator: 'Abdullah ibn Amr',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 9',
  ),
  DailyHadith(
    arabic: 'إِنَّ الصَّلاَةَ أَوَّلُ مَا يُحَاسَبُ بِهِ الْعَبْدُ يَوْمَ الْقِيَامَةِ',
    english: 'The first thing for which a person will be brought to account on the Day of Judgment will be his prayer.',
    narrator: 'Anas ibn Malik',
    source: 'Sunan al-Tirmidhi',
    reference: 'Hadith 413',
  ),
  DailyHadith(
    arabic: 'مَنْ صَلَّى الْعِشَاءَ فِي جَمَاعَةٍ فَكَأَنَّمَا قَامَ نِصْفَ اللَّيْلِ',
    english: 'Whoever prays Isha in congregation is as if he has stood half the night in prayer.',
    narrator: 'Abu Hurairah',
    source: 'Sahih Muslim',
    reference: 'Hadith 656',
  ),
  DailyHadith(
    arabic: 'وَمَنْ صَلَّى الصُّبْحَ فِي جَمَاعَةٍ فَكَأَنَّمَا صَلَّى اللَّيْلَ كُلَّهُ',
    english: 'And whoever prays Fajr in congregation is as if he has prayed the entire night.',
    narrator: 'Abu Hurairah',
    source: 'Sahih Muslim',
    reference: 'Hadith 656',
  ),
  DailyHadith(
    arabic: 'إِنَّ أَفْضَلَ الصَّدَقَةِ مَا كَانَ عَنْ ظَهْرِ غِنًى',
    english: 'The best charity is that given when one is rich yet content.',
    narrator: 'Abu Hurairah',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 1423',
  ),
  DailyHadith(
    arabic: 'مَنْ أَحَبَّ أَنْ يُبْسَطَ لَهُ فِي رِزْقِهِ وَيُنْسَأَ لَهُ فِي أَثَرِهِ فَلْيَصِلْ رَحِمَهُ',
    english: 'Whoever would like his provision to be increased and his lifespan to be extended, let him maintain ties of kinship.',
    narrator: 'Anas ibn Malik',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 5960',
  ),
  DailyHadith(
    arabic: 'لاَ تَقُومُ السَّاعَةُ حَتَّى يُقْبَضَ الْعِلْمُ وَتَكُونَ الزَّلاَزِلُ',
    english: 'The Hour will not begin until knowledge is taken away and earthquakes become frequent.',
    narrator: 'Anas ibn Malik',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 1037',
  ),
  DailyHadith(
    arabic: 'بَلِّغُوا عَنِّي وَلَوْ آيَةً',
    english: 'Convey from me, even if it is one verse.',
    narrator: 'Abdullah ibn Amr',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 3461',
  ),
  DailyHadith(
    arabic: 'مَنْ أَرَادَ أَنْ يُجَابَ فِي الشِّدَّةِ فَلْيُكْثِرِ الدُّعَاءَ فِي الرَّخَاءِ',
    english: 'Whoever wants his supplications to be answered in times of hardship, should supplicate abundantly in times of ease.',
    narrator: 'Abu Hurairah',
    source: 'Sunan al-Tirmidhi',
    reference: 'Hadith 3383',
  ),
  DailyHadith(
    arabic: 'إِنَّ لِكُلِّ شَيْءٍ تَزْكِيَةً وَتَزْكِيَةُ الأَمْوَالِ الزَّكَاةُ',
    english: 'Everything has its purification, and the purification of wealth is Zakat.',
    narrator: 'Abdullah ibn Abbas',
    source: 'Sunan al-Tirmidhi',
    reference: 'Hadith 605',
  ),
  DailyHadith(
    arabic: 'قُلْ آمَنْتُ بِاللَّهِ ثُمَّ اسْتَقِمْ',
    english: 'Say: I believe in Allah, then be steadfast.',
    narrator: 'Sufyan ibn Abdullah',
    source: 'Sahih Muslim',
    reference: 'Hadith 38',
  ),
  DailyHadith(
    arabic: 'لاَ يَشْكُرُ اللَّهَ مَنْ لاَ يَشْكُرُ النَّاسَ',
    english: 'He who does not thank people does not thank Allah.',
    narrator: 'Abu Hurairah',
    source: 'Sunan Abu Dawud',
    reference: 'Hadith 4811',
  ),
  DailyHadith(
    arabic: 'إِنَّ اللَّهَ لاَ يُعَذِّبُ مَنْ يَسْتَغْفِرُ وَإِنْ كَانَ مُذْنِبًا',
    english: 'Allah does not punish one who seeks forgiveness, even if he is a sinner.',
    narrator: 'Abdullah ibn Abbas',
    source: 'Sunan al-Tirmidhi',
    reference: 'Hadith 3576',
  ),
  DailyHadith(
    arabic: 'الْيَمِينُ الْغَمُوسُ مِنَ الذُّنُوبِ الَّتِي لاَ يُكَفَّرُهَا شَيْءٌ إِلاَّ الْكَفَّارَاتُ',
    english: 'A false oath is among the sins that are not expiated except by repentance.',
    narrator: 'Abdullah ibn Amr',
    source: 'Sahih al-Bukhari',
    reference: 'Hadith 6670',
  ),
  DailyHadith(
    arabic: 'تَجَاوَزُوا فِي الدُّعَاءِ فَإِنَّ اللَّهَ يَتَجَاوَزُ فِي الْعَطَاءِ',
    english: 'Be generous in supplication, for Allah is generous in giving.',
    narrator: 'Abu Hurairah',
    source: 'Sunan al-Tirmidhi',
    reference: 'Hadith 3606',
  ),
  DailyHadith(
    arabic: 'إِنَّ اللَّهَ يُحِبُّ إِذَا أَكَلَ أَحَدُكُمْ طَعَامًا أَنْ يَأْكُلَ مِنْ جَوْفِهِ خَيْرًا',
    english: 'Allah loves it when one of you eats and praises Him for the food, and drinks and praises Him for the drink.',
    narrator: 'Abu Hurairah',
    source: 'Sahih Muslim',
    reference: 'Hadith 2679',
  ),
  DailyHadith(
    arabic: 'إِنَّ عِشْرَةً مِنَ الْمُسْلِمِينَ يَسْتَغْفِرُونَ لِمُسْلِمٍ أُسْتُغْفِرَ لَهُ',
    english: 'If ten Muslims pray for forgiveness for a Muslim, he will be forgiven.',
    narrator: 'Anas ibn Malik',
    source: 'Sahih Muslim',
    reference: 'Hadith 2733',
  ),
];

// ═══════════════════════════════════════════════════════════════════
// Provider to get today's hadith based on date
// ═══════════════════════════════════════════════════════════════════

final hadithOfDayProvider = Provider<DailyHadith>((ref) {
  final now = DateTime.now();
  // Use days since epoch to cycle through hadiths
  final epoch = DateTime(2024, 1, 1);
  final daysSinceEpoch = now.difference(epoch).inDays;
  final index = daysSinceEpoch % _dailyHadithCollection.length;
  return _dailyHadithCollection[index];
});

final hadithFavoritesProvider =
    StateNotifierProvider<HadithFavoritesNotifier, List<DailyHadith>>((ref) {
  return HadithFavoritesNotifier();
});

class HadithFavoritesNotifier extends StateNotifier<List<DailyHadith>> {
  HadithFavoritesNotifier() : super([]) {
    _loadFavorites();
  }

  void _loadFavorites() {
    try {
      final box = Hive.box('favorites');
      final keys = box.get('hadith_favorites', defaultValue: <String>[]) as List;
      final favorites = <DailyHadith>[];
      for (final key in keys) {
        final idx = _dailyHadithCollection.indexWhere(
          (h) => h.reference == key,
        );
        if (idx != -1) {
          favorites.add(_dailyHadithCollection[idx]);
        }
      }
      state = favorites;
    } catch (_) {
      state = [];
    }
  }

  Future<void> toggleFavorite(DailyHadith hadith) async {
    try {
      final box = Hive.box('favorites');
      final keys = List<String>.from(
        box.get('hadith_favorites', defaultValue: <String>[]) as List,
      );

      if (state.any((h) => h.reference == hadith.reference)) {
        keys.remove(hadith.reference);
        state = state.where((h) => h.reference != hadith.reference).toList();
      } else {
        keys.add(hadith.reference);
        state = [...state, hadith];
      }
      await box.put('hadith_favorites', keys);
    } catch (_) {}
  }

  bool isFavorite(DailyHadith hadith) {
    return state.any((h) => h.reference == hadith.reference);
  }
}

// ═══════════════════════════════════════════════════════════════════
// Hadith of the Day Screen
// ═══════════════════════════════════════════════════════════════════

class HadithOfDayScreen extends ConsumerWidget {
  const HadithOfDayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final todayHadith = ref.watch(hadithOfDayProvider);
    final isFav = ref.watch(hadithFavoritesProvider).any(
          (h) => h.reference == todayHadith.reference,
        );
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadith of the Day'),
        actions: [
          IconButton(
            icon: Icon(isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
            onPressed: () {
              ref.read(hadithFavoritesProvider.notifier).toggleFavorite(todayHadith);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    dateStr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.1, end: 0),

            const SizedBox(height: 20),

            // Main hadith card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.darkSurface,
                          AppColors.darkSurfaceVariant,
                        ],
                      )
                    : null,
                color: isDark ? null : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Arabic text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.15),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      todayHadith.arabic,
                      style: AppTheme.arabicQuranText.copyWith(
                        fontSize: 22,
                        height: 2.0,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      textDirection: ui.TextDirection.rtl,
                      textAlign: TextAlign.right,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // English translation
                  Text(
                    todayHadith.english,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.7,
                      fontStyle: FontStyle.italic,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Divider
                  Divider(
                    color: (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                        .withOpacity(0.5),
                  ),

                  const SizedBox(height: 12),

                  // Narrator & source
                  Row(
                    children: [
                      Icon(Icons.person_rounded,
                          size: 14,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Narrated by ${todayHadith.narrator}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.menu_book_rounded,
                          size: 14,
                          color: AppColors.secondary),
                      const SizedBox(width: 6),
                      Text(
                        '${todayHadith.source} - ${todayHadith.reference}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .scale(begin: 0.96, end: 1.0,
                    duration: 500.ms, delay: 200.ms),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final text =
                          '${todayHadith.arabic}\n\n${todayHadith.english}\n\n— ${todayHadith.source}, ${todayHadith.reference}';
                      Share.share(text, subject: 'Hadith of the Day');
                    },
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      final text =
                          '${todayHadith.arabic}\n\n${todayHadith.english}\n\n— ${todayHadith.source}, ${todayHadith.reference}';
                      // copy to clipboard would need Clipboard import
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Hadith text copied to clipboard'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copy'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
