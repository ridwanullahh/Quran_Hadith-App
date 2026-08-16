import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../providers/app_lock_provider.dart';

/// A full-screen lock overlay shown when the app resumes from background.
///
/// This screen should be wrapped around the app using [AppLockOverlay].
class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  final List<String> _enteredPin = [];
  final FocusNode _pinFocusNode = FocusNode();

  bool _pinVisible = false;
  bool _shaking = false;

  @override
  void dispose() {
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _onDigitTap(String digit) {
    if (_enteredPin.length >= 4) return;
    ref.read(appLockProvider.notifier).clearError();

    setState(() {
      _enteredPin.add(digit);
    });

    if (_enteredPin.length == 4) {
      _checkPin();
    }
  }

  void _onDelete() {
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin.removeLast();
    });
  }

  Future<void> _checkPin() async {
    final pin = _enteredPin.join();
    final success =
        await ref.read(appLockProvider.notifier).verifyPin(pin);

    if (!success && mounted) {
      setState(() => _shaking = true);
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _shaking = false;
        _enteredPin.clear();
      });
    }
  }

  void _togglePinVisibility() {
    setState(() => _pinVisible = !_pinVisible);
  }

  @override
  Widget build(BuildContext context) {
    final appLockState = ref.watch(appLockProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: appLockState.showingForgotPin
            ? _buildForgotPinScreen(appLockState)
            : _buildPinScreen(appLockState),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // PIN Entry Screen
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildPinScreen(AppLockState state) {
    return Column(
      children: [
        const SizedBox(height: 60),

        // ── Lock Icon ────────────────────────────────────────────
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.lock_rounded, size: 36, color: Colors.white),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              duration: 2000.ms,
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.03, 1.03),
            ),

        const SizedBox(height: 24),

        Text(
          'Enter PIN',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.darkTextPrimary,
          ),
        ).animate().fadeIn(duration: 300.ms),

        const SizedBox(height: 6),

        Text(
          'Enter your 4-digit PIN to unlock',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: AppColors.darkTextSecondary,
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

        const SizedBox(height: 40),

        // ── PIN Dots ───────────────────────────────────────────
        GestureDetector(
          onLongPress: _togglePinVisibility,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _shaking
                ? _buildPinDots(shake: true)
                : _buildPinDots(shake: false),
          ),
        ),

        // ── Error Message ───────────────────────────────────────
        if (state.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              state.error!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(duration: 200.ms),
          ),

        const SizedBox(height: 16),

        // ── Forgot PIN Button ─────────────────────────────────
        TextButton(
          onPressed: () =>
              ref.read(appLockProvider.notifier).showForgotPin(),
          child: const Text(
            'Forgot PIN?',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.darkTextSecondary,
            ),
          ),
        ),

        const Spacer(),

        // ── Keypad ──────────────────────────────────────────────
        _buildKeypad(),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPinDots({required bool shake}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          final filled = index < _enteredPin.length;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? AppColors.primary : AppColors.darkBorder,
              border: filled
                  ? null
                  : Border.all(
                      color: AppColors.darkTextTertiary.withOpacity(0.5),
                      width: 1.5,
                    ),
              boxShadow: filled
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: filled && _pinVisible
                ? Center(
                    child: Text(
                      _enteredPin[index],
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  )
                : null,
          );
        }),
      ),
    ).animate(target: shake ? 1 : 0).shake(
        duration: 500.ms,
        horizontal: 8,
        curve: Curves.elasticOut,
      );
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          // Row 1
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _KeypadButton(digit: '1', onTap: _onDigitTap),
              _KeypadButton(digit: '2', onTap: _onDigitTap),
              _KeypadButton(digit: '3', onTap: _onDigitTap),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _KeypadButton(digit: '4', onTap: _onDigitTap),
              _KeypadButton(digit: '5', onTap: _onDigitTap),
              _KeypadButton(digit: '6', onTap: _onDigitTap),
            ],
          ),
          const SizedBox(height: 12),
          // Row 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _KeypadButton(digit: '7', onTap: _onDigitTap),
              _KeypadButton(digit: '8', onTap: _onDigitTap),
              _KeypadButton(digit: '9', onTap: _onDigitTap),
            ],
          ),
          const SizedBox(height: 12),
          // Row 4
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 72, height: 72), // spacer
              _KeypadButton(digit: '0', onTap: _onDigitTap),
              _KeypadButton(
                isDelete: true,
                onTap: (_) => _onDelete(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Forgot PIN Screen
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildForgotPinScreen(AppLockState state) {
    final question = ref.read(appLockProvider.notifier).securityQuestion;
    final answerController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () =>
                ref.read(appLockProvider.notifier).hideForgotPin(),
            child: const Icon(Icons.arrow_back_rounded, size: 28),
          ),
          const SizedBox(height: 32),

          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.help_outline_rounded,
              size: 28,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Forgot PIN?',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Answer your security question to reset the lock.\n'
            'Note: This will disable the PIN lock and you\'ll need to set it up again.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.6,
              color: AppColors.darkTextSecondary,
            ),
          ),

          const SizedBox(height: 32),

          if (question != null && question.isNotEmpty) ...[
            Text(
              'Security Question',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.darkBorder,
                  width: 0.5,
                ),
              ),
              child: Text(
                question,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkTextPrimary,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Your Answer',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: answerController,
              decoration: InputDecoration(
                hintText: 'Enter your answer',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.darkBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.darkBorder,
                    width: 0.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: AppColors.darkSurface,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  state.error!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.error,
                  ),
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final answer = answerController.text.trim();
                  if (answer.isEmpty) return;
                  await ref
                      .read(appLockProvider.notifier)
                      .verifySecurityAnswer(answer);
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Verify & Disable Lock',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ] else
            const Text(
              'No security question was set during PIN setup.\n'
              'Please reinstall the app to reset.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.error,
                height: 1.6,
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Keypad Button Widget
// ═══════════════════════════════════════════════════════════════════════

class _KeypadButton extends StatelessWidget {
  final String? digit;
  final bool isDelete;
  final void Function(String) onTap;

  const _KeypadButton({
    this.digit,
    this.isDelete = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isDelete) {
          onTap('');
        } else if (digit != null) {
          onTap(digit!);
        }
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.darkSurface,
          border: Border.all(
            color: AppColors.darkBorder,
            width: 0.5,
          ),
        ),
        child: Center(
          child: isDelete
              ? const Icon(
                  Icons.backspace_outlined,
                  size: 22,
                  color: AppColors.darkTextSecondary,
                )
              : Text(
                  digit ?? '',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// App Lock Overlay – wraps the app and shows PIN screen when locked
// ═══════════════════════════════════════════════════════════════════════

/// A widget that wraps the app and shows the [AppLockScreen] overlay
/// when the app returns from background.
///
/// Place this in the widget tree above the router:
/// ```dart
/// AppLockOverlay(child: child)
/// ```
class AppLockOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const AppLockOverlay({super.key, required this.child});

  @override
  ConsumerState<AppLockOverlay> createState() => _AppLockOverlayState();
}

class _AppLockOverlayState extends ConsumerState<AppLockOverlay>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.inactive) {
      // Lock when going to background
      ref.read(appLockProvider.notifier).lockApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLockState = ref.watch(appLockProvider);

    if (appLockState.isLocked) {
      return const AppLockScreen();
    }

    return widget.child;
  }
}

// ═══════════════════════════════════════════════════════════════════════
// PIN Setup Dialog – for first-time PIN creation from settings
// ═══════════════════════════════════════════════════════════════════════

/// Shows a dialog for setting up a new PIN.
Future<void> showPinSetupDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _PinSetupDialog(),
  );
}

