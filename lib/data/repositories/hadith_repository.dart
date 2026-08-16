import 'dart:convert';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../models/hadith/hadith_models.dart';

class HadithRepository {
  // ── In-memory cache ─────────────────────────────────────────────
  List<HadithCollection>? _collectionsCache;
  final Map<String, List<HadithBook>> _booksCache = {};
  final Map<String, List<Hadith>> _hadithsCache = {};
  final Map<String, List<Hadith>> _allHadithsByCollectionCache = {};

  // ═══════════════════════════════════════════════════════════════
  // Collections
  // ═══════════════════════════════════════════════════════════════

  /// Returns all available hadith collections
  Future<List<HadithCollection>> getCollections() async {
    if (_collectionsCache != null) return _collectionsCache!;

    try {
      final jsonString = await rootBundle.loadString(
        '${AppConstants.hadithBasePath}collections.json',
      );
      _collectionsCache = parseCollectionList(jsonString);
      return _collectionsCache!;
    } catch (e) {
      throw HadithDataException(
        'Failed to load hadith collections: $e',
      );
    }
  }

  /// Get a specific collection by its ID
  Future<HadithCollection> getCollectionById(String collectionId) async {
    final collections = await getCollections();
    final collection = collections
        .where((c) => c.id == collectionId)
        .firstOrNull;
    if (collection == null) {
      throw HadithDataException(
        'Collection "$collectionId" not found',
      );
    }
    return collection;
  }

  // ═══════════════════════════════════════════════════════════════
  // Books
  // ═══════════════════════════════════════════════════════════════

  /// Returns all books within a collection
  Future<List<HadithBook>> getBooks(String collectionId) async {
    if (_booksCache.containsKey(collectionId)) {
      return _booksCache[collectionId]!;
    }

    try {
      final jsonString = await rootBundle.loadString(
        '${AppConstants.hadithBasePath}$collectionId/books.json',
      );
      final books = parseBookList(jsonString);
      _booksCache[collectionId] = books;
      return books;
    } catch (e) {
      throw HadithDataException(
        'Failed to load books for collection "$collectionId": $e',
      );
    }
  }

  /// Get a specific book within a collection
  Future<HadithBook> getBook(
    String collectionId,
    int bookNumber,
  ) async {
    final books = await getBooks(collectionId);
    final book = books
        .where((b) => b.bookNumber == bookNumber)
        .firstOrNull;
    if (book == null) {
      throw HadithDataException(
        'Book $bookNumber not found in collection "$collectionId"',
      );
    }
    return book;
  }

  // ═══════════════════════════════════════════════════════════════
  // Hadiths
  // ═══════════════════════════════════════════════════════════════

  /// Returns all hadiths in a specific book
  Future<List<Hadith>> getHadiths(
    String collectionId,
    int bookNumber,
  ) async {
    final cacheKey = '${collectionId}_$bookNumber';
    if (_hadithsCache.containsKey(cacheKey)) {
      return _hadithsCache[cacheKey]!;
    }

    try {
      final paddedBook = bookNumber.toString().padLeft(3, '0');
      final jsonString = await rootBundle.loadString(
        '${AppConstants.hadithBasePath}$collectionId/$paddedBook.json',
      );
      final hadiths = parseHadithList(jsonString);
      _hadithsCache[cacheKey] = hadiths;
      return hadiths;
    } catch (e) {
      throw HadithDataException(
        'Failed to load hadiths for $collectionId book $bookNumber: $e',
      );
    }
  }

  /// Get a single hadith by its number within a book
  Future<Hadith> getHadithByNumber(
    String collectionId,
    int bookNumber,
    int hadithNumber,
  ) async {
    final hadiths = await getHadiths(collectionId, bookNumber);
    final hadith = hadiths
        .where((h) => h.hadithNumber == hadithNumber)
        .firstOrNull;
    if (hadith == null) {
      throw HadithDataException(
        'Hadith $hadithNumber not found in $collectionId book $bookNumber',
      );
    }
    return hadith;
  }

  /// Get all hadiths in a collection (loads all books)
  Future<List<Hadith>> getAllHadithsInCollection(
    String collectionId,
  ) async {
    if (_allHadithsByCollectionCache.containsKey(collectionId)) {
      return _allHadithsByCollectionCache[collectionId]!;
    }

    final books = await getBooks(collectionId);
    final allHadiths = <Hadith>[];

    for (final book in books) {
      try {
        final hadiths = await getHadiths(collectionId, book.bookNumber);
        allHadiths.addAll(hadiths);
      } catch (_) {
        // Skip books that fail to load
        continue;
      }
    }

    _allHadithsByCollectionCache[collectionId] = allHadiths;
    return allHadiths;
  }

  /// Get a single hadith by its global number within a collection
  Future<Hadith> getHadithByGlobalNumber(
    String collectionId,
    int globalNumber,
  ) async {
    final allHadiths = await getAllHadithsInCollection(collectionId);
    final hadith = allHadiths
        .where((h) => h.hadithNumber == globalNumber)
        .firstOrNull;
    if (hadith == null) {
      throw HadithDataException(
        'Hadith $globalNumber not found in collection "$collectionId"',
      );
    }
    return hadith;
  }

  // ═══════════════════════════════════════════════════════════════
  // Search
  // ═══════════════════════════════════════════════════════════════

