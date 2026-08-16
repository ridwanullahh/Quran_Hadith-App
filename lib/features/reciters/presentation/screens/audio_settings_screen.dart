import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../../app/theme/app_colors.dart';

/// Audio settings screen with various playback configuration options.
///
/// Settings are persisted in Hive 'settings' box under 'audio_settings' key.
class AudioSettingsScreen extends StatefulWidget {
  const AudioSettingsScreen({super.key});

  @override
  State<AudioSettingsScreen> createState() => _AudioSettingsScreenState();
}

class _AudioSettingsScreenState extends State<AudioSettingsScreen> {
  // ── Settings state ─────────────────────────────────────────────
  bool _autoPlayNextSurah = false;
  bool _wifiOnly = true;
  int _autoCacheAhead = 3;
  double _defaultSpeed = 1.0;
  String _streamQuality = 'medium'; // low, medium, high
  bool _pauseOnCall = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final box = Hive.box('settings');
    final settings = box.get('audio_settings') as Map?;
    if (settings != null) {
      setState(() {
        _autoPlayNextSurah = settings['auto_play_next_surah'] as bool? ?? false;
        _wifiOnly = settings['wifi_only'] as bool? ?? true;
        _autoCacheAhead = settings['auto_cache_ahead'] as int? ?? 3;
        _defaultSpeed = (settings['default_speed'] as num?)?.toDouble() ?? 1.0;
        _streamQuality = settings['stream_quality'] as String? ?? 'medium';
        _pauseOnCall = settings['pause_on_call'] as bool? ?? true;
      });
    }
  }

  void _saveSettings() {
    final box = Hive.box('settings');
    box.put('audio_settings', {
      'auto_play_next_surah': _autoPlayNextSurah,
      'wifi_only': _wifiOnly,
      'auto_cache_ahead': _autoCacheAhead,
      'default_speed': _defaultSpeed,
      'stream_quality': _streamQuality,
      'pause_on_call': _pauseOnCall,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // ── Playback Section ────────────────────────────────────
          _sectionHeader('Playback'),
          _card([
            _switchTile(
              icon: Icons.skip_next_rounded,
              title: 'Auto-play Next Surah',
              subtitle: 'Continue to the next surah automatically',
              value: _autoPlayNextSurah,
              onChanged: (v) {
                setState(() => _autoPlayNextSurah = v);
                _saveSettings();
              },
            ),
            const _Divider(),
            _navigationTile(
              icon: Icons.speed_rounded,
              title: 'Default Playback Speed',
              subtitle: '${_defaultSpeed}x',
              onTap: () => _showSpeedSelector(),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Download Section ────────────────────────────────────
          _sectionHeader('Downloads'),
          _card([
            _switchTile(
              icon: Icons.wifi_rounded,
              title: 'WiFi Only',
              subtitle: 'Only download when connected to WiFi',
              value: _wifiOnly,
              onChanged: (v) {
                setState(() => _wifiOnly = v);
                _saveSettings();
              },
            ),
            const _Divider(),
            _sliderTile(
              icon: Icons.cached_rounded,
              title: 'Auto-cache Ahead',
              subtitle: '$_autoCacheAhead ayahs',
              value: _autoCacheAhead.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (v) {
                setState(() => _autoCacheAhead = v.round());
                _saveSettings();
              },
            ),
          ]),
          const SizedBox(height: 16),

          // ── Streaming Section ───────────────────────────────────
          _sectionHeader('Streaming'),
          _card([
            _navigationTile(
              icon: Icons.high_quality_rounded,
              title: 'Audio Stream Quality',
              subtitle: _qualityLabel(_streamQuality),
              onTap: () => _showQualitySelector(),
            ),
          ]),
          const SizedBox(height: 16),

          // ── Phone Integration ───────────────────────────────────
          _sectionHeader('Phone'),
          _card([
            _switchTile(
              icon: Icons.phone_in_talk_rounded,
              title: 'Pause on Incoming Call',
              subtitle: 'Automatically pause playback during calls',
              value: _pauseOnCall,
              onChanged: (v) {
                setState(() => _pauseOnCall = v);
                _saveSettings();
              },
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Helper widgets
  // ═══════════════════════════════════════════════════════════════

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        children: [
          Icon(Icons.tune_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
      ),
      child: Column(children: children),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: AppColors.darkTextSecondary,
        ),
      ),
      value: value,
      activeColor: AppColors.primary,
      onChanged: onChanged,
    );
  }

  Widget _navigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: AppColors.darkTextSecondary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.darkTextTertiary, size: 20),
      onTap: onTap,
    );
  }

  Widget _sliderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: AppColors.darkTextSecondary,
        ),
      ),
      trailing: SizedBox(
        width: 120,
        child: SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 8),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.audioProgressTrack,
            thumbColor: AppColors.primary,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  String _qualityLabel(String quality) {
    switch (quality) {
      case 'low':
        return 'Low (saves data)';
      case 'high':
        return 'High (best quality)';
      default:
        return 'Medium (balanced)';
    }
  }

  void _showSpeedSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Default Speed',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ...[0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                final isSelected = _defaultSpeed == speed;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.transparent,
                    title: Text(
                      '${speed}x',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.darkTextPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.primary, size: 22)
                        : null,
                    onTap: () {
                      setState(() => _defaultSpeed = speed);
                      _saveSettings();
                      Navigator.pop(ctx);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showQualitySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Stream Quality',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ...['low', 'medium', 'high'].map((quality) {
                final isSelected = _streamQuality == quality;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.transparent,
                    title: Text(
                      quality[0].toUpperCase() + quality.substring(1),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.darkTextPrimary,
                      ),
                    ),
                    subtitle: Text(
                      _qualityLabel(quality),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.darkTextTertiary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.primary, size: 22)
                        : null,
                    onTap: () {
                      setState(() => _streamQuality = quality);
                      _saveSettings();
                      Navigator.pop(ctx);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/// A divider widget for use inside Card columns.
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: AppColors.darkBorder),
    );
  }
}
