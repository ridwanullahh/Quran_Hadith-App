import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/audio/audio_player_service.dart';
import '../../../../data/models/quran/ayah_data.dart';
import '../../../../data/models/quran/surah_info.dart';
import '../../../../data/models/quran/word_data.dart';
import '../../../../data/repositories/quran_repository.dart';
import '../../../../app/shell/mini_audio_player_provider.dart';

// ═══════════════════════════════════════════════════════════════════
// Repository Provider
// ═══════════════════════════════════════════════════════════════════

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository();
});

// ═══════════════════════════════════════════════════════════════════
// Surah List Provider
// ═══════════════════════════════════════════════════════════════════

final surahListProvider = FutureProvider<List<SurahInfo>>((ref) {
  final repository = ref.watch(quranRepositoryProvider);
  return repository.getAllSurahs();
});

// ═══════════════════════════════════════════════════════════════════
// Surah Detail Provider (ayahs + translations + tafseer)
// ═══════════════════════════════════════════════════════════════════

class SurahDetailData {
  final SurahInfo surahInfo;
  final List<AyahData> ayahs;
  final Map<int, AyahTranslation> translations;
  final Map<int, AyahTafseer> tafseer;

  const SurahDetailData({
    required this.surahInfo,
    required this.ayahs,
    required this.translations,
    required this.tafseer,
  });
}

final surahDetailProvider = FutureProvider.family<SurahDetailData, int>((
  ref,
  surahNumber,
) async {
  final repository = ref.watch(quranRepositoryProvider);

  final results = await Future.wait([
    repository.getSurahByNumber(surahNumber),
    repository.getSurahAyahs(surahNumber),
    repository.getTranslations(surahNumber),
    repository.getSurahTafseer(surahNumber),
  ]);

  final surahInfo = results[0] as SurahInfo;
  final ayahs = results[1] as List<AyahData>;
  final translations = results[2] as List<AyahTranslation>;
  final tafseer = results[3] as List<AyahTafseer>;

  final translationMap = <int, AyahTranslation>{};
  for (final t in translations) {
    translationMap[t.ayahNumber] = t;
  }

  final tafseerMap = <int, AyahTafseer>{};
  for (final t in tafseer) {
    tafseerMap[t.ayahNumber] = t;
  }

  return SurahDetailData(
    surahInfo: surahInfo,
    ayahs: ayahs,
    translations: translationMap,
    tafseer: tafseerMap,
  );
});

// ═══════════════════════════════════════════════════════════════════
// Word Analysis Provider
// ═══════════════════════════════════════════════════════════════════

final wordAnalysisProvider = FutureProvider.family<AyahWordAnalysis, int>((
  ref,
  absoluteAyahNumber,
) async {
  final repository = ref.watch(quranRepositoryProvider);
  return repository.getWordAnalysis(absoluteAyahNumber);
});

// ═══════════════════════════════════════════════════════════════════
// Search Provider
// ═══════════════════════════════════════════════════════════════════

class QuranSearchState {
  final String query;
  final List<QuranSearchResult> results;
  final bool isSearching;
  final String? error;

  const QuranSearchState({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
    this.error,
  });

  QuranSearchState copyWith({
    String? query,
    List<QuranSearchResult>? results,
    bool? isSearching,
    String? error,
  }) {
    return QuranSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      error: error,
    );
  }
}

class QuranSearchNotifier extends StateNotifier<QuranSearchState> {
  final QuranRepository _repository;

  QuranSearchNotifier(this._repository) : super(const QuranSearchState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const QuranSearchState();
      return;
    }

    state = state.copyWith(query: query, isSearching: true, error: null);

    try {
      final results = await _repository.searchQuran(query);
      state = state.copyWith(results: results, isSearching: false);
    } catch (e) {
      state = state.copyWith(isSearching: false, error: e.toString());
    }
  }

  void clear() {
    state = const QuranSearchState();
  }
}

