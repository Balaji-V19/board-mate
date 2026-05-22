import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'mascot_video_view.dart';

/// One-shot welcome-greeting mascot for the splash screen.
///
/// Plays `assets/videos/welcome.mov` exactly once, fires a soft haptic the
/// moment the greeting finishes, then calls [onGreetingDone] so the page can
/// navigate. Manages its own [VideoPlayerController] so it stays independent
/// of the shared mascot pipeline.
///
/// Failure-safe: if the asset fails to initialize, a short fallback timer
/// still triggers [onGreetingDone] so the user never gets stuck.
class SplashMascot extends StatefulWidget {
  const SplashMascot({
    super.key,
    required this.onGreetingDone,
    this.size = 260,
  });

  final VoidCallback onGreetingDone;
  final double size;

  @override
  State<SplashMascot> createState() => _SplashMascotState();
}

class _SplashMascotState extends State<SplashMascot> {
  // Welcome video is ~8s, but the splash only needs the first few seconds of
  // the greeting to land before moving the user along.
  static const Duration _greetDuration = Duration(seconds: 4);
  static const Duration _fallbackDelay = Duration(milliseconds: 1400);

  VideoPlayerController? _controller;
  Timer? _greetTimer;
  bool _disposed = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    // Navigation is time-boxed: 4s after the page mounts, regardless of how
    // long the video itself takes to load or play.
    _greetTimer = Timer(_greetDuration, _finish);
    _init();
  }

  Future<void> _init() async {
    VideoPlayerController? c;
    try {
      c = VideoPlayerController.asset('assets/videos/welcome.mov');
      await c.initialize();
      if (_disposed || !mounted) {
        await c.dispose();
        return;
      }
      await c.setLooping(false);
      await c.setVolume(0);
      await c.play();
      setState(() => _controller = c);
    } catch (_) {
      if (c != null) {
        try {
          await c.dispose();
        } catch (_) {}
      }
      // No video — shorten the wait so the user isn't staring at a blank box.
      _greetTimer?.cancel();
      _greetTimer = Timer(_fallbackDelay, _finish);
    }
  }

  void _finish() {
    if (_done || !mounted) return;
    _done = true;
    HapticFeedback.lightImpact();
    widget.onGreetingDone();
  }

  @override
  void dispose() {
    _disposed = true;
    _greetTimer?.cancel();
    final c = _controller;
    _controller = null;
    if (c != null) {
      try {
        c.pause();
      } catch (_) {}
      try {
        c.dispose();
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: MascotVideoView(controller: _controller),
    );
  }
}
