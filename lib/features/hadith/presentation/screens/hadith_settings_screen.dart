import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════
// Hadith Settings State
// ═══════════════════════════════════════════════════════════════════

class HadithSettings {
  final double arabicFontSize;
  final double translationFontSize;
  final bool showIsnad;
  final bool showGrade;
  final String defaultCollection;
  final String readingFont;

  const HadithSettings({
    this.arabicFontSize = 22.0,
    this.translationFontSize = 16.0,
    this.showIsnad = false,
    this.showGrade = true,
    this.defaultCollection = 'bukhari',
    this.readingFont = 'Inter',
  });

  Map<String, dynamic> toMap() => {
        'arabicFontSize': arabicFontSize,
        'translationFontSize': translationFontSize,
        'showIsnad': showIsnad,
        'showGrade': showGrade,
        'defaultCollection': defaultCollection,
        'readingFont': readingFont,
      };

  factory HadithSettings.fromMap(Map<dynamic, dynamic> map) {
    return HadithSettings(
      arabicFontSize: (map['arabicFontSize'] as num?)?.toDouble() ?? 22.0,
      translationFontSize: (map['translationFontSize'] as num?)?.toDouble() ?? 16.0,
      showIsnad: map['showIsnad'] as bool? ?? false,
      showGrade: map['showGrade'] as bool? ?? true,
      defaultCollection: map['defaultCollection'] as String? ?? 'bukhari',
      readingFont: map['readingFont'] as String? ?? 'Inter',
    );
  }

  HadithSettings copyWith({
    double? arabicFontSize,
    double? translationFontSize,
    bool? showIsnad,
    bool? showGrade,
    String? defaultCollection,
    String? readingFont,
  }) {
    return HadithSettings(
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      translationFontSize: translationFontSize ?? this.translationFontSize,
      showIsnad: showIsnad ?? this.showIsnad,
      showGrade: showGrade ?? this.showGrade,
      defaultCollection: defaultCollection ?? this.defaultCollection,
      readingFont: readingFont ?? this.readingFont,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Provider
// ═══════════════════════════════════════════════════════════════════

final hadithSettingsProvider =
    StateNotifierProvider<HadithSettingsNotifier, HadithSettings>((ref) {
  return HadithSettingsNotifier();
});

class HadithSettingsNotifier extends StateNotifier<HadithSettings> {
  HadithSettingsNotifier() : super(const HadithSettings()) {
    _load();
  }

  void _load() {
    try {
      final box = Hive.box('settings');
      final map = box.get('hadith_settings');
      if (map != null && map is Map) {
        state = HadithSettings.fromMap(map);
      }
    } catch (_) {}
  }

  Future<void> update(HadithSettings settings) async {
    state = settings;
    try {
      final box = Hive.box('settings');
      await box.put('hadith_settings', settings.toMap());
    } catch (_) {}
  }
}

// ═══════════════════════════════════════════════════════════════════
// Hadith Settings Screen
// ═══════════════════════════════════════════════════════════════════

class HadithSettingsScreen extends ConsumerWidget {
  const HadithSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(hadithSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadith Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // ── Font Sizes Section ─────────────────────────────
          _sectionHeader(context, 'Typography', Icons.text_fields_rounded),
          const SizedBox(height: 8),
          _SettingsCard(
            isDark: isDark,
            children: [
              // Arabic font size slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Arabic Font Size', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        Text(
                          '${settings.arabicFontSize.toInt()}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.primary,
                        thumbColor: AppColors.primary,
                        inactiveTrackColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        overlayColor: AppColors.primary.withOpacity(0.12),
                      ),
                      child: Slider(
                        value: settings.arabicFontSize,
                        min: 14.0,
                        max: 36.0,
                        divisions: 22,
                        onChanged: (val) {
                          ref.read(hadithSettingsProvider.notifier).update(
                            settings.copyWith(arabicFontSize: val),
                          );
                        },
                      ),
                    ),
                    // Preview
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                        style: AppTheme.arabicQuranText.copyWith(
                          fontSize: settings.arabicFontSize,
                          height: 2.0,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.darkBorder),

              // Translation font size slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Translation Font Size', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        Text(
                          '${settings.translationFontSize.toInt()}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.primary,
                        thumbColor: AppColors.primary,
                        inactiveTrackColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        overlayColor: AppColors.primary.withOpacity(0.12),
                      ),
                      child: Slider(
                        value: settings.translationFontSize,
                        min: 12.0,
                        max: 24.0,
                        divisions: 12,
                        onChanged: (val) {
                          ref.read(hadithSettingsProvider.notifier).update(
                            settings.copyWith(translationFontSize: val),
                          );
                        },
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'In the name of Allah, the Most Gracious, the Most Merciful.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: settings.translationFontSize,
                          height: 1.6,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Display Section ────────────────────────────────
          _sectionHeader(context, 'Display', Icons.visibility_rounded),
          const SizedBox(height: 8),
          _SettingsCard(
            isDark: isDark,
            children: [
              SwitchListTile(
                title: const Text('Show Narrator Chain (Isnad)'),
                subtitle: const Text('Display the full chain of narrators'),
                value: settings.showIsnad,
                activeColor: AppColors.primary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                onChanged: (val) {
                  ref.read(hadithSettingsProvider.notifier).update(
                    settings.copyWith(showIsnad: val),
                  );
                },
              ),
              const Divider(height: 1, color: AppColors.darkBorder, indent: 16, endIndent: 16),
              SwitchListTile(
                title: const Text('Show Hadith Grade'),
                subtitle: const Text('Display the authenticity grade badge'),
                value: settings.showGrade,
                activeColor: AppColors.primary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                onChanged: (val) {
                  ref.read(hadithSettingsProvider.notifier).update(
                    settings.copyWith(showGrade: val),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Defaults Section ───────────────────────────────
          _sectionHeader(context, 'Defaults', Icons.tune_rounded),
          const SizedBox(height: 8),
          _SettingsCard(
            isDark: isDark,
            children: [
              // Default collection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Default Collection',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['bukhari', 'muslim', 'tirmidhi', 'abudawud', 'nasai', 'ibnmajah']
                          .map((id) {
                        final isSelected = settings.defaultCollection == id;
                        final label = id
                            .replaceAllMapped(
                              RegExp(r'[A-Z]'),
                              (m) => ' ${m.group(0)}',
                            )
                            .split(' ')
                            .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
                            .join(' ');
                        return ChoiceChip(
                          label: Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            width: 0.5,
                          ),
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          onSelected: (_) {
                            ref.read(hadithSettingsProvider.notifier).update(
                              settings.copyWith(defaultCollection: id),
                            );
                          },
                        );
                      })
                          .toList(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.darkBorder, indent: 16, endIndent: 16),

              // Reading font
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reading Font',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Inter', 'Amiri', 'ScheherazadeNew']
                          .map((font) {
                        final isSelected = settings.readingFont == font;
                        return ChoiceChip(
                          label: Text(
                            font,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                              fontFamily: font,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            width: 0.5,
                          ),
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          onSelected: (_) {
                            ref.read(hadithSettingsProvider.notifier).update(
                              settings.copyWith(readingFont: font),
                            );
                          },
                        );
                      })
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 0, 0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Settings Card Helper
// ═══════════════════════════════════════════════════════════════════

class _SettingsCard extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const _SettingsCard({required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }
}
