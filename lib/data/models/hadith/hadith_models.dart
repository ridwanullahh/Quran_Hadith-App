import 'dart:convert';

/// Represents a hadith collection (e.g., Sahih al-Bukhari)
class HadithCollection {
  final String id; // e.g., 'bukhari'
  final String name;
  final String? nameArabic;
  final String? shortName;
  final String? author;
  final String? authorArabic;
  final int totalHadiths;
  final int totalBooks;
  final String? introduction;
  final bool hasVolumes;
  final int? totalVolumes;

  const HadithCollection({
    required this.id,
    required this.name,
    this.nameArabic,
    this.shortName,
    this.author,
    this.authorArabic,
    required this.totalHadiths,
    required this.totalBooks,
    this.introduction,
    this.hasVolumes = false,
    this.totalVolumes,
  });

  factory HadithCollection.fromJson(Map<String, dynamic> json) {
    return HadithCollection(
      id: json['id'] as String? ?? json['collection_id'] as String? ?? '',
      name: json['name'] as String? ?? json['collection_name'] as String? ?? '',
      nameArabic: json['name_arabic'] as String? ??
          json['nameArabic'] as String?,
      shortName: json['short_name'] as String? ??
          json['shortName'] as String?,
      author: json['author'] as String? ??
          json['imam'] as String?,
      authorArabic: json['author_arabic'] as String? ??
          json['authorArabic'] as String?,
      totalHadiths: json['total_hadiths'] as int? ??
          json['totalHadiths'] as int? ??
          json['hadith_count'] as int? ?? 0,
      totalBooks: json['total_books'] as int? ??
          json['totalBooks'] as int? ??
          json['book_count'] as int? ?? 0,
      introduction: json['introduction'] as String?,
      hasVolumes: json['has_volumes'] as bool? ??
          json['hasVolumes'] as bool? ?? false,
      totalVolumes: json['total_volumes'] as int? ??
          json['totalVolumes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_arabic': nameArabic,
      'short_name': shortName,
      'author': author,
      'author_arabic': authorArabic,
      'total_hadiths': totalHadiths,
      'total_books': totalBooks,
      'introduction': introduction,
      'has_volumes': hasVolumes,
      'total_volumes': totalVolumes,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HadithCollection && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'HadithCollection($id: $name)';
}

/// Represents a book within a hadith collection
class HadithBook {
  final int bookNumber;
  final String collectionId;
  final String bookName;
  final String? bookNameArabic;
  final int? hadithStartNumber;
  final int? hadithEndNumber;
  final int totalHadiths;
  final String? description;
  final int? volumeNumber;

  const HadithBook({
    required this.bookNumber,
    required this.collectionId,
    required this.bookName,
    this.bookNameArabic,
    this.hadithStartNumber,
    this.hadithEndNumber,
    required this.totalHadiths,
    this.description,
    this.volumeNumber,
  });

  /// Unique identifier combining collection and book number
  String get uniqueId => '${collectionId}_$bookNumber';

  factory HadithBook.fromJson(Map<String, dynamic> json) {
    return HadithBook(
      bookNumber: json['book_number'] as int? ??
          json['bookNumber'] as int? ??
          json['book'] as int? ?? 0,
      collectionId: json['collection_id'] as String? ??
          json['collectionId'] as String? ?? '',
      bookName: json['book_name'] as String? ??
          json['bookName'] as String? ??
          json['name'] as String? ?? '',
      bookNameArabic: json['book_name_arabic'] as String? ??
          json['bookNameArabic'] as String?,
      hadithStartNumber: json['hadith_start_number'] as int? ??
          json['hadithStartNumber'] as int?,
      hadithEndNumber: json['hadith_end_number'] as int? ??
          json['hadithEndNumber'] as int?,
      totalHadiths: json['total_hadiths'] as int? ??
          json['totalHadiths'] as int? ??
          json['hadith_count'] as int? ?? 0,
      description: json['description'] as String?,
      volumeNumber: json['volume_number'] as int? ??
          json['volumeNumber'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_number': bookNumber,
      'collection_id': collectionId,
      'book_name': bookName,
      'book_name_arabic': bookNameArabic,
      'hadith_start_number': hadithStartNumber,
      'hadith_end_number': hadithEndNumber,
      'total_hadiths': totalHadiths,
      'description': description,
      'volume_number': volumeNumber,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HadithBook && other.uniqueId == uniqueId;
  }

  @override
  int get hashCode => uniqueId.hashCode;

  @override
  String toString() => 'HadithBook($uniqueId: $bookName)';
}

/// Represents a single hadith (narration)
class Hadith {
  final int hadithNumber;
  final int? hadithNumberInBook; // number within the specific book
  final String collectionId;
  final int bookNumber;
  final String textArabic;
  final String? textEnglish;
  final String? textUrdu;
  final String? narratorChainArabic; // isnad
  final String? narratorChainEnglish;
  final String? narrator; // primary narrator/sahabi
  final String? grade; // authenticity grade (Sahih, Hasan, Daif, etc.)
  final String? gradeArabic;
  final List<String>? tags;
  final String? chapterTitle;
  final String? chapterTitleArabic;
  final String? reference;

  const Hadith({
    required this.hadithNumber,
    this.hadithNumberInBook,
    required this.collectionId,
    required this.bookNumber,
    required this.textArabic,
    this.textEnglish,
    this.textUrdu,
    this.narratorChainArabic,
    this.narratorChainEnglish,
    this.narrator,
    this.grade,
    this.gradeArabic,
    this.tags,
    this.chapterTitle,
    this.chapterTitleArabic,
    this.reference,
  });

  /// Unique identifier
  String get uniqueId => '${collectionId}_$bookNumber_$hadithNumber';

  /// Get the text in the specified language
  String getText(String language) {
    switch (language.toLowerCase()) {
      case 'ar':
        return textArabic;
      case 'ur':
        return textUrdu ?? textEnglish ?? textArabic;
      default:
        return textEnglish ?? textArabic;
    }
  }

  /// Whether this hadith has a graded authenticity
  bool get hasGrade => grade != null && grade!.isNotEmpty;

  /// Whether this hadith is Sahih (authentic)
  bool get isSahih {
    if (grade == null) return false;
    final g = grade!.toLowerCase();
    return g.contains('sahih') || g.contains('صحيح');
  }

  /// Whether this hadith is Hasan (good)
  bool get isHasan {
    if (grade == null) return false;
    final g = grade!.toLowerCase();
    return g.contains('hasan') || g.contains('حسن');
  }

  /// Whether this hadith is Daif (weak)
  bool get isDaif {
    if (grade == null) return false;
    final g = grade!.toLowerCase();
    return g.contains('daif') || g.contains('da\'if') || g.contains('ضعيف');
  }

  /// Truncated Arabic text for preview
  String get arabicPreview {
    if (textArabic.length <= 100) return textArabic;
    return '${textArabic.substring(0, 100)}...';
  }

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      hadithNumber: json['hadith_number'] as int? ??
          json['hadithNumber'] as int? ??
          json['number'] as int? ?? 0,
      hadithNumberInBook: json['hadith_number_in_book'] as int? ??
          json['hadithNumberInBook'] as int?,
      collectionId: json['collection_id'] as String? ??
          json['collectionId'] as String? ?? '',
      bookNumber: json['book_number'] as int? ??
          json['bookNumber'] as int? ??
          json['book'] as int? ?? 0,
      textArabic: json['text_arabic'] as String? ??
          json['textArabic'] as String? ??
          json['body_arabic'] as String? ??
          json['arabic'] as String? ?? '',
      textEnglish: json['text_english'] as String? ??
          json['textEnglish'] as String? ??
          json['body_english'] as String? ??
          json['english'] as String?,
      textUrdu: json['text_urdu'] as String? ??
          json['textUrdu'] as String? ??
          json['body_urdu'] as String?,
      narratorChainArabic: json['narrator_chain_arabic'] as String? ??
          json['narratorChainArabic'] as String? ??
          json['isnad_arabic'] as String?,
      narratorChainEnglish: json['narrator_chain_english'] as String? ??
          json['narratorChainEnglish'] as String? ??
          json['isnad_english'] as String?,
      narrator: json['narrator'] as String? ??
          json['rawi'] as String?,
      grade: json['grade'] as String? ??
          json['authenticity'] as String?,
      gradeArabic: json['grade_arabic'] as String? ??
          json['gradeArabic'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      chapterTitle: json['chapter_title'] as String? ??
          json['chapterTitle'] as String? ??
          json['chapter'] as String?,
      chapterTitleArabic: json['chapter_title_arabic'] as String? ??
          json['chapterTitleArabic'] as String?,
      reference: json['reference'] as String? ??
          json['ref'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hadith_number': hadithNumber,
      'hadith_number_in_book': hadithNumberInBook,
      'collection_id': collectionId,
      'book_number': bookNumber,
      'text_arabic': textArabic,
      'text_english': textEnglish,
      'text_urdu': textUrdu,
      'narrator_chain_arabic': narratorChainArabic,
      'narrator_chain_english': narratorChainEnglish,
      'narrator': narrator,
      'grade': grade,
      'grade_arabic': gradeArabic,
      'tags': tags,
      'chapter_title': chapterTitle,
      'chapter_title_arabic': chapterTitleArabic,
      'reference': reference,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Hadith && other.uniqueId == uniqueId;
  }

  @override
  int get hashCode => uniqueId.hashCode;

  @override
  String toString() =>
      'Hadith($uniqueId: ${arabicPreview})';
}

/// Search result for hadith queries
class HadithSearchResult {
  final Hadith hadith;
  final String? collectionName;
  final String? bookName;
  final String? highlightedArabic;
  final String? highlightedEnglish;
  final int matchStartIndex;
  final int matchLength;

  const HadithSearchResult({
    required this.hadith,
    this.collectionName,
    this.bookName,
    this.highlightedArabic,
    this.highlightedEnglish,
    this.matchStartIndex = 0,
    this.matchLength = 0,
  });

  factory HadithSearchResult.fromJson(Map<String, dynamic> json) {
    return HadithSearchResult(
      hadith: Hadith.fromJson(json['hadith'] as Map<String, dynamic>),
      collectionName: json['collection_name'] as String? ??
          json['collectionName'] as String?,
      bookName: json['book_name'] as String? ??
          json['bookName'] as String?,
      highlightedArabic: json['highlighted_arabic'] as String? ??
          json['highlightedArabic'] as String?,
      highlightedEnglish: json['highlighted_english'] as String? ??
          json['highlightedEnglish'] as String?,
      matchStartIndex: json['match_start_index'] as int? ?? 0,
      matchLength: json['match_length'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hadith': hadith.toJson(),
      'collection_name': collectionName,
      'book_name': bookName,
      'highlighted_arabic': highlightedArabic,
      'highlighted_english': highlightedEnglish,
      'match_start_index': matchStartIndex,
      'match_length': matchLength,
    };
  }
}

// ── JSON List Parsers ─────────────────────────────────────────────

List<HadithCollection> parseCollectionList(String jsonString) {
  final List<dynamic> decoded = json.decode(jsonString);
  return decoded
      .map((item) => HadithCollection.fromJson(item as Map<String, dynamic>))
      .toList();
}

List<HadithBook> parseBookList(String jsonString) {
  final List<dynamic> decoded = json.decode(jsonString);
  return decoded
      .map((item) => HadithBook.fromJson(item as Map<String, dynamic>))
      .toList();
}

List<Hadith> parseHadithList(String jsonString) {
  final List<dynamic> decoded = json.decode(jsonString);
  return decoded
      .map((item) => Hadith.fromJson(item as Map<String, dynamic>))
      .toList();
}

List<HadithSearchResult> parseHadithSearchResults(String jsonString) {
  final List<dynamic> decoded = json.decode(jsonString);
  return decoded
      .map((item) => HadithSearchResult.fromJson(item as Map<String, dynamic>))
      .toList();
}
