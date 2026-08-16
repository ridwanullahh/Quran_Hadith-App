import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// ═══════════════════════════════════════════════════════════════════
// Hadith Bookmark Model
// ═══════════════════════════════════════════════════════════════════

class HadithBookmark {
  final String collectionId;
  final int bookNumber;
  final int hadithNumber;
  final String hadithText;
  final String? hadithArabic;
  final String? collectionName;
  final String? narrator;
  final DateTime bookmarkedAt;

  const HadithBookmark({
    required this.collectionId,
    required this.bookNumber,
    required this.hadithNumber,
    required this.hadithText,
    this.hadithArabic,
    this.collectionName,
    this.narrator,
    required this.bookmarkedAt,
  });

  String get uniqueId => '${collectionId}_${bookNumber}_$hadithNumber';

  Map<String, dynamic> toMap() => {
    'collectionId': collectionId,
    'bookNumber': bookNumber,
    'hadithNumber': hadithNumber,
    'hadithText': hadithText,
    'hadithArabic': hadithArabic,
    'collectionName': collectionName,
    'narrator': narrator,
    'bookmarkedAt': bookmarkedAt.toIso8601String(),
  };

  factory HadithBookmark.fromMap(Map<dynamic, dynamic> map) {
    return HadithBookmark(
      collectionId: map['collectionId'] as String? ?? '',
      bookNumber: map['bookNumber'] as int? ?? 0,
      hadithNumber: map['hadithNumber'] as int? ?? 0,
      hadithText: map['hadithText'] as String? ?? '',
      hadithArabic: map['hadithArabic'] as String?,
      collectionName: map['collectionName'] as String?,
      narrator: map['narrator'] as String?,
      bookmarkedAt: map['bookmarkedAt'] != null
          ? DateTime.tryParse(map['bookmarkedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Hadith Bookmark Notifier
// ═══════════════════════════════════════════════════════════════════

class HadithBookmarkNotifier extends StateNotifier<List<HadithBookmark>> {
  HadithBookmarkNotifier() : super([]) {
    _loadBookmarks();
  }

  void _loadBookmarks() {
    try {
      final box = Hive.box('hadith_bookmarks');
      final bookmarks = <HadithBookmark>[];
      for (final key in box.keys) {
        final val = box.get(key);
        if (val is Map) {
          bookmarks.add(HadithBookmark.fromMap(val));
        }
      }
      bookmarks.sort((a, b) => b.bookmarkedAt.compareTo(a.bookmarkedAt));
      state = bookmarks;
    } catch (_) {
      state = [];
    }
  }

  Future<void> addBookmark({
    required String collectionId,
    required int bookNumber,
    required int hadithNumber,
    required String hadithText,
    String? hadithArabic,
    String? collectionName,
    String? narrator,
  }) async {
    try {
      final box = Hive.box('hadith_bookmarks');
      final key = '${collectionId}_${bookNumber}_$hadithNumber';
      if (box.containsKey(key)) return;

      final bookmark = HadithBookmark(
        collectionId: collectionId,
        bookNumber: bookNumber,
        hadithNumber: hadithNumber,
        hadithText: hadithText,
        hadithArabic: hadithArabic,
        collectionName: collectionName,
        narrator: narrator,
        bookmarkedAt: DateTime.now(),
      );

      await box.put(key, bookmark.toMap());
      state = [bookmark, ...state];
    } catch (_) {}
  }

  Future<void> removeBookmark({
    required String collectionId,
    required int bookNumber,
    required int hadithNumber,
  }) async {
    try {
      final box = Hive.box('hadith_bookmarks');
      final key = '${collectionId}_${bookNumber}_$hadithNumber';
      await box.delete(key);
      state = state
          .where((b) => b.uniqueId != key)
          .toList();
    } catch (_) {}
  }

  bool isBookmarked({
    required String collectionId,
    required int bookNumber,
    required int hadithNumber,
  }) {
    final key = '${collectionId}_${bookNumber}_$hadithNumber';
    return state.any((b) => b.uniqueId == key);
  }

  List<HadithBookmark> getBookmarksByCollection(String collectionId) {
 return state.where((b) => b.collectionId == collectionId).toList();
  }
}

// ═══════════════════════════════════════════════════════════════════
// Provider
// ═══════════════════════════════════════════════════════════════════

final hadithBookmarkProvider =
    StateNotifierProvider<HadithBookmarkNotifier, List<HadithBookmark>>((ref) {
  return HadithBookmarkNotifier();
});
