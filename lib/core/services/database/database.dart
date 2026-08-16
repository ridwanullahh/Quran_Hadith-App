import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../constants/app_constants.dart';
import 'tables.dart';
export 'tables.dart';
import 'daos/bookmark_dao.dart';
import 'daos/notes_dao.dart';
import 'daos/hifdh_dao.dart';
import 'daos/audio_dao.dart';

export 'daos/bookmark_dao.dart';
export 'daos/notes_dao.dart';
export 'daos/hifdh_dao.dart';
export 'daos/audio_dao.dart';

// ═══════════════════════════════════════════════════════════════════
// Stream controllers for reactive queries
// ═══════════════════════════════════════════════════════════════════

final _bookmarksController = StreamController<List<Bookmark>>.broadcast();
final _notesController = StreamController<List<Note>>.broadcast();
final _progressController =
    StreamController<List<MemorizationProgress>>.broadcast();
final _revisionsController = StreamController<List<RevisionSchedule>>.broadcast();
final _mistakesController = StreamController<List<MistakeLog>>.broadcast();

/// Notify that bookmarks table changed
void notifyBookmarksChanged() {
  // Re-emit current data is handled by the stream implementation
  _bookmarksController.add(const []);
}

/// Notify that notes table changed
void notifyNotesChanged() {
  _notesController.add(const []);
}

/// Notify that memorization progress table changed
void notifyProgressChanged() {
  _progressController.add(const []);
}

/// Notify that revision schedule table changed
void notifyRevisionsChanged() {
  _revisionsController.add(const []);
}

/// Notify that mistakes table changed
void notifyMistakesChanged() {
  _mistakesController.add(const []);
}

class AppDatabase {
  late Database _db;

  // ── DAOs ─────────────────────────────────────────────────────────
  late final BookmarkDao bookmarkDao;
  late final NotesDao notesDao;
  late final HifdhDao hifdhDao;
  late final AudioDao audioDao;

  AppDatabase._(this._db) {
    bookmarkDao = BookmarkDao(_db);
    notesDao = NotesDao(_db);
    hifdhDao = HifdhDao(_db);
    audioDao = AudioDao(_db);
  }

  static AppDatabase? _instance;

  /// Must be called before first use of [instance].
  static Future<AppDatabase> ensureInitialized() async {
    if (_instance != null) return _instance!;
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dbFolder.path, AppConstants.databaseName);
    final db = await openDatabase(
      dbPath,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute('PRAGMA journal_mode = WAL');
    _instance = AppDatabase._(db);
    return _instance!;
  }

  /// Singleton instance. Call [ensureInitialized()] first.
  static AppDatabase get instance {
    assert(_instance != null, 'Call AppDatabase.ensureInitialized() first');
    return _instance!;
  }

  /// For testing: pass a custom database
  AppDatabase.forTesting(this._db) {
    bookmarkDao = BookmarkDao(_db);
    notesDao = NotesDao(_db);
    hifdhDao = HifdhDao(_db);
    audioDao = AudioDao(_db);
  } // coverage:ignore-line

  // ═══════════════════════════════════════════════════════════════
  // Database creation & migration
  // ═══════════════════════════════════════════════════════════════

