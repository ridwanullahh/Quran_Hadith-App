import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Bottom sheet for precise playback speed control.
///
/// Features:
/// - Continuous slider from 0.5x to 2.0x (0.25x steps)
/// - Current speed display
/// - Preset chips for quick selection
/// - Apply button

class SpeedControlSheet extends StatefulWidget {
  final double currentSpeed;
  final ValueChanged<double> onSpeedChanged;

  const SpeedControlSheet({
    super.key,
    required this.currentSpeed,
    required this.onSpeedChanged,
  });

  @override
  State<SpeedControlSheet> createState() => _SpeedControlSheetState();
}

class _SpeedControlSheetState extends State<SpeedControlSheet> {
  late double _selectedSpeed;

  static const List<double> _presets = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  static const double _minSpeed = 0.5;
  static const double _maxSpeed = 2.0;
  static const double _step = 0.25;

  @override
  void initState() {
    super.initState();
    _selectedSpeed = widget.currentSpeed;
  }

  double get _sliderValue =>
      ((_selectedSpeed - _minSpeed) / _step).roundToDouble() * _step + _minSpeed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ────────────────────────────────────────────────
            Row(
              children: [
                const Text(
                  'Playback Speed',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.darkTextSecondary, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Current speed display ────────────────────────────────
            Center(
              child: Text(
                '${_sliderValue}x',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -1,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Slider ───────────────────────────────────────────────
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 6,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 10),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 18),
                activeTrackColor: AppColors.audioProgressBar,
                inactiveTrackColor: AppColors.audioProgressTrack,
                thumbColor: AppColors.audioProgressBar,
                overlayColor: AppColors.audioProgressBar.withOpacity(0.2),
              ),
              child: Slider(
                value: _sliderValue.clamp(_minSpeed, _maxSpeed),
                min: _minSpeed,
                max: _maxSpeed,
                divisions: ((_maxSpeed - _minSpeed) / _step).round(),
                label: '${_sliderValue}x',
                onChanged: (value) {
                  setState(() {
                    _selectedSpeed = (value / _step).round() * _step;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),

            // ── Speed range labels ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_minSpeed}x',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.darkTextTertiary,
                    ),
                  ),
                  Text(
                    '${_maxSpeed}x',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.darkTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Preset chips ─────────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _presets.map((speed) {
                final isSelected = _sliderValue == speed;
                return _buildChip(
                  label: '${speed}x',
                  isSelected: isSelected,
                  onTap: () {
                    setState(() => _selectedSpeed = speed);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Apply button ─────────────────────────────────────────
            FilledButton(
              onPressed: () {
                widget.onSpeedChanged(_sliderValue);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.darkSurfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.darkBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : AppColors.darkTextSecondary,
          ),
        ),
      ),
    );
  }
}
