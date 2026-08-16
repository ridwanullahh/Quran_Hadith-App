import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive/hive.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════
// Bookmark Folder Model
// ═══════════════════════════════════════════════════════════════════

class BookmarkFolder {
  final String id;
  final String name;
  final String? emoji;
  final String? colorHex;
  final DateTime createdAt;
  final List<FolderBookmark> bookmarks;

  const BookmarkFolder({
    required this.id,
    required this.name,
    this.emoji,
    this.colorHex,
    required this.createdAt,
    this.bookmarks = const [],
  });

  int get bookmarkCount => bookmarks.length;

  Color get displayColor {
    if (colorHex != null) {
      return Color(int.parse(colorHex!, radix: 16));
    }
    const defaults = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.hifdhGreen,
      const Color(0xFF7C3AED),
      const Color(0xFFEC4899),
      const Color(0xFFF97316),
    ];
    return defaults[id.hashCode.abs() % defaults.length];
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'colorHex': colorHex,
        'createdAt': createdAt.toIso8601String(),
        'bookmarks': bookmarks.map((b) => b.toMap()).toList(),
      };

  factory BookmarkFolder.fromMap(Map<dynamic, dynamic> map) {
    final rawBookmarks = map['bookmarks'] as List? ?? [];
    return BookmarkFolder(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      emoji: map['emoji'] as String?,
      colorHex: map['colorHex'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      bookmarks: rawBookmarks
          .map((b) => FolderBookmark.fromMap(b as Map))
          .toList(),
    );
  }

  BookmarkFolder copyWith({
    String? name,
    String? emoji,
    String? colorHex,
    List<FolderBookmark>? bookmarks,
  }) {
    return BookmarkFolder(
      id: id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt,
      bookmarks: bookmarks ?? this.bookmarks,
    );
  }
}

class FolderBookmark {
  final String collectionId;
  final int bookNumber;
  final int hadithNumber;
  final String preview;
  final DateTime addedAt;

  const FolderBookmark({
    required this.collectionId,
    required this.bookNumber,
    required this.hadithNumber,
    required this.preview,
    required this.addedAt,
  });

  String get uniqueId => '${collectionId}_${bookNumber}_$hadithNumber';

  Map<String, dynamic> toMap() => {
        'collectionId': collectionId,
        'bookNumber': bookNumber,
        'hadithNumber': hadithNumber,
        'preview': preview,
        'addedAt': addedAt.toIso8601String(),
      };