  static Future<void> _onCreate(Database db, int version) async {
    // ── Bookmarks ──────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        juz_number INTEGER NOT NULL DEFAULT 0,
        page INTEGER NOT NULL DEFAULT 0,
        surah_name TEXT NOT NULL,
        ayah_text TEXT NOT NULL DEFAULT '',
        category TEXT NOT NULL DEFAULT 'general',
        created_at TEXT NOT NULL,
        UNIQUE(surah_number, ayah_number)
      )
    ''');

    // ── Notes ──────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        content TEXT NOT NULL,
        title TEXT NOT NULL DEFAULT '',
        color_index INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // ── Memorization Progress ──────────────────────────────────────
    await db.execute('''
      CREATE TABLE memorization_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'new',
        repetitions INTEGER NOT NULL DEFAULT 0,
        ease_factor REAL NOT NULL DEFAULT 2.5,
        interval_days INTEGER NOT NULL DEFAULT 1,
        consecutive_correct INTEGER NOT NULL DEFAULT 0,
        total_attempts INTEGER NOT NULL DEFAULT 0,
        total_correct INTEGER NOT NULL DEFAULT 0,
        last_reviewed TEXT,
        next_review_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(surah_number, ayah_number)
      )
    ''');

    // ── Revision Schedule ──────────────────────────────────────────
    await db.execute('''
      CREATE TABLE revision_schedule (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        ayah_start INTEGER NOT NULL,
        ayah_end INTEGER NOT NULL,
        scheduled_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        priority INTEGER NOT NULL DEFAULT 0,
        notes TEXT NOT NULL DEFAULT '',
        completed_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // ── Mistake Log ────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE mistake_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        mistake_type TEXT NOT NULL,
        mistaken_text TEXT NOT NULL DEFAULT '',
        correct_text TEXT NOT NULL DEFAULT '',
        context TEXT NOT NULL DEFAULT '',
        review_count INTEGER NOT NULL DEFAULT 0,
        is_resolved INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        resolved_at TEXT
      )
    ''');

    // ── Reading History ────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE reading_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        reading_mode TEXT NOT NULL DEFAULT 'reading',
        time_spent_seconds INTEGER NOT NULL DEFAULT 0,
        read_at TEXT NOT NULL
      )
    ''');

    // ── Search History ─────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL,
        search_scope TEXT NOT NULL DEFAULT 'quran',
        result_count INTEGER NOT NULL DEFAULT 0,
        searched_at TEXT NOT NULL
      )
    ''');

    // ── Audio Downloads ────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE audio_downloads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL DEFAULT 0,
        reciter_id TEXT NOT NULL,
        file_path TEXT NOT NULL DEFAULT '',
        file_size_bytes INTEGER NOT NULL DEFAULT 0,
        download_status TEXT NOT NULL DEFAULT 'completed',
        downloaded_at TEXT NOT NULL,
        file_hash TEXT NOT NULL DEFAULT '',
        playback_count INTEGER NOT NULL DEFAULT 0,
        last_played_at TEXT,
        UNIQUE(surah_number, ayah_number, reciter_id)
      )
    ''');

    // ── Indexes ────────────────────────────────────────────────────
    await db.execute(
        'CREATE INDEX idx_bookmarks_surah_ayah ON bookmarks (surah_number, ayah_number)');
    await db.execute(
        'CREATE INDEX idx_bookmarks_category ON bookmarks (category)');
    await db.execute(
        'CREATE INDEX idx_bookmarks_created ON bookmarks (created_at)');
    await db.execute(
        'CREATE INDEX idx_notes_surah_ayah ON notes (surah_number, ayah_number)');
    await db.execute('CREATE INDEX idx_notes_updated ON notes (updated_at)');
    await db.execute(
        'CREATE INDEX idx_memorization_surah_ayah ON memorization_progress (surah_number, ayah_number)');
    await db.execute(
        'CREATE INDEX idx_memorization_status ON memorization_progress (status)');
    await db.execute(
        'CREATE INDEX idx_memorization_next_review ON memorization_progress (next_review_date)');
    await db.execute(
        'CREATE INDEX idx_revision_scheduled ON revision_schedule (scheduled_date)');
    await db.execute(
        'CREATE INDEX idx_revision_status ON revision_schedule (status)');
    await db.execute(
        'CREATE INDEX idx_mistakes_surah ON mistake_log (surah_number)');
    await db.execute(
        'CREATE INDEX idx_mistakes_resolved ON mistake_log (is_resolved)');
    await db.execute(
        'CREATE INDEX idx_reading_history_read_at ON reading_history (read_at)');
    await db.execute(
        'CREATE INDEX idx_search_history_searched ON search_history (searched_at)');
    await db.execute(
        'CREATE INDEX idx_audio_surah_reciter ON audio_downloads (surah_number, reciter_id)');
    await db.execute(
        'CREATE INDEX idx_audio_status ON audio_downloads (download_status)');
  }

  static Future<void> _onUpgrade(Database db, int from, int to) async {
    // Handle future schema migrations here
  }

  // ═══════════════════════════════════════════════════════════════
  // Reading History helpers
  // ═══════════════════════════════════════════════════════════════

  Future<int> addReadingHistory({
    required int surahNumber,
    required int ayahNumber,
    String readingMode = 'reading',
    int timeSpentSeconds = 0,
  }) async {
    return await _db.insert('reading_history', {
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'reading_mode': readingMode,
      'time_spent_seconds': timeSpentSeconds,
      'read_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<ReadingHistory>> getReadingHistory({int limit = 50}) async {
    final rows = await _db.query(
      'reading_history',
      orderBy: 'read_at DESC',
      limit: limit,
    );
    return rows.map((r) => ReadingHistory.fromMap(r)).toList();
  }

  Future<List<ReadingHistory>> getReadingHistoryBySurah(
      int surahNumber) async {
    final rows = await _db.query(
      'reading_history',
      where: 'surah_number = ?',
      whereArgs: [surahNumber],
      orderBy: 'read_at DESC',
    );
    return rows.map((r) => ReadingHistory.fromMap(r)).toList();
  }

  Future<void> pruneReadingHistory(int maxEntries) async {
    await _db.execute(
      'DELETE FROM reading_history WHERE id NOT IN ('
      '  SELECT id FROM reading_history ORDER BY read_at DESC LIMIT ?'
      ')',
      [maxEntries],
    );
  }

  Future<int> clearReadingHistory() async {
    return await _db.delete('reading_history');
  }

  // ═══════════════════════════════════════════════════════════════
  // Search History helpers
  // ═══════════════════════════════════════════════════════════════

  Future<int> addSearchHistory({
    required String query,
    String searchScope = 'quran',
    int resultCount = 0,
  }) async {
    return await _db.insert('search_history', {
      'query': query,
      'search_scope': searchScope,
      'result_count': resultCount,
      'searched_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<SearchHistory>> getSearchHistory({int limit = 50}) async {
    final rows = await _db.query(
      'search_history',
      orderBy: 'searched_at DESC',
      limit: limit,
    );
    return rows.map((r) => SearchHistory.fromMap(r)).toList();
  }

  Future<List<SearchHistory>> getSearchHistoryByScope(String scope,
      {int limit = 50}) async {
    final rows = await _db.query(
      'search_history',
      where: 'search_scope = ?',
      whereArgs: [scope],
      orderBy: 'searched_at DESC',
      limit: limit,
    );
    return rows.map((r) => SearchHistory.fromMap(r)).toList();
  }

  Future<List<SearchHistory>> searchHistory(String prefix,
      {int limit = 10}) async {
    final rows = await _db.query(
      'search_history',
      where: 'query LIKE ?',
      whereArgs: ['$prefix%'],
      orderBy: 'searched_at DESC',
      limit: limit,
    );
    return rows.map((r) => SearchHistory.fromMap(r)).toList();
  }

  Future<void> pruneSearchHistory(int maxEntries) async {
    await _db.execute(
      'DELETE FROM search_history WHERE id NOT IN ('
      '  SELECT id FROM search_history ORDER BY searched_at DESC LIMIT ?'
      ')',
      [maxEntries],
    );
  }

  Future<int> deleteSearchEntry(int id) async {
    return await _db
        .delete('search_history', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearSearchHistory() async {
    return await _db.delete('search_history');
  }

  // ═══════════════════════════════════════════════════════════════
  // Bulk Operations
  // ═══════════════════════════════════════════════════════════════

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

  // ═══════════════════════════════════════════════════════════════
  // Database Size
  // ═══════════════════════════════════════════════════════════════

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

Future<String> _databasePath() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  return p.join(dbFolder.path, AppConstants.databaseName);
}
