import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/database/database.dart';

// ═══════════════════════════════════════════════════════════════════
// Search History Provider
// ═══════════════════════════════════════════════════════════════════

class SearchHistoryState {
  final List<SearchHistory> entries;
  final bool isLoading;

  const SearchHistoryState({
    this.entries = const [],
    this.isLoading = false,
  });

  SearchHistoryState copyWith({
    List<SearchHistory>? entries,
    bool? isLoading,
  }) {
    return SearchHistoryState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SearchHistoryNotifier extends StateNotifier<SearchHistoryState> {
  SearchHistoryNotifier() : super(const SearchHistoryState()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    state = state.copyWith(isLoading: true);
    try {
      final db = AppDatabase.instance;
      final entries = await db.getSearchHistory(limit: 10);
      state = state.copyWith(entries: entries, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Insert a new search entry into the DB and refresh.
  Future<void> addEntry({
    required String query,
    String searchScope = 'quran',
    int resultCount = 0,
  }) async {
    try {
      final db = AppDatabase.instance;
      await db.addSearchHistory(
        query: query,
        searchScope: searchScope,
        resultCount: resultCount,
      );
      await _loadHistory();
    } catch (_) {
      // silently fail
    }
  }

  /// Delete a single search entry by its DB id.
  Future<void> deleteEntry(int id) async {
    try {
      final db = AppDatabase.instance;
      await db.deleteSearchEntry(id);
      await _loadHistory();
    } catch (_) {
      // silently fail
    }
  }

  /// Clear all search history.
  Future<void> clearAll() async {
    try {
      final db = AppDatabase.instance;
      await db.clearSearchHistory();
      state = const SearchHistoryState();
    } catch (_) {
      // silently fail
    }
  }
}

final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, SearchHistoryState>((ref) {
  return SearchHistoryNotifier();
});
