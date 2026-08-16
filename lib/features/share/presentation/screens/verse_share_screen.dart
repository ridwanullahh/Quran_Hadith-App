import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../data/repositories/quran_repository.dart';
import '../../../../data/models/quran/surah_info.dart';

/// Background theme for the shareable verse card.
enum VerseShareTheme {
  teal('Teal Gradient', LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D6E5B), Color(0xFF094E3F), Color(0xFF073D31)],
  )),
  gold('Gold Gradient', LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4A843), Color(0xFFB08A2F), Color(0xFF8B6E24)],
  )),
  dark('Dark', LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A1628), Color(0xFF111D33), Color(0xFF0A1628)],
  )),
  purple('Purple', LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6B21A8), Color(0xFF581C87), Color(0xFF4A1D7A)],
  )),
  sunset('Sunset', LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE85D3A), Color(0xFFD4442F), Color(0xFFB83A2A)],
  ));

  const VerseShareTheme(this.label, this.gradient);
  final String label;
  final LinearGradient gradient;
}

/// Screen that lets users customise and share a verse as a beautiful image card.
///
/// Call [shareVerse] from anywhere to open this screen.
class VerseShareScreen extends StatefulWidget {
  final int surahNumber;
  final int ayahNumber;

  const VerseShareScreen({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
  });

  @override
  State<VerseShareScreen> createState() => _VerseShareScreenState();
}

class _VerseShareScreenState extends State<VerseShareScreen> {
  VerseShareTheme _selectedTheme = VerseShareTheme.teal;
  bool _isGenerating = false;
  bool _showTranslation = true;

  SurahInfo? _surah;
  String _arabicText = '';
  String _translationText = '';
  bool _loading = true;

  final GlobalKey _cardKey = GlobalKey();
  final QuranRepository _repo = QuranRepository();

  @override
  void initState() {
    super.initState();
    _loadVerseData();
  }

  Future<void> _loadVerseData() async {
    try {
      final surah = await _repo.getSurahByNumber(widget.surahNumber);
      final ayahs = await _repo.getSurahAyahs(widget.surahNumber);
      final ayah = ayahs.where((a) => a.ayahNumber == widget.ayahNumber).firstOrNull;
      AyahTranslation? translation;
      try {
        translation = await _repo.getAyahTranslation(
          widget.surahNumber,
          widget.ayahNumber,
        );
      } catch (_) {
        // Translation not available
      }

      if (mounted) {
        setState(() {
          _surah = surah;
          _arabicText = ayah?.textUthmani ?? '';
          _translationText = translation?.text ?? '';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load verse: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Verse'),
        actions: [
          if (!_loading && _arabicText.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: _isGenerating ? null : _captureAndShare,
              tooltip: 'Share Image',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Preview Card ────────────────────────────────────
                  Center(
                    child: RepaintBoundary(
                      key: _cardKey,
                      child: _buildShareCard(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Theme Picker ────────────────────────────────────
                  Text(
                    'Card Theme',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: VerseShareTheme.values.map((t) {
                      final selected = _selectedTheme == t;
                      return ChoiceChip(
                        label: Text(t.label, style: const TextStyle(fontSize: 12)),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedTheme = t),
                        avatar: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            gradient: t.gradient,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // ── Show Translation Toggle ─────────────────────────
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show Translation'),
                    subtitle: const Text('Include English translation on card'),
                    value: _showTranslation,
                    onChanged: (v) => setState(() => _showTranslation = v),
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(height: 16),

                  // ── Action Buttons ──────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isGenerating ? null : _copyText,
                          icon: const Icon(Icons.copy_rounded),
                          label: const Text('Copy Text'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed:
                              _isGenerating ? null : _captureAndShare,
                          icon: _isGenerating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.share_rounded),
                          label: Text(_isGenerating ? 'Generating...' : 'Share Image'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Card Builder
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildShareCard() {
    final isDarkTheme = _selectedTheme == VerseShareTheme.dark;
    final isPurpleTheme = _selectedTheme == VerseShareTheme.purple;
    final isSunsetTheme = _selectedTheme == VerseShareTheme.sunset;
    final textColor = (isDarkTheme || isPurpleTheme || isSunsetTheme)
        ? Colors.white
        : Colors.white;

    return Container(
      width: 360,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      decoration: BoxDecoration(
        gradient: _selectedTheme.gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Decorative Bismillah ─────────────────────────────
          Opacity(
            opacity: 0.15,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white],
              ).createShader(bounds),
              child: const Text(
                '\uFD3F بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ \uFD3E',
                style: TextStyle(
                  fontFamily: 'ScheherazadeNew',
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Arabic Text ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 0.5,
              ),
            ),
            child: Text(
              _arabicText,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.8,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 20),

          // ── Translation ───────────────────────────────────────
          if (_showTranslation && _translationText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '"$_translationText"',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: textColor.withOpacity(0.85),
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (_showTranslation && _translationText.isNotEmpty)
            const SizedBox(height: 24)
          else
            const SizedBox(height: 16),

          // ── Divider ──────────────────────────────────────────
          Container(
            width: 60,
            height: 1,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 16),

          // ── Surah Reference ─────────────────────────────────
          Text(
            'Surah ${_surah?.nameEnglish ?? ''} (${_surah?.nameArabic ?? ''}) : ${widget.ayahNumber}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // ── App Branding ────────────────────────────────────
          ShaderMask(
            shaderCallback: (bounds) => AppColors.goldGradient
                .createShader(bounds),
            child: const Text(
              '\u25C7 MinhaajulHudaa \u25C7',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Image Capture & Share
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _captureAndShare() async {
    setState(() => _isGenerating = true);
    try {
      final boundary = _cardKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/verse_${widget.surahNumber}_${widget.ayahNumber}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Surah ${_surah?.nameEnglish ?? ''} : ${widget.ayahNumber}\n\n$_arabicText',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Copy to Clipboard
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _copyText() async {
    final surahName = _surah?.nameEnglish ?? '';
    final text = '$_arabicText\n\n'
        '${_showTranslation && _translationText.isNotEmpty ? '"$_translationText"\n\n' : ''}'
        '— Surah $surahName (${_surah?.nameArabic ?? ''}) : ${widget.ayahNumber}\n'
        '— MinhaajulHudaa';

    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verse copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Utility Function – call from anywhere
// ═══════════════════════════════════════════════════════════════════════

/// Opens the [VerseShareScreen] as a full-screen dialog or pushes it.
///
/// Usage:
/// ```dart
/// shareVerse(1, 1, context);
/// ```
Future<void> shareVerse(
  int surahNumber,
  int ayahNumber,
  BuildContext context,
) async {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => VerseShareScreen(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
      ),
    ),
  );
}
