import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/hadith/hadith_models.dart';
import '../../../../data/repositories/hadith_repository.dart';

// ═══════════════════════════════════════════════════════════════════
// Repository Provider
// ═══════════════════════════════════════════════════════════════════

final hadithRepositoryProvider = Provider<HadithRepository>((ref) {
  return HadithRepository();
});

// ═══════════════════════════════════════════════════════════════════
// Collections Provider
// ═══════════════════════════════════════════════════════════════════

final hadithCollectionsProvider = FutureProvider<List<HadithCollection>>((ref) {
  final repository = ref.watch(hadithRepositoryProvider);
  return repository.getCollections();
});

// ═══════════════════════════════════════════════════════════════════
// Collection Detail Provider
// ═══════════════════════════════════════════════════════════════════

final hadithCollectionProvider =
    FutureProvider.family<HadithCollection, String>((ref, collectionId) {
  final repository = ref.watch(hadithRepositoryProvider);
  return repository.getCollectionById(collectionId);
});

// ═══════════════════════════════════════════════════════════════════
// Books Provider
// ═══════════════════════════════════════════════════════════════════

final hadithBooksProvider =
    FutureProvider.family<List<HadithBook>, String>((ref, collectionId) {
  final repository = ref.watch(hadithRepositoryProvider);
  return repository.getBooks(collectionId);
});

// ═══════════════════════════════════════════════════════════════════
// Hadiths in a Book Provider
// ═══════════════════════════════════════════════════════════════════

class BookIdKey {
  final String collectionId;
  final int bookNumber;

  const BookIdKey({required this.collectionId, required this.bookNumber});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookIdKey &&
        other.collectionId == collectionId &&
        other.bookNumber == bookNumber;
  }

  @override
  int get hashCode => Object.hash(collectionId, bookNumber);
}

final hadithsInBookProvider =
    FutureProvider.family<List<Hadith>, BookIdKey>((ref, key) {
  final repository = ref.watch(hadithRepositoryProvider);
  return repository.getHadiths(key.collectionId, key.bookNumber);
});

// ═══════════════════════════════════════════════════════════════════
// Hadith Search State
// ═══════════════════════════════════════════════════════════════════

class HadithSearchState {
  final String query;
  final List<HadithSearchResult> results;
  final bool isSearching;
  final String? error;

  const HadithSearchState({
    this.query = '',
    this.results = const [],
    this.isSearching = false,
    this.error,
  });

  HadithSearchState copyWith({
    String? query,
    List<HadithSearchResult>? results,
    bool? isSearching,
    String? error,
  }) {
    return HadithSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      error: error,
    );
  }
}

class HadithSearchNotifier extends StateNotifier<HadithSearchState> {
  final HadithRepository _repository;

  HadithSearchNotifier(this._repository)
      : super(const HadithSearchState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const HadithSearchState();
      return;
    }

    state = state.copyWith(query: query, isSearching: true, error: null);

    try {
      final results = await _repository.searchHadith(query);
      state = state.copyWith(results: results, isSearching: false);
    } catch (e) {
      state = state.copyWith(isSearching: false, error: e.toString());
    }
  }

  void clear() {
    state = const HadithSearchState();
  }
}

final hadithSearchProvider =
    StateNotifierProvider<HadithSearchNotifier, HadithSearchState>((ref) {
  final repository = ref.watch(hadithRepositoryProvider);
  return HadithSearchNotifier(repository);
});
