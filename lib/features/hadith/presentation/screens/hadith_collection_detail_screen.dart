import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════
// Collection Detail Data Model
// ═══════════════════════════════════════════════════════════════════

class CollectionDetail {
  final String id;
  final String name;
  final String nameArabic;
  final String author;
  final String authorArabic;
  final int totalHadiths;
  final int totalBooks;
  final int? totalVolumes;
  final String birthYear;
  final String deathYear;
  final String birthPlace;
  final String description;
  final String introduction;
  final List<Kitab> books;

  const CollectionDetail({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.author,
    required this.authorArabic,
    required this.totalHadiths,
    required this.totalBooks,
    this.totalVolumes,
    required this.birthYear,
    required this.deathYear,
    required this.birthPlace,
    required this.description,
    required this.introduction,
    required this.books,
  });
}

class Kitab {
  final int number;
  final String name;
  final String nameArabic;
  final int hadithCount;
  final String? description;

  const Kitab({
    required this.number,
    required this.name,
    required this.nameArabic,
    required this.hadithCount,
    this.description,
  });
}

// ═══════════════════════════════════════════════════════════════════
// Hardcoded collection details for 6 major collections
// ═══════════════════════════════════════════════════════════════════

final collectionDetailProvider = Provider.family<CollectionDetail, String>((ref, id) {
  return _collections[id] ?? _collections['bukhari']!;
});

