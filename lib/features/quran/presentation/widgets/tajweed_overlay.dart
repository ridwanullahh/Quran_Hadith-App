import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════
// Tajweed Color Coding
// Simplified pattern-based tajweed rule detection.
// ═══════════════════════════════════════════════════════════════════

class TajweedColors {
  TajweedColors._();

  /// Ghunnah: noon/meem with shadda (ّن / مّ)
  static const Color ghunnah = Color(0xFF2E7D32);

  /// Ikhfa: noon followed by non-ghunnah letter
  static const Color ikhfa = Color(0xFF1565C0);

  /// Iqlab: noon followed by ba (ب)
  static const Color iqlab = Color(0xFF6A1B9A);

  /// Idgham: noon followed by waaw/meem/laam/raa/yaa
  static const Color idgham = Color(0xFFE65100);

  /// Izhhar: noon followed by remaining letters (izhhar letters)
  static const Color izhhar = Color(0xFFC62828);

  /// Qalqalah: qaf/taa/baa/jeem/daal at end of word
  static const Color qalqalah = Color(0xFF00838F);

  /// Madd: alif/yaaw/waaw with madd sign
  static const Color madd = Color(0xFFF57F17);
}

/// Ikhfa letters: all letters except the idgham letters, iqlab, and
/// the izhhar throat/adjacent letters.
/// For simplicity, we classify noon-sakinah/tanween rules:
/// - Idgham: و م ل ر ي
/// - Iqlab: ب
/// - Izhhar (remaining): ء ه ع ح غ خ
/// - Ikhfa: everything else

const String _idghamLetters = 'وملري';
const String _iqlabLetter = 'ب';
const String _izhharLetters = 'أإئابةتحخدذرزسشصضطظعغفقكلمنهوى';

const String _qalqalahLetters = 'قطبدج';

/// Arabic diacritical marks
const String _shadda = 'ّ';
const String _sukun = 'ْ';
const String _fatha = 'َ';
const String _damma = 'ُ';
const String _kasra = 'ِ';
const String _maddSign = 'ٓ';
const String _longMadd = 'ۥ';

/// Represents a single word segment with its tajweed color.
class _TajweedSegment {
  final String text;
  final Color color;

  const _TajweedSegment({required this.text, required this.color});
}

/// A widget that wraps Arabic text and color-codes words by tajweed rules.
///
/// This is a simplified pattern-matching implementation. It scans each word
/// for common tajweed markers and assigns colors accordingly.
class TajweedOverlay extends StatelessWidget {
  /// The Arabic text to render with tajweed coloring.
  final String text;

  /// Base text style (should include Arabic font family).
  final TextStyle? style;

  /// Whether tajweed highlighting is enabled.
  final bool enabled;

  /// Text alignment override.
  final TextAlign? textAlign;

  const TajweedOverlay({
    super.key,
    required this.text,
    this.style,
    this.enabled = true,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled || text.isEmpty) {
      return Text(
        text,
        style: style,
        textAlign: textAlign ?? TextAlign.right,
        textDirection: TextDirection.rtl,
      );
    }

    final defaultColor = style?.color ??
        (Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFFE8E6E1)
            : const Color(0xFF1A1A2E));

