import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/services/database/database.dart';

// ═══════════════════════════════════════════════════════════════════
// Providers
// ═══════════════════════════════════════════════════════════════════

final notesDbProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final notesStreamProvider = StreamProvider<List<Note>>((ref) {
  final db = ref.watch(notesDbProvider);
  return db.notesDao.watchAllNotes();
});

// ═══════════════════════════════════════════════════════════════════
// Screen
// ═══════════════════════════════════════════════════════════════════

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String _searchQuery = '';
  String _filterSurah = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notesAsync = ref.watch(notesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showNoteEditor(context, ref),
            tooltip: 'Add Note',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Filter chips for surahs
          SizedBox(
            height: 40,
            child: notesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (notes) {
                final surahNumbers = notes.map((n) => n.surahNumber).toSet().toList()..sort();
                if (surahNumbers.length <= 1) return const SizedBox.shrink();

                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: _filterSurah == 'All',
                      onTap: () => setState(() => _filterSurah = 'All'),
                    ),
                    ...surahNumbers.map((s) => _FilterChip(
                      label: 'Surah $s',
                      isSelected: _filterSurah == 'Surah $s',
                      onTap: () => setState(() => _filterSurah = 'Surah $s'),
                    )),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 4),

          // Notes list
          Expanded(
            child: notesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator.adaptive()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text('Failed to load notes', style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
              data: (notes) {
                var filtered = notes;

                // Filter by surah
                if (_filterSurah != 'All') {
                  final surahNum = int.tryParse(_filterSurah.replaceAll('Surah ', '')) ?? 0;
                  filtered = filtered.where((n) => n.surahNumber == surahNum).toList();
                }

                // Filter by search
                if (_searchQuery.isNotEmpty) {
                  filtered = filtered.where((n) {
                    return n.content.toLowerCase().contains(_searchQuery) ||
                        n.title.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                if (filtered.isEmpty) {
                  return _EmptyState(
                    message: notes.isEmpty ? 'No notes yet' : 'No matching notes',
                    subMessage: notes.isEmpty
                        ? 'Add notes while studying the Quran to review them here.'
                        : 'Try a different search or filter.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final note = filtered[index];
                    return _NoteCard(
                      note: note,
                      onTap: () => _showNoteEditor(context, ref, note: note),
                      onDelete: () => _deleteNote(note.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _deleteNote(int id) {
    final db = ref.read(notesDbProvider);
    db.notesDao.deleteNote(id);
  }

  Future<void> _showNoteEditor(
    BuildContext context,
    WidgetRef ref, {
    Note? note,
  }) async {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    final surahController = TextEditingController(text: '${note?.surahNumber ?? 1}');
    final ayahController = TextEditingController(text: '${note?.ayahNumber ?? 1}');
    int colorIndex = note?.colorIndex ?? 0;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(note == null ? 'New Note' : 'Edit Note'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Color selector
                Row(
                  children: [
                    const Text('Color: '),
                    const SizedBox(width: 8),
                    ...List.generate(6, (i) {
                      final colors = [
                        AppColors.primary,
                        AppColors.secondary,
                        AppColors.revisionBlue,
                        const Color(0xFF7C3AED),
                        const Color(0xFFEC4899),
                        AppColors.hifdhGreen,
                      ];
                      return GestureDetector(
                        onTap: () => setDialogState(() => colorIndex = i),
                        child: Container(
                          width: 28,
                          height: 28,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: colors[i],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorIndex == i ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 12),

                // Surah/Ayah
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: surahController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Surah #',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: ayahController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Ayah #',
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title (optional)',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),

                // Content
                TextField(
                  controller: contentController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Note content...',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final content = contentController.text.trim();
                if (content.isEmpty) return;

                final surahNum = int.tryParse(surahController.text.trim()) ?? 1;
                final ayahNum = int.tryParse(ayahController.text.trim()) ?? 1;
                final title = titleController.text.trim();

                final db = ref.read(notesDbProvider);

                if (note == null) {
                  db.notesDao.addNote(
                    surahNumber: surahNum,
                    ayahNumber: ayahNum,
                    content: content,
                    title: title,
                    colorIndex: colorIndex,
                  );
                } else {
                  db.notesDao.updateNote(
                    id: note.id,
                    content: content,
                    title: title,
                    colorIndex: colorIndex,
                  );
                }

                Navigator.pop(ctx, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    titleController.dispose();
    contentController.dispose();
    surahController.dispose();
    ayahController.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════
// Note Card
// ═══════════════════════════════════════════════════════════════════

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  Color get _noteColor {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.revisionBlue,
      const Color(0xFF7C3AED),
      const Color(0xFFEC4899),
      AppColors.hifdhGreen,
    ];
    return colors[note.colorIndex.clamp(0, colors.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Note?'),
            content: const Text('This note will be permanently deleted.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: _noteColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      // Color indicator
                      Container(
                        width: 4,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _noteColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Title or reference
                      Expanded(
                        child: Text(
                          note.title.isNotEmpty
                              ? note.title
                              : 'Surah ${note.surahNumber} : ${note.ayahNumber}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Date
                      Text(
                        _formatDate(note.updatedAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.35),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                  // Content preview
                  if (note.content.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      note.content,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.65),
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Surah reference
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        size: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Surah ${note.surahNumber} : Ayah ${note.ayahNumber}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.02, end: 0);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ═══════════════════════════════════════════════════════════════════
// Filter Chip
// ═══════════════════════════════════════════════════════════════════

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder),
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Empty State
// ═══════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final String message;
  final String subMessage;

  const _EmptyState({required this.message, required this.subMessage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add_rounded,
              size: 56,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subMessage,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
              height: 1.5,
            ),
          ],
        ),
      ),
    );
  }
}