  factory FolderBookmark.fromMap(Map<dynamic, dynamic> map) {
    return FolderBookmark(
      collectionId: map['collectionId'] as String? ?? '',
      bookNumber: map['bookNumber'] as int? ?? 0,
      hadithNumber: map['hadithNumber'] as int? ?? 0,
      preview: map['preview'] as String? ?? '',
      addedAt: DateTime.tryParse(map['addedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Bookmark Folders Screen
// ═══════════════════════════════════════════════════════════════════

class HadithBookmarkFoldersScreen extends StatefulWidget {
  const HadithBookmarkFoldersScreen({super.key});

  @override
  State<HadithBookmarkFoldersScreen> createState() => _HadithBookmarkFoldersScreenState();
}

class _HadithBookmarkFoldersScreenState extends State<HadithBookmarkFoldersScreen> {
  List<BookmarkFolder> _folders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  void _loadFolders() {
    try {
      final box = Hive.box('hadith_bookmark_folders');
      final entries = <BookmarkFolder>[];
      for (final key in box.keys) {
        final val = box.get(key);
        if (val is Map) {
          entries.add(BookmarkFolder.fromMap(val));
        }
      }
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        _folders = entries;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveFolder(BookmarkFolder folder) async {
    try {
      final box = Hive.box('hadith_bookmark_folders');
      await box.put(folder.id, folder.toMap());
      _loadFolders();
    } catch (_) {}
  }

  Future<void> _deleteFolder(String id) async {
    try {
      final box = Hive.box('hadith_bookmark_folders');
      await box.delete(id);
      _loadFolders();
    } catch (_) {}
  }

  void _showCreateFolderDialog() {
    final nameController = TextEditingController();
    final emojis = ['📚', '⭐', '📿', '🕌', '💎', '📝', '🌟', '🤲', '📖', '❤️'];
    String selectedEmoji = '📚';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('New Folder'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Folder Name',
                      hintText: 'e.g., Jumu\'ah Hadiths',
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  Text('Icon', style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: emojis.map((e) {
                      final isSelected = selectedEmoji == e;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedEmoji = e),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected ? Border.all(color: AppColors.primary, width: 1.5) : null,
                          ),
                          child: Center(
                            child: Text(e, style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    final folder = BookmarkFolder(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      emoji: selectedEmoji,
                      createdAt: DateTime.now(),
                    );
                    _saveFolder(folder);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showFolderDetail(BookmarkFolder folder) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FolderDetailScreen(folder: folder),
      ),
    ).then((_) => _loadFolders());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark Folders'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateFolderDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.create_new_folder_rounded),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _folders.isEmpty
              ? _buildEmptyState(theme, isDark)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _folders.length,
                  itemBuilder: (context, index) {
                    final folder = _folders[index];
                    return _FolderCard(
                      folder: folder,
                      index: index,
                      isDark: isDark,
                      onTap: () => _showFolderDetail(folder),
                      onLongPress: () => _confirmDelete(folder),
                    );
                  },
                ),
    );
  }

  void _confirmDelete(BookmarkFolder folder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text('Delete "${folder.name}" and all ${folder.bookmarkCount} bookmarks?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              _deleteFolder(folder.id);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkBorder : AppColors.lightBorder).withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.folder_open_rounded,
                size: 36,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Folders Yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Organize your hadith bookmarks into folders. Tap the + button to create one.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Folder Card
// ═══════════════════════════════════════════════════════════════════

class _FolderCard extends StatelessWidget {
  final BookmarkFolder folder;
  final int index;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _FolderCard({
    required this.folder,
    required this.index,
    required this.isDark,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: folder.displayColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      folder.emoji ?? '📁',
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        folder.name,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${folder.bookmarkCount} bookmarks',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
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
    ).animate().fadeIn(delay: (index * 60).ms, duration: 400.ms).slideY(begin: 0.03, end: 0);
  }
}

// ═══════════════════════════════════════════════════════════════════
// Folder Detail Screen
// ═════════════════════════════════════════════════════════════════

class _FolderDetailScreen extends StatefulWidget {
  final BookmarkFolder folder;
  const _FolderDetailScreen({required this.folder});

  @override
  State<_FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<_FolderDetailScreen> {
  late BookmarkFolder _folder;

  @override
  void initState() {
    super.initState();
    _folder = widget.folder;
  }

  Future<void> _addSampleBookmark() async {
    final sample = FolderBookmark(
      collectionId: 'bukhari',
      bookNumber: 1,
      hadithNumber: _folder.bookmarkCount + 1,
      preview: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ...',
      addedAt: DateTime.now(),
    );
    final updated = _folder.copyWith(
      bookmarks: [..._folder.bookmarks, sample],
    );
    try {
      final box = Hive.box('hadith_bookmark_folders');
      await box.put(updated.id, updated.toMap());
      setState(() => _folder = updated);
    } catch (_) {}
  }

  Future<void> _removeBookmark(int index) async {
    final newBookmarks = List<FolderBookmark>.from(_folder.bookmarks)..removeAt(index);
    final updated = _folder.copyWith(bookmarks: newBookmarks);
    try {
      final box = Hive.box('hadith_bookmark_folders');
      await box.put(updated.id, updated.toMap());
      setState(() => _folder = updated);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_folder.emoji ?? ''} ${_folder.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _addSampleBookmark,
            tooltip: 'Add Bookmark',
          ),
        ],
      ),
      body: _folder.bookmarks.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_add_rounded,
                        size: 48, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    const SizedBox(height: 16),
                    Text(
                      'No bookmarks in this folder',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _addSampleBookmark,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add a bookmark'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _folder.bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = _folder.bookmarks[index];
                return Dismissible(
                  key: ValueKey(bookmark.uniqueId),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _removeBookmark(index),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_rounded, color: AppColors.error),
                  ),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 0.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                '#',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bookmark.preview,
                                  style: AppTheme.arabicQuranText.copyWith(
                                    fontSize: 16,
                                    height: 1.6,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                  textDirection: TextDirection.rtl,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${bookmark.collectionId.toUpperCase()} · Book ${bookmark.bookNumber} · Hadith #${bookmark.hadithNumber}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
