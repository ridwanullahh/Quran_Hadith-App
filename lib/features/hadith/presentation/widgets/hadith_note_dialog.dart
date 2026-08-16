import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../../app/theme/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════
// Hadith Note Dialog / Bottom Sheet
// ═══════════════════════════════════════════════════════════════════

class HadithNoteDialog extends StatefulWidget {
  final String collectionId;
  final int bookNumber;
  final int hadithNumber;
  final String hadithPreview;

  const HadithNoteDialog({
    super.key,
    required this.collectionId,
    required this.bookNumber,
    required this.hadithNumber,
    required this.hadithPreview,
  });

  /// Shows the note dialog and returns the saved note text, or null if cancelled.
  static Future<String?> show({
    required BuildContext context,
    required String collectionId,
    required int bookNumber,
    required int hadithNumber,
    required String hadithPreview,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HadithNoteDialog(
        collectionId: collectionId,
        bookNumber: bookNumber,
        hadithNumber: hadithNumber,
        hadithPreview: hadithPreview,
      ),
    );
  }

  static String noteKey({
    required String collectionId,
    required int bookNumber,
    required int hadithNumber,
  }) {
    return '${collectionId}_${bookNumber}_$hadithNumber';
  }

  @override
  State<HadithNoteDialog> createState() => _HadithNoteDialogState();
}

class _HadithNoteDialogState extends State<HadithNoteDialog> {
  late TextEditingController _controller;
  late String _existingNote;
  static const int _maxLength = 1000;

  @override
  void initState() {
    super.initState();
    _existingNote = _loadNote();
    _controller = TextEditingController(text: _existingNote);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _loadNote() {
    try {
      final box = Hive.box('hadith_notes');
      final key = HadithNoteDialog.noteKey(
        collectionId: widget.collectionId,
        bookNumber: widget.bookNumber,
        hadithNumber: widget.hadithNumber,
      );
      return box.get(key, defaultValue: '') as String;
    } catch (_) {
      return '';
    }
  }

  Future<void> _saveNote() async {
    final text = _controller.text.trim();
    try {
      final box = Hive.box('hadith_notes');
      final key = HadithNoteDialog.noteKey(
        collectionId: widget.collectionId,
        bookNumber: widget.bookNumber,
        hadithNumber: widget.hadithNumber,
      );
      if (text.isEmpty) {
        await box.delete(key);
      } else {
        await box.put(key, {
          'note': text,
          'hadithPreview': widget.hadithPreview,
          'collectionId': widget.collectionId,
          'bookNumber': widget.bookNumber,
          'hadithNumber': widget.hadithNumber,
          'savedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (_) {}
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = _existingNote.isNotEmpty;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.darkBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Row(
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isEditing ? 'Edit Note' : 'Add Note',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (isEditing)
                      TextButton(
                        onPressed: () {
                          _controller.clear();
                        },
                        child: Text(
                          'Clear',
                          style: TextStyle(color: AppColors.error, fontSize: 13),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),

                // Hadith preview
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.hadithPreview.length > 120
                        ? '${widget.hadithPreview.substring(0, 120)}...'
                        : widget.hadithPreview,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 16),

                // Note text field
                TextField(
                  controller: _controller,
                  maxLines: 5,
                  maxLength: _maxLength,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Write your note about this hadith...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saveNote,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(isEditing ? 'Update' : 'Save Note'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
