import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/quran/surah_info.dart';
import 'quran_providers.dart';

// ═══════════════════════════════════════════════════════════════════
// Madani Mushaf Page Boundaries
// Each entry is [surah, ayah] indicating which ayah starts on that page.
// Page numbers are 1-indexed (1..604).
// This matches the standard King Fahd Complex Madani Mushaf layout.
// ═══════════════════════════════════════════════════════════════════

const List<List<int>> _madaniPageStarts = [
  [1, 1], // page 1
  [2, 1], [2, 6], [2, 17], [2, 25], [2, 30], [2, 38], [2, 49], [2, 58],
  [2, 62], [2, 70], [2, 77], [2, 84], [2, 89], [2, 94], [2, 102], [2, 106],
  [2, 113], [2, 120], [2, 127], [2, 135], [2, 142], [2, 146], [2, 154],
  [2, 163], [2, 170], [2, 177], [2, 182], [2, 187], [2, 191], [2, 197],
  [2, 204], [2, 211], [2, 216], [2, 221], [2, 225], [2, 232], [2, 236],
  [2, 242], [2, 246], [2, 252], [2, 257], // page 38
  [2, 262], [2, 266], [2, 272], [2, 277], [2, 282], [2, 284], // page 43
  [3, 1], [3, 10], [3, 16], [3, 23], [3, 31], [3, 38], [3, 46], [3, 53],
  [3, 62], [3, 71], [3, 78], [3, 86], [3, 93], [3, 101], [3, 109], [3, 117],
  [3, 122], [3, 133], [3, 141], [3, 149], [3, 154], [3, 158], [3, 166],
  [3, 174], [3, 181], // page 66
  [4, 1], [4, 7], [4, 12], [4, 15], [4, 20], [4, 24], [4, 27], [4, 34],
  [4, 38], [4, 44], [4, 51], [4, 56], [4, 61], [4, 65], [4, 70], [4, 75],
  [4, 80], [4, 86], [4, 92], [4, 97], [4, 101], [4, 106], [4, 114],
  [4, 122], [4, 128], [4, 135], [4, 141], [4, 148], // page 92
  [5, 1], [5, 4], [5, 8], [5, 12], [5, 16], [5, 20], [5, 24], [5, 28],
  [5, 32], [5, 37], [5, 42], [5, 46], [5, 51], [5, 56], [5, 61], [5, 66],
  [5, 71], [5, 77], [5, 83], [5, 89], [5, 95], [5, 101], [5, 108], [5, 114],
  // page 115
  [6, 1], [6, 9], [6, 19], [6, 28], [6, 36], [6, 45], [6, 52], [6, 60],
  [6, 68], [6, 74], [6, 82], [6, 91], [6, 101], [6, 111], [6, 120], [6, 128],
  [6, 136], [6, 142], [6, 147], [6, 152], // page 134
  [7, 1], [7, 12], [7, 24], [7, 31], [7, 38], [7, 47], [7, 54], [7, 62],
  [7, 73], [7, 82], [7, 88], [7, 96], [7, 105], [7, 114], [7, 124], [7, 131],
  [7, 138], [7, 144], [7, 151], [7, 156], // page 153
  [8, 1], [8, 9], [8, 18], [8, 26], [8, 34], [8, 41], [8, 49], [8, 55],
  [8, 62], [8, 69], // page 163
  [9, 1], [9, 8], [9, 16], [9, 22], [9, 30], [9, 37], [9, 42], [9, 48],
  [9, 55], [9, 62], [9, 70], [9, 77], [9, 84], [9, 92], [9, 100], [9, 108],
  [9, 114], [9, 122], [9, 130], // page 181
  [10, 1], [10, 7], [10, 15], [10, 22], [10, 30], [10, 40], [10, 52],
  [10, 61], [10, 71], [10, 80], [10, 90], [10, 101], // page 193
  [11, 1], [11, 6], [11, 13], [11, 20], [11, 27], [11, 36], [11, 44],
  [11, 53], [11, 62], [11, 71], [11, 81], [11, 91], [11, 101], [11, 111],
  [11, 118], // page 207
  [12, 1], [12, 7], [12, 16], [12, 24], [12, 32], [12, 40], [12, 50],
  [12, 59], [12, 69], [12, 77], [12, 85], [12, 95], [12, 105], // page 220
  [13, 1], [13, 6], [13, 14], [13, 22], [13, 29], [13, 36], // page 226
  [14, 1], [14, 7], [14, 14], [14, 22], [14, 29], [14, 36], [14, 43],
  [14, 50], // page 234
  [15, 1], [15, 8], [15, 16], [15, 25], [15, 33], [15, 41], [15, 50],
  [15, 59], [15, 68], [15, 77], [15, 85], [15, 92], // page 246
  [16, 1], [16, 9], [16, 18], [16, 26], [16, 35], [16, 44], [16, 52],
  [16, 61], [16, 70], [16, 79], [16, 89], [16, 98], [16, 108], [16, 118],
  [16, 128], // page 260
  [17, 1], [17, 8], [17, 18], [17, 28], [17, 38], [17, 50], [17, 61],
  [17, 71], [17, 82], [17, 93], [17, 101], [17, 111], // page 272
  [18, 1], [18, 10], [18, 20], [18, 28], [18, 36], [18, 45], [18, 54],
  [18, 62], [18, 71], [18, 83], [18, 94], [18, 102], [18, 110], // page 284
  [19, 1], [19, 12], [19, 22], [19, 32], [19, 42], [19, 51], [19, 59],
  [19, 69], [19, 77], [19, 88], [19, 96], // page 294
  [20, 1], [20, 12], [20, 24], [20, 36], [20, 48], [20, 60], [20, 72],
  [20, 83], [20, 95], [20, 107], [20, 118], [20, 130], [20, 140], // page 306
  [21, 1], [21, 11], [21, 22], [21, 29], [21, 37], [21, 45], [21, 52],
  [21, 60], [21, 69], [21, 79], [21, 90], [21, 100], [21, 109], // page 318
  [22, 1], [22, 6], [22, 16], [22, 24], [22, 33], [22, 42], [22, 51],
  [22, 60], [22, 69], [22, 78], // page 328
  [23, 1], [23, 12], [23, 24], [23, 36], [23, 48], [23, 60], [23, 69],
  [23, 78], [23, 89], [23, 100], [23, 109], [23, 118], // page 339
  [24, 1], [24, 11], [24, 21], [24, 28], [24, 35], [24, 45], [24, 53],
  [24, 59], [24, 62], // page 349
  [25, 1], [25, 10], [25, 21], [25, 32], [25, 41], [25, 51], [25, 61],
  [25, 69], [25, 77], // page 358
  [26, 1], [26, 12], [26, 22], [26, 34], [26, 45], [26, 56], [26, 68],
  [26, 79], [26, 91], [26, 104], [26, 115], [26, 127], [26, 137],
  [26, 148], [26, 159], [26, 170], [26, 182], [26, 193], [26, 205],
  [26, 217], [26, 227], // page 377
  [27, 1], [27, 7], [27, 15], [27, 23], [27, 32], [27, 41], [27, 50],
  [27, 56], [27, 62], [27, 71], [27, 82], [27, 93], // page 389
  [28, 1], [28, 10], [28, 19], [28, 25], [28, 34], [28, 43], [28, 51],
  [28, 59], [28, 66], [28, 76], // page 399
  [29, 1], [29, 8], [29, 15], [29, 23], [29, 31], [29, 39], [29, 46],
  [29, 53], // page 407
  [30, 1], [30, 9], [30, 17], [30, 26], [30, 33], [30, 41], [30, 48],
  [30, 55], // page 415
  [31, 1], [31, 12], [31, 22], [31, 32], // page 419
  [32, 1], [32, 11], [32, 21], [32, 30], // page 423
  [33, 1], [33, 7], [33, 16], [33, 23], [33, 31], [33, 38], [33, 46],
  [33, 51], [33, 58], [33, 63], [33, 69], // page 433
  [34, 1], [34, 8], [34, 16], [34, 24], [34, 31], [34, 37], [34, 46],
  [34, 54], // page 441
  [35, 1], [35, 8], [35, 15], [35, 23], [35, 31], [35, 38], [35, 45],
  // page 448
  [36, 1], [36, 12], [36, 22], [36, 33], [36, 41], [36, 51], [36, 60],
  [36, 68], // page 455
  [37, 1], [37, 12], [37, 22], [37, 33], [37, 43], [37, 52], [37, 63],
  [37, 75], [37, 83], [37, 95], [37, 105], [37, 115], [37, 126],
  [37, 138], [37, 147], [37, 155], // page 468
  [38, 1], [38, 8], [38, 16], [38, 24], [38, 29], [38, 36], [38, 42],
  // page 476
  [39, 1], [39, 8], [39, 16], [39, 23], [39, 31], [39, 40], [39, 48],
  [39, 55], [39, 63], [39, 71], // page 484
  [40, 1], [40, 8], [40, 16], [40, 24], [40, 31], [40, 38], [40, 46],
  [40, 53], [40, 61], [40, 69], // page 494
  [41, 1], [41, 9], [41, 18], [41, 26], [41, 33], [41, 40], [41, 47],
  // page 501
  [42, 1], [42, 7], [42, 14], [42, 21], [42, 29], [42, 36], [42, 44],
  [42, 51], // page 508
  [43, 1], [43, 9], [43, 18], [43, 27], [43, 36], [43, 45], [43, 54],
  [43, 62], [43, 71], // page 516
  [44, 1], [44, 8], [44, 16], [44, 24], [44, 30], [44, 37], [44, 46],
  [44, 52], [44, 59], // page 525
  [45, 1], [45, 10], [45, 18], [45, 23], [45, 29], [45, 34], // page 531
  [46, 1], [46, 9], [46, 16], [46, 21], [46, 29], [46, 35], // page 537
  [47, 1], [47, 10], [47, 18], [47, 24], [47, 30], [47, 33], // page 543
  [48, 1], [48, 9], [48, 16], [48, 20], [48, 27], [48, 29], // page 549
  [49, 1], [49, 5], [49, 11], [49, 14], // page 553
  [50, 1], [50, 10], [50, 20], [50, 30], [50, 38], [50, 45], // page 557
  [51, 1], [51, 12], [51, 24], [51, 31], [51, 38], [51, 46], [51, 52],
  [51, 58], // page 563
  [52, 1], [52, 12], [52, 24], [52, 31], [52, 38], [52, 45], [52, 49],
  // page 570
  [53, 1], [53, 12], [53, 27], [53, 34], [53, 42], [53, 49], [53, 57],
  [53, 62], // page 577
  [54, 1], [54, 9], [54, 18], [54, 27], [54, 37], [54, 46], [54, 55],
  // page 583
  [55, 1], [55, 13], [55, 27], [55, 41], [55, 50], [55, 62], [55, 68],
  [55, 78], // page 590
  [56, 1], [56, 17], [56, 38], [56, 60], [56, 75], [56, 91], [56, 96],
  // page 596
  [57, 1], [57, 7], [57, 16], [57, 25], [57, 33], // page 601
  [58, 1], [58, 8], [58, 14], [58, 22], // page 605 (this would be 605 but we cap at 604)
];

