import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Models ──────────────────────────────────────────────────────────

class DhikrOption {
  final String id;
  final String arabicName;
  final String englishName;
  final int targetCount;
  final String arabicText;

  const DhikrOption({
    required this.id,
    required this.arabicName,
    required this.englishName,
    required this.targetCount,
    required this.arabicText,
  });
}

class SessionEntry {
  final String dhikrId;
  final int count;
  final DateTime timestamp;

  const SessionEntry({
    required this.dhikrId,
    required this.count,
    required this.timestamp,
  });
}

// ── Pre-defined Dhikr Options ──────────────────────────────────────

const List<DhikrOption> kDhikrOptions = [
  DhikrOption(
    id: 'subhanallah',
    arabicName: 'سُبْحَانَ اللَّهِ',
    englishName: 'SubhanAllah',
    targetCount: 33,
    arabicText: 'سُبْحَانَ اللَّهِ',
  ),
  DhikrOption(
    id: 'alhamdulillah',
    arabicName: 'الْحَمْدُ لِلَّهِ',
    englishName: 'AlhamduliLlah',
    targetCount: 33,
    arabicText: 'الْحَمْدُ لِلَّهِ',
  ),
  DhikrOption(
    id: 'allahu_akbar',
    arabicName: 'اللَّهُ أَكْبَرُ',
    englishName: 'Allahu Akbar',
    targetCount: 34,
    arabicText: 'اللَّهُ أَكْبَرُ',
  ),
  DhikrOption(
    id: 'la_ilaha',
    arabicName: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
    englishName: 'La ilaha illallah',
    targetCount: 100,
    arabicText: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
  ),
  DhikrOption(
    id: 'astaghfirullah',
    arabicName: 'أَسْتَغْفِرُ اللَّهَ',
    englishName: 'Astaghfirullah',
    targetCount: 100,
    arabicText: 'أَسْتَغْفِرُ اللَّهَ',
  ),
  DhikrOption(
    id: 'salawat',
    arabicName: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
    englishName: 'Salawat',
    targetCount: 100,
    arabicText: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ',
  ),
];

// ── Preset Combinations ────────────────────────────────────────────

class PresetCombination {
  final String name;
  final String description;
  final List<DhikrOption> dhikrs;

  const PresetCombination({
    required this.name,
    required this.description,
    required this.dhikrs,
  });
}

const List<PresetCombination> kPresetCombinations = [
  PresetCombination(
    name: 'After Salah',
    description: 'The Prophet\'s ﷺ post-prayer dhikr',
    dhikrs: [
      DhikrOption(
        id: 'subhanallah',
        arabicName: 'سُبْحَانَ اللَّهِ',
        englishName: 'SubhanAllah',
        targetCount: 33,
        arabicText: 'سُبْحَانَ اللَّهِ',
      ),
      DhikrOption(
        id: 'alhamdulillah',
        arabicName: 'الْحَمْدُ لِلَّهِ',
        englishName: 'AlhamduliLlah',
        targetCount: 33,
        arabicText: 'الْحَمْدُ لِلَّهِ',
      ),
      DhikrOption(
        id: 'allahu_akbar',
        arabicName: 'اللَّهُ أَكْبَرُ',
        englishName: 'Allahu Akbar',
        targetCount: 34,
        arabicText: 'اللَّهُ أَكْبَرُ',
      ),
    ],
  ),
  PresetCombination(
    name: 'Morning Adhkar',
    description: 'Morning remembrance',
    dhikrs: [
      DhikrOption(
        id: 'astaghfirullah',
        arabicName: 'أَسْتَغْفِرُ اللَّهَ',
        englishName: 'Astaghfirullah',
        targetCount: 100,
        arabicText: 'أَسْتَغْفِرُ اللَّهَ',
      ),
      DhikrOption(
        id: 'subhanallah',
        arabicName: 'سُبْحَانَ اللَّهِ',
        englishName: 'SubhanAllah',
        targetCount: 33,
        arabicText: 'سُبْحَانَ اللَّهِ',
      ),
    ],
  ),
  PresetCombination(
    name: 'Tasbih Fatimah',
    description: 'The tasbih of Fatimah (RA)',
    dhikrs: [
      DhikrOption(
        id: 'subhanallah',
        arabicName: 'سُبْحَانَ اللَّهِ',
        englishName: 'SubhanAllah',
        targetCount: 33,
        arabicText: 'سُبْحَانَ اللَّهِ',
      ),
      DhikrOption(
        id: 'alhamdulillah',
        arabicName: 'الْحَمْدُ لِلَّهِ',
        englishName: 'AlhamduliLlah',
        targetCount: 33,
        arabicText: 'الْحَمْدُ لِلَّهِ',
      ),
      DhikrOption(
        id: 'allahu_akbar',
        arabicName: 'اللَّهُ أَكْبَرُ',
        englishName: 'Allahu Akbar',
        targetCount: 34,
        arabicText: 'اللَّهُ أَكْبَرُ',
      ),
    ],
  ),
];

// ── Arabic Numerals ───────────────────────────────────────────────

const String _arabicDigits = '٠١٢٣٤٥٦٧٨٩';

