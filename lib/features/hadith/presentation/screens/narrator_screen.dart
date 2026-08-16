import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════
// Narrator Data Model
// ═══════════════════════════════════════════════════════════════════

class NarratorInfo {
  final String nameEnglish;
  final String nameArabic;
  final String title;
  final int hadithCount;
  final String birthYear;
  final String deathYear;
  final String birthPlace;
  final String tribe;
  final String description;
  final List<String> teachers;
  final List<String> students;
  final List<String> keyCollections;

  const NarratorInfo({
    required this.nameEnglish,
    required this.nameArabic,
    required this.title,
    required this.hadithCount,
    required this.birthYear,
    required this.deathYear,
    required this.birthPlace,
    required this.tribe,
    required this.description,
    required this.teachers,
    required this.students,
    required this.keyCollections,
  });

  /// Generates a URL-safe slug from the English name.
  String get slug => nameEnglish
      .toLowerCase()
      .replaceAll(RegExp(r"[^a-z0-9]+"), '-');
}

/// Find a narrator by slug identifier.
NarratorInfo? findNarratorBySlug(String slug) {
  try {
    return narrators.firstWhere((n) => n.slug == slug);
  } catch (_) {
    return null;
  }
}

/// Find a narrator by English name (partial match).
NarratorInfo? findNarratorByName(String name) {
  final lower = name.toLowerCase();
  for (final n in narrators) {
    if (n.nameEnglish.toLowerCase() == lower) return n;
  }
  for (final n in narrators) {
    if (n.nameEnglish.toLowerCase().contains(lower)) return n;
  }
  return null;
}

// ═══════════════════════════════════════════════════════════════════
// 20 Major Hadith Narrators (Companions)
// ═══════════════════════════════════════════════════════════════════

