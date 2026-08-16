import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/popup/popup_service.dart';

// ══════════════════════════════════════════════════════════════════════
// Popup Settings Widget
// ══════════════════════════════════════════════════════════════════════

/// A settings panel that can be embedded in the notification settings
/// screen to control in-app popup behaviour.
class PopupSettingsWidget extends ConsumerStatefulWidget {
  const PopupSettingsWidget({super.key});

  @override
  ConsumerState<PopupSettingsWidget> createState() =>
      _PopupSettingsWidgetState();
}

class _PopupSettingsWidgetState extends ConsumerState<PopupSettingsWidget> {
  bool _enabled = true;
  int _intervalMinutes = PopupService.defaultIntervalMinutes;
  PopupContentType _contentType = PopupService.defaultContentType;
  DateTime? _lastShown;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final service = PopupService.instance;
    setState(() {
      _enabled = service.isEnabled;
      _intervalMinutes = service.intervalMinutes;
      _contentType = service.contentType;
      _lastShown = service.lastShownTime;
    });
  }

  Future<void> _setEnabled(bool val) async {
    await PopupService.instance.setEnabled(val);
    setState(() => _enabled = val);
  }

  Future<void> _setInterval(int minutes) async {
    await PopupService.instance.setIntervalMinutes(minutes);
    setState(() => _intervalMinutes = minutes);
  }

  Future<void> _setContentType(PopupContentType type) async {
    await PopupService.instance.setContentType(type);
    setState(() => _contentType = type);
  }

  String _formatLastShown() {
    if (_lastShown == null) return 'Never';
    final now = DateTime.now();
    final diff = now.difference(_lastShown!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Title ───────────────────────────
        _SectionTitle(
          title: 'In-App Reminders',
          icon: Icons.lightbulb_rounded,
        ),

        // ── Main Card ─────────────────────────────
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              // Enable / Disable toggle.
              _SettingsTile(
                icon: const Icon(Icons.lightbulb_rounded, size: 18),
                iconColor: AppColors.secondary,
                title: 'In-App Popups',
                subtitle:
                    'Show periodic Qur\'an verses & hadiths while using the app',
                trailing: Switch(
                  value: _enabled,
                  onChanged: _setEnabled,
                  activeColor: AppColors.primary,
                ),
              ),

              if (_enabled) ...[
                const _Divider(),

                // Interval selector.
                _SettingsTile(
                  icon: const Icon(Icons.schedule_rounded, size: 18),
                  iconColor: AppColors.primary,
                  title: 'Interval',
                  subtitle: _intervalLabel(_intervalMinutes),
                  trailing: _IntervalDropdown(
                    currentValue: _intervalMinutes,
                    onChanged: _setInterval,
                    isDark: isDark,
                  ),
                ),

                const _Divider(),

                // Content type selector.
                _SettingsTile(
                  icon: const Icon(Icons.category_rounded, size: 18),
                  iconColor: AppColors.secondary,
                  title: 'Content Type',
                  subtitle: _contentTypeLabel(_contentType),
                  trailing: _ContentTypeDropdown(
                    currentValue: _contentType,
                    onChanged: _setContentType,
                    isDark: isDark,
                  ),
                ),

                const _Divider(),

                // Last shown time.
                _SettingsTile(
                  icon: const Icon(Icons.history_rounded, size: 18),
                  iconColor: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                  title: 'Last Shown',
                  subtitle: _formatLastShown(),
                ),

                const _Divider(),

                // Show now button.
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        PopupService.instance.showPopup(context);
                        // Refresh the last-shown time after the popup.
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (mounted) setState(() => _loadSettings());
                        });
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const Text('Show Now'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 350.ms),
      ],
    );
  }

  String _intervalLabel(int minutes) {
    if (minutes < 60) return 'Every $minutes minutes';
    final hours = minutes ~/ 60;
    if (minutes % 60 == 0) {
      return hours == 1 ? 'Every hour' : 'Every $hours hours';
    }
    return 'Every ${hours}h ${minutes % 60}m';
  }

  String _contentTypeLabel(PopupContentType type) {
    switch (type) {
      case PopupContentType.quran:
        return 'Qur\'an only';
      case PopupContentType.hadith:
        return 'Hadith only';
      case PopupContentType.both:
        return 'Both (random)';
    }
  }
}

// ══════════════════════════════════════════════════════════════════════
// Interval Dropdown
// ══════════════════════════════════════════════════════════════════════

class _IntervalDropdown extends StatelessWidget {
  final int currentValue;
  final ValueChanged<int> onChanged;
  final bool isDark;

  const _IntervalDropdown({
    required this.currentValue,
    required this.onChanged,
    required this.isDark,
  });

  static const _options = <int, String>{
    15: '15 min',
    30: '30 min',
    60: '1 hour',
    120: '2 hours',
    240: '4 hours',
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: onChanged,
      itemBuilder: (context) => _options.entries
          .map((e) => PopupMenuItem(
                value: e.key,
                child: Text(
                  e.value,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: e.key == currentValue
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary),
                    fontWeight: e.key == currentValue
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                .withOpacity(0.6),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _options[currentValue] ?? '$currentValue min',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.unfold_more_rounded,
              size: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Content Type Dropdown
// ══════════════════════════════════════════════════════════════════════

class _ContentTypeDropdown extends StatelessWidget {
  final PopupContentType currentValue;
  final ValueChanged<PopupContentType> onChanged;
  final bool isDark;

  const _ContentTypeDropdown({
    required this.currentValue,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PopupContentType>(
      onSelected: onChanged,
      itemBuilder: (context) => PopupContentType.values
          .map((type) => PopupMenuItem(
                value: type,
                child: Text(
                  _label(type),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: type == currentValue
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary),
                    fontWeight:
                        type == currentValue ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                .withOpacity(0.6),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _label(currentValue),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.unfold_more_rounded,
              size: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _label(PopupContentType type) {
    switch (type) {
      case PopupContentType.quran:
        return "Qur'an";
      case PopupContentType.hadith:
        return 'Hadith';
      case PopupContentType.both:
        return 'Both';
    }
  }
}

// ══════════════════════════════════════════════════════════════════════
// Shared Helpers (mirror the ones in notification_settings_screen)
// ══════════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.secondary),
          const SizedBox(width: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final Icon icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle = '',
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
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
            child: icon,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
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
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkBorder
            : AppColors.lightBorder,
      ),
    );
  }
}
