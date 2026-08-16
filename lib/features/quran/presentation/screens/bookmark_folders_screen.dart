import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/quran_providers.dart';

// ═══════════════════════════════════════════════════════════════════
// Bookmark Folder Model (stored in Hive 'settings' box)
// ═══════════════════════════════════════════════════════════════════

class BookmarkFolder {
  final String id;
  final String name;
  final String iconCodePoint; // hex string for IconData
  final int colorValue;
  final bool isDefault;

  const BookmarkFolder({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    this.isDefault = false,
  });

  Color get color => Color(colorValue);
  IconData get icon => IconData(int.parse(iconCodePoint, radix: 16), fontFamily: 'MaterialIcons');

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'iconCodePoint': iconCodePoint,
        'colorValue': colorValue,
        'isDefault': isDefault,
      };

  factory BookmarkFolder.fromMap(Map<String, dynamic> map) => BookmarkFolder(
        id: map['id'] as String,
        name: map['name'] as String,
        iconCodePoint: map['iconCodePoint'] as String,
        colorValue: map['colorValue'] as int,
        isDefault: (map['isDefault'] as bool?) ?? false,
      );

  static const defaults = [
    BookmarkFolder(id: 'last_read', name: 'Last Read', iconCodePoint: 'e916', colorValue: 0xFF0D6E5B, isDefault: true),
    BookmarkFolder(id: 'favorites', name: 'Favorite Ayahs', iconCodePoint: 'e87d', colorValue: 0xFFD4A843, isDefault: true),
    BookmarkFolder(id: 'study_notes', name: 'Study Notes', iconCodePoint: 'e873', colorValue: 0xFF3B82F6, isDefault: true),
    BookmarkFolder(id: 'memorization', name: 'Memorization Targets', iconCodePoint: 'e86f', colorValue: 0xFF10B981, isDefault: true),
  ];
}

// ═══════════════════════════════════════════════════════════════════
// Bookmark Folders Provider
// ═══════════════════════════════════════════════════════════════════

final bookmarkFoldersProvider =
    StateNotifierProvider<BookmarkFoldersNotifier, List<BookmarkFolder>>((ref) {
  return BookmarkFoldersNotifier();
});

class BookmarkFoldersNotifier extends StateNotifier<List<BookmarkFolder>> {
  BookmarkFoldersNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    try {
      final box = Hive.box('settings');
      final raw = box.get('bookmark_folders');
      if (raw != null && raw is List) {
        state = raw.map((e) => BookmarkFolder.fromMap(Map<String, dynamic>.from(e as Map))).toList();
      } else {
        // Initialize defaults
        state = List.from(BookmarkFolder.defaults);
        await _save();
      }
    } catch (_) {
      state = List.from(BookmarkFolder.defaults);
    }
  }

  Future<void> _save() async {
    final box = Hive.box('settings');
    await box.put('bookmark_folders', state.map((f) => f.toMap()).toList());
  }

  Future<void> addFolder(BookmarkFolder folder) async {
    state = [...state, folder];
    await _save();
  }

  Future<void> removeFolder(String id) async {
    state = state.where((f) => f.id != id && !f.isDefault).toList();
    await _save();
  }
}

// ═══════════════════════════════════════════════════════════════════
// Bookmark Folders Screen
// ═══════════════════════════════════════════════════════════════════

class BookmarkFoldersScreen extends ConsumerWidget {
  const BookmarkFoldersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final folders = ref.watch(bookmarkFoldersProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Bookmark Folders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Folder',
            onPressed: () => _showAddFolderDialog(context, ref),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: folders.length + 1, // +1 for add custom at bottom
        itemBuilder: (context, index) {
          if (index == folders.length) {
            return _buildAddCustomTile(isDark, () => _showAddFolderDialog(context, ref));
          }
          final folder = folders[index];
          return _FolderCard(
            folder: folder,
            isDark: isDark,
            onTap: () {
              // Navigate to bookmarks filtered by folder category
              context.pop();
              context.push('/bookmarks');
            },
            onLongPress: folder.isDefault
                ? null
                : () async {
                    await ref.read(bookmarkFoldersProvider.notifier).removeFolder(folder.id);
                  },
          );
        },
      ),
    );
  }

  void _showAddFolderDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int selectedColor = AppColors.primary.value;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'New Bookmark Folder',
              style: TextStyle(
                fontFamily: AppTheme.latinFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Folder name',
                    hintStyle: TextStyle(
                      fontFamily: AppTheme.latinFontFamily,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                // Color picker row
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    AppColors.primary,
                    AppColors.secondary,
                    AppColors.success,
                    AppColors.info,
                    AppColors.warning,
                    AppColors.error,
                    AppColors.medinanBadge,
                    AppColors.revisionBlue,
                  ].map((color) {
                    final isSelected = color.value == selectedColor;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = color.value),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    ref.read(bookmarkFoldersProvider.notifier).addFolder(
                          BookmarkFolder(
                            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                            name: name,
                            iconCodePoint: 'e87d',
                            colorValue: selectedColor,
                          ),
                        );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddCustomTile(bool isDark, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primary,
                width: 1,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Add Custom Folder',
                  style: TextStyle(
                    fontFamily: AppTheme.latinFontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  final BookmarkFolder folder;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _FolderCard({
    required this.folder,
    required this.isDark,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: folder.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(folder.icon, size: 22, color: folder.color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        folder.name,
                        style: TextStyle(
                          fontFamily: AppTheme.latinFontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${folder.isDefault ? 'Default' : 'Custom'} folder',
                        style: TextStyle(
                          fontFamily: AppTheme.latinFontFamily,
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
