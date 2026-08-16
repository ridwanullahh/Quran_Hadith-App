import 'dart:async';

import 'package:flutter/material.dart';

import 'popup_service.dart';

// ══════════════════════════════════════════════════════════════════════
// Popup Overlay
// ══════════════════════════════════════════════════════════════════════

/// A widget that wraps the app and periodically checks whether an
/// in-app popup should be shown. It also reacts to app resume via
/// [WidgetsBindingObserver].
///
/// Place this widget **inside** the [MaterialApp] / [Navigator] tree
/// so that the service can call [showDialog] with a valid context.
class PopupOverlay extends StatefulWidget {
  final Widget child;

  const PopupOverlay({
    super.key,
    required this.child,
  });

  @override
  State<PopupOverlay> createState() => _PopupOverlayState();
}

class _PopupOverlayState extends State<PopupOverlay>
    with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  @override
  void dispose() {
    _stopTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ── App Lifecycle ─────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Give the UI a moment to settle after resume.
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        PopupService.instance.checkAndShowPopup(context);
      });
    }
  }

  // ── Timer ─────────────────────────────────────────────────────

  void _startTimer() {
    _stopTimer();
    // Check every 60 seconds.
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      PopupService.instance.checkAndShowPopup(context);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