const List<NarratorInfo> narrators = [
  NarratorInfo(
    nameEnglish: 'Abu Hurairah',
    nameArabic: 'أبو هريرة',
    title: 'The Most Prolific Narrator',
    hadithCount: 5374,
    birthYear: '16 BH (603 CE)',
    deathYear: '57 AH (676 CE)',
    birthPlace: 'Yemen',
    tribe: 'Daws tribe, Yemen',
    description:
        'Abd al-Rahman ibn Sakhr al-Dawsi, known as Abu Hurairah, was one of the most prolific narrators of hadith. He embraced Islam in 7 AH and dedicated his life to learning and preserving the Prophet\'s sayings. He spent more time with the Prophet than most companions and was known for his exceptional memory. The Prophet gave him the kunya "Abu Hurairah" (Father of the Kitten) because he used to care for a small cat. He narrated 5,374 hadiths in the six major collections.',
    teachers: ['Prophet Muhammad ﷺ', 'Umar ibn al-Khattab', 'Abu Bakr as-Siddiq', 'Aisha bint Abu Bakr'],
    students: ['Sa\'id ibn al-Musayyib', 'Al-Hasan al-Basri', 'Urwa ibn az-Zubayr', 'Abu Salama ibn Abdur-Rahman'],
    keyCollections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud', 'Nasa\'i', 'Ibn Majah'],
  ),
  NarratorInfo(
    nameEnglish: 'Aisha bint Abu Bakr',
    nameArabic: 'عائشة بنت أبي بكر',
    title: 'Mother of the Believers',
    hadithCount: 2210,
    birthYear: '9 BH (614 CE)',
    deathYear: '57 AH (678 CE)',
    birthPlace: 'Mecca, Arabia',
    tribe: 'Quraysh',
    description:
        'Aisha bint Abu Bakr was the youngest wife of the Prophet and one of the most knowledgeable companions. She narrated 2,210 hadiths, making her one of the top narrators. She was renowned for her expertise in Islamic jurisprudence, Quranic interpretation, poetry, and medicine. Many companions and Tabi\'in would consult her on religious matters. Her precision in narration was unmatched — she would often correct other narrators.',
    teachers: ['Prophet Muhammad ﷺ', 'Abu Bakr as-Siddiq', 'Umm Salama'],
    students: ['Urwa ibn az-Zubayr', 'Amrah bint Abdur-Rahman', 'Al-Qasim ibn Muhammad', 'Abu Salama'],
    keyCollections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud', 'Nasa\'i'],
  ),
  NarratorInfo(
    nameEnglish: 'Abdullah ibn Umar',
    nameArabic: 'عبدالله بن عمر',
    title: 'The Pious Son',
    hadithCount: 2630,
    birthYear: '10 BH (613 CE)',
    deathYear: '73 AH (693 CE)',
    birthPlace: 'Mecca, Arabia',
    tribe: 'Quraysh (Adi)',
    description:
        'Abdullah ibn Umar ibn al-Khattab was the son of the second Caliph, Umar ibn al-Khattab. He embraced Islam as a young boy and participated in many battles. He was known for his strict adherence to the Sunnah and his piety. He narrated 2,630 hadiths and was one of the most respected jurists among the companions. He was especially meticulous in following the Prophet\'s example in every aspect of life.',
    teachers: ['Prophet Muhammad ﷺ', 'Umar ibn al-Khattab', 'Abu Bakr as-Siddiq', 'Uthman ibn Affan'],
    students: ['Sa\'id ibn al-Musayyib', 'Sulaiman ibn Yasar', 'Nafi\' ibn Abdur-Rahman', 'Urwa ibn az-Zubayr'],
    keyCollections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud', 'Nasa\'i', 'Ibn Majah'],
  ),
  NarratorInfo(
    nameEnglish: 'Anas ibn Malik',
    nameArabic: 'أنس بن مالك',
    title: 'The Prophet\'s Servant',
    hadithCount: 2286,
    birthYear: '10 BH (613 CE)',
    deathYear: '93 AH (712 CE)',
    birthPlace: 'Medina, Arabia',
    tribe: 'Khazraj (Ansar)',
    description:
        'Anas ibn Malik served the Prophet Muhammad for ten years, from the age of ten until the Prophet\'s death. His mother, Umm Sulaim, presented him to the Prophet after the migration to Medina. Anas narrated 2,286 hadiths, many of which provide intimate details about the Prophet\'s daily life, character, and habits. He lived a very long life (over 100 years) and was one of the last companions to die.',
    teachers: ['Prophet Muhammad ﷺ', 'Umar ibn al-Khattab', 'Abu Bakr as-Siddiq', 'Uthman ibn Affan'],
    students: ['Al-Hasan al-Basri', 'Thabit al-Bunani', 'Qatadah ibn Di\'amah', 'Muhammad ibn Sirin'],
    keyCollections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud', 'Nasa\'i', 'Ibn Majah'],
  ),
  NarratorInfo(
    nameEnglish: 'Abdullah ibn Abbas',
    nameArabic: 'عبدالله بن عباس',
    title: 'Interpreter of the Quran',
    hadithCount: 1660,
    birthYear: '3 BH (618 CE)',
    deathYear: '68 AH (688 CE)',
    birthPlace: 'Mecca, Arabia',
    tribe: 'Quraysh (Hashim)',
    description:
        'Abdullah ibn Abbas was the cousin of the Prophet Muhammad and the son of his uncle, Abbas ibn Abdul-Muttalib. He was known as "Habir al-Ummah" (the Scholar of the Nation) and "Tarjuman al-Quran" (the Interpreter of the Quran). He narrated 1,660 hadiths and was the foremost authority on Quranic exegesis (tafsir). The Prophet made a special dua for him: "O Allah, teach him the Book (the Quran) and the wisdom."',
    teachers: ['Prophet Muhammad ﷺ', 'Umar ibn al-Khattab', 'Ali ibn Abi Talib', 'Zayd ibn Thabit'],
    students: ['Sa\'id ibn Jubayr', 'Ikrimah', 'Mujahid ibn Jabr', 'Ata ibn Abi Rabah'],
    keyCollections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud', 'Nasa\'i'],
  ),
  NarratorInfo(
    nameEnglish: 'Umar ibn al-Khattab',
    nameArabic: 'عمر بن الخطاب',
    title: 'The Second Caliph',
    hadithCount: 539,
    birthYear: '40 BH (584 CE)',
    deathYear: '23 AH (644 CE)',
    birthPlace: 'Mecca, Arabia',
    tribe: 'Quraysh (Adi)',
    description:
        'Umar ibn al-Khattab was the second Caliph of Islam and one of the ten companions promised Paradise. Known as "Al-Faruq" (the Distinguisher of Truth from Falsehood), his conversion to Islam was a turning point for the Muslim community. Though he narrated fewer hadiths (539) due to his assassination early in life, many of his own sayings and rulings are recorded in hadith literature. He was known for his justice and firm leadership.',
    teachers: ['Prophet Muhammad ﷺ', 'Abu Bakr as-Siddiq'],
    students: ['Abdullah ibn Umar', 'Abdullah ibn Abbas', 'Abu Hurairah', 'Aisha bint Abu Bakr'],
    keyCollections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud'],
  ),
  NarratorInfo(
    nameEnglish: 'Ali ibn Abi Talib',
    nameArabic: 'علي بن أبي طالب',
    title: 'The Fourth Caliph',
    hadithCount: 586,
    birthYear: '23 BH (600 CE)',
    deathYear: '40 AH (661 CE)',
    birthPlace: 'Mecca, Arabia',
    tribe: 'Quraysh (Hashim)',
    description:
        'Ali ibn Abi Talib was the cousin and son-in-law of the Prophet Muhammad, married to his daughter Fatimah. He was the fourth Rightly Guided Caliph and the first male to accept Islam. He narrated 586 hadiths and was known for his immense knowledge and wisdom. He was raised in the Prophet\'s household and was the youngest companion present at the meeting at Da\'wat al-Ashirah.',
    teachers: ['Prophet Muhammad ﷺ'],
    students: ['Hasan ibn Ali', 'Husayn ibn Ali', 'Abdullah ibn Abbas', 'Abu Ayyub al-Ansari'],
    keyCollections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud', 'Nasa\'i'],
  ),
  NarratorInfo(
    nameEnglish: 'Abu Bakr as-Siddiq',
    nameArabic: 'أبو بكر الصديق',
    title: 'The First Caliph',
    hadithCount: 142,
    birthYear: '51 BH (573 CE)',
    deathYear: '13 AH (634 CE)',
    birthPlace: 'Mecca, Arabia',
    tribe: 'Quraysh (Taym)',
    description:
        'Abu Bakr as-Siddiq was the first adult male to accept Islam, the closest companion of the Prophet, and the first Caliph. Known as "As-Siddiq" (the Truthful) for his unwavering faith, he narrated only 142 hadiths due to his relatively short caliphate (2 years) and death just 2 years after the Prophet. His narrations are considered extremely reliable. He was the Prophet\'s father-in-law through Aisha.',
    teachers: ['Prophet Muhammad ﷺ'],
    students: ['Aisha bint Abu Bakr', 'Abdullah ibn Umar', 'Abu Hurairah', 'Umar ibn al-Khattab'],
    keyCollections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud'],
  ),
  NarratorInfo(
    nameEnglish: 'Abu Musa al-Ash\'ari',
    nameArabic: 'أبو موسى الأشعري',
    title: 'The Voice of the Quran',
    hadithCount: 360,
    birthYear: 'Unknown',
    deathYear: '44 AH (664 CE)',
    birthPlace: 'Yemen',
    tribe: 'Ash\'ar tribe, Yemen',
    description:
        'Abu Musa Abdullah ibn Qays al-Ash\'ari was known for his beautiful recitation of the Quran and was appointed governor of Basra and later Kufa. He narrated 360 hadiths and was known for his eloquence and knowledge of Islamic jurisprudence. The Prophet praised his voice, saying it resembled the voice of Prophet Dawud (David). He was one of the judges appointed by Umar ibn al-Khattab.',
    teachers: ['Prophet Muhammad ﷺ', 'Umar ibn al-Khattab', 'Ali ibn Abi Talib'],
    students: ['Qatadah ibn Di\'amah', 'Hisham ibn Urwa', 'Yahya ibn Abi Kathir'],
    keyCollections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud'],
  ),
  NarratorInfo(
    nameEnglish: 'Mu\'adh ibn Jabal',
    nameArabic: 'معاذ بن جبل',
    title: 'The Scholar of the Ummah',
    hadithCount: 157,
    birthYear: '18 BH (605 CE)',
    deathYear: '18 AH (639 CE)',
    birthPlace: 'Medina, Arabia',
    tribe: 'Khazraj (Ansar)',
    description:
        'Mu\'adh ibn Jabal was one of the most knowledgeable companions and was known as "the most knowledgeable of this Ummah about what is lawful and what is unlawful." He was sent by the Prophet as a teacher and judge to Yemen. He died young during the plague of Amwas in Syria. Despite narrating only 157 hadiths due to his early death at age 37, his fiqh rulings carry great weight.',
    teachers: ['Prophet Muhammad ﷺ', 'Umar ibn al-Khattab'],
    students: ['Abu Ayyub al-Ansari', 'Fadl ibn Abbas', 'Abu Idris al-Khawlani'],
    keyCollections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud', 'Ibn Majah'],
  ),
  NarratorInfo(
    nameEnglish: 'Abdullah ibn Amr ibn al-Aas',
    nameArabic: 'عبدالله بن عمرو بن العاص',
    title: 'The Record Keeper',
    hadithCount: 700,
    birthYear: '7 BH (617 CE)',
    deathYear: '65 AH (685 CE)',
    birthPlace: 'Mecca, Arabia',
    tribe: 'Quraysh',
    description:
        'Abdullah ibn Amr ibn al-Aas was one of the early companions who embraced Islam before his father, Amr ibn al-Aas. He was unique among companions for writing down hadiths during the Prophet\'s lifetime. He had a special collection called "As-Sadiqah" (The Truthful) containing the Prophet\'s sayings. He narrated 700 hadiths and was known for his extensive worship and fasting beyond the obligatory acts.',
    teachers: ['Prophet Muhammad ﷺ', 'Abu Bakr as-Siddiq', 'Umar ibn al-Khattab', 'Uthman ibn Affan'],
    students: ['Amir ibn Shurahbil', 'Abu al-Aswad ad-Du\'ali', 'Sulaiman ibn Yasar'],
    keyCollections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud'],
  ),
  NarratorInfo(
    nameEnglish: 'Abu Dharr al-Ghifari',
    nameArabic: 'أبو ذر الغفاري',
    title: 'The Ascetic Companion',
    hadithCount: 281,
    birthYear: 'Unknown',
    deathYear: '32 AH (652 CE)',
    birthPlace: 'Arabia',
    tribe: 'Ghifar tribe',
    description:
        'Jundub ibn Junadah, known as Abu Dharr al-Ghifari, was the fifth person to embrace Islam and was known for his extreme piety and asceticism. He was among the first to accept Islam from outside Mecca. He narrated 281 hadiths and was known for his strong stance on social justice, particularly criticizing hoarding of wealth. He was eventually exiled to Rabdhah by Uthman due to political tensions.',
    teachers: ['Prophet Muhammad ﷺ'],
    students: ['Abu Ishaq as-Sabi\'i', 'Abdullah ibn Harith', 'Zirr ibn Hubaysh'],
    keyCollections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud', 'Ibn Majah'],
  ),
  NarratorInfo(
    nameEnglish: 'Uthman ibn Affan',
    nameArabic: 'عثمان بن عفان',
    title: 'The Third Caliph',
    hadithCount: 146,
    birthYear: '40 BH (576 CE)',
    deathYear: '35 AH (656 CE)',
    birthPlace: 'Mecca, Arabia',
    tribe: 'Quraysh (Umayyah)',
    description:
        'Uthman ibn Affan was the third Rightly Guided Caliph and one of the ten companions promised Paradise. He was known as "Dhun-Nurayn" (the Possessor of Two Lights) for marrying two of the Prophet\'s daughters, Ruqayyah and Umm Kulthum. He narrated 146 hadiths and was the one who compiled the Quran into a single standardized manuscript. His generous charity, including purchasing the well of Rumah for Muslims, is well documented.',
    teachers: ['Prophet Muhammad ﷺ', 'Abu Bakr as-Siddiq'],
    students: ['Abu Hurairah', 'Abdullah ibn Umar', 'Ali ibn Abi Talib'],
    keyCollections: ['Bukhari', 'Muslim', 'Tirmidhi'],
  ),
  NarratorInfo(
    nameEnglish: 'Abdullah ibn Mas\'ud',
    nameArabic: 'عبدالله بن مسعود',
    title: 'Master of Quran Recitation',
    hadithCount: 848,
    birthYear: '30 BH (594 CE)',
    deathYear: '32 AH (653 CE)',
    birthPlace: 'Mecca, Arabia',
    tribe: 'Hudhayl tribe',
    description:
        'Abdullah ibn Mas\'ud was one of the earliest converts to Islam and was known for his deep knowledge of the Quran. The Prophet testified to his knowledge of Quranic recitation. He was the first person to publicly recite the Quran in Mecca. He narrated 848 hadiths and was known for his strict following of the Sunnah. He was also one of the few companions who compiled the Quran during the Prophet\'s lifetime.',
    teachers: ['Prophet Muhammad ﷺ', 'Abu Bakr as-Siddiq', 'Umar ibn al-Khattab', 'Uthman ibn Affan'],
    students: ['Alqamah ibn Qays', 'Al-Aswad ibn Yazid', 'Masruq ibn al-Ajda\'', 'Abu Wa\'il'],
    keyCollections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud', 'Nasa\'i', 'Ibn Majah'],
  ),
  NarratorInfo(
    nameEnglish: 'Sa\'d ibn Abi Waqqas',
    nameArabic: 'سعد بن أبي وقاص',
    title: 'The Victor of Qadisiyyah',
    hadithCount: 269,
    birthYear: '23 BH (598 CE)',
    deathYear: '55 AH (675 CE)',
    birthPlace: 'Mecca, Arabia',
    tribe: 'Quraysh (Zuhrah)',
    description:
        'Sa\'d ibn Abi Waqqas was one of the ten companions promised Paradise and one of the first to accept Islam at age 17. He was the commander of the Muslim army at the historic Battle of Qadisiyyah against the Persian Empire. He was the first person to shoot an arrow in Islam. He narrated 269 hadiths and was one of the Prophet\'s scribes. He introduced Islam to China during the reign of Uthman.',
    teachers: ['Prophet Muhammad ﷺ', 'Umar ibn al-Khattab'],
    students: ['Ibrahim ibn Sa\'d', 'Musa ibn Sa\'d', 'Abu Umama al-Bahili'],
    keyCollections: ['Bukhari', 'Muslim', 'Tirmidhi'],
  ),
  NarratorInfo(
    nameEnglish: 'Jabir ibn Abdullah',
    nameArabic: 'جابر بن عبدالله',
    title: 'The Ansari Reporter',
    hadithCount: 1530,
    birthYear: '16 BH (604 CE)',
    deathYear: '78 AH (697 CE)',
    birthPlace: 'Medina, Arabia',
    tribe: 'Khazraj (Ansar)',
    description:
        'Jabir ibn Abdullah al-Ansari was one of the most prolific narrators from the Ansar (Medinan supporters). He narrated 1,530 hadiths, making him one of the top seven narrators. He participated in 19 battles with the Prophet despite his young age. His narrations are particularly valuable for Islamic jurisprudence, especially regarding Hajj, marriage, and business transactions. His father, Abdullah, died at the Battle of Uhud.',
    teachers: ['Prophet Muhammad ﷺ', 'Abu Bakr as-Siddiq', 'Umar ibn al-Khattab'],
    students: ['Ata ibn Abi Rabah', 'Amir al-Sha\'bi', 'Muhammad ibn Ali ibn al-Husayn'],
    keyCollections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud', 'Nasa\'i', 'Ibn Majah'],
  ),
  NarratorInfo(
    nameEnglish: 'Zayd ibn Thabit',
    nameArabic: 'زيد بن ثابت',
    title: 'The Scribe of Revelation',
    hadithCount: 92,
    birthYear: '11 BH (611 CE)',
    deathYear: '45 AH (665 CE)',
    birthPlace: 'Medina, Arabia',
    tribe: 'Khazraj (Ansar)',
    description:
        'Zayd ibn Thabit was the chief scribe of the Prophet and was tasked with compiling the Quran during the time of Abu Bakr and Uthman. He learned Hebrew at the Prophet\'s request to read letters from Jewish tribes, and learned Syriac to read Roman communications. He narrated 92 hadiths and was one of the few companions who had the entire Quran memorized during the Prophet\'s lifetime.',
    teachers: ['Prophet Muhammad ﷺ', 'Umar ibn al-Khattab', 'Abu Bakr as-Siddiq'],
    students: ['Kharijah ibn Zayd', 'Abu Zanad', 'Ubaydullah ibn Abdillah'],
    keyCollections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud'],
  ),
  NarratorInfo(
    nameEnglish: 'Abu Ubaidah ibn al-Jarrah',
    nameArabic: 'أبو عبيدة بن الجراح',
    title: 'The Trustee of the Ummah',
    hadithCount: 56,
    birthYear: '40 BH (584 CE)',
    deathYear: '18 AH (639 CE)',
    birthPlace: 'Mecca, Arabia',
    tribe: 'Quraysh (Fihr)',
    description:
        'Amir ibn Abdullah ibn al-Jarrah, known as Abu Ubaidah, was one of the ten companions promised Paradise and was called by the Prophet "Amin al-Ummah" (the Trustee of the Nation). He commanded the Muslim armies in Syria and successfully conquered Damascus. He narrated only 56 hadiths, many of which are considered highly authoritative, as he was a man of few words who spoke only when necessary.',
    teachers: ['Prophet Muhammad ﷺ', 'Abu Bakr as-Siddiq'],
    students: ['Abu Darda', 'Bilal ibn Rabah', 'Ubadah ibn as-Samit'],
    keyCollections: ['Bukhari', 'Muslim', 'Tirmidhi'],
  ),
  NarratorInfo(
    nameEnglish: 'Bilal ibn Rabah',
    nameArabic: 'بلال بن رباح',
    title: 'The First Mu\'adhdhin',
    hadithCount: 44,
    birthYear: 'Unknown',
    deathYear: '20 AH (641 CE)',
    birthPlace: 'Ethiopia (Abyssinia)',
    tribe: 'Ethiopian (Abu Dhabi tribe)',
    description:
        'Bilal ibn Rabah was an Abyssinian freed slave who became one of the most beloved companions of the Prophet. He was the first person to be appointed as the mu\'adhdhin (caller to prayer) in Islam. He endured severe persecution for accepting Islam but never wavered in his faith. He narrated 44 hadiths. His adhan is considered one of the most iconic symbols of Islam, and he chose to remain in Medina after the Prophet\'s death.',
    teachers: ['Prophet Muhammad ﷺ'],
    students: ['Abu Darda', 'Abu Ubaidah ibn al-Jarrah', 'Umar ibn al-Khattab'],
    keyCollections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud'],
  ),
  NarratorInfo(
    nameEnglish: 'Salman al-Farisi',
    nameArabic: 'سلمان الفارسي',
    title: 'The Persian Seeker of Truth',
    hadithCount: 48,
    birthYear: 'Unknown',
    deathYear: '36 AH (656 CE)',
    birthPlace: 'Isfahan, Persia',
    tribe: 'Persian (from Ramhurmuz)',
    description:
        'Salman al-Farisi was a Persian companion who traveled extensively in search of the true religion before finding Islam. He was sold into slavery but was freed by the Prophet. He was the one who suggested digging the trench (Khandaq) during the Battle of the Trench, which saved Medina. The Prophet said about him: "Salman is one of us, the People of the Household." He narrated 48 hadiths and became governor of Mada\'in.',
    teachers: ['Prophet Muhammad ﷺ', 'Abu Bakr as-Siddiq'],
    students: ['Abu Sa\'id al-Khudri', 'Kathir ibn Abi Kathir', 'Abdullah ibn al-Harith'],
    keyCollections: ['Bukhari', 'Muslim', 'Tirmidhi'],
  ),
  NarratorInfo(
    nameEnglish: 'Abu Sa\'id al-Khudri',
    nameArabic: 'أبو سعيد الخدري',
    title: 'The Ansari Narrator',
    hadithCount: 1170,
    birthYear: 'Unknown',
    deathYear: '74 AH (693 CE)',
    birthPlace: 'Medina, Arabia',
    tribe: 'Khazraj (Ansar)',
    description:
        'Sa\'d ibn Malik ibn Sinan, known as Abu Sa\'id al-Khudri, was one of the most prolific narrators from the Ansar. He narrated 1,170 hadiths, making him one of the top narrators. He participated in multiple battles including Badr, Uhud, and the Trench. His hadiths are particularly important regarding issues of purification, prayer, and the hereafter. He was known for his piety and was one of the major scholars of Medina.',
    teachers: ['Prophet Muhammad ﷺ', 'Abu Bakr as-Siddiq', 'Umar ibn al-Khattab', 'Ali ibn Abi Talib'],
    students: ['Muhammad ibn al-Munkadir', 'Yahya ibn Sa\'id', 'Qatadah ibn Di\'amah'],
    keyCollections: ['Bukhari', 'Muslim', 'Tirmidhi', 'Abu Dawud', 'Nasa\'i', 'Ibn Majah'],
  ),
];

