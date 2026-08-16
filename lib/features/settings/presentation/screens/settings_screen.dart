import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../app/app.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/database/database.dart';
import '../../../hifdh/presentation/providers/hifdh_providers.dart';
import '../providers/theme_provider.dart';
import '../../../app_lock/presentation/providers/app_lock_provider.dart';
import '../../../app_lock/presentation/screens/app_lock_screen.dart';


class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  double _arabicFontSize = 24.0;
  String _translationLanguage = 'en';
  String _defaultReciter = 'mishary';
  String _audioQuality = 'high';
  AppThemeMode _themeMode = AppThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = Hive.box('settings');
    setState(() {
      _arabicFontSize = box.get('arabic_font_size', defaultValue: 24.0) as double;
      _translationLanguage = box.get('translation_language', defaultValue: 'en') as String;
      _defaultReciter = box.get('default_reciter', defaultValue: 'mishary') as String;
      _audioQuality = box.get('audio_quality', defaultValue: 'high') as String;
      // Default to light theme (per product brief: "light by default").
      final savedMode = box.get('theme_mode', defaultValue: 'light') as String;
      _themeMode = ThemeModeNotifier.fromString(savedMode);
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final box = Hive.box('settings');
    await box.put(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Appearance ──────────────────────────────────────
          _SectionTitle(title: 'Appearance', icon: Icons.palette_rounded),
          _SettingsCard(
            children: [
              // Theme toggle
              _SettingsTile(
                icon: _themeModeIcon(_themeMode),
                iconColor: AppColors.primary,
                title: 'Theme',
                subtitle: _themeModeLabel(_themeMode),
                trailing: SegmentedButton<AppThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: AppThemeMode.light,
                      label: Text('Light', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.light_mode_rounded, size: 16),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.dark,
                      label: Text('Dark', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.dark_mode_rounded, size: 16),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.amoled,
                      label: Text('AMOLED', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.brightness_3_rounded, size: 16),
                    ),
                  ],
                  selected: {_themeMode},
                  onSelectionChanged: (modes) {
                    final mode = modes.first;
                    setState(() => _themeMode = mode);
                    ref.read(themeModeProvider.notifier).setThemeMode(mode);
                    _saveSetting('theme_mode', ThemeModeNotifier.toStringValue(mode));
                  },
                ),
              ),
              const _Divider(),
              // Arabic font size
              _SettingsTile(
                icon: Icons.text_fields_rounded,
                iconColor: AppColors.secondary,
                title: 'Arabic Font Size',
                subtitle: '${_arabicFontSize.round()}px',
                trailing: SizedBox(
                  width: 200,
                  child: Slider(
                    value: _arabicFontSize,
                    min: 16,
                    max: 40,
                    divisions: 12,
                    activeColor: AppColors.secondary,
                    onChanged: (value) {
                      setState(() => _arabicFontSize = value);
                      _saveSetting('arabic_font_size', value);
                    },
                  ),
                ),
              ),
            ],
          ),

          // ── Quran ───────────────────────────────────────────
          const SizedBox(height: 8),
          _SectionTitle(title: 'Quran', icon: Icons.menu_book_rounded),
          _SettingsCard(
            children: [
              // Translation language
              _SettingsTile(
                icon: Icons.translate_rounded,
                iconColor: AppColors.primary,
                title: 'Translation Language',
                subtitle: AppConstants.translationLanguages[_translationLanguage] ?? 'English',
                trailing: DropdownButton<String>(
                  value: _translationLanguage,
                  underline: const SizedBox.shrink(),
                  borderRadius: BorderRadius.circular(8),
                  items: AppConstants.translationLanguages.entries.map((e) {
                    return DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value, style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _translationLanguage = value);
                    _saveSetting('translation_language', value);
                  },
                ),
              ),
            ],
          ),

          // ── Audio ───────────────────────────────────────────
          const SizedBox(height: 8),
          _SectionTitle(title: 'Audio', icon: Icons.headphones_rounded),
          _SettingsCard(
            children: [
              // Default reciter
              _SettingsTile(
                icon: Icons.person_rounded,
                iconColor: AppColors.revisionBlue,
                title: 'Default Reciter',
                subtitle: AppConstants.reciters
                        .where((r) => r['id'] == _defaultReciter)
                        .firstOrNull?['name'] ??
                    'Mishary Rashid Alafasy',
                trailing: DropdownButton<String>(
                  value: _defaultReciter,
                  underline: const SizedBox.shrink(),
                  borderRadius: BorderRadius.circular(8),
                  items: AppConstants.reciters.map((r) {
                    return DropdownMenuItem(
                      value: r['id'],
                      child: Text(
                        r['name']!,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _defaultReciter = value);
                    _saveSetting('default_reciter', value);
                  },
                ),
              ),
              const _Divider(),
              // Audio quality
              _SettingsTile(
                icon: Icons.high_quality_rounded,
                iconColor: AppColors.hifdhGreen,
                title: 'Audio Quality',
                subtitle: _audioQualityLabel(_audioQuality),
                trailing: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'low',
                      label: Text('Low', style: TextStyle(fontSize: 12)),
                    ),
                    ButtonSegment(
                      value: 'medium',
                      label: Text('Med', style: TextStyle(fontSize: 12)),
                    ),
                    ButtonSegment(
                      value: 'high',
                      label: Text('High', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                  selected: {_audioQuality},
                  onSelectionChanged: (values) {
                    final q = values.first;
                    setState(() => _audioQuality = q);
                    _saveSetting('audio_quality', q);
                  },
                ),
              ),
            ],
          ),

          // ── Security ──────────────────────────────────────
          const SizedBox(height: 8),
          _SectionTitle(title: 'Security', icon: Icons.lock_rounded),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.pin_rounded,
                iconColor: AppColors.primary,
                title: 'App Lock',
                subtitle: 'PIN-based lock when app is in background',
                trailing: Switch(
                  value: ref.watch(appLockProvider).isEnabled,
                  onChanged: (enabled) async {
                    if (enabled && !ref.read(appLockProvider).isSetup) {
                      await showPinSetupDialog(context);
                    } else {
                      await ref.read(appLockProvider.notifier).setEnabled(enabled);
                    }
                  },
                  activeColor: AppColors.primary,
                ),
              ),
            ],
          ),

          // ── Data ───────────────────────────────────────────
          const SizedBox(height: 8),
          _SectionTitle(title: 'Data & Storage', icon: Icons.storage_rounded),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.delete_sweep_rounded,
                iconColor: AppColors.error,
                title: 'Clear All Data',
                subtitle: 'Remove bookmarks, notes, and progress',
                trailing: FilledButton.tonal(
                  onPressed: () => _showClearDataDialog(context),
                  style: FilledButton.styleFrom(
                    foregroundColor: AppColors.error,
                    backgroundColor: AppColors.error.withOpacity(0.1),
                  ),
                  child: const Text('Clear'),
                ),
              ),
            ],
          ),

          // ── About ──────────────────────────────────────────
          const SizedBox(height: 8),
          _SectionTitle(title: 'About', icon: Icons.info_outline_rounded),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.apps_rounded,
                iconColor: AppColors.primary,
                title: 'Version',
                subtitle: '0.1.0+1',
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.system_update_rounded,
                iconColor: AppColors.success,
                title: 'Check for Updates',
                subtitle: 'See if a newer version is available',
                onTap: () => context.push('/update'),
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.replay_rounded,
                iconColor: AppColors.secondary,
                title: 'Replay Onboarding',
                subtitle: 'Go through the setup wizard again',
                onTap: () async {
                  final box = Hive.box('settings');
                  await box.put('onboarding_completed', false);
                  if (mounted) {
                    context.go('/onboarding');
                  }
                },
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.code_rounded,
                iconColor: AppColors.darkTextTertiary,
                title: 'MinhaajulHudaa',
                subtitle: 'A premium Qur\'an & Hadith application built with Flutter.',
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your bookmarks, notes, '
          'memorization progress, and audio downloads. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final db = AppDatabase.instance;
                await db.clearAllData();
                ref.invalidate(hifzhStatsProvider);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data cleared successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to clear data: $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );
  }

  IconData _themeModeIcon(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.light => Icons.light_mode_rounded,
      AppThemeMode.dark => Icons.dark_mode_rounded,
      AppThemeMode.amoled => Icons.brightness_3_rounded,
    };
  }

  String _themeModeLabel(AppThemeMode mode) {
    return switch (mode) {
      AppThemeMode.light => 'Light theme',
      AppThemeMode.dark => 'Dark theme',
      AppThemeMode.amoled => 'AMOLED (true black)',
    };
  }

  String _audioQualityLabel(String quality) {
    return switch (quality) {
      'low' => 'Low quality (saves space)',
      'medium' => 'Medium quality',
      'high' => 'High quality (best sound)',
      _ => 'High quality',
    };
  }
}

// ═══════════════════════════════════════════════════════════════════
// Reusable Components
// ═══════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
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

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBorder
              : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle = '',
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
    );
  }
}
