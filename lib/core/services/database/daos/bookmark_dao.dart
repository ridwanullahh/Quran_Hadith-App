import 'package:drift/drift.dart';
import '../tables.dart';
import '../database.dart';

part 'bookmark_dao.g.dart';

@DriftAccessor(tables: [Bookmarks])
class BookmarkDao extends DatabaseAccessor<AppDatabase>
    with _$BookmarkDaoMixin {
  BookmarkDao(super.db);

  // ── Create ──────────────────────────────────────────────────────
  Future<int> addBookmark({
    required int surahNumber,
    required int ayahNumber,
    int juzNumber = 0,
    int page = 0,
    required String surahName,
    String ayahText = '',
    String category = 'general',
  }) {
    return into(bookmarks).insertOnConflictUpdate(BookmarksCompanion.insert(
      surahNumber: Value(surahNumber),
      ayahNumber: Value(ayahNumber),
      juzNumber: Value(juzNumber),
      page: Value(page),
      surahName: Value(surahName),
      ayahText: Value(ayahText),
      category: Value(category),
      createdAt: Value(DateTime.now()),
    ));
  }

  // ── Read ────────────────────────────────────────────────────────
  Future<List<Bookmark>> getAllBookmarks() {
    return (select(bookmarks)
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .get();
  }

  Future<List<Bookmark>> getBookmarksByCategory(String category) {
    return (select(bookmarks)
          ..where((t) => t.category.equals(category))
          ..orderBy([
            (t) => OrderingTerm.asc(t.surahNumber),
            (t) => OrderingTerm.asc(t.ayahNumber),
          ]))
        .get();
  }

  Future<List<Bookmark>> getBookmarksBySurah(int surahNumber) {
    return (select(bookmarks)
          ..where((t) => t.surahNumber.equals(surahNumber))
          ..orderBy([
            (t) => OrderingTerm.asc(t.ayahNumber),
          ]))
        .get();
  }

  Future<Bookmark?> getBookmark(int surahNumber, int ayahNumber) {
    return (select(bookmarks)
          ..where((t) => t.surahNumber.equals(surahNumber) & t.ayahNumber.equals(ayahNumber)))
        .getSingleOrNull();
  }

  /// Returns distinct categories used in bookmarks
  Future<List<String>> getBookmarkCategories() async {
    final query = selectOnly(bookmarks)
      ..addColumns([bookmarks.category])
      ..groupBy([bookmarks.category]);
    final rows = await query.get();
    return rows
        .map((row) => row.read(bookmarks.category) ?? 'general')
        .toList();
  }

  /// Watches all bookmarks for reactive UI
  Stream<List<Bookmark>> watchAllBookmarks() {
    return (select(bookmarks)
          ..orderBy([
            (t) => OrderingTerm.desc(t.createdAt),
          ]))
        .watch();
  }

  /// Watches bookmarks for a specific surah
  Stream<List<Bookmark>> watchBookmarksBySurah(int surahNumber) {
    return (select(bookmarks)
          ..where((t) => t.surahNumber.equals(surahNumber))
          ..orderBy([
            (t) => OrderingTerm.asc(t.ayahNumber),
          ]))
        .watch();
  }

  /// Checks if a specific ayah is bookmarked
  Future<bool> isBookmarked(int surahNumber, int ayahNumber) async {
    final result = await getBookmark(surahNumber, ayahNumber);
    return result != null;
  }

  // ── Update ──────────────────────────────────────────────────────
  Future<bool> updateBookmarkCategory(
    int id,
    String newCategory,
  ) {
    return (update(bookmarks)..where((t) => t.id.equals(id))).write(
      BookmarksCompanion(
        category: Value(newCategory),
      ),
    ).then((rows) => rows > 0);
  }

  // ── Delete ──────────────────────────────────────────────────────
  Future<int> removeBookmark(int surahNumber, int ayahNumber) {
    return (delete(bookmarks)
          ..where((t) =>
              t.surahNumber.equals(surahNumber) &
              t.ayahNumber.equals(ayahNumber)))
        .go();
  }

  Future<int> removeBookmarkById(int id) {
    return (delete(bookmarks)..where((t) => t.id.equals(id))).go();
  }

  Future<int> removeBookmarksByCategory(String category) {
    return (delete(bookmarks)..where((t) => t.category.equals(category))).go();
  }

  Future<int> clearAllBookmarks() {
    return delete(bookmarks).go();
  }

  // ── Count ───────────────────────────────────────────────────────
  Future<int> getBookmarkCount() async {
    final countExpr = bookmarks.id.count();
    final query = selectOnly(bookmarks)..addColumns([countExpr]);
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }
}