String toArabicNumerals(int number) {
  return number.toString().split('').map((d) {
    final idx = int.tryParse(d);
    return idx != null ? _arabicDigits[idx] : d;
  }).join();
}

// ── State ──────────────────────────────────────────────────────────

class TasbihState {
  final DhikrOption selectedDhikr;
  final int currentCount;
  final bool isCustom;
  final String customArabic;
  final String customEnglish;
  final int customTarget;
  final List<SessionEntry> todaySessions;
  final bool showCelebration;
  final bool showDhikrPicker;
  final bool showPresets;

  const TasbihState({
    required this.selectedDhikr,
    this.currentCount = 0,
    this.isCustom = false,
    this.customArabic = '',
    this.customEnglish = '',
    this.customTarget = 100,
    this.todaySessions = const [],
    this.showCelebration = false,
    this.showDhikrPicker = false,
    this.showPresets = false,
  });

  double get progress =>
      selectedDhikr.targetCount > 0
          ? (currentCount / selectedDhikr.targetCount).clamp(0.0, 1.0)
          : 0.0;

  int get target => isCustom ? customTarget : selectedDhikr.targetCount;

  int get todayTotal => todaySessions.fold(0, (sum, s) => sum + s.count);

  TasbihState copyWith({
    DhikrOption? selectedDhikr,
    int? currentCount,
    bool? isCustom,
    String? customArabic,
    String? customEnglish,
    int? customTarget,
    List<SessionEntry>? todaySessions,
    bool? showCelebration,
    bool? showDhikrPicker,
    bool? showPresets,
  }) {
    return TasbihState(
      selectedDhikr: selectedDhikr ?? this.selectedDhikr,
      currentCount: currentCount ?? this.currentCount,
      isCustom: isCustom ?? this.isCustom,
      customArabic: customArabic ?? this.customArabic,
      customEnglish: customEnglish ?? this.customEnglish,
      customTarget: customTarget ?? this.customTarget,
      todaySessions: todaySessions ?? this.todaySessions,
      showCelebration: showCelebration ?? this.showCelebration,
      showDhikrPicker: showDhikrPicker ?? this.showDhikrPicker,
      showPresets: showPresets ?? this.showPresets,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────────

class TasbihNotifier extends StateNotifier<TasbihState> {
  TasbihNotifier()
      : super(TasbihState(selectedDhikr: kDhikrOptions.first));

  void selectDhikr(DhikrOption dhikr) {
    _recordCurrentSession();
    state = state.copyWith(
      selectedDhikr: dhikr,
      currentCount: 0,
      isCustom: false,
      showDhikrPicker: false,
      showCelebration: false,
    );
  }

  void selectCustom({
    required String arabic,
    required String english,
    required int target,
  }) {
    _recordCurrentSession();
    state = state.copyWith(
      selectedDhikr: const DhikrOption(
        id: 'custom',
        arabicName: 'مخصص',
        englishName: 'Custom',
        targetCount: 100,
        arabicText: '',
    ),
      currentCount: 0,
      isCustom: true,
      customArabic: arabic,
      customEnglish: english,
      customTarget: target,
      showDhikrPicker: false,
      showCelebration: false,
    );
  }

  void increment() {
    if (state.showCelebration) return;
    final newCount = state.currentCount + 1;
    final target = state.target;
    if (newCount >= target) {
      // Target reached – record and celebrate
      final session = SessionEntry(
        dhikrId: state.selectedDhikr.id,
        count: target,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        currentCount: target,
        todaySessions: [...state.todaySessions, session],
        showCelebration: true,
      );
    } else {
      state = state.copyWith(currentCount: newCount);
    }
  }

  void reset() {
    state = state.copyWith(currentCount: 0, showCelebration: false);
  }

  void dismissCelebration() {
    state = state.copyWith(showCelebration: false, currentCount: 0);
  }

  void toggleDhikrPicker() {
    state = state.copyWith(
      showDhikrPicker: !state.showDhikrPicker,
      showPresets: false,
    );
  }

  void togglePresets() {
    state = state.copyWith(
      showPresets: !state.showPresets,
      showDhikrPicker: false,
    );
  }

  void closeOverlays() {
    state = state.copyWith(
      showDhikrPicker: false,
      showPresets: false,
    );
  }

  void _recordCurrentSession() {
    if (state.currentCount > 0) {
      final session = SessionEntry(
        dhikrId: state.selectedDhikr.id,
        count: state.currentCount,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        todaySessions: [...state.todaySessions, session],
      );
    }
  }
}

// ── Providers ──────────────────────────────────────────────────────

final tasbihProvider = StateNotifierProvider<TasbihNotifier, TasbihState>(
  (ref) => TasbihNotifier(),
);

final dhikrOptionsProvider = Provider<List<DhikrOption>>((ref) => kDhikrOptions);

final presetCombinationsProvider =
    Provider<List<PresetCombination>>((ref) => kPresetCombinations);

final todaySessionSummaryProvider = Provider<Map<String, int>>((ref) {
  final tasbihState = ref.watch(tasbihProvider);
  final map = <String, int>{};
  for (final session in tasbihState.todaySessions) {
    map[session.dhikrId] = (map[session.dhikrId] ?? 0) + session.count;
  }
  return map;
});