  /// Search hadiths across all collections
  Future<List<HadithSearchResult>> searchHadith(
    String query, {
    String? collectionId,
    int maxResults = 50,
    String language = 'en',
  }) async {
    if (query.trim().isEmpty) return [];

    final results = <HadithSearchResult>[];
    final normalizedQuery = query.trim().toLowerCase();
    final collectionsToSearch = <String>[];

    if (collectionId != null) {
      collectionsToSearch.add(collectionId);
    } else {
      final collections = await getCollections();
      for (final c in collections) {
        collectionsToSearch.add(c.id);
      }
    }

    for (final colId in collectionsToSearch) {
      if (results.length >= maxResults) break;

      try {
        final books = await getBooks(colId);
        String? collectionName;
        try {
          final col = await getCollectionById(colId);
          collectionName = col.name;
        } catch (_) {
          collectionName = colId;
        }

        for (final book in books) {
          if (results.length >= maxResults) break;

          try {
            final hadiths = await getHadiths(colId, book.bookNumber);

            for (final hadith in hadiths) {
              if (results.length >= maxResults) break;

              // Search Arabic text (exact substring match)
              int arabicIndex = hadith.textArabic.indexOf(query);
              if (arabicIndex >= 0) {
                results.add(HadithSearchResult(
                  hadith: hadith,
                  collectionName: collectionName,
                  bookName: book.bookName,
                  highlightedArabic: hadith.textArabic,
                  matchStartIndex: arabicIndex,
                  matchLength: query.length,
                ));
                continue;
              }

              // Search English text
              if (hadith.textEnglish != null) {
                final englishLower =
                    hadith.textEnglish!.toLowerCase();
                int englishIndex = englishLower.indexOf(normalizedQuery);
                if (englishIndex >= 0) {
                  results.add(HadithSearchResult(
                    hadith: hadith,
                    collectionName: collectionName,
                    bookName: book.bookName,
                    highlightedEnglish: hadith.textEnglish,
                    matchStartIndex: englishIndex,
                    matchLength: query.length,
                ));
                continue;
              }
            }
            }
          } catch (_) {
            continue;
          }
        }
      } catch (_) {
        continue;
      }
    }

    return results;
  }

  /// Search hadiths within a specific collection
  Future<List<HadithSearchResult>> searchHadithInCollection(
    String query,
    String collectionId, {
    int maxResults = 50,
  }) async {
    return searchHadith(
      query,
      collectionId: collectionId,
      maxResults: maxResults,
    );
  }

  /// Search hadiths within a specific book
  Future<List<HadithSearchResult>> searchHadithInBook(
    String query,
    String collectionId,
    int bookNumber, {
    int maxResults = 50,
  }) async {
    if (query.trim().isEmpty) return [];

    final results = <HadithSearchResult>[];
    final normalizedQuery = query.trim().toLowerCase();

    try {
      final hadiths = await getHadiths(collectionId, bookNumber);
      final book = await getBook(collectionId, bookNumber);
      final col = await getCollectionById(collectionId);

      for (final hadith in hadiths) {
        if (results.length >= maxResults) break;

        int arabicIndex = hadith.textArabic.indexOf(query);
        if (arabicIndex >= 0) {
          results.add(HadithSearchResult(
            hadith: hadith,
            collectionName: col.name,
            bookName: book.bookName,
            highlightedArabic: hadith.textArabic,
            matchStartIndex: arabicIndex,
            matchLength: query.length,
          ));
          continue;
        }

        if (hadith.textEnglish != null) {
          final englishLower = hadith.textEnglish!.toLowerCase();
          int englishIndex = englishLower.indexOf(normalizedQuery);
          if (englishIndex >= 0) {
            results.add(HadithSearchResult(
              hadith: hadith,
              collectionName: col.name,
              bookName: book.bookName,
              highlightedEnglish: hadith.textEnglish,
              matchStartIndex: englishIndex,
              matchLength: query.length,
            ));
          }
        }
      }
    } catch (_) {
      // Return empty results on error
    }

    return results;
  }

  /// Get hadiths by narrator
  Future<List<Hadith>> getHadithsByNarrator(
    String collectionId,
    String narratorName,
  ) async {
    final allHadiths =
        await getAllHadithsInCollection(collectionId);
    final normalized = narratorName.toLowerCase();
    return allHadiths
        .where((h) =>
            h.narrator?.toLowerCase().contains(normalized) ?? false)
        .toList();
  }

  /// Get hadiths by grade (Sahih, Hasan, Daif)
  Future<List<Hadith>> getHadithsByGrade(
    String collectionId,
    String grade,
  ) async {
    final allHadiths =
        await getAllHadithsInCollection(collectionId);
    final normalizedGrade = grade.toLowerCase();
    return allHadiths
        .where((h) =>
            h.grade?.toLowerCase().contains(normalizedGrade) ?? false)
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // Cache Management
  // ═══════════════════════════════════════════════════════════════

  /// Clear all cached data
  void clearCache() {
    _collectionsCache = null;
    _booksCache.clear();
    _hadithsCache.clear();
    _allHadithsByCollectionCache.clear();
  }

  /// Pre-load collection list
  Future<void> preloadCollections() async {
    await getCollections();
  }
}

/// Custom exception for hadith data loading errors
class HadithDataException implements Exception {
  final String message;
  final Object? cause;

  const HadithDataException(this.message, {this.cause});

  @override
  String toString() => 'HadithDataException: $message';
}