class _PinSetupDialog extends ConsumerStatefulWidget {
  const _PinSetupDialog();

  @override
  ConsumerState<_PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends ConsumerState<_PinSetupDialog> {
  final List<String> _pin = [];
  final List<String> _confirmPin = [];
  bool _step = false; // false = enter pin, true = confirm pin

  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  bool _showQuestions = false;

  static const _defaultQuestions = [
    'What is your mother\'s maiden name?',
    'What was the name of your first pet?',
    'What city were you born in?',
    'What is your favorite Surah?',
    'What is the name of your first school?',
  ];

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _onDigitTap(String digit) {
    final currentPin = _step ? _confirmPin : _pin;
    if (currentPin.length >= 4) return;

    setState(() {
      currentPin.add(digit);
    });

    if (currentPin.length == 4) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_step) {
          setState(() => _step = true);
        } else {
          _checkMatch();
        }
      });
    }
  }

  void _onBackspace() {
    final currentPin = _step ? _confirmPin : _pin;
    if (currentPin.isNotEmpty) {
      setState(() => currentPin.removeLast());
    }
  }

  void _checkMatch() {
    if (_pin.join() == _confirmPin.join()) {
      // Show security question setup
      setState(() => _showQuestions = true);
    } else {
      setState(() {
        _confirmPin.clear();
        _step = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PINs do not match. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _completeSetup() async {
    final question = _questionController.text.trim();
    final answer = _answerController.text.trim();
    if (question.isEmpty || answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in the security question and answer.')),
      );
      return;
    }

    final success = await ref.read(appLockProvider.notifier).setupPin(
          pin: _pin.join(),
          securityQuestion: question,
          securityAnswer: answer,
        );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN lock enabled successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: _showQuestions ? _buildSecurityQuestion() : _buildPinEntry(),
    );
  }

  Widget _buildPinEntry() {
    final currentPin = _step ? _confirmPin : _pin;
    final title = _step ? 'Confirm PIN' : 'Create PIN';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _step ? 'Re-enter your 4-digit PIN' : 'Choose a 4-digit PIN',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // PIN dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < currentPin.length
                      ? AppColors.primary
                      : AppColors.darkBorder,
                ),
              );
            }),
          ),
          const SizedBox(height: 32),

          // Mini keypad
          Column(
            children: [
              for (var row = 0; row < 3; row++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (col) {
                      final digit = '${row * 3 + col + 1}';
                      return GestureDetector(
                        onTap: () => _onDigitTap(digit),
                        child: Container(
                          width: 60,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.darkBackground,
                          ),
                          child: Center(
                            child: Text(
                              digit,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: AppColors.darkTextPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(width: 60, height: 48),
                    GestureDetector(
                      onTap: () => _onDigitTap('0'),
                      child: Container(
                        width: 60,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.darkBackground,
                        ),
                        child: const Center(
                          child: Text(
                            '0',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkTextPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _onBackspace,
                      child: const SizedBox(
                        width: 60,
                        height: 48,
                        child: Center(
                          child: Icon(
                            Icons.backspace_outlined,
                            size: 20,
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityQuestion() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security Question',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This helps you recover your PIN if you forget it.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            value: _questionController.text.isEmpty ? null : _questionController.text,
            decoration: InputDecoration(
              labelText: 'Choose a question',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppColors.darkBackground,
            ),
            dropdownColor: AppColors.darkSurface,
            items: _defaultQuestions.map((q) {
              return DropdownMenuItem(value: q, child: Text(q, style: const TextStyle(fontSize: 13)));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                _questionController.text = value;
                setState(() {});
              }
            },
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _answerController,
            decoration: InputDecoration(
              labelText: 'Your Answer',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppColors.darkBackground,
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              Expanded(
                child: FilledButton(
                  onPressed: _completeSetup,
                  child: const Text('Enable Lock'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
