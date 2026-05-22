import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/mascot_mood.dart';
import '../providers/mascot_notifier.dart';
import 'mascot_video_view.dart';

/// Drop-in mascot widget for pages that want to embed the mascot inline (so it
/// scrolls with content) instead of being painted by the global host.
///
/// - Sets the desired [mood] on mount and whenever it changes.
/// - Renders the transparent video with no decoration / no background.
/// - Taps on the mascot are intentionally no-ops — the mascot is decorative,
///   not interactive.
/// - If anything goes wrong (asset missing, init failure) it silently renders
///   a same-sized empty box so layout is undisturbed.
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
