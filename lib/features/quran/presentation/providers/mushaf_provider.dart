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
        [1, 1], [2, 4], [2, 14], [2, 24], [2, 35], [2, 45], [2, 55], [2, 66], [2, 76], [2, 86],     [2, 97], [2, 107], [2, 117], [2, 128], [2, 138], [2, 148], [2, 159], [2, 169], [2, 179], [2, 190],     [2, 200], [2, 210], [2, 221], [2, 231], [2, 241], [2, 252], [2, 262], [2, 272], [2, 283], [3, 7],     [3, 17], [3, 28], [3, 38], [3, 48], [3, 59], [3, 69], [3, 79], [3, 90], [3, 100], [3, 110],     [3, 120], [3, 131], [3, 141], [3, 151], [3, 162], [3, 172], [3, 182], [3, 193], [4, 3], [4, 13],     [4, 24], [4, 34], [4, 44], [4, 55], [4, 65], [4, 75], [4, 86], [4, 96], [4, 106], [4, 117],     [4, 127], [4, 137], [4, 148], [4, 158], [4, 168], [5, 3], [5, 13], [5, 23], [5, 34], [5, 44],     [5, 54], [5, 65], [5, 75], [5, 85], [5, 96], [5, 106], [5, 116], [6, 6], [6, 17], [6, 27],     [6, 37], [6, 48], [6, 58], [6, 68], [6, 79], [6, 89], [6, 99], [6, 110], [6, 120], [6, 130],     [6, 141], [6, 151], [6, 161], [7, 7], [7, 17], [7, 27], [7, 38], [7, 48], [7, 58], [7, 69],     [7, 79], [7, 89], [7, 100], [7, 110], [7, 120], [7, 131], [7, 141], [7, 151], [7, 162], [7, 172],     [7, 182], [7, 193], [7, 203], [8, 7], [8, 17], [8, 28], [8, 38], [8, 48], [8, 59], [8, 69],     [9, 4], [9, 15], [9, 25], [9, 35], [9, 46], [9, 56], [9, 66], [9, 77], [9, 87], [9, 97],     [9, 108], [9, 118], [9, 128], [10, 10], [10, 20], [10, 30], [10, 41], [10, 51], [10, 61], [10, 72],     [10, 82], [10, 92], [10, 103], [11, 4], [11, 14], [11, 25], [11, 35], [11, 45], [11, 56], [11, 66],     [11, 76], [11, 87], [11, 97], [11, 107], [11, 117], [12, 5], [12, 15], [12, 25], [12, 36], [12, 46],     [12, 56], [12, 67], [12, 77], [12, 87], [12, 98], [12, 108], [13, 7], [13, 18], [13, 28], [13, 38],     [14, 6], [14, 16], [14, 26], [14, 37], [14, 47], [15, 5], [15, 16], [15, 26], [15, 36], [15, 47],     [15, 57], [15, 67], [15, 78], [15, 88], [15, 98], [16, 10], [16, 20], [16, 30], [16, 41], [16, 51],     [16, 61], [16, 71], [16, 82], [16, 92], [16, 102], [16, 113], [16, 123], [17, 5], [17, 16], [17, 26],     [17, 36], [17, 47], [17, 57], [17, 67], [17, 78], [17, 88], [17, 98], [17, 109], [18, 8], [18, 18],     [18, 29], [18, 39], [18, 49], [18, 60], [18, 70], [18, 80], [18, 91], [18, 101], [19, 1], [19, 12],     [19, 22], [19, 32], [19, 43], [19, 53], [19, 63], [19, 74], [19, 84], [19, 94], [20, 6], [20, 17],     [20, 27], [20, 37], [20, 48], [20, 58], [20, 68], [20, 79], [20, 89], [20, 99], [20, 110], [20, 120],     [20, 130], [21, 6], [21, 16], [21, 26], [21, 37], [21, 47], [21, 57], [21, 68], [21, 78], [21, 88],     [21, 99], [21, 109], [22, 7], [22, 18], [22, 28], [22, 38], [22, 49], [22, 59], [22, 69], [23, 2],     [23, 12], [23, 22], [23, 33], [23, 43], [23, 53], [23, 63], [23, 74], [23, 84], [23, 94], [23, 105],     [23, 115], [24, 7], [24, 18], [24, 28], [24, 38], [24, 49], [24, 59], [25, 5], [25, 16], [25, 26],     [25, 36], [25, 47], [25, 57], [25, 67], [26, 1], [26, 11], [26, 21], [26, 32], [26, 42], [26, 52],     [26, 63], [26, 73], [26, 83], [26, 94], [26, 104], [26, 114], [26, 125], [26, 135], [26, 145], [26, 156],     [26, 166], [26, 176], [26, 187], [26, 197], [26, 207], [26, 217], [27, 1], [27, 11], [27, 21], [27, 32],     [27, 42], [27, 52], [27, 63], [27, 73], [27, 83], [28, 1], [28, 11], [28, 21], [28, 32], [28, 42],     [28, 52], [28, 63], [28, 73], [28, 83], [29, 6], [29, 16], [29, 26], [29, 37], [29, 47], [29, 57],     [29, 68], [30, 9], [30, 19], [30, 30], [30, 40], [30, 50], [31, 1], [31, 11], [31, 21], [31, 32],     [32, 8], [32, 18], [32, 28], [33, 9], [33, 19], [33, 29], [33, 40], [33, 50], [33, 60], [33, 71],     [34, 8], [34, 18], [34, 29], [34, 39], [34, 49], [35, 6], [35, 16], [35, 26], [35, 37], [36, 2],     [36, 12], [36, 23], [36, 33], [36, 43], [36, 54], [36, 64], [36, 74], [37, 2], [37, 12], [37, 22],     [37, 33], [37, 43], [37, 53], [37, 64], [37, 74], [37, 84], [37, 95], [37, 105], [37, 115], [37, 125],     [37, 136], [37, 146], [37, 156], [37, 167], [37, 177], [38, 5], [38, 16], [38, 26], [38, 36], [38, 47],     [38, 57], [38, 67], [38, 78], [38, 88], [39, 10], [39, 21], [39, 31], [39, 41], [39, 52], [39, 62],     [39, 72], [40, 8], [40, 18], [40, 28], [40, 39], [40, 49], [40, 59], [40, 70], [40, 80], [41, 5],     [41, 16], [41, 26], [41, 36], [41, 47], [42, 3], [42, 13], [42, 23], [42, 34], [42, 44], [43, 1],     [43, 12], [43, 22], [43, 32], [43, 43], [43, 53], [43, 63], [43, 74], [43, 84], [44, 5], [44, 16],     [44, 26], [44, 36], [44, 47], [44, 57], [45, 8], [45, 19], [45, 29], [46, 2], [46, 13], [46, 23],     [46, 33], [47, 9], [47, 19], [47, 29], [48, 2], [48, 12], [48, 22], [49, 4], [49, 14], [50, 6],     [50, 17], [50, 27], [50, 37], [51, 3], [51, 13], [51, 23], [51, 33], [51, 44], [51, 54], [52, 4],     [52, 15], [52, 25], [52, 35], [52, 46], [53, 7], [53, 17], [53, 28], [53, 38], [53, 48], [53, 59],     [54, 7], [54, 17], [54, 28], [54, 38], [54, 48], [55, 4], [55, 14], [55, 24], [55, 35], [55, 45],     [55, 55], [55, 66], [55, 76], [56, 8], [56, 19], [56, 29], [56, 39], [56, 50], [56, 60], [56, 70],     [56, 81], [56, 91], [57, 5], [57, 15], [57, 26], [58, 7], [58, 17], [59, 6], [59, 16], [60, 2],     [60, 13], [61, 10], [62, 6], [63, 6], [64, 5], [64, 15], [65, 8], [66, 6], [67, 4], [67, 15],     [67, 25], [68, 5], [68, 16], [68, 26], [68, 36], [68, 47], [69, 5], [69, 15], [69, 26], [69, 36],     [69, 46], [70, 5], [70, 15], [70, 25], [70, 36], [71, 2], [71, 12], [71, 23], [72, 5], [72, 15],     [72, 25], [73, 8], [73, 18], [74, 8], [74, 19], [74, 29], [74, 39], [74, 50], [75, 4], [75, 14],     [75, 25], [75, 35], [76, 5], [76, 16], [76, 26], [77, 5], [77, 16], [77, 26], [77, 36], [77, 47],     [78, 7], [78, 17], [78, 28], [78, 38], [79, 8], [79, 19], [79, 29], [79, 39], [80, 4], [80, 14],     [80, 24], [80, 35], [81, 3], [81, 13], [81, 24], [82, 5], [82, 15], [83, 6], [83, 17], [83, 27],     [84, 1], [84, 12], [84, 22], [85, 7], [85, 18], [86, 6], [86, 16], [87, 10], [88, 1], [88, 11],     [88, 22], [89, 6], [89, 16], [89, 27], [90, 7], [90, 17], [91, 8], [92, 3], [92, 13], [93, 3],     [94, 2], [95, 4], [96, 7], [96, 17], [98, 3], [99, 6], [100, 8], [101, 7], [102, 7], [104, 6],     [106, 2], [108, 2], [110, 3], [114, 1], 
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
      return j + 1; // j is 0-indexed, so juz = j + 1
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
