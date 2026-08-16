import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../tables.dart';
import '../database.dart' show notifyBookmarksChanged;

class BookmarkDao {
  final Database _db;
  BookmarkDao(this._db);

  // ── Create ──────────────────────────────────────────────────────
  Future<int> addBookmark({
    required int surahNumber,
    required int ayahNumber,
    int juzNumber = 0,
    int page = 0,
    required String surahName,
    String ayahText = '',
    String category = 'general',
  }) async {
    final id = await _db.insert('bookmarks', {
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'juz_number': juzNumber,
      'page': page,
      'surah_name': surahName,
      'ayah_text': ayahText,
      'category': category,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    notifyBookmarksChanged();
    return id;
  }

  // ── Read ────────────────────────────────────────────────────────
  Future<List<Bookmark>> getAllBookmarks() async {
    final rows = await _db.query('bookmarks',
        orderBy: 'created_at DESC');
    return rows.map((r) => Bookmark.fromMap(r)).toList();
  }

  Future<List<Bookmark>> getBookmarksByCategory(String category) async {
    final rows = await _db.query('bookmarks',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'surah_number ASC, ayah_number ASC');
    return rows.map((r) => Bookmark.fromMap(r)).toList();
  }

  Future<List<Bookmark>> getBookmarksBySurah(int surahNumber) async {
    final rows = await _db.query('bookmarks',
        where: 'surah_number = ?',
        whereArgs: [surahNumber],
        orderBy: 'ayah_number ASC');
    return rows.map((r) => Bookmark.fromMap(r)).toList();
  }

  Future<Bookmark?> getBookmark(int surahNumber, int ayahNumber) async {
    final rows = await _db.query('bookmarks',
        where: 'surah_number = ? AND ayah_number = ?',
        whereArgs: [surahNumber, ayahNumber],
        limit: 1);
    if (rows.isEmpty) return null;
    return Bookmark.fromMap(rows.first);
  }

  Future<List<String>> getBookmarkCategories() async {
    final rows = await _db.rawQuery(
        'SELECT DISTINCT category FROM bookmarks');
    return rows
        .map((r) => r['category'] as String? ?? 'general')
        .toList();
  }

  Stream<List<Bookmark>> watchAllBookmarks() async* {
    yield await getAllBookmarks();
  }

  Stream<List<Bookmark>> watchBookmarksBySurah(int surahNumber) async* {
    yield await getBookmarksBySurah(surahNumber);
  }

  Future<bool> isBookmarked(int surahNumber, int ayahNumber) async {
    final bookmark = await getBookmark(surahNumber, ayahNumber);
    return bookmark != null;
  }

  // ── Update ──────────────────────────────────────────────────────
  Future<bool> updateBookmarkCategory(int id, String newCategory) async {
    final count = await _db.update('bookmarks', {'category': newCategory},
        where: 'id = ?', whereArgs: [id]);
    notifyBookmarksChanged();
    return count > 0;
  }

  // ── Delete ──────────────────────────────────────────────────────
  Future<int> removeBookmark(int surahNumber, int ayahNumber) async {
    final count = await _db.delete('bookmarks',
        where: 'surah_number = ? AND ayah_number = ?',
        whereArgs: [surahNumber, ayahNumber]);
    if (count > 0) notifyBookmarksChanged();
    return count;
  }

  Future<int> removeBookmarkById(int id) async {
    final count =
        await _db.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
    if (count > 0) notifyBookmarksChanged();
    return count;
  }

  Future<int> removeBookmarksByCategory(String category) async {
    final count = await _db.delete('bookmarks',
        where: 'category = ?', whereArgs: [category]);
    if (count > 0) notifyBookmarksChanged();
    return count;
  }

  Future<int> clearAllBookmarks() async {
    final count = await _db.delete('bookmarks');
    if (count > 0) notifyBookmarksChanged();
    return count;
  }

  // ── Count ───────────────────────────────────────────────────────
  Future<int> getBookmarkCount() async {
    final result =
        await _db.rawQuery('SELECT COUNT(*) as cnt FROM bookmarks');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
