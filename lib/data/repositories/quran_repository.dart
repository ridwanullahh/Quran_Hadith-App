import 'dart:convert';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../models/quran/surah_info.dart';
import '../models/quran/ayah_data.dart';
import '../models/quran/word_data.dart';

class QuranRepository {
  // ── In-memory cache to avoid re-reading assets ──────────────────
  List<SurahInfo>? _surahsCache;
  final Map<int, List<AyahData>> _ayahsCache = {};
  final Map<String, List<AyahTranslation>> _translationsCache = {};
  final Map<String, List<AyahTafseer>> _tafseerCache = {};
  final Map<int, AyahWordAnalysis> _wordAnalysisCache = {};
  Map<String, dynamic>? _wbwDataCache;

  // ── Single-file Quran text caches (lazy-loaded once) ───────────
  // Shape: { "<surahNumber>": ["ayah 1 text", "ayah 2 text", ...], ... }
  Map<String, List<String>>? _uthmaniTextCache;
  Map<String, List<String>>? _translationTextCache;

  /// Load the full Uthmani text map from assets/data/quran_uthmani.json.
  /// This is a single 1.4 MB file containing all 114 surahs. We load it once
  /// and serve all subsequent `getSurahAyahs` calls from the in-memory map.
  Future<Map<String, List<String>>> _loadUthmaniText() async {
    if (_uthmaniTextCache != null) return _uthmaniTextCache!;
    try {
      final jsonString = await rootBundle.loadString(
        AppConstants.quranUthmaniAssetPath,
      );
      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      _uthmaniTextCache = decoded.map((k, v) {
        final list = (v as List<dynamic>).cast<String>();
        return MapEntry(k, list);
      });
      return _uthmaniTextCache!;
    } catch (e) {
      throw QuranDataException(
        'Failed to load Uthmani text from ${AppConstants.quranUthmaniAssetPath}: $e',
      );
    }
  }

  /// Load the full English translation map from
  /// assets/data/quran_en_translation.json.
  Future<Map<String, List<String>>> _loadTranslationText() async {
    if (_translationTextCache != null) return _translationTextCache!;
    try {
      final jsonString = await rootBundle.loadString(
        AppConstants.quranEnTranslationAssetPath,
      );
      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      _translationTextCache = decoded.map((k, v) {
        final list = (v as List<dynamic>).cast<String>();
        return MapEntry(k, list);
      });
      return _translationTextCache!;
    } catch (e) {
      throw QuranDataException(
        'Failed to load English translations: $e',
      );
    }
  }

  /// Compute the juz (1-30) for an ayah at (surahNumber, ayahInSurah).
  /// Uses `AppConstants.juzBreakdown` which lists the starting (surah, ayah)
  /// of each juz. We find the largest j such that juzBreakdown[j-1] <=
  /// (surah, ayahInSurah) in (surah, ayah) tuple ordering.
  int _juzForAyah(int surahNumber, int ayahInSurah) {
    int juz = 1;
    for (int j = 0; j < AppConstants.juzBreakdown.length; j++) {
      final start = AppConstants.juzBreakdown[j];
      final startSurah = start['surah']!;
      final startAyah = start['ayah']!;
      if (surahNumber > startSurah ||
          (surahNumber == startSurah && ayahInSurah >= startAyah)) {
        juz = j + 1;
      } else {
        break;
      }
    }
    return juz;
  }

  // ═══════════════════════════════════════════════════════════════
  // Surahs
  // ═══════════════════════════════════════════════════════════════

  /// Returns all 114 surah metadata
  Future<List<SurahInfo>> getAllSurahs() async {
    if (_surahsCache != null) return _surahsCache!;

    try {
      final jsonString = await rootBundle.loadString(
        AppConstants.surahInfoAssetPath,
      );
      _surahsCache = parseSurahList(jsonString);
      return _surahsCache!;
    } catch (e) {
      throw QuranDataException(
        'Failed to load surah info from assets: $e',
      );
    }
  }

  /// Get a single surah's metadata by its number (1-114)
  Future<SurahInfo> getSurahByNumber(int surahNumber) async {
    final surahs = await getAllSurahs();
    final surah = surahs.where((s) => s.number == surahNumber).firstOrNull;
    if (surah == null) {
      throw QuranDataException(
        'Surah $surahNumber not found',
      );
    }
    return surah;
  }