    final segments = _analyzeText(text);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RichText(
        textAlign: textAlign ?? TextAlign.right,
        text: TextSpan(
          style: style ??
              AppTheme.arabicQuranText.copyWith(color: defaultColor),
          children: segments
              .map((seg) => TextSpan(
                    text: seg.text,
                    style: (style ?? AppTheme.arabicQuranText).copyWith(
                      color: seg.color,
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  /// Splits text into words and analyzes each word for tajweed patterns.
  List<_TajweedSegment> _analyzeText(String text) {
    final segments = <_TajweedSegment>[];
    final words = text.split(' ');

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final wordSegments = _analyzeWord(word);
      segments.addAll(wordSegments);
      if (i < words.length - 1) {
        final defaultColor = style?.color ?? const Color(0xFF1A1A2E);
        segments.add(_TajweedSegment(text: ' ', color: defaultColor!));
      }
    }

    return segments;
  }

  /// Analyzes a single Arabic word for tajweed patterns.
  List<_TajweedSegment> _analyzeWord(String word) {
    final defaultColor = style?.color ?? const Color(0xFF1A1A2E);
    final segments = <_TajweedSegment>[];

    if (word.isEmpty) return segments;

    // Check for Madd (elongation)
    if (_hasMadd(word)) {
      segments.add(_TajweedSegment(text: word, color: TajweedColors.madd));
      return segments;
    }

    // Check for Ghunnah (shadda on noon or meem)
    if (_hasGhunnah(word)) {
      segments.add(_TajweedSegment(text: word, color: TajweedColors.ghunnah));
      return segments;
    }

    // Check for Noon Sakinah / Tanween rules
    if (_hasNoonSakinahOrTanween(word)) {
      final nextLetter = _extractBaseLetter(word);
      final rule = _classifyNoonRule(word, nextLetter);
      segments.add(_TajweedSegment(text: word, color: rule));
      return segments;
    }

    // Check for Qalqalah at end of word
    if (_hasQalqalah(word)) {
      segments.add(_TajweedSegment(text: word, color: TajweedColors.qalqalah));
      return segments;
    }

    // Default - no special rule detected
    segments.add(_TajweedSegment(text: word, color: defaultColor!));
    return segments;
  }

  /// Check if the word has a madd sign (ٓ or ى with sukun/madd context).
  bool _hasMadd(String word) {
    // Direct madd sign
    if (word.contains(_maddSign)) return true;
    // Alif with madd: آ
    if (word.contains('آ')) return true;
    // Yaaw with madd
    if (word.contains(_longMadd)) return true;
    // Pattern: letter + madd diacritic
    for (int i = 0; i < word.length; i++) {
      if (word[i] == _maddSign && i > 0) return true;
    }
    return false;
  }

  /// Check if the word has shadda on noon (نّ) or meem (مّ).
  bool _hasGhunnah(String word) {
    return word.contains('نّ') || word.contains('نًّ') || word.contains('نٍّ') ||
        word.contains('نٌّ') ||
        word.contains('مّ') || word.contains('مًّ') || word.contains('مٍّ') ||
        word.contains('مٌّ');
  }

  /// Check if the word has noon sakinah (نْ) or tanween (ً ٌ ٍ).
  bool _hasNoonSakinahOrTanween(String word) {
    return word.contains('نْ') ||
        word.contains('ً') ||
        word.contains('ٌ') ||
        word.contains('ٍ');
  }

  /// Extract the base Arabic letter (strip diacritics) for classification.
  String _extractBaseLetter(String word) {
    // For noon sakinah rules, find the letter after نْ or the tanween context
    final noonSakinIdx = word.indexOf('نْ');
    if (noonSakinIdx >= 0 && noonSakinIdx + 2 < word.length) {
      return _stripDiacritics(word[noonSakinIdx + 2]);
    }

    // For tanween, check the next letter after the tanween mark
    for (int i = 0; i < word.length; i++) {
      if (word[i] == 'ً' || word[i] == 'ٌ' || word[i] == 'ٍ') {
        if (i + 1 < word.length) {
          return _stripDiacritics(word[i + 1]);
        }
      }
    }

    return '';
  }

  /// Strip diacritical marks from a character.
  String _stripDiacritics(String char) {
    const diacritics = [_fatha, _damma, _kasra, _sukun, _shadda, _maddSign];
    String result = char;
    for (final d in diacritics) {
      result = result.replaceAll(d, '');
    }
    return result;
  }

  /// Classify the noon sakinah / tanween rule based on the following letter.
  Color _classifyNoonRule(String word, String nextLetter) {
    if (nextLetter.isEmpty) {
      return style?.color ?? const Color(0xFF1A1A2E);
    }

    // Iqlab: noon followed by ب
    if (_iqlabLetter.contains(nextLetter)) {
      return TajweedColors.iqlab;
    }

    // Idgham: noon followed by و م ل ر ي
    if (_idghamLetters.contains(nextLetter)) {
      return TajweedColors.idgham;
    }

    // Izhhar: noon followed by throat/adjacent letters
    if (_izhharLetters.contains(nextLetter)) {
      return TajweedColors.izhhar;
    }

    // Ikhfa: everything else
    return TajweedColors.ikhfa;
  }

  /// Check if the word ends with a qalqalah letter with sukun.
  bool _hasQalqalah(String word) {
    if (word.isEmpty) return false;

    // Check last 2-3 characters for qalqalah letter + sukun
    for (int i = word.length - 1; i >= 0; i--) {
      final char = _stripDiacritics(word[i]);
      if (char.isEmpty) continue;
      if (_qalqalahLetters.contains(char)) {
        // Check if it has sukun or is at the end (end of ayah = stop = qalqalah)
        final remaining = word.substring(i);
        if (remaining.contains(_sukun) || i == word.length - 1) {
          return true;
        }
      }
      break;
    }
    return false;
  }
}

// ═══════════════════════════════════════════════════════════════════
// Tajweed Legend Widget
// ═══════════════════════════════════════════════════════════════════

class TajweedLegend extends StatelessWidget {
  const TajweedLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark
        ? const Color(0xFFE8E6E1)
        : const Color(0xFF1A1A2E);

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _legendItem(TajweedColors.ghunnah, 'Ghunnah', labelColor),
        _legendItem(TajweedColors.ikhfa, 'Ikhfa', labelColor),
        _legendItem(TajweedColors.iqlab, 'Iqlab', labelColor),
        _legendItem(TajweedColors.idgham, 'Idgham', labelColor),
        _legendItem(TajweedColors.izhhar, 'Izhhar', labelColor),
        _legendItem(TajweedColors.qalqalah, 'Qalqalah', labelColor),
        _legendItem(TajweedColors.madd, 'Madd', labelColor),
      ],
    );
  }

  Widget _legendItem(Color color, String label, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.latinFontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
