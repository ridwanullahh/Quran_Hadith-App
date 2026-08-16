import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'popup_service.dart';

// ═══════════════════════════════════════════════════════════════════
// Popup Dialog Widget
// ═══════════════════════════════════════════════════════════════════

/// A stunning, glassmorphism-styled dialog that displays a random
/// Qur'an verse or Hadith with Arabic text, translation, and reference.
class PopupDialog extends StatefulWidget {
  final dynamic content;
  final bool isQuran;
  final VoidCallback onSnooze;
  final VoidCallback onClose;

  const PopupDialog({
    super.key,
    required this.content,
    required this.isQuran,
    required this.onSnooze,
    required this.onClose,
  });

  @override
  State<PopupDialog> createState() => _PopupDialogState();
}

class _PopupDialogState extends State<PopupDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() {
    _controller.reverse().then((_) => widget.onClose());
  }

  void _copyText() {
    String text;
    if (widget.isQuran) {
      final verse = widget.content as PopupQuranVerse;
      text =
          '${verse.arabic}\n\n${verse.english}\n\n— ${verse.reference}\n\nShared from MinhaajulHudaa';
    } else {
      final hadith = widget.content as PopupHadith;
      text =
          '“${hadith.text}”\n\nNarrated by: ${hadith.narrator}\n\n— ${hadith.collection}\n\nShared from MinhaajulHudaa';
    }
    Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareText() {
    // Copy to clipboard for sharing.
    _copyText();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFE8E6E1) : const Color(0xFF1A1A2E);
    final secondaryTextColor =
        isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    final primary = const Color(0xFF0D6E5B);
    final secondary = const Color(0xFFD4A843);
    final bgColor = isDark ? const Color(0xFF111D33) : const Color(0xFFFFFFFF);
    final surfaceColor =
        isDark ? const Color(0xFF172640) : const Color(0xFFF0EDE5);

    return Center(
      child: GestureDetector(
        onTap: _close,
        child: Container(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping inside.
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: MediaQuery.of(context).size.height * 0.06,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        color: bgColor,
                        border: Border.all(
                          color: secondary.withOpacity(0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.12),
                            blurRadius: 40,
                            spreadRadius: 0,
                            offset: const Offset(0, 12),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 24,
                            spreadRadius: 0,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(27),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(27),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  bgColor.withOpacity(0.88),
                                  bgColor.withOpacity(0.78),
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ── Header ──────────────────────
                                _buildHeader(
                                  isDark: isDark,
                                  primary: primary,
                                  secondary: secondary,
                                  textColor: textColor,
                                ),
                                const SizedBox(height: 20),

                                // ── Content ──────────────────────
                                if (widget.isQuran)
                                  _buildQuranContent(
                                    textColor: textColor,
                                    secondaryTextColor: secondaryTextColor,
                                    surfaceColor: surfaceColor,
                                  )
                                else
                                  _buildHadithContent(
                                    textColor: textColor,
                                    secondaryTextColor: secondaryTextColor,
                                    surfaceColor: surfaceColor,
                                  ),

                                const SizedBox(height: 20),

                                // ── Actions ──────────────────────
                                _buildActions(
                                  primary: primary,
                                  secondary: secondary,
                                ),

                                const SizedBox(height: 6),

                                // ── Snooze ───────────────────────
                                _buildSnoozeButton(secondaryTextColor),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────

  Widget _buildHeader({
    required bool isDark,
    required Color primary,
    required Color secondary,
    required Color textColor,
  }) {
    final title =
        widget.isQuran ? 'Qur\'an Verse' : 'Hadith of the Moment';
    final icon = widget.isQuran
        ? Icons.menu_book_rounded
        : Icons.auto_stories_rounded;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (widget.isQuran ? primary : secondary).withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: widget.isQuran
                  ? [primary, primary.withOpacity(0.7)]
                  : [secondary, secondary.withOpacity(0.7)],
            ).createShader(bounds),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Text(
                '\u2726 ',
                style: TextStyle(
                  color: secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _close,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (isDark
                      ? const Color(0xFF1E2D47)
                      : const Color(0xFFE5E2D9))
                  .withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.close_rounded,
              size: 18,
              color: textColor.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  // ── Quran Content ─────────────────────────────────────────────

  Widget _buildQuranContent({
    required Color textColor,
    required Color secondaryTextColor,
    required Color surfaceColor,
  }) {
    final verse = widget.content as PopupQuranVerse;

    return Column(
      children: [
        // Arabic text.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            verse.arabic,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'ScheherazadeNew',
              fontSize: 26,
              height: 2.0,
              color: Color(0xFFD4A843),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // English translation.
        Text(
          verse.english,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.5,
            height: 1.7,
            color: textColor.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        // Reference.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0D6E5B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '— ${verse.reference}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D6E5B),
            ),
          ),
        ),
      ],
    );
  }

  // ── Hadith Content ────────────────────────────────────────────

  Widget _buildHadithContent({
    required Color textColor,
    required Color secondaryTextColor,
    required Color surfaceColor,
  }) {
    final hadith = widget.content as PopupHadith;

    return Column(
      children: [
        // Hadith text.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '\u201C${hadith.text}\u201D',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              height: 1.8,
              color: textColor.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Narrator.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: 14,
              color: secondaryTextColor,
            ),
            const SizedBox(width: 6),
            Text(
              'Narrated by: ${hadith.narrator}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Collection.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFD4A843).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '— ${hadith.collection}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFFD4A843),
            ),
          ),
        ),
      ],
    );
  }

  // ── Action Buttons ────────────────────────────────────────────

  Widget _buildActions({
    required Color primary,
    required Color secondary,
  }) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.share_rounded,
            label: 'Share',
            color: primary,
            onTap: _shareText,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.copy_rounded,
            label: 'Copy',
            color: secondary,
            onTap: _copyText,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            icon: Icons.close_rounded,
            label: 'Close',
            color: Colors.grey.shade400,
            onTap: _close,
          ),
        ),
      ],
    );
  }

  // ── Snooze Button ─────────────────────────────────────────────

  Widget _buildSnoozeButton(Color secondaryTextColor) {
    return TextButton(
      onPressed: widget.onSnooze,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      child: Text(
        'Don\'t show again for 1 hour',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: secondaryTextColor.withOpacity(0.7),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Action Button
// ═══════════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
