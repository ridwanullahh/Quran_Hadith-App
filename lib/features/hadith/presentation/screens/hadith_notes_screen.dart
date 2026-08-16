import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../../../app/theme/app_colors.dart';
import '../widgets/hadith_note_dialog.dart';

// ═══════════════════════════════════════════════════════════════════
// Hadith Note Entry
// ═══════════════════════════════════════════════════════════════════

class HadithNoteEntry {
  final String key;
  final String note;
  final String hadithPreview;
  final String collectionId;
  final int bookNumber;
  final int hadithNumber;
  final DateTime savedAt;

  const HadithNoteEntry({
    required this.key,
    required this.note,
    required this.hadithPreview,
    required this.collectionId,
    required this.bookNumber,
    required this.hadithNumber,
    required this.savedAt,
  });

  factory HadithNoteEntry.fromMap(String key, Map<dynamic, dynamic> map) {
    return HadithNoteEntry(
      key: key,
      note: map['note'] as String? ?? '',
      hadithPreview: map['hadithPreview'] as String? ?? '',
      collectionId: map['collectionId'] as String? ?? '',
      bookNumber: map['bookNumber'] as int? ?? 0,
      hadithNumber: map['hadithNumber'] as int? ?? 0,
      savedAt: map['savedAt'] != null
          ? DateTime.tryParse(map['savedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Hadith Notes Screen
// ═══════════════════════════════════════════════════════════════════

class HadithNotesScreen extends StatefulWidget {
  const HadithNotesScreen({super.key});

  @override
  State<HadithNotesScreen> createState() => _HadithNotesScreenState();
}

class _HadithNotesScreenState extends State<HadithNotesScreen> {
  List<HadithNoteEntry> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    try {
      final box = Hive.box('hadith_notes');
      final entries = <HadithNoteEntry>[];
      for (final key in box.keys) {
        final val = box.get(key);
        if (val is Map) {
          entries.add(HadithNoteEntry.fromMap(key as String, val));
        }
      }
      entries.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      setState(() {
        _notes = entries;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteNote(String key) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final box = Hive.box('hadith_notes');
      await box.delete(key);
      _loadNotes();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadith Notes'),
        actions: [
          if (_notes.isNotEmpty)
            Text(
              '${_notes.length}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
              ? _buildEmptyState(theme, isDark)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _notes.length,
                  itemBuilder: (context, index) {
                    final entry = _notes[index];
                    return _NoteCard(
                      entry: entry,
                      index: index,
                      isDark: isDark,
                      onTap: () async {
                        await HadithNoteDialog.show(
                          context: context,
                          collectionId: entry.collectionId,
                          bookNumber: entry.bookNumber,
                          hadithNumber: entry.hadithNumber,
                          hadithPreview: entry.hadithPreview,
                        );
                        _loadNotes();
                      },
                      onLongPress: () => _deleteNote(entry.key),
                      onNavigate: () {
                        context.push(
                          '/hadith/book/${entry.collectionId}_${entry.bookNumber}',
                        );
                      },
                    );
                  },
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
                Icons.edit_note_rounded,
                size: 36,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Hadith Notes Yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add notes to any hadith while reading. Tap the note icon on a hadith card to get started.',
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
// Note Card
// ═══════════════════════════════════════════════════════════════════

class _NoteCard extends StatelessWidget {
  final HadithNoteEntry entry;
  final int index;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onNavigate;

  const _NoteCard({
    required this.entry,
    required this.index,
    required this.isDark,
    required this.onTap,
    required this.onLongPress,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = _formatTimeAgo(entry.savedAt);

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.note_rounded, size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.collectionId.replaceAll('-', ' ').toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Hadith #${entry.hadithNumber} · Book ${entry.bookNumber}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Hadith preview
                if (entry.hadithPreview.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      entry.hadithPreview.length > 100
                          ? '${entry.hadithPreview.substring(0, 100)}...'
                          : entry.hadithPreview,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Note content
                Text(
                  entry.note,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 10),

                // Footer actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onNavigate,
                      icon: const Icon(Icons.open_in_new_rounded, size: 14),
                      label: const Text('Open Hadith'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: (index * 50).ms, duration: 300.ms).slideY(begin: 0.03, end: 0),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.month}/${dateTime.day}';
  }
}