const Map<String, CollectionDetail> _collections = {
  'bukhari': CollectionDetail(
    id: 'bukhari',
    name: 'Sahih al-Bukhari',
    nameArabic: 'صحيح البخاري',
    author: 'Imam Muhammad ibn Ismail al-Bukhari',
    authorArabic: 'الإمام محمد بن إسماعيل البخاري',
    totalHadiths: 7563,
    totalBooks: 97,
    totalVolumes: 3,
    birthYear: '194 AH (810 CE)',
    deathYear: '256 AH (870 CE)',
    birthPlace: 'Bukhara, Uzbekistan',
    description:
        'Sahih al-Bukhari is the most authentic collection of Hadith. Imam al-Bukhari spent 16 years compiling it, selecting 7,563 hadiths out of approximately 600,000 that he examined. He would perform ablution and pray two rak\'ahs before writing each hadith to ensure spiritual purity.',
    introduction:
        'Imam al-Bukhari began his journey of hadith collection at the age of 16, traveling extensively across the Islamic world — to Hijaz, Egypt, Syria, Iraq, and Khorasan — to meet scholars and verify narrations. His strict criteria for authenticity required that each narrator be of excellent character, have a reliable memory, and have directly met the narrator before them in the chain. The collection was organized into books (kutub) and chapters (abwab) covering all aspects of Islamic life: faith, prayer, pilgrimage, charity, fasting, marriage, trade, and more.',
    books: [
      Kitab(number: 1, name: 'Revelation', nameArabic: 'الوحي', hadithCount: 7),
      Kitab(number: 2, name: 'Faith (Iman)', nameArabic: 'الإيمان', hadithCount: 51),
      Kitab(number: 3, name: 'Knowledge', nameArabic: 'العلم', hadithCount: 81),
      Kitab(number: 4, name: 'Ablution (Wudu)', nameArabic: 'الوضوء', hadithCount: 89),
      Kitab(number: 5, name: 'Bathing (Ghusl)', nameArabic: 'الغسل', hadithCount: 73),
      Kitab(number: 6, name: 'Menstrual Periods', nameArabic: 'الحيض', hadithCount: 43),
      Kitab(number: 7, name: 'Prayer (Salah)', nameArabic: 'الصلاة', hadithCount: 376),
      Kitab(number: 8, name: 'Times of Prayer', nameArabic: 'أوقات الصلاة', hadithCount: 148),
      Kitab(number: 9, name: 'Call to Prayer', nameArabic: 'الأذان', hadithCount: 86),
      Kitab(number: 10, name: 'Friday Prayer', nameArabic: 'الجمعة', hadithCount: 66),
      Kitab(number: 11, name: 'Fear Prayer', nameArabic: 'صلاة الخوف', hadithCount: 35),
      Kitab(number: 12, name: 'Eid Prayers', nameArabic: 'صلاة العيدين', hadithCount: 34),
      Kitab(number: 13, name: 'Night Prayer (Tahajjud)', nameArabic: 'صلاة الليل', hadithCount: 136),
      Kitab(number: 14, name: 'Funeral Prayers', nameArabic: 'صلاة الجنازة', hadithCount: 157),
      Kitab(number: 15, name: 'Zakat', nameArabic: 'الزكاة', hadithCount: 139),
      Kitab(number: 16, name: 'Pilgrimage (Hajj)', nameArabic: 'الحج', hadithCount: 378),
      Kitab(number: 17, name: 'Fasting (Sawm)', nameArabic: 'الصوم', hadithCount: 157),
      Kitab(number: 18, name: 'Night of Decree (Laylat al-Qadr)', nameArabic: 'ليلة القدر', hadithCount: 18),
      Kitab(number: 19, name: 'I\'tikaf', nameArabic: 'الاعتكاف', hadithCount: 20),
      Kitab(number: 20, name: 'Pilgrimage on Behalf of Another', nameArabic: 'الحج عن الغير', hadithCount: 67),
      Kitab(number: 24, name: 'Obligatory Charity Tax (Zakat)', nameArabic: 'الصدقة', hadithCount: 118),
      Kitab(number: 34, name: 'Sales and Trade', nameArabic: 'البيوع', hadithCount: 192),
      Kitab(number: 51, name: 'Patience and Perseverance', nameArabic: 'الصبر', hadithCount: 92),
      Kitab(number: 52, name: 'Divine Will (Qadr)', nameArabic: 'القدر', hadithCount: 30),
      Kitab(number: 56, name: 'Virtues of the Quran', nameArabic: 'فضائل القرآن', hadithCount: 84),
      Kitab(number: 59, name: 'Beginnings of Creation', nameArabic: 'بدء الخلق', hadithCount: 75),
      Kitab(number: 60, name: 'Virtues and Merits of the Prophet', nameArabic: 'مناقب النبي', hadithCount: 322),
      Kitab(number: 65, name: 'Prophetic Commentary', nameArabic: 'تفسير القرآن', hadithCount: 502),
      Kitab(number: 72, name: 'Hunting and Slaughter', nameArabic: 'الصيد والذبائح', hadithCount: 68),
      Kitab(number: 78, name: 'Good Manners', nameArabic: 'الأدب', hadithCount: 276),
      Kitab(number: 81, name: 'To Make the Heart Tender (Riqaq)', nameArabic: 'الرقائق', hadithCount: 158),
      Kitab(number: 86, name: 'Dreams', nameArabic: 'الرؤيا', hadithCount: 62),
      Kitab(number: 93, name: 'Holding Fast to the Quran and Sunnah', nameArabic: 'الاعتصام بالكتاب والسنة', hadithCount: 34),
      Kitab(number: 97, name: 'Oneness of Allah (Tawhid)', nameArabic: 'التوحيد', hadithCount: 160),
    ],
  ),
  'muslim': CollectionDetail(
    id: 'muslim',
    name: 'Sahih Muslim',
    nameArabic: 'صحيح مسلم',
    author: 'Imam Muslim ibn al-Hajjaj al-Naysaburi',
    authorArabic: 'الإمام مسلم بن الحجاج النيسابوري',
    totalHadiths: 5362,
    totalBooks: 56,
    totalVolumes: 2,
    birthYear: '204 AH (821 CE)',
    deathYear: '261 AH (875 CE)',
    birthPlace: 'Nishapur, Iran',
    description:
        'Sahih Muslim is the second most authentic collection of Hadith after Sahih al-Bukhari. Imam Muslim studied under Imam al-Bukhari and collected narrations with an equally rigorous methodology. His arrangement of hadiths by topic rather than by chain of narration makes his collection particularly useful for studying Islamic jurisprudence.',
    introduction:
        'Imam Muslim began his academic journey in Nishapur before traveling to Hijaz, Egypt, Syria, and Iraq. He compiled his collection from 300,000 narrations, selecting approximately 4,000 unique hadiths (without repetition) that met his strict authenticity criteria. Imam Muslim organized his hadiths by subject matter, grouping related narrations together, which allows scholars to study the full context of each topic. His verification process included ensuring that each narrator in the chain was trustworthy and that the chain was continuous.',
    books: [
      Kitab(number: 1, name: 'Faith', nameArabic: 'الإيمان', hadithCount: 63),
      Kitab(number: 2, name: 'Purification', nameArabic: 'الطهارة', hadithCount: 101),
      Kitab(number: 3, name: 'Menstruation', nameArabic: 'الحيض', hadithCount: 28),
      Kitab(number: 4, name: 'Prayer', nameArabic: 'الصلاة', hadithCount: 172),
      Kitab(number: 5, name: 'Mosques and Places of Prayer', nameArabic: 'المساجد', hadithCount: 50),
      Kitab(number: 6, name: 'Funeral Prayers', nameArabic: 'الجنائز', hadithCount: 126),
      Kitab(number: 7, name: 'Zakat', nameArabic: 'الزكاة', hadithCount: 108),
      Kitab(number: 8, name: 'Fasting', nameArabic: 'الصيام', hadithCount: 81),
      Kitab(number: 9, name: 'Pilgrimage', nameArabic: 'الحج', hadithCount: 177),
      Kitab(number: 10, name: 'Marriage', nameArabic: 'النكاح', hadithCount: 139),
      Kitab(number: 11, name: 'Nursing', nameArabic: 'الرضاع', hadithCount: 17),
      Kitab(number: 12, name: 'Divorce', nameArabic: 'الطلاق', hadithCount: 52),
      Kitab(number: 13, name: 'Emancipating Slaves', nameArabic: 'العتق', hadithCount: 28),
      Kitab(number: 14, name: 'Sales and Trade', nameArabic: 'البيع', hadithCount: 97),
      Kitab(number: 15, name: 'Gifts and Favors', nameArabic: 'الهبات', hadithCount: 14),
      Kitab(number: 16, name: 'Bequests', nameArabic: 'الوصايا', hadithCount: 19),
      Kitab(number: 17, name: 'Wills and Inheritance', nameArabic: 'المواريث', hadithCount: 40),
      Kitab(number: 18, name: 'Punishments', nameArabic: 'الحدود', hadithCount: 37),
      Kitab(number: 19, name: 'Retaliation (Qisas)', nameArabic: 'القصاص', hadithCount: 13),
      Kitab(number: 20, name: 'Judgments', nameArabic: 'الأقضية', hadithCount: 36),
      Kitab(number: 21, name: 'Laws of Peace Treaties', nameArabic: 'السلم', hadithCount: 38),
      Kitab(number: 22, name: 'Oaths and Vows', nameArabic: 'الأيمان والنذور', hadithCount: 46),
      Kitab(number: 23, name: 'Sacrifices', nameArabic: 'الذبائح', hadithCount: 12),
      Kitab(number: 24, name: 'Drinks and Intoxicants', nameArabic: 'الأشربة', hadithCount: 31),
      Kitab(number: 25, name: 'Clothing and Adornment', nameArabic: 'اللباس والزينة', hadithCount: 52),
      Kitab(number: 26, name: 'Etiquette', nameArabic: 'الأدب', hadithCount: 61),
      Kitab(number: 27, name: 'Greetings', nameArabic: 'السلام', hadithCount: 76),
      Kitab(number: 28, name: 'Sitting and Posture', nameArabic: 'المجلس', hadithCount: 30),
      Kitab(number: 29, name: 'Sneezing and Yawning', nameArabic: 'التثاؤب والعطاس', hadithCount: 13),
      Kitab(number: 30, name: 'Dreams', nameArabic: 'الرؤيا', hadithCount: 23),
      Kitab(number: 31, name: 'Virtues and Merits', nameArabic: 'فضائل', hadithCount: 77),
      Kitab(number: 32, name: 'Virtues of the Companions', nameArabic: 'فضائل الصحابة', hadithCount: 339),
      Kitab(number: 33, name: 'Virtues of the Quran', nameArabic: 'فضائل القرآن', hadithCount: 54),
      Kitab(number: 34, name: 'Remembrance of Allah (Dhikr)', nameArabic: 'الأذكار', hadithCount: 92),
      Kitab(number: 35, name: 'Repentance', nameArabic: 'التوبة', hadithCount: 15),
      Kitab(number: 36, name: 'Self-Purification', nameArabic: 'الزهد', hadithCount: 75),
      Kitab(number: 37, name: 'Book of Destiny', nameArabic: 'القدر', hadithCount: 22),
      Kitab(number: 42, name: 'Trials and Tribulations', nameArabic: 'الفتن', hadithCount: 54),
      Kitab(number: 43, name: 'Knowledge', nameArabic: 'العلم', hadithCount: 25),
      Kitab(number: 44, name: 'Praise and Gratitude', nameArabic: 'الشكر', hadithCount: 31),
      Kitab(number: 45, name: 'Supplication', nameArabic: 'الدعاء', hadithCount: 93),
      Kitab(number: 46, name: 'Sacrificial Offerings', nameArabic: 'الأضاحي', hadithCount: 18),
      Kitab(number: 50, name: 'Paradise and Hell', nameArabic: 'الجنة والنار', hadithCount: 114),
      Kitab(number: 56, name: 'Oneness, Lordship and Attributes of Allah', nameArabic: 'التوحيد', hadithCount: 94),
    ],
  ),
  'abudawud': CollectionDetail(
    id: 'abudawud',
    name: 'Sunan Abu Dawud',
    nameArabic: 'سنن أبي داود',
    author: 'Imam Abu Dawud Sulayman ibn al-Ash\'ath al-Sijistani',
    authorArabic: 'الإمام أبو داود سليمان بن الأشعث السجستاني',
    totalHadiths: 5274,
    totalBooks: 43,
    birthYear: '202 AH (817 CE)',
    deathYear: '275 AH (889 CE)',
    birthPlace: 'Sistan, Iran',
    description:
        'Sunan Abu Dawud is one of the six major hadith collections (Kutub al-Sittah). Imam Abu Dawud compiled it over 20 years, selecting narrations that he considered useful for Islamic jurisprudence. It contains many hadiths related to practical aspects of Islamic law.',
    introduction:
        'Imam Abu Dawud traveled widely to collect hadiths, visiting Basra, Kufa, Baghdad, Mecca, Medina, Syria, Egypt, and other centers of Islamic learning. He compiled his collection from 500,000 narrations. Unlike Bukhari and Muslim, Abu Dawud included some hasan (good) and even a few da\'if (weak) narrations that he considered beneficial for juristic rulings, marking the weaker ones in his text.',
    books: [
      Kitab(number: 1, name: 'Purification', nameArabic: 'الطهارة', hadithCount: 250),
      Kitab(number: 2, name: 'Prayer', nameArabic: 'الصلاة', hadithCount: 1075),
      Kitab(number: 3, name: 'Funeral Prayer', nameArabic: 'الجنائز', hadithCount: 180),
      Kitab(number: 4, name: 'Zakat', nameArabic: 'الزكاة', hadithCount: 195),
      Kitab(number: 5, name: 'Fasting', nameArabic: 'الصيام', hadithCount: 87),
      Kitab(number: 6, name: 'Pilgrimage', nameArabic: 'الحج', hadithCount: 320),
      Kitab(number: 7, name: 'Marriage', nameArabic: 'النكاح', hadithCount: 277),
      Kitab(number: 8, name: 'Divorce', nameArabic: 'الطلاق', hadithCount: 72),
      Kitab(number: 9, name: 'Trade', nameArabic: 'البيع', hadithCount: 194),
      Kitab(number: 10, name: 'Food', nameArabic: 'الأطعمة', hadithCount: 74),
      Kitab(number: 11, name: 'Sacrifices', nameArabic: 'الذبائح', hadithCount: 40),
      Kitab(number: 12, name: 'Hunting', nameArabic: 'الصيد', hadithCount: 27),
      Kitab(number: 13, name: 'Oaths', nameArabic: 'الأيمان', hadithCount: 56),
      Kitab(number: 14, name: 'Virtues and Merits', nameArabic: 'الفضائل', hadithCount: 178),
      Kitab(number: 15, name: 'Knowledge', nameArabic: 'العلم', hadithCount: 41),
      Kitab(number: 16, name: 'Prayer (Night)', nameArabic: 'صلاة الليل', hadithCount: 62),
      Kitab(number: 17, name: 'Jihad', nameArabic: 'الجهاد', hadithCount: 146),
      Kitab(number: 18, name: 'Clothing', nameArabic: 'اللباس', hadithCount: 72),
      Kitab(number: 19, name: 'Medicine', nameArabic: 'الطب', hadithCount: 70),
      Kitab(number: 20, name: 'Etiquette', nameArabic: 'الأدب', hadithCount: 463),
      Kitab(number: 21, name: 'Trials', nameArabic: 'الفتن', hadithCount: 63),
      Kitab(number: 22, name: 'Paradise', nameArabic: 'الجنة', hadithCount: 36),
      Kitab(number: 23, name: 'Judgments', nameArabic: 'الأقضية', hadithCount: 89),
      Kitab(number: 24, name: 'Wills', nameArabic: 'الوصايا', hadithCount: 29),
      Kitab(number: 25, name: 'Inheritance', nameArabic: 'الميراث', hadithCount: 35),
      Kitab(number: 26, name: 'Punishments', nameArabic: 'الحدود', hadithCount: 60),
      Kitab(number: 27, name: 'Forgiveness', nameArabic: 'العفو', hadithCount: 15),
      Kitab(number: 28, name: 'Prophetic Medicine', nameArabic: 'الطب النبوي', hadithCount: 25),
      Kitab(number: 29, name: 'Trials of Dajjal', nameArabic: 'الملاحم', hadithCount: 28),
      Kitab(number: 30, name: 'Supplication', nameArabic: 'الدعاء', hadithCount: 92),
      Kitab(number: 33, name: 'Clothing and Adornment', nameArabic: 'الزينة', hadithCount: 55),
      Kitab(number: 36, name: 'Wudu\' and Prayer', nameArabic: 'الوضوء والصلاة', hadithCount: 65),
      Kitab(number: 41, name: 'Qiyam al-Layl', nameArabic: 'التهجد', hadithCount: 23),
      Kitab(number: 42, name: 'Supplications (General)', nameArabic: 'الأدعية العامة', hadithCount: 47),
      Kitab(number: 43, name: 'Food and Drink', nameArabic: 'المطعم والمشرب', hadithCount: 48),
    ],
  ),
  'tirmidhi': CollectionDetail(
    id: 'tirmidhi',
    name: 'Jami\' at-Tirmidhi',
    nameArabic: 'جامع الترمذي',
    author: 'Imam Abu Isa Muhammad at-Tirmidhi',
    authorArabic: 'الإمام أبو عيسى محمد الترمذي',
    totalHadiths: 4290,
    totalBooks: 49,
    birthYear: '209 AH (824 CE)',
    deathYear: '279 AH (892 CE)',
    birthPlace: 'Termez, Uzbekistan',
    description:
        'Jami\' at-Tirmidhi is one of the six major hadith collections. It is distinguished by its grading system — Imam Tirmidhi graded each hadith as Sahih, Hasan, Gharib (rare), or Da\'if. It is considered the most comprehensive collection for understanding hadith classification.',
    introduction:
        'Imam Tirmidhi was a student of Imam al-Bukhari and was known for his exceptional memory. He compiled this collection from 300,000 narrations, selecting those that had practical value. His unique contribution was providing a scholarly grading after each hadith, indicating its authenticity level and explaining his reasoning. He also included discussions on the juristic implications of narrations, making his work invaluable for both hadith scholars and jurists.',
    books: [
      Kitab(number: 1, name: 'On Purification', nameArabic: 'الطهارة', hadithCount: 146),
      Kitab(number: 2, name: 'On Prayer', nameArabic: 'الصلاة', hadithCount: 420),
      Kitab(number: 3, name: 'On the Mosques', nameArabic: 'المساجد', hadithCount: 65),
      Kitab(number: 4, name: 'On Friday', nameArabic: 'الجمعة', hadithCount: 47),
      Kitab(number: 5, name: 'On the Two Eids', nameArabic: 'العيدين', hadithCount: 36),
      Kitab(number: 6, name: 'On Fasting', nameArabic: 'الصيام', hadithCount: 108),
      Kitab(number: 7, name: 'On Pilgrimage', nameArabic: 'الحج', hadithCount: 277),
      Kitab(number: 8, name: 'On Jihad', nameArabic: 'الجهاد', hadithCount: 115),
      Kitab(number: 9, name: 'On Sacrifices', nameArabic: 'الضحايا', hadithCount: 24),
      Kitab(number: 10, name: 'On Hunting', nameArabic: 'الصيد', hadithCount: 15),
      Kitab(number: 11, name: 'On Food', nameArabic: 'الأطعمة', hadithCount: 52),
      Kitab(number: 12, name: 'On Clothing', nameArabic: 'اللباس', hadithCount: 52),
      Kitab(number: 13, name: 'On Virtues', nameArabic: 'الفضائل', hadithCount: 231),
      Kitab(number: 14, name: 'On Merits of the Quran', nameArabic: 'فضائل القرآن', hadithCount: 48),
      Kitab(number: 15, name: 'On Supplication', nameArabic: 'الدعاء', hadithCount: 82),
      Kitab(number: 16, name: 'On Qira\'at', nameArabic: 'القراءات', hadithCount: 14),
      Kitab(number: 17, name: 'On Marriage', nameArabic: 'النكاح', hadithCount: 215),
      Kitab(number: 18, name: 'On Divorce', nameArabic: 'الطلاق', hadithCount: 50),
      Kitab(number: 19, name: 'On Maintenance', nameArabic: 'النفقات', hadithCount: 28),
      Kitab(number: 20, name: 'On Vows and Oaths', nameArabic: 'الأيمان والنذور', hadithCount: 34),
      Kitab(number: 21, name: 'On Judgments', nameArabic: 'الأحكام', hadithCount: 96),
      Kitab(number: 22, name: 'On Wills', nameArabic: 'الوصايا', hadithCount: 16),
      Kitab(number: 23, name: 'On Inheritance', nameArabic: 'المواريث', hadithCount: 38),
      Kitab(number: 24, name: 'On Punishments', nameArabic: 'الحدود', hadithCount: 55),
      Kitab(number: 25, name: 'On Blood Money', nameArabic: 'الديات', hadithCount: 27),
      Kitab(number: 26, name: 'On Knowledge', nameArabic: 'العلم', hadithCount: 80),
      Kitab(number: 27, name: 'On Virtues of Companions', nameArabic: 'فضائل الصحابة', hadithCount: 220),
      Kitab(number: 28, name: 'On Piety', nameArabic: 'الزهد', hadithCount: 105),
      Kitab(number: 29, name: 'On Dreams', nameArabic: 'الرؤيا', hadithCount: 16),
      Kitab(number: 30, name: 'On Tribulations', nameArabic: 'الفتن', hadithCount: 64),
      Kitab(number: 35, name: 'On Purification of the Soul', nameArabic: 'الرقائق', hadithCount: 108),
      Kitab(number: 40, name: 'On Scholars', nameArabic: 'فضائل العلماء', hadithCount: 85),
      Kitab(number: 44, name: 'On Characteristics of the Prophet', nameArabic: 'شمائل النبي', hadithCount: 340),
      Kitab(number: 45, name: 'On Names of the Prophet', nameArabic: 'أسماء النبي', hadithCount: 52),
      Kitab(number: 49, name: 'On Tafsir', nameArabic: 'التفسير', hadithCount: 234),
    ],
  ),
  'nasai': CollectionDetail(
    id: 'nasai',
    name: 'Sunan an-Nasa\'i',
    nameArabic: 'سنن النسائي',
    author: 'Imam Ahmad ibn Shu\'ayb an-Nasa\'i',
    authorArabic: 'الإمام أحمد بن شعيب النسائي',
    totalHadiths: 5758,
    totalBooks: 51,
    birthYear: '215 AH (830 CE)',
    deathYear: '303 AH (915 CE)',
    birthPlace: 'Nasa, Turkmenistan',
    description:
        'Sunan an-Nasa\'i is one of the six major hadith collections. Imam an-Nasa\'i was known for his meticulous verification of narrators and is sometimes called "the most knowledgeable of hadith scholars regarding the narrators." His collection is particularly valued for its detailed coverage of ritual purification and prayer.',
    introduction:
        'Imam an-Nasa\'i traveled extensively to Egypt, Hijaz, Iraq, and Syria to study hadith. His original collection, called "As-Sunan al-Kubra" (The Great Collection), contained approximately 12,000 narrations. The version commonly known today, "As-Sunan as-Sughra" (The Small Collection), is an abridgement. His methodology was very strict — he only included narrations from the most reliable narrators and was highly critical of narrators he considered untrustworthy.',
    books: [
      Kitab(number: 1, name: 'Purification', nameArabic: 'الطهارة', hadithCount: 390),
      Kitab(number: 2, name: 'Times of Prayer', nameArabic: 'المواقيت', hadithCount: 105),
      Kitab(number: 3, name: 'Call to Prayer', nameArabic: 'الأذان', hadithCount: 65),
      Kitab(number: 4, name: 'Prayer', nameArabic: 'الصلاة', hadithCount: 520),
      Kitab(number: 5, name: 'Friday', nameArabic: 'الجمعة', hadithCount: 54),
      Kitab(number: 6, name: 'Prayer in Congregation', nameArabic: 'صلاة الجماعة', hadithCount: 42),
      Kitab(number: 7, name: 'Prayer of the Traveler', nameArabic: 'صلاة المسافر', hadithCount: 38),
      Kitab(number: 8, name: 'Tahajjud', nameArabic: 'صلاة التهجد', hadithCount: 44),
      Kitab(number: 9, name: 'Funeral Prayers', nameArabic: 'صلاة الجنائز', hadithCount: 168),
      Kitab(number: 10, name: 'Zakat', nameArabic: 'الزكاة', hadithCount: 168),
      Kitab(number: 11, name: 'Fasting', nameArabic: 'الصيام', hadithCount: 152),
      Kitab(number: 12, name: 'Pilgrimage', nameArabic: 'الحج', hadithCount: 340),
      Kitab(number: 13, name: 'Jihad', nameArabic: 'الجهاد', hadithCount: 140),
      Kitab(number: 14, name: 'Marriage', nameArabic: 'النكاح', hadithCount: 215),
      Kitab(number: 15, name: 'Divorce', nameArabic: 'الطلاق', hadithCount: 98),
      Kitab(number: 16, name: 'Emancipating Slaves', nameArabic: 'العتق والولاء', hadithCount: 45),
      Kitab(number: 17, name: 'Inheritance', nameArabic: 'المواريث', hadithCount: 48),
      Kitab(number: 18, name: 'Wills', nameArabic: 'الوصايا', hadithCount: 32),
      Kitab(number: 19, name: 'Bequests', nameArabic: 'الهبات', hadithCount: 25),
      Kitab(number: 20, name: 'Sales and Trade', nameArabic: 'البيع', hadithCount: 175),
      Kitab(number: 21, name: 'Preemption', nameArabic: 'الشروط', hadithCount: 34),
      Kitab(number: 22, name: 'Pledge and Mortgages', nameArabic: 'الرهن', hadithCount: 28),
      Kitab(number: 23, name: 'Sharecropping', nameArabic: 'المزارعة', hadithCount: 22),
      Kitab(number: 24, name: 'Judgments', nameArabic: 'الأقضية', hadithCount: 98),
      Kitab(number: 25, name: 'Punishments', nameArabic: 'الحدود', hadithCount: 78),
      Kitab(number: 26, name: 'Sacrifices', nameArabic: 'الذبائح', hadithCount: 32),
      Kitab(number: 27, name: 'Hunting', nameArabic: 'الصيد', hadithCount: 22),
      Kitab(number: 28, name: 'Drinks', nameArabic: 'الأشربة', hadithCount: 42),
      Kitab(number: 29, name: 'Clothing and Adornment', nameArabic: 'الزينة واللباس', hadithCount: 72),
      Kitab(number: 30, name: 'Etiquette', nameArabic: 'آداب القعود', hadithCount: 65),
      Kitab(number: 31, name: 'Book of Sunan', nameArabic: 'كتاب السنن', hadithCount: 45),
      Kitab(number: 32, name: 'Virtues and Merits', nameArabic: 'الفضائل', hadithCount: 165),
      Kitab(number: 33, name: 'Merits of the Companions', nameArabic: 'مناقب الصحابة', hadithCount: 340),
      Kitab(number: 34, name: 'Knowledge', nameArabic: 'العلم', hadithCount: 34),
      Kitab(number: 35, name: 'Supplication', nameArabic: 'الدعاء', hadithCount: 88),
      Kitab(number: 36, name: 'Praising and Glorifying Allah', nameArabic: 'التسبيح', hadithCount: 32),
      Kitab(number: 37, name: 'Trials', nameArabic: 'الفتن', hadithCount: 52),
      Kitab(number: 38, name: 'Paradise and Hell', nameArabic: 'الجنة والنار', hadithCount: 86),
      Kitab(number: 39, name: 'Signs of the Hour', nameArabic: 'علامات الساعة', hadithCount: 45),
      Kitab(number: 40, name: 'Zuhd (Asceticism)', nameArabic: 'الزهد', hadithCount: 85),
      Kitab(number: 41, name: 'Medicine', nameArabic: 'الطب', hadithCount: 65),
      Kitab(number: 42, name: 'Gifts', nameArabic: 'الهبة', hadithCount: 22),
      Kitab(number: 43, name: 'Blood Money', nameArabic: 'الديات', hadithCount: 35),
      Kitab(number: 44, name: 'Book of Qiyam al-Layl', nameArabic: 'التهجد', hadithCount: 28),
      Kitab(number: 45, name: 'Tawhid', nameArabic: 'التوحيد', hadithCount: 48),
      Kitab(number: 46, name: 'Name of the Prophet', nameArabic: 'تسمية النبي', hadithCount: 38),
      Kitab(number: 47, name: 'Merits of Quran', nameArabic: 'فضائل القرآن', hadithCount: 45),
      Kitab(number: 48, name: 'Dreams', nameArabic: 'الرؤيا', hadithCount: 22),
      Kitab(number: 49, name: 'Wudu\' of the Prophet', nameArabic: 'وضوء النبي', hadithCount: 35),
      Kitab(number: 50, name: 'Prayer Qasr', nameArabic: 'صلاة القصر', hadithCount: 22),
      Kitab(number: 51, name: 'The Quranic Surahs', nameArabic: 'سور القرآن', hadithCount: 30),
    ],
  ),
  'ibnmajah': CollectionDetail(
    id: 'ibnmajah',
    name: 'Sunan Ibn Majah',
    nameArabic: 'سنن ابن ماجه',
    author: 'Imam Muhammad ibn Yazid Ibn Majah al-Qazwini',
    authorArabic: 'الإمام محمد بن يزيد ابن ماجه القزويني',
    totalHadiths: 4341,
    totalBooks: 37,
    birthYear: '209 AH (824 CE)',
    deathYear: '273 AH (887 CE)',
    birthPlace: 'Qazvin, Iran',
    description:
        'Sunan Ibn Majah is the last of the six major hadith collections (Kutub al-Sittah). While some scholars initially debated its inclusion among the six canonical collections, it was ultimately accepted due to its valuable content. It contains many hadiths not found in the other five collections.',
    introduction:
        'Imam Ibn Majah traveled to many Islamic centers of learning including Basra, Kufa, Baghdad, Mecca, Medina, Syria, and Egypt. He compiled his collection from narrations by 428 sheikhs. The collection is organized into 37 books covering topics including faith, prayer, charity, fasting, pilgrimage, marriage, trade, knowledge, asceticism, and eschatology. His work contains approximately 1,330 hadiths that are authentic, 428 that are good, and the remainder that are weak or fabricated.',
    books: [
      Kitab(number: 1, name: 'The Book of the Sunnah', nameArabic: 'كتاب السنة', hadithCount: 62),
      Kitab(number: 2, name: 'The Book of Purification', nameArabic: 'كتاب الطهارة', hadithCount: 217),
      Kitab(number: 3, name: 'The Book of Prayer', nameArabic: 'كتاب الصلاة', hadithCount: 285),
      Kitab(number: 4, name: 'The Book of Mosques', nameArabic: 'كتاب المساجد', hadithCount: 45),
      Kitab(number: 5, name: 'The Book of Prayer for the Dead', nameArabic: 'كتاب صلاة الموتى', hadithCount: 152),
      Kitab(number: 6, name: 'The Book of the Sunnah of Prayer', nameArabic: 'كتاب سنة الصلاة', hadithCount: 148),
      Kitab(number: 7, name: 'The Book of Zakat', nameArabic: 'كتاب الزكاة', hadithCount: 178),
      Kitab(number: 8, name: 'The Book of Fasting', nameArabic: 'كتاب الصيام', hadithCount: 96),
      Kitab(number: 9, name: 'The Book of Prayer at Night', nameArabic: 'كتاب صلاة الليل', hadithCount: 82),
      Kitab(number: 10, name: 'The Book of the Two Eids', nameArabic: 'كتاب العيدين', hadithCount: 42),
      Kitab(number: 11, name: 'The Book of Pilgrimage', nameArabic: 'كتاب الحج', hadithCount: 316),
      Kitab(number: 12, name: 'The Book of Umrah', nameArabic: 'كتاب العمرة', hadithCount: 38),
      Kitab(number: 13, name: 'The Book of Jihad', nameArabic: 'كتاب الجهاد', hadithCount: 128),
      Kitab(number: 14, name: 'The Book of Marriage', nameArabic: 'كتاب النكاح', hadithCount: 235),
      Kitab(number: 15, name: 'The Book of Divorce', nameArabic: 'كتاب الطلاق', hadithCount: 72),
      Kitab(number: 16, name: 'The Book of Expiation', nameArabic: 'كتاب الكفارات', hadithCount: 28),
      Kitab(number: 17, name: 'The Book of Sacrifice', nameArabic: 'كتاب الذبائح', hadithCount: 42),
      Kitab(number: 18, name: 'The Book of Hunting', nameArabic: 'كتاب الصيد', hadithCount: 18),
      Kitab(number: 19, name: 'The Book of Food', nameArabic: 'كتاب الأطعمة', hadithCount: 74),
      Kitab(number: 20, name: 'The Book of Drinks', nameArabic: 'كتاب الأشربة', hadithCount: 52),
      Kitab(number: 21, name: 'The Book of Clothing', nameArabic: 'كتاب اللباس', hadithCount: 68),
      Kitab(number: 22, name: 'The Book of Adornment', nameArabic: 'كتاب الزينة', hadithCount: 52),
      Kitab(number: 23, name: 'The Book of Treatment', nameArabic: 'كتاب الطب', hadithCount: 78),
      Kitab(number: 24, name: 'The Book of Sales and Trade', nameArabic: 'كتاب البيع', hadithCount: 165),
      Kitab(number: 25, name: 'The Book of Wills', nameArabic: 'كتاب الوصايا', hadithCount: 22),
      Kitab(number: 26, name: 'The Book of Inheritance', nameArabic: 'كتاب الميراث', hadithCount: 48),
      Kitab(number: 27, name: 'The Book of Punishments', nameArabic: 'كتاب الحدود', hadithCount: 58),
      Kitab(number: 28, name: 'The Book of Judgments', nameArabic: 'كتاب الأحكام', hadithCount: 82),
      Kitab(number: 29, name: 'The Book of Oaths', nameArabic: 'كتاب الأيمان', hadithCount: 32),
      Kitab(number: 30, name: 'The Book of Vows', nameArabic: 'كتاب النذور', hadithCount: 24),
      Kitab(number: 31, name: 'The Book of Manumission', nameArabic: 'كتاب العتق', hadithCount: 22),
      Kitab(number: 32, name: 'The Book of Knowledge', nameArabic: 'كتاب العلم', hadithCount: 52),
      Kitab(number: 33, name: 'The Book of Tribulations', nameArabic: 'كتاب الفتن', hadithCount: 52),
      Kitab(number: 34, name: 'The Book of Asceticism', nameArabic: 'كتاب الزهد', hadithCount: 78),
      Kitab(number: 35, name: 'The Book of Dreams', nameArabic: 'كتاب الرؤيا', hadithCount: 18),
      Kitab(number: 36, name: 'The Book of Supplication', nameArabic: 'كتاب الدعاء', hadithCount: 92),
      Kitab(number: 37, name: 'The Book of Tawhid', nameArabic: 'كتاب التوحيد', hadithCount: 42),
    ],
  ),
};

