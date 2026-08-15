import 'dart:convert';

class AyahData {
  final int number;
  final int surahNumber;
  final int ayahNumber;
  final String textUthmani;
  final String? textIndopak;
  final int juzNumber;
  final int? page;
  final int? hizbQuarter;
  final bool sajda;
  final String? sajdaType; // recommended or obligatory

  const AyahData({
    required this.number,
    required this.surahNumber,
    required this.ayahNumber,
    required this.textUthmani,
    this.textIndopak,
    required this.juzNumber,
    this.page,
    this.hizbQuarter,
    this.sajda = false,
    this.sajdaType,
  });

  factory AyahData.fromJson(Map<String, dynamic> json) {
    return AyahData(
      number: json['number'] as int? ?? 0,
      surahNumber: json['surah_number'] as int? ??
          json['surahNumber'] as int? ?? 0,
      ayahNumber: json['ayah_number'] as int? ??
          json['ayahNumber'] as int? ??
          json['ayat_number'] as int? ??
          json['ayatNumber'] as int? ?? 0,
      textUthmani: json['text_uthmani'] as String? ??
          json['textUthmani'] as String? ??
          json['text'] as String? ?? '',
      textIndopak: json['text_indopak'] as String? ??
          json['textIndopak'] as String?,
      juzNumber: json['juz_number'] as int? ??
          json['juzNumber'] as int? ?? 0,
      page: json['page'] as int?,
      hizbQuarter: json['hizb_quarter'] as int? ??
          json['hizbQuarter'] as int?,
      sajda: json['sajda'] as bool? ?? false,
      sajdaType: json['sajda_type'] as String? ??
          json['sajdaType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'text_uthmani': textUthmani,
      'text_indopak': textIndopak,
      'juz_number': juzNumber,
      'page': page,
      'hizb_quarter': hizbQuarter,
      'sajda': sajda,
      'sajda_type': sajdaType,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AyahData && other.number == number;
  }

  @override
  int get hashCode => number.hashCode;

  @override
  String toString() => 'AyahData($number [${surahNumber}:$ayahNumber])';
}

/// Translation for a single ayah
class AyahTranslation {
  final int surahNumber;
  final int ayahNumber;
  final int number;
  final String text;
  final String language;
  final String? translatorName;

  const AyahTranslation({
    required this.surahNumber,
    required this.ayahNumber,
    required this.number,
    required this.text,
    required this.language,
    this.translatorName,
  });

  factory AyahTranslation.fromJson(Map<String, dynamic> json) {
    return AyahTranslation(
      surahNumber: json['surah_number'] as int? ??
          json['surahNumber'] as int? ?? 0,
      ayahNumber: json['ayah_number'] as int? ??
          json['ayahNumber'] as int? ?? 0,
      number: json['number'] as int? ?? 0,
      text: json['text'] as String? ??
          json['translation'] as String? ?? '',
      language: json['language'] as String? ?? 'en',
      translatorName: json['translator_name'] as String? ??
          json['translatorName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'number': number,
      'text': text,
      'language': language,
      'translator_name': translatorName,
    };
  }
}

/// Tafseer (exegesis) for a single ayah
class AyahTafseer {
  final int surahNumber;
  final int ayahNumber;
  final String text;
  final String source; // e.g., 'ibn_kathir'
  final String? sourceName;

  const AyahTafseer({
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    required this.source,
    this.sourceName,
  });

  factory AyahTafseer.fromJson(Map<String, dynamic> json) {
    return AyahTafseer(
      surahNumber: json['surah_number'] as int? ??
          json['surahNumber'] as int? ?? 0,
      ayahNumber: json['ayah_number'] as int? ??
          json['ayahNumber'] as int? ?? 0,
      text: json['text'] as String? ??
          json['tafseer'] as String? ?? '',
      source: json['source'] as String? ??
          json['tafseer_id'] as String? ?? '',
      sourceName: json['source_name'] as String? ??
          json['sourceName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'text': text,
      'source': source,
      'source_name': sourceName,
    };
  }
}

/// Search result from Quran text search
class QuranSearchResult {
  final int surahNumber;
  final int ayahNumber;
  final int ayahNumberInSurah;
  final String matchedArabic;
  final String? matchedTranslation;
  final String? surahName;
  final String? highlightedText;
  final int matchStartIndex;
  final int matchLength;

  const QuranSearchResult({
    required this.surahNumber,
    required this.ayahNumber,
    required this.ayahNumberInSurah,
    required this.matchedArabic,
    this.matchedTranslation,
    this.surahName,
    this.highlightedText,
    this.matchStartIndex = 0,
    this.matchLength = 0,
  });

  factory QuranSearchResult.fromJson(Map<String, dynamic> json) {
    return QuranSearchResult(
      surahNumber: json['surah_number'] as int? ??
          json['surahNumber'] as int? ?? 0,
      ayahNumber: json['ayah_number'] as int? ??
          json['ayahNumber'] as int? ?? 0,
      ayahNumberInSurah: json['ayah_number_in_surah'] as int? ??
          json['ayahNumberInSurah'] as int? ?? 0,
      matchedArabic: json['matched_arabic'] as String? ??
          json['matchedArabic'] as String? ?? '',
      matchedTranslation: json['matched_translation'] as String? ??
          json['matchedTranslation'] as String?,
      surahName: json['surah_name'] as String? ??
          json['surahName'] as String?,
      highlightedText: json['highlighted_text'] as String? ??
          json['highlightedText'] as String?,
      matchStartIndex: json['match_start_index'] as int? ??
          json['matchStartIndex'] as int? ?? 0,
      matchLength: json['match_length'] as int? ??
          json['matchLength'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'ayah_number_in_surah': ayahNumberInSurah,
      'matched_arabic': matchedArabic,
      'matched_translation': matchedTranslation,
      'surah_name': surahName,
      'highlighted_text': highlightedText,
      'match_start_index': matchStartIndex,
      'match_length': matchLength,
    };
  }
}

/// Parse a list of ayah data from JSON string
List<AyahData> parseAyahList(String jsonString) {
  final List<dynamic> decoded = json.decode(jsonString);
  return decoded
      .map((item) => AyahData.fromJson(item as Map<String, dynamic>))
      .toList();
}

/// Parse a list of translations from JSON string
List<AyahTranslation> parseTranslationList(String jsonString) {
  final List<dynamic> decoded = json.decode(jsonString);
  return decoded
      .map((item) => AyahTranslation.fromJson(item as Map<String, dynamic>))
      .toList();
}

/// Parse a list of tafseer entries from JSON string
List<AyahTafseer> parseTafseerList(String jsonString) {
  final List<dynamic> decoded = json.decode(jsonString);
  return decoded
      .map((item) => AyahTafseer.fromJson(item as Map<String, dynamic>))
      .toList();
}
