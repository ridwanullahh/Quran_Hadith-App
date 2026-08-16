import 'package:drift/drift.dart';

// ═══════════════════════════════════════════════════════════════════
// Table: Bookmarks
// Stores user bookmarks for specific ayahs
// ═══════════════════════════════════════════════════════════════════
class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();
  IntColumn get juzNumber => integer().withDefault(const Constant(0))();
  IntColumn get page => integer().withDefault(const Constant(0))();
  TextColumn get surahName => text()();
  TextColumn get ayahText => text().withDefault(const Constant(''))();
  TextColumn get category => text().withDefault(const Constant('general'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {surahNumber, ayahNumber},
      ];
}

// ═══════════════════════════════════════════════════════════════════
// Table: Notes
// User annotations and personal notes on ayahs
// ═══════════════════════════════════════════════════════════════════
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();
  TextColumn get content => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  IntColumn get colorIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ═══════════════════════════════════════════════════════════════════
// Table: MemorizationProgress
// Tracks hifdh (memorization) progress per ayah
// ═══════════════════════════════════════════════════════════════════
class MemorizationProgress extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();
  TextColumn get status =>
      text().withDefault(const Constant('new'))(); // new, learning, review, memorized, mastered
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  RealColumn get easeFactor =>
      real().withDefault(const Constant(2.5))(); // SM-2 algorithm
  IntColumn get intervalDays => integer().withDefault(const Constant(1))();
  IntColumn get consecutiveCorrect =>
      integer().withDefault(const Constant(0))();
  IntColumn get totalAttempts => integer().withDefault(const Constant(0))();
  IntColumn get totalCorrect => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastReviewed => dateTime().nullable()();
  DateTimeColumn get nextReviewDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {surahNumber, ayahNumber},
      ];
}

// ═══════════════════════════════════════════════════════════════════
// Table: RevisionSchedule
// Schedules for spaced-repetition revision
// ═══════════════════════════════════════════════════════════════════
class RevisionSchedule extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahStart => integer()();
  IntColumn get ayahEnd => integer()();
  DateTimeColumn get scheduledDate => dateTime()();
  TextColumn get status =>
      text().withDefault(const Constant('pending'))(); // pending, completed, skipped, overdue
  IntColumn get priority => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ═══════════════════════════════════════════════════════════════════
// Table: MistakeLog
// Records mistakes during memorization testing
// ═══════════════════════════════════════════════════════════════════
class MistakeLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();
  TextColumn get mistakeType => text()(); // hesitation, minor_error, major_error, skipped_word, skipped_ayah, wrong_order
  TextColumn get mistakenText => text().withDefault(const Constant(''))();
  TextColumn get correctText => text().withDefault(const Constant(''))();
  TextColumn get context => text().withDefault(const Constant(''))();
  IntColumn get reviewCount => integer().withDefault(const Constant(0))();
  BoolColumn get isResolved => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get resolvedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ═══════════════════════════════════════════════════════════════════
// Table: ReadingHistory
// Tracks what the user has read
// ═══════════════════════════════════════════════════════════════════
class ReadingHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber => integer()();
  TextColumn get readingMode =>
      text().withDefault(const Constant('reading'))(); // reading, translation, tafseer
  IntColumn get timeSpentSeconds =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get readAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ═══════════════════════════════════════════════════════════════════
// Table: SearchHistory
// Tracks user search queries for quick re-search
// ═══════════════════════════════════════════════════════════════════
class SearchHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get query => text()();
  TextColumn get searchScope =>
      text().withDefault(const Constant('quran'))(); // quran, hadith, all
  IntColumn get resultCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get searchedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ═══════════════════════════════════════════════════════════════════
// Table: AudioDownload
// Tracks downloaded audio files for offline playback
// ═══════════════════════════════════════════════════════════════════
class AudioDownloads extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get surahNumber => integer()();
  IntColumn get ayahNumber =>
      integer().withDefault(const Constant(0))(); // 0 means full surah
  TextColumn get reciterId => text()();
  TextColumn get filePath => text()();
  IntColumn get fileSizeBytes => integer().withDefault(const Constant(0))();
  TextColumn get downloadStatus =>
      text().withDefault(const Constant('completed'))(); // pending, downloading, completed, failed, cancelled
  DateTimeColumn get downloadedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get fileHash => text().withDefault(const Constant(''))();
  IntColumn get playbackCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {surahNumber, ayahNumber, reciterId},
      ];
}
