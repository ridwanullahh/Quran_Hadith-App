import 'package:drift/drift.dart';
import '../tables.dart';
import '../database.dart';

part 'notes_dao.g.dart';

@DriftAccessor(tables: [Notes])
class NotesDao extends DatabaseAccessor<AppDatabase>
    with _$NotesDaoMixin {
  NotesDao(super.db);

  // ── Create ──────────────────────────────────────────────────────
  Future<int> addNote({
    required int surahNumber,
    required int ayahNumber,
    required String content,
    String title = '',
    int colorIndex = 0,
  }) {
    final now = DateTime.now();
    return into(notes).insert(NotesCompanion.insert(
      surahNumber: Value(surahNumber),
      ayahNumber: Value(ayahNumber),
      content: Value(content),
      title: Value(title),
      colorIndex: Value(colorIndex),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
  }

  // ── Read ────────────────────────────────────────────────────────
  Future<List<Note>> getAllNotes() {
    return (select(notes)
          ..orderBy([
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .get();
  }

  Future<List<Note>> getNotesBySurah(int surahNumber) {
    return (select(notes)
          ..where((t) => t.surahNumber.equals(surahNumber))
          ..orderBy([
            (t) => OrderingTerm.asc(t.ayahNumber),
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .get();
  }

  Future<List<Note>> getNotesForAyah(int surahNumber, int ayahNumber) {
    return (select(notes)
          ..where((t) =>
              t.surahNumber.equals(surahNumber) &
              t.ayahNumber.equals(ayahNumber))
          ..orderBy([
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .get();
  }

  Future<Note?> getNoteById(int id) {
    return (select(notes)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Search notes by content or title
  Future<List<Note>> searchNotes(String query) {
    final pattern = '%$query%';
    return (select(notes)
          ..where((t) =>
              t.content.like(pattern) | t.title.like(pattern))
          ..orderBy([
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .get();
  }

  /// Get recent notes (last N notes by update time)
  Future<List<Note>> getRecentNotes({int limit = 10}) {
    return (select(notes)
          ..orderBy([
            (t) => OrderingTerm.desc(t.updatedAt),
          ])
          ..limit(limit))
        .get();
  }

  /// Watch all notes for reactive UI
  Stream<List<Note>> watchAllNotes() {
    return (select(notes)
          ..orderBy([
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .watch();
  }

  /// Watch notes for a specific surah
  Stream<List<Note>> watchNotesBySurah(int surahNumber) {
    return (select(notes)
          ..where((t) => t.surahNumber.equals(surahNumber))
          ..orderBy([
            (t) => OrderingTerm.asc(t.ayahNumber),
          ]))
        .watch();
  }

  /// Watch notes for a specific ayah
  Stream<List<Note>> watchNotesForAyah(int surahNumber, int ayahNumber) {
    return (select(notes)
          ..where((t) =>
              t.surahNumber.equals(surahNumber) &
              t.ayahNumber.equals(ayahNumber))
          ..orderBy([
            (t) => OrderingTerm.desc(t.updatedAt),
          ]))
        .watch();
  }

  // ── Update ──────────────────────────────────────────────────────
  Future<bool> updateNote({
    required int id,
    required String content,
    String? title,
    int? colorIndex,
  }) {
    return (update(notes)..where((t) => t.id.equals(id))).write(
      NotesCompanion(
        content: Value(content),
        title: title != null ? Value(title) : const Value.absent(),
        colorIndex:
            colorIndex != null ? Value(colorIndex) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    ).then((rows) => rows > 0);
  }

  // ── Delete ──────────────────────────────────────────────────────
  Future<int> deleteNote(int id) {
    return (delete(notes)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteNotesForAyah(int surahNumber, int ayahNumber) {
    return (delete(notes)
          ..where((t) =>
              t.surahNumber.equals(surahNumber) &
              t.ayahNumber.equals(ayahNumber)))
        .go();
  }

  Future<int> deleteNotesBySurah(int surahNumber) {
    return (delete(notes)..where((t) => t.surahNumber.equals(surahNumber))).go();
  }

  Future<int> clearAllNotes() {
    return delete(notes).go();
  }

  // ── Count ───────────────────────────────────────────────────────
  Future<int> getNoteCount() async {
    final countExpr = notes.id.count();
    final query = selectOnly(notes)..addColumns([countExpr]);
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  Future<int> getNoteCountForSurah(int surahNumber) async {
    final countExpr = notes.id.count();
    final query = selectOnly(notes)
      ..addColumns([countExpr])
      ..where(notes.surahNumber.equals(surahNumber));
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }
}