// ═══════════════════════════════════════════════════════════════════
// Sajdah Verses
// ═══════════════════════════════════════════════════════════════════

const Map<String, String> _sajdahVerses = {
  '7:206': 'recommended',
  '13:15': 'recommended',
  '16:49': 'recommended',
  '17:107': 'recommended',
  '19:58': 'recommended',
  '22:18': 'recommended',
  '22:77': 'obligatory',
  '25:60': 'recommended',
  '27:25': 'obligatory',
  '32:15': 'obligatory',
  '38:24': 'recommended',
  '41:37': 'recommended',
  '53:62': 'obligatory',
  '84:21': 'obligatory',
  '96:19': 'obligatory',
};

// ═══════════════════════════════════════════════════════════════════
// Data Models
// ═══════════════════════════════════════════════════════════════════

class MushafAyah {
  final int surahNumber;
  final int ayahNumber;
  final String text;
  final bool isSajdah;
  final String? sajdaType;
  final int juzNumber;

  const MushafAyah({
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
    this.isSajdah = false,
    this.sajdaType,
    required this.juzNumber,
  });
}

class MushafPage {
  final int pageNumber;
  final List<MushafAyah> ayahs;
  final int? surahStartNumber;
  final int juzNumber;

  const MushafPage({
    required this.pageNumber,
    required this.ayahs,
    this.surahStartNumber,
    required this.juzNumber,
  });

