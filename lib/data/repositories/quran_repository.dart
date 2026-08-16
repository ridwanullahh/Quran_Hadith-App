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

  /// Returns all ayahs for a given surah
  Future<List<AyahData>> getSurahAyahs(int surahNumber) async {
    if (_ayahsCache.containsKey(surahNumber)) {
      return _ayahsCache[surahNumber]!;
    }

    try {
      // Asset path pattern: assets/data/surahs/{surahNumber}.json
      final paddedNumber = surahNumber.toString().padLeft(3, '0');
      final jsonString = await rootBundle.loadString(
        'assets/data/surahs/$paddedNumber.json',
      );
      final ayahs = parseAyahList(jsonString);
      _ayahsCache[surahNumber] = ayahs;
      return ayahs;
    } catch (e) {
      throw QuranDataException(
        'Failed to load ayahs for surah $surahNumber: $e',
      );
    }
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

  /// Get translations for a surah in the specified language
  Future<List<AyahTranslation>> getTranslations(
    int surahNumber, {
    String language = 'en',
  }) async {
    final cacheKey = '${surahNumber}_$language';
    if (_translationsCache.containsKey(cacheKey)) {
      return _translationsCache[cacheKey]!;
    }

    try {
      final paddedNumber = surahNumber.toString().padLeft(3, '0');
      final jsonString = await rootBundle.loadString(
        '${AppConstants.quranTranslationBasePath}${language}/$paddedNumber.json',
      );
      final translations = parseTranslationList(jsonString);
      _translationsCache[cacheKey] = translations;
      return translations;
    } catch (e) {
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

  /// Get tafseer for a surah from a specific source
  Future<List<AyahTafseer>> getSurahTafseer(
    int surahNumber, {
    String source = 'ibn_kathir',
  }) async {
    final cacheKey = '${surahNumber}_$source';
    if (_tafseerCache.containsKey(cacheKey)) {
      return _tafseerCache[cacheKey]!;
    }

    try {
      final paddedNumber = surahNumber.toString().padLeft(3, '0');
      final jsonString = await rootBundle.loadString(
        '${AppConstants.tafseerBasePath}$source/$paddedNumber.json',
      );
      final tafseer = parseTafseerList(jsonString);
      _tafseerCache[cacheKey] = tafseer;
      return tafseer;
    } catch (e) {
      throw QuranDataException(
        'Failed to load $source tafseer for surah $surahNumber: $e',
      );
    }
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
