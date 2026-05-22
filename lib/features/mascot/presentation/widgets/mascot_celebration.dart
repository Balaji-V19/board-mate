import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_textstyle.dart';
import 'mascot_video_view.dart';

/// Full-screen "you did it!" moment shown after a learning section is
/// completed. Plays the celebrating mascot through to its end then dismisses
/// so the caller can navigate onward.
///
/// Manages its own [VideoPlayerController] — kept isolated from the shared
/// mascot pipeline so the celebration can't interfere with the inline mascots
/// already on the underlying page.
///
/// Failure-safe: any error initializing or playing the video falls back to a
/// short text-only display; the dialog always closes itself.
class MascotCelebrationDialog extends StatefulWidget {
  const MascotCelebrationDialog({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  State<MascotCelebrationDialog> createState() =>
      _MascotCelebrationDialogState();
}

class _MascotCelebrationDialogState extends State<MascotCelebrationDialog> {
  static const Duration _fallbackDuration = Duration(milliseconds: 2400);
  static const Duration _safetyCap = Duration(seconds: 10);

  VideoPlayerController? _controller;
  Timer? _safetyTimer;
  Timer? _secondHaptic;
  bool _disposed = false;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _fireHaptics();
    _init();
  }

  void _fireHaptics() {
    // Two-pulse "ta-da" feel: heavy thump then a softer pop.
    HapticFeedback.heavyImpact();
    _secondHaptic = Timer(const Duration(milliseconds: 180), () {
      HapticFeedback.mediumImpact();
    });
  }

  Future<void> _init() async {
    VideoPlayerController? c;
    try {
      c = VideoPlayerController.asset('assets/videos/celebrating.mov');
      await c.initialize();
      if (_disposed || !mounted) {
        await c.dispose();
        return;
      }
      // Play once — the dialog closes when the video reaches its end.
      await c.setLooping(false);
      await c.setVolume(0);
      c.addListener(_onVideoTick);
      // Hard upper bound so we never get stuck if the listener never fires.
      _safetyTimer = Timer(_safetyCap, _close);
      await c.play();
      setState(() => _controller = c);
    } catch (_) {
      if (c != null) {
        try {
          await c.dispose();
        } catch (_) {}
      }
      // No video — fall back to a short text-only celebration.
      _safetyTimer = Timer(_fallbackDuration, _close);
    }
  }

  void _onVideoTick() {
    final c = _controller;
    if (c == null) return;
    final v = c.value;
    if (v.hasError) {
      _close();
      return;
    }
    if (v.isInitialized &&
        v.duration > Duration.zero &&
        v.position >= v.duration &&
        !v.isPlaying) {
      _close();
    }
  }

  void _close() {
    if (_closed || !mounted) return;
    _closed = true;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _disposed = true;
    _safetyTimer?.cancel();
    _secondHaptic?.cancel();
    final c = _controller;
    _controller = null;
    if (c != null) {
      try {
        c.removeListener(_onVideoTick);
      } catch (_) {}
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
    return PopScope(
      canPop: false,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 260.w,
                  height: 260.w,
                  child: MascotVideoView(controller: _controller),
                ),
                SizedBox(height: 16.h),
                Text(
                  widget.title,
                  style: AppTextStyle.largeTitle().copyWith(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Text(
                    widget.subtitle,
                    style: AppTextStyle.body(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Convenience: show the celebration full-screen and wait until it dismisses.
/// The dialog stays up until the celebrating mascot video plays through to
/// its end (or a 10s safety cap, whichever comes first).
Future<void> showMascotCelebration(
  BuildContext context, {
  required String title,
  required String subtitle,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.background.withValues(alpha: 0.96),
    builder: (_) => MascotCelebrationDialog(
      title: title,
      subtitle: subtitle,
    ),
  );
}