// ═══════════════════════════════════════════════════════════════════
// Hadith Collection Detail Screen
// ═══════════════════════════════════════════════════════════════════

class HadithCollectionDetailScreen extends ConsumerWidget {
  final String collectionId;

  const HadithCollectionDetailScreen({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final detail = ref.watch(collectionDetailProvider(collectionId));

    final accentColors = {
      'bukhari': AppColors.primary,
      'muslim': AppColors.secondary,
      'abudawud': AppColors.revisionBlue,
      'tirmidhi': const Color(0xFF7C3AED),
      'nasai': AppColors.hifdhGreen,
      'ibnmajah': const Color(0xFFF97316),
    };
    final accent = accentColors[collectionId] ?? AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(detail.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withOpacity(0.15),
                    accent.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: accent.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Arabic name
                  Text(
                    detail.nameArabic,
                    style: AppTheme.arabicQuranText.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 12),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatChip(
                        label: 'Hadiths',
                        value: '${detail.totalHadiths}',
                        color: accent,
                      ),
                      _StatChip(
                        label: 'Books',
                        value: '${detail.totalBooks}',
                        color: AppColors.secondary,
                      ),
                      if (detail.totalVolumes != null)
                        _StatChip(
                          label: 'Volumes',
                          value: '${detail.totalVolumes}',
                          color: AppColors.revisionBlue,
                        ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1)),

            const SizedBox(height: 20),

            // Author info section
            _SectionHeader(
              title: 'About the Author',
              icon: Icons.person_rounded,
              color: accent,
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 100.ms),
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
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
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: accent.withOpacity(0.1),
                        child: Text(
                          detail.authorArabic.substring(0, 2),
                          style: AppTheme.arabicQuranText.copyWith(
                            fontSize: 16,
                            color: accent,
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
                              detail.author,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              detail.authorArabic,
                              style: AppTheme.arabicQuranText.copyWith(
                                fontSize: 16,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.cake_rounded, size: 16, color: accent),
                      const SizedBox(width: 6),
                      Text(
                        'Born: ${detail.birthYear}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.location_on_rounded, size: 16, color: accent),
                      const SizedBox(width: 6),
                      Text(
                        detail.birthPlace,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.event_rounded, size: 16, color: AppColors.error),
                      const SizedBox(width: 6),
                      Text(
                        'Died: ${detail.deathYear}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 150.ms),

            // Introduction
            _SectionHeader(
              title: 'Introduction',
              icon: Icons.info_rounded,
              color: accent,
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 200.ms),
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 0.5,
                ),
              ),
              child: Text(
                detail.introduction,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.8,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 250.ms),

            // Books (Kutub) list
            _SectionHeader(
              title: 'Books (Kutub)',
              icon: Icons.menu_book_rounded,
              color: accent,
              badge: '${detail.books.length}',
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 300.ms),
            const SizedBox(height: 8),

            ...detail.books.asMap().entries.map((entry) {
              final idx = entry.key;
              final book = entry.value;
              return _KitabCard(
                book: book,
                index: idx,
                accentColor: accent,
              );
            }),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Helper Widgets
// ═══════════════════════════════════════════════════════════════════

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String? badge;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _KitabCard extends StatelessWidget {
  final Kitab book;
  final int index;
  final Color accentColor;

  const _KitabCard({
    required this.book,
    required this.index,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Book number
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${book.number}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Book name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.nameArabic,
                    style: AppTheme.arabicQuranText.copyWith(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
            // Hadith count
            Text(
              '${book.hadithCount}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'hadiths',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 30).ms, duration: 250.ms).slideX(begin: 0.03, end: 0),
    );
  }
}