  /// Get surahs filtered by revelation type
  Future<List<SurahInfo>> getSurahsByRevelationType(String type) async {
    final surahs = await getAllSurahs();
    return surahs.where((s) => s.revelationType == type).toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // Ayahs
  // ═══════════════════════════════════════════════════════════════

  /// Returns all ayahs for a given surah.
  ///
  /// Loads from the single-file `assets/data/quran_uthmani.json` (a
  /// `Map<String, List<String>>` keyed by surah number). The juz number for
  /// each ayah is derived from `AppConstants.juzBreakdown`. Page and hizb
  /// fields are left null when the bundled data does not provide them.
  Future<List<AyahData>> getSurahAyahs(int surahNumber) async {
    if (_ayahsCache.containsKey(surahNumber)) {
      return _ayahsCache[surahNumber]!;
    }

    try {
      // Ensure surah metadata is loaded first so _absoluteAyahNumber works.
      if (_surahsCache == null) {
        await getAllSurahs();
      }
      final uthmani = await _loadUthmaniText();
      final surahKey = surahNumber.toString();
      final ayahTexts = uthmani[surahKey];
      if (ayahTexts == null) {
        throw QuranDataException(
          'Surah $surahNumber not found in Uthmani text asset',
        );
      }

      // Determine the starting juz for this surah so we can derive per-ayah
      // juz numbers without scanning the breakdown for every ayah.
      final ayahs = <AyahData>[];
      for (int i = 0; i < ayahTexts.length; i++) {
        final ayahInSurah = i + 1;
        ayahs.add(AyahData(
          number: _absoluteAyahNumber(surahNumber, ayahInSurah),
          surahNumber: surahNumber,
          ayahNumber: ayahInSurah,
          textUthmani: ayahTexts[i],
          juzNumber: _juzForAyah(surahNumber, ayahInSurah),
          page: null,
          hizbQuarter: null,
          sajda: false,
          sajdaType: null,
        ));
      }
      _ayahsCache[surahNumber] = ayahs;
      return ayahs;
    } catch (e) {
      if (e is QuranDataException) rethrow;
      throw QuranDataException(
        'Failed to load ayahs for surah $surahNumber: $e',
      );
    }
  }

  /// Compute the absolute (Mushaf) ayah number for (surah, ayahInSurah).
  /// Cached after the first computation per surah.
  final Map<int, int> _surahStartOffsetCache = {};
  int _absoluteAyahNumber(int surahNumber, int ayahInSurah) {
    // We need the total ayahs of all preceding surahs. We use the cached
    // surah list when available; otherwise fall back to a synchronous
    // approximation that will be replaced once getAllSurahs is called.
    if (_surahsCache != null) {
      int offset = _surahStartOffsetCache[surahNumber] ??= () {
        int sum = 0;
        for (final s in _surahsCache!) {
          if (s.number < surahNumber) sum += s.totalAyahs;
        }
        return sum;
      }();
      return offset + ayahInSurah;
    }
    // Synchronous fallback: only correct if surah list has been loaded.
    // The caller typically calls getAllSurahs first; if not, the absolute
    // number is approximate but unique within a session.
    return surahNumber * 1000 + ayahInSurah;
  }

  /// Get a single ayah by absolute ayah number
  Future<AyahData> getAyahByNumber(int absoluteAyahNumber) async {
    final surahs = await getAllSurahs();
    int cumulative = 0;
    for (final surah in surahs) {
      if (cumulative + surah.totalAyahs >= absoluteAyahNumber) {
        final ayahNum = absoluteAyahNumber - cumulative;
        final ayahs = await getSurahAyahs(surah.number);
        final ayah = ayahs.where((a) => a.ayahNumber == ayahNum).firstOrNull;
        if (ayah != null) return ayah;
      }
      cumulative += surah.totalAyahs;
    }
    throw QuranDataException(
      'Ayah $absoluteAyahNumber not found',
    );
  }

  /// Get ayahs for a specific page
  Future<List<AyahData>> getAyahsByPage(int pageNumber) async {
    final allAyahs = await _loadAllAyahs();
    return allAyahs
        .where((a) => a.page == pageNumber)
        .toList();
  }

  /// Get ayahs for a specific juz
  Future<List<AyahData>> getAyahsByJuz(int juzNumber) async {
    if (juzNumber < 1 || juzNumber > AppConstants.totalJuz) {
      throw QuranDataException(
        'Invalid juz number: $juzNumber',
      );
    }
    final allAyahs = await _loadAllAyahs();
    return allAyahs
        .where((a) => a.juzNumber == juzNumber)
        .toList();
  }

  /// Load all ayahs into memory (used for page/juz lookups)
  Future<List<AyahData>> _loadAllAyahs() async {
    final allAyahs = <AyahData>[];
    for (int i = 1; i <= AppConstants.totalSurahs; i++) {
      final ayahs = await getSurahAyahs(i);
      allAyahs.addAll(ayahs);
    }
    return allAyahs;
  }

  // ═══════════════════════════════════════════════════════════════
  // Translations
  // ═══════════════════════════════════════════════════════════════

  /// Get translations for a surah in the specified language.
  ///
  /// Currently only `en` is bundled (`assets/data/quran_en_translation.json`).
  /// Other languages return an empty list rather than throwing, so the UI can
  /// gracefully fall back to Arabic-only display.
  Future<List<AyahTranslation>> getTranslations(
    int surahNumber, {
    String language = 'en',
  }) async {
    final cacheKey = '${surahNumber}_$language';
    if (_translationsCache.containsKey(cacheKey)) {
      return _translationsCache[cacheKey]!;
    }

    try {
      if (language != 'en') {
        // No bundled translation assets for non-English languages yet.
        final empty = <AyahTranslation>[];
        _translationsCache[cacheKey] = empty;
        return empty;
      }
      final translationMap = await _loadTranslationText();
      final surahKey = surahNumber.toString();
      final texts = translationMap[surahKey] ?? <String>[];
      final surahOffset = _surahsCache == null
          ? 0
          : _surahsCache!.fold<int>(0, (sum, s) => s.number < surahNumber ? sum + s.totalAyahs : sum);
      final translations = <AyahTranslation>[];
      for (int i = 0; i < texts.length; i++) {
        translations.add(AyahTranslation(
          surahNumber: surahNumber,
          ayahNumber: i + 1,
          number: surahOffset + i + 1,
          text: texts[i],
          language: language,
        ));
      }
      _translationsCache[cacheKey] = translations;
      return translations;
    } catch (e) {
      if (e is QuranDataException) rethrow;
      throw QuranDataException(
        'Failed to load $language translations for surah $surahNumber: $e',
      );
    }
  }

  /// Get translation for a specific ayah
  Future<AyahTranslation?> getAyahTranslation(
    int surahNumber,
    int ayahNumber, {
    String language = 'en',
  }) async {
    final translations = await getTranslations(surahNumber, language: language);
    return translations
        .where((t) => t.ayahNumber == ayahNumber)
        .firstOrNull;
  }

  // ═══════════════════════════════════════════════════════════════
  // Tafseer
  // ═══════════════════════════════════════════════════════════════

  /// Get tafseer for a surah from a specific source.
  ///
  /// No tafseer assets are currently bundled with the app. This method
  /// returns an empty list instead of throwing, so the tafseer tab can show
  /// a graceful "not available" message rather than crashing the screen.
  Future<List<AyahTafseer>> getSurahTafseer(
    int surahNumber, {
    String source = 'ibn_kathir',
  }) async {
    final cacheKey = '${surahNumber}_$source';
    if (_tafseerCache.containsKey(cacheKey)) {
      return _tafseerCache[cacheKey]!;
    }
    // No bundled tafseer assets — return empty list (UI shows placeholder).
    final empty = <AyahTafseer>[];
    _tafseerCache[cacheKey] = empty;
    return empty;
  }

  /// Get tafseer for a specific ayah
  Future<AyahTafseer?> getTafseer(
    int surahNumber,
    int ayahNumber, {
    String source = 'ibn_kathir',
  }) async {
    final tafseer = await getSurahTafseer(surahNumber, source: source);
    return tafseer
        .where((t) => t.ayahNumber == ayahNumber)
        .firstOrNull;
  }

  // ═══════════════════════════════════════════════════════════════
  // Word Analysis
  // ═══════════════════════════════════════════════════════════════

  /// Get word-by-word analysis for a specific ayah
  Future<AyahWordAnalysis> getWordAnalysis(
    int ayahNumber, {
    int? wordIndex,
  }) async {
    if (_wordAnalysisCache.containsKey(ayahNumber)) {
      return _wordAnalysisCache[ayahNumber]!;
    }

    try {
      // Find which surah this ayah belongs to
      final surahs = await getAllSurahs();
      int cumulative = 0;
      int targetSurah = 0;
      int ayahInSurah = 0;
      for (final surah in surahs) {
        if (cumulative + surah.totalAyahs >= ayahNumber) {
          targetSurah = surah.number;
          ayahInSurah = ayahNumber - cumulative;
          break;
        }
        cumulative += surah.totalAyahs;
      }

      if (targetSurah == 0) {
        throw QuranDataException(
          'Could not determine surah for ayah $ayahNumber',
        );
      }

      // Lazy-load the compressed word-by-word file once
      if (_wbwDataCache == null) {
        final jsonString = await rootBundle.loadString(
          'assets/data/quran_wbw.json',
        );
        _wbwDataCache = json.decode(jsonString) as Map<String, dynamic>;
      }

      final surahMap = _wbwDataCache![targetSurah.toString()]
          as Map<String, dynamic>?
          ?? {};
      final wordTexts = (surahMap[ayahInSurah.toString()] as List<dynamic>?)
          ?.cast<String>() ?? <String>[];

      // Build WordData objects with just the Arabic field populated
      final words = <WordData>[];
      for (int i = 0; i < wordTexts.length; i++) {
        words.add(WordData(
          number: i + 1,
          ayahNumber: ayahInSurah,
          wordNumber: i + 1,
          wordPosition: i + 1,
          textArabic: wordTexts[i],
          textTransliteration: '',
        ));
      }

      final analysis = AyahWordAnalysis(
        ayahNumber: ayahInSurah,
        surahNumber: targetSurah,
        words: words,
      );
      _wordAnalysisCache[ayahNumber] = analysis;
      return analysis;
    } catch (e) {
      throw QuranDataException(
        'Failed to load word analysis for ayah $ayahNumber: $e',
      );
    }
  }

  /// Get a single word's data
  Future<WordData?> getWord(
    int ayahNumber,
    int wordIndex,
  ) async {
    final analysis = await getWordAnalysis(ayahNumber);
    return analysis.wordAt(wordIndex);
  }

  // ═══════════════════════════════════════════════════════════════
  // Search
  // ═══════════════════════════════════════════════════════════════

  /// Search Quran text (Arabic and/or translation)
  Future<List<QuranSearchResult>> searchQuran(
    String query, {
    int maxResults = 50,
    String language = 'en',
  }) async {
    if (query.trim().isEmpty) return [];

    final results = <QuranSearchResult>[];
    final surahs = await getAllSurahs();
    final normalizedQuery = query.trim().toLowerCase();

    for (final surah in surahs) {
      if (results.length >= maxResults) break;

      try {
        final ayahs = await getSurahAyahs(surah.number);
        List<AyahTranslation>? translations;
        try {
          translations = await getTranslations(surah.number, language: language);
        } catch (_) {
          translations = null;
        }

        for (final ayah in ayahs) {
          if (results.length >= maxResults) break;

          // Search Arabic text (exact substring match)
          int arabicMatchIndex = ayah.textUthmani.indexOf(query);
          if (arabicMatchIndex >= 0) {
            results.add(QuranSearchResult(
              surahNumber: surah.number,
              ayahNumber: ayah.number,
              ayahNumberInSurah: ayah.ayahNumber,
              matchedArabic: ayah.textUthmani,
              matchedTranslation: translations
                  ?.where((t) => t.ayahNumber == ayah.ayahNumber)
                  .firstOrNull
                  ?.text,
              surahName: surah.nameEnglish,
              matchStartIndex: arabicMatchIndex,
              matchLength: query.length,
            ));
            continue;
          }

          // Search translation text
          if (translations != null) {
            final translation = translations
                .where((t) => t.ayahNumber == ayah.ayahNumber)
                .firstOrNull;
            if (translation != null) {
              final translationLower = translation.text.toLowerCase();
              int translationMatchIndex = translationLower.indexOf(normalizedQuery);
              if (translationMatchIndex >= 0) {
                results.add(QuranSearchResult(
                  surahNumber: surah.number,
                  ayahNumber: ayah.number,
                  ayahNumberInSurah: ayah.ayahNumber,
                  matchedArabic: ayah.textUthmani,
                  matchedTranslation: translation.text,
                  surahName: surah.nameEnglish,
                  matchStartIndex: translationMatchIndex,
                  matchLength: query.length,
                ));
              }
            }
          }
        }
      } catch (_) {
        // Skip surahs that fail to load
        continue;
      }
    }

    return results;
  }

  // ═══════════════════════════════════════════════════════════════
  // Cache Management
  // ═══════════════════════════════════════════════════════════════

  /// Clear all cached data
  void clearCache() {
    _surahsCache = null;
    _ayahsCache.clear();
    _translationsCache.clear();
    _tafseerCache.clear();
    _wordAnalysisCache.clear();
    _wbwDataCache = null;
    _uthmaniTextCache = null;
    _translationTextCache = null;
    _surahStartOffsetCache.clear();
  }

  /// Pre-load all surah info into cache
  Future<void> preloadSurahInfo() async {
    await getAllSurahs();
  }

  /// Pre-load ayahs for specific surahs
  Future<void> preloadSurahs(List<int> surahNumbers) async {
    for (final num in surahNumbers) {
      await getSurahAyahs(num);
    }
  }
}

/// Custom exception for Quran data loading errors
class QuranDataException implements Exception {
  final String message;
  final Object? cause;

  const QuranDataException(this.message, {this.cause});

  @override
  String toString() => 'QuranDataException: $message';
}