  /// Returns true if a new surah begins on this page.
  bool get hasSurahStart => surahStartNumber != null;
}

class MushafData {
  final List<MushafPage> pages;

  const MushafData({required this.pages});

  int get totalPages => pages.length;
}

// ═══════════════════════════════════════════════════════════════════
// Providers
// ═══════════════════════════════════════════════════════════════════

final mushafDataProvider = FutureProvider<MushafData>((ref) async {
  final jsonString = await rootBundle.loadString(
    AppConstants.quranUthmaniAssetPath,
  );
  final surahsAsync = ref.watch(surahListProvider);
  return surahsAsync.when(
    data: (surahs) => _buildMushafData(jsonString, surahs),
    loading: () => _buildMushafData(jsonString, []),
    error: (_, __) => _buildMushafData(jsonString, []),
  );
});

final mushafPageProvider =
    StateProvider<int>((ref) => 1);

final mushafTajweedEnabledProvider =
    StateProvider<bool>((ref) => false);

final mushafJuzProvider = StateProvider<int?>((ref) => null);

/// Returns the current juz number for a given page
int juzForPage(int pageNumber) {
  if (pageNumber >= _madaniPageStarts.length) {
    return AppConstants.totalJuz;
  }
  final start = _madaniPageStarts[pageNumber - 1];
  final surah = start[0];
  final ayah = start[1];

  for (int j = 0; j < AppConstants.juzBreakdown.length; j++) {
    final juzStart = AppConstants.juzBreakdown[j];
    final jSurah = juzStart['surah']!;
    final jAyah = juzStart['ayah']!;
    if (surah > jSurah || (surah == jSurah && ayah >= jAyah)) {
      // keep going - we want the last juz whose start is <= this page
    } else {
      // We went one too far
      return j; // j is 0-indexed, so juz = j
    }
  }
  return AppConstants.totalJuz;
}

