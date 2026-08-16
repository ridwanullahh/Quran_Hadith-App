import 'package:sqflite/sqflite.dart';

import '../tables.dart';
import '../database.dart' show notifyNotesChanged, notesStream;

class NotesDao {
  final Database _db;
  NotesDao(this._db);

  // ── Create ──────────────────────────────────────────────────────
  Future<int> addNote({
    required int surahNumber,
    required int ayahNumber,
    required String content,
    String title = '',
    int colorIndex = 0,
  }) async {
    final now = DateTime.now();
    final id = await _db.insert('notes', {
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'content': content,
      'title': title,
      'color_index': colorIndex,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
    notifyNotesChanged();
    return id;
  }

  // ── Read ────────────────────────────────────────────────────────
  Future<List<Note>> getAllNotes() async {
    final rows = await _db.query('notes', orderBy: 'updated_at DESC');
    return rows.map((r) => Note.fromMap(r)).toList();
  }

  Future<List<Note>> getNotesBySurah(int surahNumber) async {
    final rows = await _db.query('notes',
        where: 'surah_number = ?',
        whereArgs: [surahNumber],
        orderBy: 'ayah_number ASC, updated_at DESC');
    return rows.map((r) => Note.fromMap(r)).toList();
  }

  Future<List<Note>> getNotesForAyah(int surahNumber, int ayahNumber) async {
    final rows = await _db.query('notes',
        where: 'surah_number = ? AND ayah_number = ?',
        whereArgs: [surahNumber, ayahNumber],
        orderBy: 'updated_at DESC');
    return rows.map((r) => Note.fromMap(r)).toList();
  }

  Future<Note?> getNoteById(int id) async {
    final rows = await _db.query('notes',
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return Note.fromMap(rows.first);
  }

  Future<List<Note>> searchNotes(String query) async {
    final pattern = '%$query%';
    final rows = await _db.query('notes',
        where: 'content LIKE ? OR title LIKE ?',
        whereArgs: [pattern, pattern],
        orderBy: 'updated_at DESC');
    return rows.map((r) => Note.fromMap(r)).toList();
  }

  Future<List<Note>> getRecentNotes({int limit = 10}) async {
    final rows = await _db.query('notes',
        orderBy: 'updated_at DESC', limit: limit);
    return rows.map((r) => Note.fromMap(r)).toList();
  }

  Stream<List<Note>> watchAllNotes() async* {
    yield await getAllNotes();
    await for (final _ in notesStream) {
      yield await getAllNotes();
    }
  }

  Stream<List<Note>> watchNotesBySurah(int surahNumber) async* {
    yield await getNotesBySurah(surahNumber);
    await for (final _ in notesStream) {
      yield await getNotesBySurah(surahNumber);
    }
  }

  Stream<List<Note>> watchNotesForAyah(int surahNumber, int ayahNumber) async* {
    yield await getNotesForAyah(surahNumber, ayahNumber);
    await for (final _ in notesStream) {
      yield await getNotesForAyah(surahNumber, ayahNumber);
    }
  }

  // ── Update ──────────────────────────────────────────────────────
  Future<bool> updateNote({
    required int id,
    required String content,
    String? title,
    int? colorIndex,
  }) async {
    final values = <String, dynamic>{
      'content': content,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (title != null) values['title'] = title;
    if (colorIndex != null) values['color_index'] = colorIndex;
    final count =
        await _db.update('notes', values, where: 'id = ?', whereArgs: [id]);
    if (count > 0) notifyNotesChanged();
    return count > 0;
  }

  // ── Delete ──────────────────────────────────────────────────────
  Future<int> deleteNote(int id) async {
    final count =
        await _db.delete('notes', where: 'id = ?', whereArgs: [id]);
    if (count > 0) notifyNotesChanged();
    return count;
  }

  Future<int> deleteNotesForAyah(int surahNumber, int ayahNumber) async {
    final count = await _db.delete('notes',
        where: 'surah_number = ? AND ayah_number = ?',
        whereArgs: [surahNumber, ayahNumber]);
    if (count > 0) notifyNotesChanged();
    return count;
  }

  Future<int> deleteNotesBySurah(int surahNumber) async {
    final count = await _db.delete('notes',
        where: 'surah_number = ?', whereArgs: [surahNumber]);
    if (count > 0) notifyNotesChanged();
    return count;
  }

  Future<int> clearAllNotes() async {
    final count = await _db.delete('notes');
    if (count > 0) notifyNotesChanged();
    return count;
  }

  // ── Count ───────────────────────────────────────────────────────
  Future<int> getNoteCount() async {
    final result = await _db.rawQuery('SELECT COUNT(*) as cnt FROM notes');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getNoteCountForSurah(int surahNumber) async {
    final result = await _db.rawQuery(
        'SELECT COUNT(*) as cnt FROM notes WHERE surah_number = ?',
        [surahNumber]);
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
