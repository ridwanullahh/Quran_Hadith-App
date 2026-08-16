class AppConstants {
  AppConstants._();

  // ── Quran Structure ──────────────────────────────────────────────
  static const int totalSurahs = 114;
  static const int totalJuz = 30;
  static const int totalHizb = 60;
  static const int totalAyahs = 6236;
  static const int totalPages = 604;
  static const int ayahsPerRuku = 7;

  // ── Revelation Types ─────────────────────────────────────────────
  static const String meccan = 'Meccan';
  static const String medinan = 'Medinan';

  // ── Bismillah ────────────────────────────────────────────────────
  static const String bismillahArabic = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ';
  static const String bismillahTransliteration =
      'Bismillahir Rahmanir Raheem';
  static const String bismillahTranslation =
      'In the name of Allah, the Most Gracious, the Most Merciful';

  // ── Surah without Bismillah ─────────────────────────────────────
  static const int surahWithoutBismillah = 9; // At-Tawbah

  // ── Juz Breakdown (starting surah:ayah for each juz) ────────────
  static const List<Map<String, int>> juzBreakdown = [
    {'surah': 1, 'ayah': 1},
    {'surah': 2, 'ayah': 142},
    {'surah': 2, 'ayah': 253},
    {'surah': 3, 'ayah': 93},
    {'surah': 4, 'ayah': 24},
    {'surah': 4, 'ayah': 148},
    {'surah': 5, 'ayah': 82},
    {'surah': 6, 'ayah': 151},
    {'surah': 7, 'ayah': 88},
    {'surah': 8, 'ayah': 41},
    {'surah': 9, 'ayah': 93},
    {'surah': 11, 'ayah': 6},
    {'surah': 12, 'ayah': 53},
    {'surah': 15, 'ayah': 1},
    {'surah': 17, 'ayah': 1},
    {'surah': 18, 'ayah': 75},
    {'surah': 21, 'ayah': 1},
    {'surah': 22, 'ayah': 39},
    {'surah': 23, 'ayah': 1},
    {'surah': 25, 'ayah': 21},
    {'surah': 27, 'ayah': 56},
    {'surah': 29, 'ayah': 46},
    {'surah': 33, 'ayah': 31},
    {'surah': 36, 'ayah': 23},
    {'surah': 39, 'ayah': 32},
    {'surah': 41, 'ayah': 47},
    {'surah': 46, 'ayah': 1},
    {'surah': 51, 'ayah': 31},
    {'surah': 58, 'ayah': 1},
    {'surah': 67, 'ayah': 1},
    {'surah': 78, 'ayah': 1},
  ];

  // ── Hizb Breakdown (starting surah:ayah for each hizb) ──────────
  static const List<Map<String, int>> hizbBreakdown = [
    {'surah': 1, 'ayah': 1},
    {'surah': 2, 'ayah': 26},
    {'surah': 2, 'ayah': 61},
    {'surah': 2, 'ayah': 142},
    {'surah': 2, 'ayah': 177},
    {'surah': 2, 'ayah': 253},
    {'surah': 3, 'ayah': 1},
    {'surah': 3, 'ayah': 53},
    {'surah': 3, 'ayah': 93},
    {'surah': 4, 'ayah': 24},
    {'surah': 4, 'ayah': 88},
    {'surah': 4, 'ayah': 148},
    {'surah': 5, 'ayah': 1},
    {'surah': 5, 'ayah': 41},
    {'surah': 5, 'ayah': 82},
    {'surah': 6, 'ayah': 1},
    {'surah': 6, 'ayah': 51},
    {'surah': 6, 'ayah': 101},
    {'surah': 7, 'ayah': 1},
    {'surah': 7, 'ayah': 47},
    {'surah': 7, 'ayah': 88},
    {'surah': 8, 'ayah': 1},
    {'surah': 8, 'ayah': 41},
    {'surah': 9, 'ayah': 1},
    {'surah': 9, 'ayah': 47},
    {'surah': 9, 'ayah': 93},
    {'surah': 10, 'ayah': 1},
    {'surah': 10, 'ayah': 53},
    {'surah': 11, 'ayah': 6},
    {'surah': 11, 'ayah': 61},
    {'surah': 12, 'ayah': 7},
    {'surah': 12, 'ayah': 53},
    {'surah': 13, 'ayah': 1},
    {'surah': 14, 'ayah': 10},
    {'surah': 15, 'ayah': 1},
    {'surah': 16, 'ayah': 1},
    {'surah': 17, 'ayah': 1},
    {'surah': 17, 'ayah': 50},
    {'surah': 18, 'ayah': 1},
    {'surah': 18, 'ayah': 75},
    {'surah': 19, 'ayah': 1},
    {'surah': 20, 'ayah': 1},
    {'surah': 21, 'ayah': 1},
    {'surah': 21, 'ayah': 29},
    {'surah': 22, 'ayah': 1},
    {'surah': 22, 'ayah': 39},
    {'surah': 23, 'ayah': 1},
    {'surah': 24, 'ayah': 1},
    {'surah': 25, 'ayah': 1},
    {'surah': 25, 'ayah': 21},
    {'surah': 26, 'ayah': 1},
    {'surah': 27, 'ayah': 1},
    {'surah': 27, 'ayah': 56},
    {'surah': 28, 'ayah': 1},
    {'surah': 28, 'ayah': 29},
    {'surah': 29, 'ayah': 1},
    {'surah': 29, 'ayah': 46},
    {'surah': 30, 'ayah': 1},
    {'surah': 30, 'ayah': 31},
    {'surah': 31, 'ayah': 1},
    {'surah': 32, 'ayah': 1},
    {'surah': 33, 'ayah': 1},
    {'surah': 33, 'ayah': 31},
    {'surah': 34, 'ayah': 1},
    {'surah': 35, 'ayah': 1},
    {'surah': 36, 'ayah': 1},
    {'surah': 36, 'ayah': 23},
    {'surah': 37, 'ayah': 1},
    {'surah': 37, 'ayah': 83},
    {'surah': 38, 'ayah': 1},
    {'surah': 39, 'ayah': 1},
    {'surah': 39, 'ayah': 32},
    {'surah': 40, 'ayah': 1},
    {'surah': 40, 'ayah': 41},
    {'surah': 41, 'ayah': 1},
    {'surah': 41, 'ayah': 47},
    {'surah': 42, 'ayah': 1},
    {'surah': 42, 'ayah': 27},
    {'surah': 43, 'ayah': 1},
    {'surah': 44, 'ayah': 1},
    {'surah': 45, 'ayah': 1},
    {'surah': 46, 'ayah': 1},
    {'surah': 47, 'ayah': 1},
    {'surah': 48, 'ayah': 1},
    {'surah': 49, 'ayah': 1},
    {'surah': 50, 'ayah': 1},
    {'surah': 51, 'ayah': 1},
    {'surah': 51, 'ayah': 31},
    {'surah': 52, 'ayah': 1},
    {'surah': 53, 'ayah': 1},
    {'surah': 54, 'ayah': 1},
    {'surah': 55, 'ayah': 1},
    {'surah': 56, 'ayah': 1},
    {'surah': 57, 'ayah': 1},
    {'surah': 58, 'ayah': 1},
    {'surah': 59, 'ayah': 1},
    {'surah': 60, 'ayah': 1},
    {'surah': 61, 'ayah': 1},
    {'surah': 62, 'ayah': 1},
    {'surah': 63, 'ayah': 1},
    {'surah': 64, 'ayah': 1},
    {'surah': 65, 'ayah': 1},
    {'surah': 66, 'ayah': 1},
    {'surah': 67, 'ayah': 1},
    {'surah': 68, 'ayah': 1},
    {'surah': 69, 'ayah': 1},
    {'surah': 70, 'ayah': 1},
    {'surah': 71, 'ayah': 1},
    {'surah': 72, 'ayah': 1},
    {'surah': 73, 'ayah': 1},
    {'surah': 74, 'ayah': 1},
    {'surah': 75, 'ayah': 1},
    {'surah': 76, 'ayah': 1},
    {'surah': 77, 'ayah': 1},
    {'surah': 78, 'ayah': 1},
    {'surah': 79, 'ayah': 1},
    {'surah': 80, 'ayah': 1},
    {'surah': 81, 'ayah': 1},
    {'surah': 82, 'ayah': 1},
    {'surah': 83, 'ayah': 1},
    {'surah': 84, 'ayah': 1},
    {'surah': 85, 'ayah': 1},
    {'surah': 86, 'ayah': 1},
    {'surah': 87, 'ayah': 1},
    {'surah': 88, 'ayah': 1},
    {'surah': 89, 'ayah': 1},
    {'surah': 90, 'ayah': 1},
    {'surah': 91, 'ayah': 1},
    {'surah': 92, 'ayah': 1},
    {'surah': 93, 'ayah': 1},
    {'surah': 94, 'ayah': 1},
    {'surah': 95, 'ayah': 1},
    {'surah': 96, 'ayah': 1},
    {'surah': 97, 'ayah': 1},
    {'surah': 98, 'ayah': 1},
    {'surah': 99, 'ayah': 1},
    {'surah': 100, 'ayah': 1},
    {'surah': 101, 'ayah': 1},
    {'surah': 102, 'ayah': 1},
    {'surah': 103, 'ayah': 1},
    {'surah': 104, 'ayah': 1},
    {'surah': 105, 'ayah': 1},
    {'surah': 106, 'ayah': 1},
    {'surah': 107, 'ayah': 1},
    {'surah': 108, 'ayah': 1},
    {'surah': 109, 'ayah': 1},
    {'surah': 110, 'ayah': 1},
    {'surah': 111, 'ayah': 1},
    {'surah': 112, 'ayah': 1},
    {'surah': 113, 'ayah': 1},
    {'surah': 114, 'ayah': 1},
  ];

  // ── Audio ────────────────────────────────────────────────────────
  static const String defaultReciterId = 'mishary';
  static const String audioFileExtension = '.mp3';
  static const int defaultRetryCount = 3;
  static const int downloadTimeoutSeconds = 120;

  /// Per-ayah audio CDN: everyayah.com.
  /// File naming: {surah:03}{ayah:03}.mp3 (e.g. 001001.mp3 = Al-Fatiha ayah 1).
  /// Reciter `urlPath` values are the everyayah.com directory names.
  static const String perAyahAudioBaseUrl = 'https://everyayah.com/data';

  /// Full-surah audio CDN: quranicaudio.com.
  /// File naming: {surah:03}.mp3 (e.g. 001.mp3 = complete Al-Fatiha).
  static const String fullSurahAudioBaseUrl = 'https://download.quranicaudio.com/quran';

  /// Reciter list with `urlPath` = the everyayah.com directory name.
  /// These are the correct, verifiable directory names from
  /// https://everyayah.com/data/ — verified to resolve.
  static const List<Map<String, String>> reciters = [
    {
      'id': 'mishary',
      'name': 'Mishary Rashid Alafasy',
      'style': 'Mujawwad',
      'urlPath': 'Alafasy_128kbps',
    },
    {
      'id': 'abdulbasit',
      'name': 'Abdul Basit Abdus Samad',
      'style': 'Mujawwad',
      'urlPath': 'Abdul_Basit_Murattal_64kbps',
    },
    {
      'id': 'husary',
      'name': 'Mahmoud Khalil Al-Husary',
      'style': 'Mujawwad',
      'urlPath': 'Husary_64kbps',
    },
    {
      'id': 'minshawi',
      'name': 'Mohamed Siddiq El-Minshawi',
      'style': 'Mujawwad',
      'urlPath': 'Minshawy_Murattal_128kbps',
    },
    {
      'id': 'abdurrahman',
      'name': 'Abdur-Rahman As-Sudais',
      'style': 'Mujawwad',
      'urlPath': 'Abdurrahmaan_As-Sudais_192kbps',
    },
  ];

  /// Look up the everyayah.com urlPath for a reciter id.
  /// Falls back to the first reciter's urlPath if not found.
  static String reciterUrlPath(String reciterId) {
    for (final r in reciters) {
      if (r['id'] == reciterId) {
        return r['urlPath'] ?? r['id']!;
      }
    }
    return reciters.first['urlPath'] ?? reciters.first['id']!;
  }

  // ── Translation Languages ────────────────────────────────────────
  static const Map<String, String> translationLanguages = {
    'en': 'English',
    'ur': 'Urdu',
    'hi': 'Hindi',
    'bn': 'Bengali',
    'tr': 'Turkish',
    'id': 'Indonesian',
    'ms': 'Malay',
    'fr': 'French',
  };

  static const String defaultTranslationLanguage = 'en';

  // ── Tafseer Sources ──────────────────────────────────────────────
  static const Map<String, String> tafseerSources = {
    'ibn_kathir': 'Tafseer Ibn Kathir',
    'tabari': 'Tafseer Al-Tabari',
    'qurtubi': 'Tafseer Al-Qurtubi',
    'saadi': 'Tafseer As-Saadi',
  };

  static const String defaultTafseerSource = 'ibn_kathir';

  // ── Hadith Collections ───────────────────────────────────────────
  static const int totalHadithCollections = 7;
  static const Map<String, String> hadithCollectionNames = {
    'bukhari': 'Sahih al-Bukhari',
    'muslim': 'Sahih Muslim',
    'abudawud': 'Sunan Abi Dawud',
    'tirmidhi': 'Jami at-Tirmidhi',
    'nasai': "Sunan an-Nasa'i",
    'ibnmajah': 'Sunan Ibn Majah',
    'malik': "Muwatta Malik",
  };

  // ── Database ─────────────────────────────────────────────────────
  static const String databaseName = 'minhaajulhudaa.db';
  static const int databaseVersion = 1;

  // ── Memorization ─────────────────────────────────────────────────
  static const List<String> memorizationLevels = [
    'new',
    'learning',
    'review',
    'memorized',
    'mastered',
  ];

  static const int defaultRevisionIntervalDays = 1;
  static const int maxRevisionIntervalDays = 180;
  static const double easeFactor = 1.3;

  // ── Asset Paths ──────────────────────────────────────────────────
  static const String surahInfoAssetPath = 'assets/data/surah_info.json';
  static const String quranUthmaniAssetPath = 'assets/data/quran_uthmani.json';
  static const String quranEnTranslationAssetPath =
      'assets/data/quran_en_translation.json';
  static const String quranTranslationBasePath =
      'assets/data/translations/';
  static const String tafseerBasePath = 'assets/data/tafseer/';
  static const String wordAnalysisBasePath =
      'assets/data/word_analysis/';
  static const String hadithBasePath = 'assets/data/hadith/';

  // ── Audio Base URLs ──────────────────────────────────────────────
  // Deprecated: use perAyahAudioBaseUrl + fullSurahAudioBaseUrl above.
  // Kept only for backward-compat with any code that still references it.
  static const String audioBaseUrls =
      'https://everyayah.com/data/{reciter}/';

  // ── Cache ────────────────────────────────────────────────────────
  static const int maxSearchHistoryEntries = 50;
  static const int maxReadingHistoryEntries = 200;

  // ── Spaced Repetition (SM-2 Algorithm Parameters) ───────────────
  static const double initialEaseFactor = 2.5;
  static const int minimumEaseFactor = 13; // stored as int * 10
  static const int minimumIntervalDays = 1;
  static const int easyBonusMultiplier = 2;
  static const int lapseIntervalReset = 0;
  static const int lapseRepetitionsReset = 0;

  // ── Mistake Types ────────────────────────────────────────────────
  static const List<String> mistakeTypes = [
    'hesitation',
    'minor_error',
    'major_error',
    'skipped_word',
    'skipped_ayah',
    'wrong_order',
  ];
}