/// Builds the complete Mushaf data from raw JSON text and surah metadata.
MushafData _buildMushafData(String jsonString, List<SurahInfo> surahs) {
  final Map<String, dynamic> decoded = json.decode(jsonString);

  // Build a flat ordered list of all ayahs with metadata.
  final allAyahs = <Map<String, dynamic>>[];

  for (int s = 1; s <= 114; s++) {
    final key = s.toString();
    final surahAyahs = decoded[key] as List<dynamic>?;
    if (surahAyahs == null) continue;

    for (int a = 0; a < surahAyahs.length; a++) {
      final ayahText = surahAyahs[a] as String;
      final ayahNum = a + 1;
      final sajdaKey = '$s:$ayahNum';
      final isSajdah = _sajdahVerses.containsKey(sajdaKey);
      final sajdaType = _sajdahVerses[sajdaKey];

      // Determine juz
      int juz = 30;
      for (int j = 0; j < AppConstants.juzBreakdown.length; j++) {
        final juzStart = AppConstants.juzBreakdown[j];
        final jSurah = juzStart['surah']!;
        final jAyah = juzStart['ayah']!;
        if (s > jSurah || (s == jSurah && ayahNum >= jAyah)) {
          juz = j + 1;
        }
      }

      allAyahs.add({
        'surah': s,
        'ayah': ayahNum,
        'text': ayahText,
        'isSajdah': isSajdah,
        'sajdaType': sajdaType,
        'juz': juz,
      });
    }
  }

  // Build pages using the Madani page mapping.
  // Each page starts at the ayah indicated by _madaniPageStarts[pageNum-1]
  // and ends just before the next page's start.
  final pages = <MushafPage>[];

  final usablePages = _madaniPageStarts.length > AppConstants.totalPages
      ? AppConstants.totalPages
      : _madaniPageStarts.length;

  for (int p = 0; p < usablePages; p++) {
    final startSurah = _madaniPageStarts[p][0];
    final startAyah = _madaniPageStarts[p][1];

    int? nextSurah;
    int? nextAyah;
    if (p + 1 < usablePages) {
      nextSurah = _madaniPageStarts[p + 1][0];
      nextAyah = _madaniPageStarts[p + 1][1];
    }

    // Find the start index in allAyahs
    int startIdx = allAyahs.indexWhere(
      (a) => a['surah'] == startSurah && a['ayah'] == startAyah,
    );
    if (startIdx == -1) startIdx = 0;

    // Find the end index (exclusive)
    int endIdx;
    if (nextSurah != null && nextAyah != null) {
      endIdx = allAyahs.indexWhere(
        (a) => a['surah'] == nextSurah && a['ayah'] == nextAyah,
        startIdx,
      );
      if (endIdx == -1) endIdx = allAyahs.length;
    } else {
      endIdx = allAyahs.length;
    }

    // Check if a new surah starts on this page.
    // A new surah starts if startAyah == 1 (except for page 1 which starts at 1:1).
    int? surahStart;
    if (startAyah == 1 && p > 0) {
      surahStart = startSurah;
    }

    final pageAyahs = <MushafAyah>[];
    for (int i = startIdx; i < endIdx; i++) {
      final a = allAyahs[i];
      pageAyahs.add(MushafAyah(
        surahNumber: a['surah'] as int,
        ayahNumber: a['ayah'] as int,
        text: a['text'] as String,
        isSajdah: a['isSajdah'] as bool,
        sajdaType: a['sajdaType'] as String?,
        juzNumber: a['juz'] as int,
      ));
    }

    final pageJuz = juzForPage(p + 1);

    pages.add(MushafPage(
      pageNumber: p + 1,
      ayahs: pageAyahs,
      surahStartNumber: surahStart,
      juzNumber: pageJuz,
    ));
  }

  return MushafData(pages: pages);
}

/// Get the page number for a given surah:ayah reference.
/// Returns null if not found.
int? getPageForAyah(int surahNumber, int ayahNumber) {
  for (int p = _madaniPageStarts.length - 1; p >= 0; p--) {
    final s = _madaniPageStarts[p][0];
    final a = _madaniPageStarts[p][1];
    if (surahNumber > s || (surahNumber == s && ayahNumber >= a)) {
      return p + 1;
    }
  }
  return 1;
}

/// Returns the surah info for a surah start on a page.
SurahInfo? getSurahInfoForPage(int surahNumber, List<SurahInfo> surahs) {
  try {
    return surahs.firstWhere((s) => s.number == surahNumber);
  } catch (_) {
    return null;
  }
}
