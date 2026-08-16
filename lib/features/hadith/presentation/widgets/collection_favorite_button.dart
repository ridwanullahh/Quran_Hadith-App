import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../app/theme/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════
// Collection Favorites Provider
// ═══════════════════════════════════════════════════════════════════

final collectionFavoritesProvider =
    StateNotifierProvider<CollectionFavoritesNotifier, List<String>>((ref) {
  return CollectionFavoritesNotifier();
});

class CollectionFavoritesNotifier extends StateNotifier<List<String>> {
  CollectionFavoritesNotifier() : super([]) {
    _load();
  }

  void _load() {
    try {
      final box = Hive.box('settings');
      final list = List<String>.from(
        box.get('favorite_collections', defaultValue: <String>[]) as List,
      );
      state = list;
    } catch (_) {
      state = [];
    }
  }

  Future<void> toggle(String collectionId) async {
    try {
      final box = Hive.box('settings');
      final list = List<String>.from(state);

      if (list.contains(collectionId)) {
        list.remove(collectionId);
      } else {
        list.add(collectionId);
      }

      await box.put('favorite_collections', list);
      state = list;
    } catch (_) {}
  }

  bool isFavorite(String collectionId) => state.contains(collectionId);
}

// ═══════════════════════════════════════════════════════════════════
// Collection Favorite Button Widget
// ═══════════════════════════════════════════════════════════════════

class CollectionFavoriteButton extends ConsumerWidget {
  final String collectionId;
  final double? size;

  const CollectionFavoriteButton({
    super.key,
    required this.collectionId,
    this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(
      collectionFavoritesProvider.select((list) => list.contains(collectionId)),
    );

    return IconButton(
      icon: Icon(
        isFav ? Icons.star_rounded : Icons.star_border_rounded,
        color: isFav ? AppColors.secondary : null,
        size: size ?? 22,
      ),
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(width: size != null ? size! + 8 : 32, height: size != null ? size! + 8 : 32),
      onPressed: () {
        ref.read(collectionFavoritesProvider.notifier).toggle(collectionId);
      },
    );
  }
}