final searchProvider =
    StateNotifierProvider<QuranSearchNotifier, QuranSearchState>((ref) {
  final repository = ref.watch(quranRepositoryProvider);
  return QuranSearchNotifier(repository);
});

// ═══════════════════════════════════════════════════════════════════
// Last Read Provider
// ═══════════════════════════════════════════════════════════════════

class LastReadState {
  final int? surahNumber;
  final int? ayahNumber;
  final DateTime? lastReadAt;

  const LastReadState({
    this.surahNumber,
    this.ayahNumber,
    this.lastReadAt,
  });

  LastReadState copyWith({
    int? surahNumber,
    int? ayahNumber,
    DateTime? lastReadAt,
  }) {
    return LastReadState(
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      lastReadAt: lastReadAt ?? this.lastReadAt,
    );
  }
}

class LastReadNotifier extends StateNotifier<LastReadState> {
  LastReadNotifier() : super(const LastReadState());

  void update({required int surahNumber, required int ayahNumber}) {
    state = LastReadState(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      lastReadAt: DateTime.now(),
    );
  }
}

final lastReadProvider =
    StateNotifierProvider<LastReadNotifier, LastReadState>((ref) {
  return LastReadNotifier();
});

// ═══════════════════════════════════════════════════════════════════
// Reading Mode Toggles
// ═══════════════════════════════════════════════════════════════════

final showTranslationProvider = StateProvider<bool>((ref) => false);
final showTafseerProvider = StateProvider<bool>((ref) => false);

// ═══════════════════════════════════════════════════════════════════
// Audio Playback State for Reading Screen
// ═══════════════════════════════════════════════════════════════════

class SurahAudioState {
  final bool isPlaying;
  final int currentAyah;
  final int totalAyahs;
  final String reciterId;

  const SurahAudioState({
    this.isPlaying = false,
    this.currentAyah = 0,
    this.totalAyahs = 0,
    this.reciterId = 'mishary',
  });

  SurahAudioState copyWith({
    bool? isPlaying,
    int? currentAyah,
    int? totalAyahs,
    String? reciterId,
  }) {
    return SurahAudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentAyah: currentAyah ?? this.currentAyah,
      totalAyahs: totalAyahs ?? this.totalAyahs,
      reciterId: reciterId ?? this.reciterId,
    );
  }
}

class SurahAudioNotifier extends StateNotifier<SurahAudioState> {
  final Ref _ref;

  SurahAudioNotifier(this._ref) : super(const SurahAudioState());

  QuranAudioHandler? get _handler => _ref.read(audioHandlerProvider);

  Future<void> playSurah({
    required int surahNumber,
    required int totalAyahs,
    String reciterId = 'mishary',
  }) async {
    final handler = _handler;
    if (handler == null) return;

    state = SurahAudioState(
      isPlaying: true,
      currentAyah: 1,
      totalAyahs: totalAyahs,
      reciterId: reciterId,
    );

    await handler.playSurah(
      surahNumber: surahNumber,
      totalAyahs: totalAyahs,
      reciterId: reciterId,
    );
  }

  void pause() {
    _handler?.pause();
    state = state.copyWith(isPlaying: false);
  }

  void resume() {
    _handler?.resume();
    state = state.copyWith(isPlaying: true);
  }

  void stop() {
    _handler?.stop();
    state = const SurahAudioState();
  }

  void updateCurrentAyah(int ayah) {
    state = state.copyWith(currentAyah: ayah);
  }
}

final surahAudioProvider =
    StateNotifierProvider<SurahAudioNotifier, SurahAudioState>((ref) {
  return SurahAudioNotifier(ref);
});

// ═══════════════════════════════════════════════════════════════════
// Juz Filter State
// ═══════════════════════════════════════════════════════════════════

final juzFilterProvider = StateProvider<int?>((ref) => null);
final revelationFilterProvider = StateProvider<String>((ref) => 'All');
