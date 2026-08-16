import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Holds the app lock state including whether it's enabled, the PIN,
/// security question, and whether the lock screen should be shown.
class AppLockState {
  final bool isEnabled;
  final bool isSetup;
  final bool isLocked;
  final bool isVerifying;
  final bool showingForgotPin;
  final String? error;

  const AppLockState({
    this.isEnabled = false,
    this.isSetup = false,
    this.isLocked = false,
    this.isVerifying = false,
    this.showingForgotPin = false,
    this.error,
  });

  AppLockState copyWith({
    bool? isEnabled,
    bool? isSetup,
    bool? isLocked,
    bool? isVerifying,
    bool? showingForgotPin,
    String? error,
    bool clearError = false,
  }) {
    return AppLockState(
      isEnabled: isEnabled ?? this.isEnabled,
      isSetup: isSetup ?? this.isSetup,
      isLocked: isLocked ?? this.isLocked,
      isVerifying: isVerifying ?? this.isVerifying,
      showingForgotPin: showingForgotPin ?? this.showingForgotPin,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Manages PIN-based app lock.
///
/// Uses Hive `settings` box for persistence.
/// Call [lockApp] when the app goes to background, and [unlockApp] when
/// the correct PIN is entered.
class AppLockNotifier extends StateNotifier<AppLockState> {
  AppLockNotifier() : super(const AppLockState()) {
    _loadState();
  }

  static const String _pinKey = 'app_lock_pin';
  static const String _enabledKey = 'app_lock_enabled';
  static const String _securityQuestionKey = 'app_lock_security_question';
  static const String _securityAnswerKey = 'app_lock_security_answer';

  Future<void> _loadState() async {
    final box = Hive.box('settings');
    final pin = box.get(_pinKey, defaultValue: '') as String;
    final enabled = box.get(_enabledKey, defaultValue: false) as bool;

    state = state.copyWith(
      isEnabled: enabled,
      isSetup: pin.isNotEmpty,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Setup
  // ═══════════════════════════════════════════════════════════════════

  /// Set up a new 4-digit PIN with a security question for recovery.
  Future<bool> setupPin({
    required String pin,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      state = state.copyWith(error: 'PIN must be exactly 4 digits');
      return false;
    }

    final box = Hive.box('settings');
    await box.put(_pinKey, pin);
    await box.put(_enabledKey, true);
    await box.put(_securityQuestionKey, securityQuestion);
    await box.put(_securityAnswerKey, securityAnswer.toLowerCase().trim());

    state = state.copyWith(
      isEnabled: true,
      isSetup: true,
      clearError: true,
    );
    return true;
  }

  // ═══════════════════════════════════════════════════════════════════
  // Enable / Disable
  // ═══════════════════════════════════════════════════════════════════

  Future<void> setEnabled(bool enabled) async {
    final box = Hive.box('settings');
    await box.put(_enabledKey, enabled);
    state = state.copyWith(isEnabled: enabled);
  }

  Future<void> disableLock() async {
    final box = Hive.box('settings');
    await box.put(_enabledKey, false);
    await box.put(_pinKey, '');
    await box.put(_securityQuestionKey, '');
    await box.put(_securityAnswerKey, '');
    state = state.copyWith(isEnabled: false, isSetup: false);
  }

  // ═══════════════════════════════════════════════════════════════════
  // Lock / Unlock
  // ═══════════════════════════════════════════════════════════════════

  /// Show the lock screen overlay.
  void lockApp() {
    if (state.isEnabled && state.isSetup) {
      state = state.copyWith(isLocked: true);
    }
  }

  /// Attempt to unlock with the given PIN.
  Future<bool> verifyPin(String pin) async {
    state = state.copyWith(isVerifying: true);
    // Small delay to prevent brute-force
    await Future.delayed(const Duration(milliseconds: 300));

    final box = Hive.box('settings');
    final storedPin = box.get(_pinKey, defaultValue: '') as String;

    if (pin == storedPin) {
      state = state.copyWith(isLocked: false, isVerifying: false, clearError: true);
      return true;
    } else {
      state = state.copyWith(isVerifying: false, error: 'Incorrect PIN');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // Forgot PIN
  // ═══════════════════════════════════════════════════════════════════

  /// Get the stored security question.
  String? get securityQuestion {
    final box = Hive.box('settings');
    return box.get(_securityQuestionKey) as String?;
  }

  /// Verify the security answer and generate a temporary unlock.
  Future<bool> verifySecurityAnswer(String answer) async {
    final box = Hive.box('settings');
    final storedAnswer =
        box.get(_securityAnswerKey, defaultValue: '') as String;

    if (answer.toLowerCase().trim() == storedAnswer) {
      // Disable the lock since user forgot the PIN
      await disableLock();
      state = state.copyWith(isLocked: false, clearError: true);
      return true;
    }
    state = state.copyWith(error: 'Incorrect answer. Please try again.');
    return false;
  }

  /// Generate a new random PIN and update it (used after security question recovery).
  Future<String> resetPin() async {
    final random = Random();
    final newPin = List.generate(4, (_) => random.nextInt(10)).join();
    final box = Hive.box('settings');
    await box.put(_pinKey, newPin);
    return newPin;
  }

  void showForgotPin() {
    state = state.copyWith(showingForgotPin: true, clearError: true);
  }

  void hideForgotPin() {
    state = state.copyWith(showingForgotPin: false, clearError: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for app lock functionality.
final appLockProvider =
    StateNotifierProvider.autoDispose<AppLockNotifier, AppLockState>(
  (ref) => AppLockNotifier(),
);
