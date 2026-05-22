import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/mascot_mood.dart';
import '../providers/mascot_notifier.dart';
import 'mascot_video_view.dart';

/// Drop-in mascot widget for pages that want to embed the mascot inline.
///
/// - Calls `setMood(widget.mood)` on `initState` and whenever the [mood]
///   prop changes, so a page can land on the screen and immediately show
///   the right mascot even if the [_MascotOverlay]'s router listener
///   hasn't fired yet.
/// - Renders the video only when the notifier's current mood matches —
///   keeps inline mascots on hidden shell branches from showing through
///   when the active branch is on a different mood.
class MascotInline extends ConsumerStatefulWidget {
  const MascotInline({
    super.key,
    required this.mood,
    this.size = 56,
  });

  final MascotMood mood;
  final double size;

  @override
  ConsumerState<MascotInline> createState() => _MascotInlineState();
}

class _MascotInlineState extends ConsumerState<MascotInline> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyMood());
  }

  @override
  void didUpdateWidget(covariant MascotInline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _applyMood());
    }
  }

  void _applyMood() {
    if (!mounted) return;
    ref.read(mascotNotifierProvider).setMood(widget.mood);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(mascotNotifierProvider);
    final showVideo = notifier.isReady &&
        !notifier.hasError &&
        notifier.currentMood == widget.mood &&
        notifier.controller != null;

    if (!showVideo) {
      return SizedBox(width: widget.size, height: widget.size);
    }

    return IgnorePointer(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: MascotVideoView(controller: notifier.controller),
      ),
    );
  }
}
