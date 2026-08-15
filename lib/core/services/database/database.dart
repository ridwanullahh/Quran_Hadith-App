import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../constants/app_constants.dart';
import 'tables.dart' as tbl;
import 'daos/bookmark_dao.dart';
import 'daos/notes_dao.dart';
import 'daos/hifdh_dao.dart';
import 'daos/audio_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    tbl.Bookmarks,
    tbl.Notes,
    tbl.MemorizationProgress,
    tbl.RevisionSchedule,
    tbl.MistakeLog,
    tbl.ReadingHistory,
    tbl.SearchHistory,
    tbl.AudioDownloads,
  ],
  daos: [
    BookmarkDao,
    NotesDao,
    HifdhDao,
    AudioDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());

  static AppDatabase? _instance;

  /// Singleton factory constructor
  static AppDatabase get instance {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  /// For testing: pass a custom connection
  AppDatabase.forTesting(super.e);  // coverage:ignore-line

  @override
  int get schemaVersion => AppConstants.databaseVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();

          // Create indexes for better query performance
          await customStatement(
            'CREATE INDEX idx_bookmarks_surah_ayah ON bookmarks (surah_number, ayah_number)',
          );
          await customStatement(
            'CREATE INDEX idx_bookmarks_category ON bookmarks (category)',
          );
          await customStatement(
            'CREATE INDEX idx_bookmarks_created ON bookmarks (created_at)',
          );
          await customStatement(
            'CREATE INDEX idx_notes_surah_ayah ON notes (surah_number, ayah_number)',
          );
          await customStatement(
            'CREATE INDEX idx_notes_updated ON notes (updated_at)',
          );
          await customStatement(
            'CREATE INDEX idx_memorization_surah_ayah ON memorization_progress (surah_number, ayah_number)',
          );
          await customStatement(
            'CREATE INDEX idx_memorization_status ON memorization_progress (status)',
          );
          await customStatement(
            'CREATE INDEX idx_memorization_next_review ON memorization_progress (next_review_date)',
          );
          await customStatement(
            'CREATE INDEX idx_revision_scheduled ON revision_schedule (scheduled_date)',
          );
          await customStatement(
            'CREATE INDEX idx_revision_status ON revision_schedule (status)',
          );
          await customStatement(
            'CREATE INDEX idx_mistakes_surah ON mistake_log (surah_number)',
          );
          await customStatement(
            'CREATE INDEX idx_mistakes_resolved ON mistake_log (is_resolved)',
          );
          await customStatement(
            'CREATE INDEX idx_reading_history_read_at ON reading_history (read_at)',
          );
          await customStatement(
            'CREATE INDEX idx_search_history_searched ON search_history (searched_at)',
          );
          await customStatement(
            'CREATE INDEX idx_audio_surah_reciter ON audio_downloads (surah_number, reciter_id)',
          );
          await customStatement(
            'CREATE INDEX idx_audio_status ON audio_downloads (download_status)',
          );
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Handle future schema migrations here
          // Example: if (from == 1 && to == 2) { await m.addColumn(...); }
        },
        beforeOpen: (details) async {
          // Enable foreign keys
          await customStatement('PRAGMA foreign_keys = ON');
          // Set journal mode to WAL for better concurrent read performance
          await customStatement('PRAGMA journal_mode = WAL');
        },
      );

  // ── Reading History helpers (direct access, no dedicated DAO) ──

  Future<int> addReadingHistory({
    required int surahNumber,
    required int ayahNumber,
    String readingMode = 'reading',
    int timeSpentSeconds = 0,
  }) {
    return into(readingHistory).insert(ReadingHistoryCompanion.insert(
      surahNumber: Value(surahNumber),
      ayahNumber: Value(ayahNumber),
      readingMode: Value(readingMode),
      timeSpentSeconds: Value(timeSpentSeconds),
      readAt: Value(DateTime.now()),
    ));
  }

  Future<List<ReadingHistory>> getReadingHistory({int limit = 50}) {
    return (select(readingHistory)
          ..orderBy([
            (t) => OrderingTerm.desc(t.readAt),
          ])
          ..limit(limit))
        .get();
  }

  Future<List<ReadingHistory>> getReadingHistoryBySurah(int surahNumber) {
    return (select(readingHistory)
          ..where((t) => t.surahNumber.equals(surahNumber))
          ..orderBy([
            (t) => OrderingTerm.desc(t.readAt),
          ]))
        .get();
  }

  Future<void> pruneReadingHistory(int maxEntries) async {
    await customStatement(
      'DELETE FROM reading_history WHERE id NOT IN ('
      '  SELECT id FROM reading_history ORDER BY read_at DESC LIMIT ?'
      ')',
      [maxEntries],
    );
  }

  Future<int> clearReadingHistory() {
    return delete(readingHistory).go();
  }

  // ── Search History helpers ─────────────────────────────────────

  Future<int> addSearchHistory({
    required String query,
    String searchScope = 'quran',
    int resultCount = 0,
  }) {
    return into(searchHistory).insert(SearchHistoryCompanion.insert(
      query: Value(query),
      searchScope: Value(searchScope),
      resultCount: Value(resultCount),
      searchedAt: Value(DateTime.now()),
    ));
  }

  Future<List<SearchHistory>> getSearchHistory({int limit = 50}) {
    return (select(searchHistory)
          ..orderBy([
            (t) => OrderingTerm.desc(t.searchedAt),
          ])
          ..limit(limit))
        .get();
  }

  Future<List<SearchHistory>> getSearchHistoryByScope(
      String scope, {int limit = 50}) {
    return (select(searchHistory)
          ..where((t) => t.searchScope.equals(scope))
          ..orderBy([
            (t) => OrderingTerm.desc(t.searchedAt),
          ])
          ..limit(limit))
        .get();
  }

  /// Search for matching queries (prefix match)
  Future<List<SearchHistory>> searchHistory(String prefix, {int limit = 10}) {
    final pattern = '$prefix%';
    return (select(searchHistory)
          ..where((t) => t.query.like(pattern))
          ..orderBy([
            (t) => OrderingTerm.desc(t.searchedAt),
          ])
          ..limit(limit))
        .get();
  }

  Future<void> pruneSearchHistory(int maxEntries) async {
    await customStatement(
      'DELETE FROM search_history WHERE id NOT IN ('
      '  SELECT id FROM search_history ORDER BY searched_at DESC LIMIT ?'
      ')',
      [maxEntries],
    );
  }

  Future<int> deleteSearchEntry(int id) {
    return (delete(searchHistory)..where((t) => t.id.equals(id))).go();
  }

  Future<int> clearSearchHistory() {
    return delete(searchHistory).go();
  }

  // ── Bulk Operations ────────────────────────────────────────────

  /// Delete all data from all tables (used for reset functionality)
  Future<void> clearAllData() async {
    await bookmarkDao.clearAllBookmarks();
    await notesDao.clearAllNotes();
    await hifdhDao.clearAllProgress();
    await hifdhDao.clearAllRevisions();
    await hifdhDao.clearAllMistakes();
    await audioDao.clearAllDownloads();
    await clearReadingHistory();
    await clearSearchHistory();
  }

  /// Get total database size on disk
  Future<int> getDatabaseSizeBytes() async {
    final dbPath = await _databasePath();
    int totalSize = 0;
    final file = File(dbPath);
    if (await file.exists()) {
      totalSize += await file.length();
    }
    final walFile = File('$dbPath-wal');
    if (await walFile.exists()) {
      totalSize += await walFile.length();
    }
    final shmFile = File('$dbPath-shm');
    if (await shmFile.exists()) {
      totalSize += await shmFile.length();
    }
    return totalSize;
  }
}

// ── Connection Helper ─────────────────────────────────────────────

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.databaseName));
    return NativeDatabase.createInBackground(file);
  });
}

Future<String> _databasePath() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  return p.join(dbFolder.path, AppConstants.databaseName);
}
