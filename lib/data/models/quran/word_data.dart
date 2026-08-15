import 'dart:convert';

/// Word-by-word analysis data for Quranic ayahs
class WordData {
  final int number;
  final int ayahNumber;
  final int wordNumber;
  final int wordPosition;
  final String textArabic;
  final String textTransliteration;
  final String? translation;
  final String? rootLetters;
  final List<String>? rootWords;
  final String? partOfSpeech; // noun, verb, particle, pronoun, etc.
  final String? morphology;
  final String? grammarNote;

  const WordData({
    required this.number,
    required this.ayahNumber,
    required this.wordNumber,
    required this.wordPosition,
    required this.textArabic,
    required this.textTransliteration,
    this.translation,
    this.rootLetters,
    this.rootWords,
    this.partOfSpeech,
    this.morphology,
    this.grammarNote,
  });

  factory WordData.fromJson(Map<String, dynamic> json) {
    return WordData(
      number: json['number'] as int? ?? 0,
      ayahNumber: json['ayah_number'] as int? ??
          json['ayahNumber'] as int? ?? 0,
      wordNumber: json['word_number'] as int? ??
          json['wordNumber'] as int? ?? 0,
      wordPosition: json['word_position'] as int? ??
          json['wordPosition'] as int? ?? 0,
      textArabic: json['text_arabic'] as String? ??
          json['textArabic'] as String? ??
          json['arabic'] as String? ?? '',
      textTransliteration: json['text_transliteration'] as String? ??
          json['textTransliteration'] as String? ??
          json['transliteration'] as String? ?? '',
      translation: json['translation'] as String? ??
          json['meaning'] as String?,
      rootLetters: json['root_letters'] as String? ??
          json['rootLetters'] as String? ??
          json['root'] as String?,
      rootWords: (json['root_words'] as List<dynamic>?)?.cast<String>() ??
          (json['rootWords'] as List<dynamic>?)?.cast<String>(),
      partOfSpeech: json['part_of_speech'] as String? ??
          json['partOfSpeech'] as String? ??
          json['pos'] as String?,
      morphology: json['morphology'] as String? ??
          json['morphology_detail'] as String?,
      grammarNote: json['grammar_note'] as String? ??
          json['grammarNote'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'ayah_number': ayahNumber,
      'word_number': wordNumber,
      'word_position': wordPosition,
      'text_arabic': textArabic,
      'text_transliteration': textTransliteration,
      'translation': translation,
      'root_letters': rootLetters,
      'root_words': rootWords,
      'part_of_speech': partOfSpeech,
      'morphology': morphology,
      'grammar_note': grammarNote,
    };
  }

  /// Whether this word has root analysis available
  bool get hasRootAnalysis =>
      rootLetters != null && rootLetters!.isNotEmpty;

  /// Whether this word has morphological details
  bool get hasMorphology =>
      morphology != null && morphology!.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WordData && other.number == number;
  }

  @override
  int get hashCode => number.hashCode;

  @override
  String toString() =>
      'WordData($number [$ayahNumber:$wordPosition] $textArabic)';
}

/// Ayah word analysis container - groups all words of an ayah
/// with optional grammar notes for the entire ayah
class AyahWordAnalysis {
  final int ayahNumber;
  final int surahNumber;
  final List<WordData> words;
  final String? ayahGrammarNote;

  const AyahWordAnalysis({
    required this.ayahNumber,
    required this.surahNumber,
    required this.words,
    this.ayahGrammarNote,
  });

  /// Get word at a specific position (0-indexed)
  WordData? wordAt(int wordIndex) {
    if (wordIndex < 0 || wordIndex >= words.length) return null;
    return words[wordIndex];
  }

  /// Get word by its word_number field
  WordData? wordByNumber(int wordNumber) {
    for (final w in words) {
      if (w.wordNumber == wordNumber) return w;
    }
    return null;
  }

  /// Total word count in this ayah
  int get wordCount => words.length;

  /// All unique root letters found in this ayah
  List<String> get uniqueRoots {
    final roots = <String>{};
    for (final w in words) {
      if (w.rootLetters != null && w.rootLetters!.isNotEmpty) {
        roots.add(w.rootLetters!);
      }
    }
    return roots.toList()..sort();
  }

  /// Full Arabic text reconstructed from word data
  String get fullArabicText =>
      words.map((w) => w.textArabic).join(' ');

  /// Full transliteration text
  String get fullTransliterationText =>
      words.map((w) => w.textTransliteration).join(' ');

  /// Full translation text
  String get fullTranslationText =>
      words.map((w) => w.translation ?? '').join(' ');

  factory AyahWordAnalysis.fromJson(Map<String, dynamic> json) {
    final wordsList = (json['words'] as List<dynamic>?)
            ?.map((w) => WordData.fromJson(w as Map<String, dynamic>))
            .toList() ??
        <WordData>[];

    return AyahWordAnalysis(
      ayahNumber: json['ayah_number'] as int? ??
          json['ayahNumber'] as int? ?? 0,
      surahNumber: json['surah_number'] as int? ??
          json['surahNumber'] as int? ?? 0,
      words: wordsList,
      ayahGrammarNote: json['ayah_grammar_note'] as String? ??
          json['ayahGrammarNote'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ayah_number': ayahNumber,
      'surah_number': surahNumber,
      'words': words.map((w) => w.toJson()).toList(),
      'ayah_grammar_note': ayahGrammarNote,
    };
  }
}

/// Parse word analysis for a single ayah
AyahWordAnalysis parseWordAnalysis(String jsonString) {
  return AyahWordAnalysis.fromJson(
    json.decode(jsonString) as Map<String, dynamic>,
  );
}

/// Parse a list of word data from JSON string
List<WordData> parseWordList(String jsonString) {
  final List<dynamic> decoded = json.decode(jsonString);
  return decoded
      .map((item) => WordData.fromJson(item as Map<String, dynamic>))
      .toList();
}