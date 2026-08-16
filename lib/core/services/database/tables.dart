// ═══════════════════════════════════════════════════════════════════
// Data model classes for database tables.
// These replace the Drift-generated data classes.
// ═══════════════════════════════════════════════════════════════════

class Bookmark {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final int juzNumber;
  final int page;
  final String surahName;
  final String ayahText;
  final String category;
  final DateTime createdAt;

  const Bookmark({
    this.id = -1,
    required this.surahNumber,
    required this.ayahNumber,
    this.juzNumber = 0,
    this.page = 0,
    required this.surahName,
    this.ayahText = '',
    this.category = 'general',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        if (id != -1) 'id': id,
        'surah_number': surahNumber,
        'ayah_number': ayahNumber,
        'juz_number': juzNumber,
        'page': page,
        'surah_name': surahName,
        'ayah_text': ayahText,
        'category': category,
        'created_at': createdAt.toIso8601String(),
      };

  factory Bookmark.fromMap(Map<String, dynamic> map) => Bookmark(
        id: map['id'] as int,
        surahNumber: map['surah_number'] as int,
        ayahNumber: map['ayah_number'] as int,
        juzNumber: (map['juz_number'] as int?) ?? 0,
        page: (map['page'] as int?) ?? 0,
        surahName: map['surah_name'] as String,
        ayahText: (map['ayah_text'] as String?) ?? '',
        category: (map['category'] as String?) ?? 'general',
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

class Note {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final String content;
  final String title;
  final int colorIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    this.id = -1,
    required this.surahNumber,
    required this.ayahNumber,
    required this.content,
    this.title = '',
    this.colorIndex = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        if (id != -1) 'id': id,
        'surah_number': surahNumber,
        'ayah_number': ayahNumber,
        'content': content,
        'title': title,
        'color_index': colorIndex,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Note.fromMap(Map<String, dynamic> map) => Note(
        id: map['id'] as int,
        surahNumber: map['surah_number'] as int,
        ayahNumber: map['ayah_number'] as int,
        content: map['content'] as String,
        title: (map['title'] as String?) ?? '',
        colorIndex: (map['color_index'] as int?) ?? 0,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: DateTime.parse(map['updated_at'] as String),
      );
}

class MemorizationProgress {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final String status;
  final int repetitions;
  final double easeFactor;
  final int intervalDays;
  final int consecutiveCorrect;
  final int totalAttempts;
  final int totalCorrect;
  final DateTime? lastReviewed;
  final DateTime? nextReviewDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MemorizationProgress({
    this.id = -1,
    required this.surahNumber,
    required this.ayahNumber,
    this.status = 'new',
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.intervalDays = 1,
    this.consecutiveCorrect = 0,
    this.totalAttempts = 0,
    this.totalCorrect = 0,
    this.lastReviewed,
    this.nextReviewDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        if (id != -1) 'id': id,
        'surah_number': surahNumber,
        'ayah_number': ayahNumber,
        'status': status,
        'repetitions': repetitions,
        'ease_factor': easeFactor,
        'interval_days': intervalDays,
        'consecutive_correct': consecutiveCorrect,
        'total_attempts': totalAttempts,
        'total_correct': totalCorrect,
        'last_reviewed': lastReviewed?.toIso8601String(),
        'next_review_date': nextReviewDate?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory MemorizationProgress.fromMap(Map<String, dynamic> map) => MemorizationProgress(
        id: map['id'] as int,
        surahNumber: map['surah_number'] as int,
        ayahNumber: map['ayah_number'] as int,
        status: (map['status'] as String?) ?? 'new',
        repetitions: (map['repetitions'] as int?) ?? 0,
        easeFactor: (map['ease_factor'] as num?)?.toDouble() ?? 2.5,
        intervalDays: (map['interval_days'] as int?) ?? 1,
        consecutiveCorrect: (map['consecutive_correct'] as int?) ?? 0,
        totalAttempts: (map['total_attempts'] as int?) ?? 0,
        totalCorrect: (map['total_correct'] as int?) ?? 0,
        lastReviewed: map['last_reviewed'] != null
            ? DateTime.parse(map['last_reviewed'] as String)
            : null,
        nextReviewDate: map['next_review_date'] != null
            ? DateTime.parse(map['next_review_date'] as String)
            : null,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: DateTime.parse(map['updated_at'] as String),
      );
}

class RevisionSchedule {
  final int id;
  final int surahNumber;
  final int ayahStart;
  final int ayahEnd;
  final DateTime scheduledDate;
  final String status;
  final int priority;
  final String notes;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RevisionSchedule({
    this.id = -1,
    required this.surahNumber,
    required this.ayahStart,
    required this.ayahEnd,
    required this.scheduledDate,
    this.status = 'pending',
    this.priority = 0,
    this.notes = '',
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        if (id != -1) 'id': id,
        'surah_number': surahNumber,
        'ayah_start': ayahStart,
        'ayah_end': ayahEnd,
        'scheduled_date': scheduledDate.toIso8601String(),
        'status': status,
        'priority': priority,
        'notes': notes,
        'completed_at': completedAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory RevisionSchedule.fromMap(Map<String, dynamic> map) => RevisionSchedule(
        id: map['id'] as int,
        surahNumber: map['surah_number'] as int,
        ayahStart: map['ayah_start'] as int,
        ayahEnd: map['ayah_end'] as int,
        scheduledDate: DateTime.parse(map['scheduled_date'] as String),
        status: (map['status'] as String?) ?? 'pending',
        priority: (map['priority'] as int?) ?? 0,
        notes: (map['notes'] as String?) ?? '',
        completedAt: map['completed_at'] != null
            ? DateTime.parse(map['completed_at'] as String)
            : null,
        createdAt: DateTime.parse(map['created_at'] as String),
        updatedAt: DateTime.parse(map['updated_at'] as String),
      );
}

class MistakeLog {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final String mistakeType;
  final String mistakenText;
  final String correctText;
  final String context;
  final int reviewCount;
  final bool isResolved;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const MistakeLog({
    this.id = -1,
    required this.surahNumber,
    required this.ayahNumber,
    required this.mistakeType,
    this.mistakenText = '',
    this.correctText = '',
    this.context = '',
    this.reviewCount = 0,
    this.isResolved = false,
    required this.createdAt,
    this.resolvedAt,
  });

  Map<String, dynamic> toMap() => {
        if (id != -1) 'id': id,
        'surah_number': surahNumber,
        'ayah_number': ayahNumber,
        'mistake_type': mistakeType,
        'mistaken_text': mistakenText,
        'correct_text': correctText,
        'context': context,
        'review_count': reviewCount,
        'is_resolved': isResolved ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
        'resolved_at': resolvedAt?.toIso8601String(),
      };

  factory MistakeLog.fromMap(Map<String, dynamic> map) => MistakeLog(
        id: map['id'] as int,
        surahNumber: map['surah_number'] as int,
        ayahNumber: map['ayah_number'] as int,
        mistakeType: map['mistake_type'] as String,
        mistakenText: (map['mistaken_text'] as String?) ?? '',
        correctText: (map['correct_text'] as String?) ?? '',
        context: (map['context'] as String?) ?? '',
        reviewCount: (map['review_count'] as int?) ?? 0,
        isResolved: (map['is_resolved'] as int?) == 1,
        createdAt: DateTime.parse(map['created_at'] as String),
        resolvedAt: map['resolved_at'] != null
            ? DateTime.parse(map['resolved_at'] as String)
            : null,
      );
}

class ReadingHistory {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final String readingMode;
  final int timeSpentSeconds;
  final DateTime readAt;

  const ReadingHistory({
    this.id = -1,
    required this.surahNumber,
    required this.ayahNumber,
    this.readingMode = 'reading',
    this.timeSpentSeconds = 0,
    required this.readAt,
  });

  Map<String, dynamic> toMap() => {
        if (id != -1) 'id': id,
        'surah_number': surahNumber,
        'ayah_number': ayahNumber,
        'reading_mode': readingMode,
        'time_spent_seconds': timeSpentSeconds,
        'read_at': readAt.toIso8601String(),
      };

  factory ReadingHistory.fromMap(Map<String, dynamic> map) => ReadingHistory(
        id: map['id'] as int,
        surahNumber: map['surah_number'] as int,
        ayahNumber: map['ayah_number'] as int,
        readingMode: (map['reading_mode'] as String?) ?? 'reading',
        timeSpentSeconds: (map['time_spent_seconds'] as int?) ?? 0,
        readAt: DateTime.parse(map['read_at'] as String),
      );
}

class SearchHistory {
  final int id;
  final String query;
  final String searchScope;
  final int resultCount;
  final DateTime searchedAt;

  const SearchHistory({
    this.id = -1,
    required this.query,
    this.searchScope = 'quran',
    this.resultCount = 0,
    required this.searchedAt,
  });

  Map<String, dynamic> toMap() => {
        if (id != -1) 'id': id,
        'query': query,
        'search_scope': searchScope,
        'result_count': resultCount,
        'searched_at': searchedAt.toIso8601String(),
      };

  factory SearchHistory.fromMap(Map<String, dynamic> map) => SearchHistory(
        id: map['id'] as int,
        query: map['query'] as String,
        searchScope: (map['search_scope'] as String?) ?? 'quran',
        resultCount: (map['result_count'] as int?) ?? 0,
        searchedAt: DateTime.parse(map['searched_at'] as String),
      );
}

class AudioDownload {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final String reciterId;
  final String filePath;
  final int fileSizeBytes;
  final String downloadStatus;
  final DateTime downloadedAt;
  final String fileHash;
  final int playbackCount;
  final DateTime? lastPlayedAt;

  const AudioDownload({
    this.id = -1,
    required this.surahNumber,
    this.ayahNumber = 0,
    required this.reciterId,
    this.filePath = '',
    this.fileSizeBytes = 0,
    this.downloadStatus = 'completed',
    required this.downloadedAt,
    this.fileHash = '',
    this.playbackCount = 0,
    this.lastPlayedAt,
  });

  Map<String, dynamic> toMap() => {
        if (id != -1) 'id': id,
        'surah_number': surahNumber,
        'ayah_number': ayahNumber,
        'reciter_id': reciterId,
        'file_path': filePath,
        'file_size_bytes': fileSizeBytes,
        'download_status': downloadStatus,
        'downloaded_at': downloadedAt.toIso8601String(),
        'file_hash': fileHash,
        'playback_count': playbackCount,
        'last_played_at': lastPlayedAt?.toIso8601String(),
      };

  factory AudioDownload.fromMap(Map<String, dynamic> map) => AudioDownload(
        id: map['id'] as int,
        surahNumber: map['surah_number'] as int,
        ayahNumber: (map['ayah_number'] as int?) ?? 0,
        reciterId: map['reciter_id'] as String,
        filePath: (map['file_path'] as String?) ?? '',
        fileSizeBytes: (map['file_size_bytes'] as int?) ?? 0,
        downloadStatus: (map['download_status'] as String?) ?? 'completed',
        downloadedAt: DateTime.parse(map['downloaded_at'] as String),
        fileHash: (map['file_hash'] as String?) ?? '',
        playbackCount: (map['playback_count'] as int?) ?? 0,
        lastPlayedAt: map['last_played_at'] != null
            ? DateTime.parse(map['last_played_at'] as String)
            : null,
      );
}
