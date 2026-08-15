import 'dart:convert';

class SurahInfo {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String nameTransliteration;
  final int totalAyahs;
  final String revelationType; // Meccan or Medinan
  final int revelationOrder;
  final int juzStart;
  final int? juzEnd;
  final int? hizbQuarterStart;
  final int? pageStart;
  final int? pageEnd;
  final String? description;

  const SurahInfo({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.nameTransliteration,
    required this.totalAyahs,
    required this.revelationType,
    required this.revelationOrder,
    required this.juzStart,
    this.juzEnd,
    this.hizbQuarterStart,
    this.pageStart,
    this.pageEnd,
    this.description,
  });

  bool get isMeccan => revelationType == 'Meccan';
  bool get isMedinan => revelationType == 'Medinan';
  bool get hasBismillah => number != 9;

  /// Human-readable duration estimate (rough: ~3 seconds per ayah)
  Duration get estimatedReadingDuration =>
      Duration(seconds: totalAyahs * 3);

  factory SurahInfo.fromJson(Map<String, dynamic> json) {
    return SurahInfo(
      number: json['number'] as int? ?? 0,
      nameArabic: json['name_arabic'] as String? ?? json['nameArabic'] as String? ?? '',
      nameEnglish: json['name_english'] as String? ??
          json['nameEnglish'] as String? ??
          json['english_name'] as String? ??
          json['englishName'] as String? ?? '',
      nameTransliteration: json['name_transliteration'] as String? ??
          json['nameTransliteration'] as String? ?? '',
      totalAyahs: json['total_ayahs'] as int? ??
          json['totalAyahs'] as int? ??
          json['number_of_ayahs'] as int? ??
          json['numberOfAyahs'] as int? ?? 0,
      revelationType: json['revelation_type'] as String? ??
          json['revelationType'] as String? ??
          json['type'] as String? ?? 'Meccan',
      revelationOrder: json['revelation_order'] as int? ??
          json['revelationOrder'] as int? ?? 0,
      juzStart: json['juz_start'] as int? ??
          json['juzStart'] as int? ?? 0,
      juzEnd: json['juz_end'] as int? ??
          json['juzEnd'] as int?,
      hizbQuarterStart: json['hizb_quarter_start'] as int? ??
          json['hizbQuarterStart'] as int?,
      pageStart: json['page_start'] as int? ??
          json['pageStart'] as int?,
      pageEnd: json['page_end'] as int? ??
          json['pageEnd'] as int?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name_arabic': nameArabic,
      'name_english': nameEnglish,
      'name_transliteration': nameTransliteration,
      'total_ayahs': totalAyahs,
      'revelation_type': revelationType,
      'revelation_order': revelationOrder,
      'juz_start': juzStart,
      'juz_end': juzEnd,
      'hizb_quarter_start': hizbQuarterStart,
      'page_start': pageStart,
      'page_end': pageEnd,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SurahInfo && other.number == number;
  }

  @override
  int get hashCode => number.hashCode;

  @override
  String toString() =>
      'SurahInfo($number: $nameEnglish / $nameArabic, $totalAyahs ayahs, $revelationType)';

  /// Create a copy with optional field overrides
  SurahInfo copyWith({
    int? number,
    String? nameArabic,
    String? nameEnglish,
    String? nameTransliteration,
    int? totalAyahs,
    String? revelationType,
    int? revelationOrder,
    int? juzStart,
    int? juzEnd,
    int? hizbQuarterStart,
    int? pageStart,
    int? pageEnd,
    String? description,
  }) {
    return SurahInfo(
      number: number ?? this.number,
      nameArabic: nameArabic ?? this.nameArabic,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      nameTransliteration: nameTransliteration ?? this.nameTransliteration,
      totalAyahs: totalAyahs ?? this.totalAyahs,
      revelationType: revelationType ?? this.revelationType,
      revelationOrder: revelationOrder ?? this.revelationOrder,
      juzStart: juzStart ?? this.juzStart,
      juzEnd: juzEnd ?? this.juzEnd,
      hizbQuarterStart: hizbQuarterStart ?? this.hizbQuarterStart,
      pageStart: pageStart ?? this.pageStart,
      pageEnd: pageEnd ?? this.pageEnd,
      description: description ?? this.description,
    );
  }
}

/// Model for a list of surahs returned from API/JSON
List<SurahInfo> parseSurahList(String jsonString) {
  final List<dynamic> decoded = json.decode(jsonString);
  return decoded
      .map((item) => SurahInfo.fromJson(item as Map<String, dynamic>))
      .toList();
}
