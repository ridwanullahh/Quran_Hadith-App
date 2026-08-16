import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../app/theme/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════
// Advanced Verse Copy Menu — bottom sheet with copy options
// ═══════════════════════════════════════════════════════════════════

class VerseCopyMenu {
  VerseCopyMenu._();

  /// Show the copy bottom sheet for an ayah.
  static void show({
    required BuildContext context,
    required String arabicText,
    String? translationText,
    required String surahName,
    required int surahNumber,
    required int ayahNumber,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _VerseCopySheet(
        arabicText: arabicText,
        translationText: translationText,
        surahName: surahName,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
      ),
    );
  }
}

class _VerseCopySheet extends StatelessWidget {
  final String arabicText;
  final String? translationText;
  final String surahName;
  final int surahNumber;
  final int ayahNumber;

  const _VerseCopySheet({
    required this.arabicText,
    this.translationText,
    required this.surahName,
    required this.surahNumber,
    required this.ayahNumber,
  });

  String _ref() => '$surahName $surahNumber:$ayahNumber';

  void _copy(String data, String label, BuildContext context) {
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasTranslation = translationText != null && translationText!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'Copy Verse',
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _ref(),
            style: TextStyle(
              fontFamily: AppTheme.latinFontFamily,
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Options
          _CopyOption(
            icon: Icons.translate_rounded,
            title: 'Arabic Only',
            subtitle: 'Copy the Arabic text of the verse',
            onTap: () => _copy(arabicText, 'Arabic text', context),
            isDark: isDark,
          ),
          if (hasTranslation) ...[
            const SizedBox(height: 8),
            _CopyOption(
              icon: Icons.language_rounded,
              title: 'Translation Only',
              subtitle: 'Copy the English translation',
              onTap: () => _copy(translationText!, 'Translation', context),
              isDark: isDark,
            ),
          ],
          const SizedBox(height: 8),
          _CopyOption(
            icon: Icons.format_list_numbered_rounded,
            title: 'Arabic + Translation',
            subtitle: 'Copy both Arabic and translation',
            onTap: () {
              final both = StringBuffer();
              both.writeln(arabicText);
              if (hasTranslation) {
                both.writeln();
                both.writeln(translationText);
              }
              _copy(both.toString().trim(), 'Arabic & translation', context);
            },
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _CopyOption(
            icon: Icons.bookmark_rounded,
            title: 'With Reference',
            subtitle: 'Include surah name and ayah number',
            onTap: () {
              final withRef = StringBuffer();
              withRef.writeln(arabicText);
              if (hasTranslation) {
                withRef.writeln();
                withRef.writeln(translationText);
              }
              withRef.writeln();
              withRef.writeln('— $_ref()');
              _copy(withRef.toString().trim(), 'Verse with reference', context);
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _CopyOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;

  const _CopyOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTheme.latinFontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: AppTheme.latinFontFamily,
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.content_copy_rounded,
                size: 18,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