// ═══════════════════════════════════════════════════════════════════
// Narrator Screen
// ═══════════════════════════════════════════════════════════════════

class NarratorScreen extends StatefulWidget {
  const NarratorScreen({super.key});

  @override
  State<NarratorScreen> createState() => _NarratorScreenState();
}

class _NarratorScreenState extends State<NarratorScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filtered = _searchQuery.isEmpty
        ? narrators
        : narrators.where((n) {
            final q = _searchQuery.toLowerCase();
            return n.nameEnglish.toLowerCase().contains(q) ||
                n.nameArabic.contains(q) ||
                n.tribe.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadith Narrators'),
        actions: [
          Text(
            '${narrators.length} narrators',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search narrators...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final narrator = filtered[index];
                return _NarratorCard(
                  narrator: narrator,
                  index: index,
                  isDark: isDark,
                  onTap: () => context.push('/hadith/narrators/${narrator.slug}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

// ═══════════════════════════════════════════════════════════════════
// Helper Widgets
// ═══════════════════════════════════════════════════════════════════

class _NarratorCard extends StatelessWidget {
  final NarratorInfo narrator;
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
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withOpacity(0.08),
                  child: Text(
                    narrator.nameArabic.substring(0, 2),
                    style: AppTheme.arabicQuranText.copyWith(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        narrator.nameEnglish,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        narrator.nameArabic,
                        style: AppTheme.arabicQuranText.copyWith(
                          fontSize: 14,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            narrator.title,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${narrator.hadithCount} hadiths',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: (index * 40).ms, duration: 300.ms).slideX(begin: 0.02, end: 0),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Narrator Detail Screen (Deep-Link)
// ═══════════════════════════════════════════════════════════════════

class NarratorDetailScreen extends StatelessWidget {
  final String narratorId;

  const NarratorDetailScreen({super.key, required this.narratorId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Try to find by slug first, then by name
    final narrator = findNarratorBySlug(narratorId) ??
        findNarratorByName(narratorId);

    if (narrator == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Narrator Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off_rounded, size: 56, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Narrator "$narratorId" not found.',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Check the narrator identifier and try again.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(narrator.nameEnglish),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  narrator.nameArabic.substring(0, 3),
                  style: AppTheme.arabicQuranText.copyWith(
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      narrator.nameEnglish,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      narrator.nameArabic,
                      style: AppTheme.arabicQuranText.copyWith(
                        fontSize: 20,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        narrator.title,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 20),

          // Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.15),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      '${narrator.hadithCount}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Hadiths',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 40, color: AppColors.darkBorder),
                Column(
                  children: [
                    Text(
                      '${narrator.teachers.length}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      'Teachers',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 40, color: AppColors.darkBorder),
                Column(
                  children: [
                    Text(
                      '${narrator.students.length}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.hifdhGreen,
                      ),
                    ),
                    Text(
                      'Students',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

          const SizedBox(height: 20),

          // Bio
          _DetailSection(
            title: 'Biography',
            icon: Icons.article_rounded,
            child: Text(
              narrator.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.7,
              ),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

          const SizedBox(height: 16),

          // Birth & Death
          _DetailSection(
            title: 'Lifespan',
            icon: Icons.cake_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(icon: Icons.calendar_today_rounded, label: 'Birth', value: narrator.birthYear),
                const SizedBox(height: 8),
                _InfoRow(icon: Icons.event_rounded, label: 'Death', value: narrator.deathYear),
                const SizedBox(height: 8),
                _InfoRow(icon: Icons.place_rounded, label: 'Birthplace', value: narrator.birthPlace),
                const SizedBox(height: 8),
                _InfoRow(icon: Icons.groups_rounded, label: 'Tribe', value: narrator.tribe),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

          const SizedBox(height: 16),

          // Teachers
          _DetailSection(
            title: 'Notable Teachers',
            icon: Icons.school_rounded,
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: narrator.teachers.map((t) => Chip(
                label: Text(t, style: const TextStyle(fontSize: 12)),
                avatar: Icon(Icons.person_rounded, size: 16, color: AppColors.primary),
                backgroundColor: AppColors.primary.withOpacity(0.06),
                side: BorderSide(color: AppColors.primary.withOpacity(0.15), width: 0.5),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              )).toList(),
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

          const SizedBox(height: 16),

          // Students
          _DetailSection(
            title: 'Notable Students',
            icon: Icons.people_rounded,
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: narrator.students.map((s) => Chip(
                label: Text(s, style: const TextStyle(fontSize: 12)),
                avatar: Icon(Icons.person_rounded, size: 16, color: AppColors.hifdhGreen),
                backgroundColor: AppColors.hifdhGreen.withOpacity(0.06),
                side: BorderSide(color: AppColors.hifdhGreen.withOpacity(0.15), width: 0.5),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              )).toList(),
            ),
          ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

          const SizedBox(height: 16),

          // Key Collections
          _DetailSection(
            title: 'Key Collections',
            icon: Icons.menu_book_rounded,
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: narrator.keyCollections.map((c) => Chip(
                label: Text(c, style: const TextStyle(fontSize: 12)),
                avatar: Icon(Icons.book_rounded, size: 16, color: AppColors.secondary),
                backgroundColor: AppColors.secondary.withOpacity(0.06),
                side: BorderSide(color: AppColors.secondary.withOpacity(0.15), width: 0.5),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              )).toList(),
            ),
          ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Detail Section Helper
// ═══════════════════════════════════════════════════════════════════

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _DetailSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }
}

