import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Renders the mascot video preserving its native aspect ratio. Returns an
/// empty box whenever the controller is missing, uninitialized, or errored so
/// the rest of the UI is never disrupted.
///
/// No background is drawn here — the videos are expected to ship with an alpha
/// channel and are composited directly onto whatever screen is underneath.
class MascotVideoView extends StatelessWidget {
  const MascotVideoView({super.key, required this.controller});

  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (c == null || !c.value.isInitialized) {
      return const SizedBox.shrink();
    }
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: c,
      builder: (context, value, _) {
        if (!value.isInitialized || value.hasError) {
          return const SizedBox.shrink();
        }
        return FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: value.size.width,
            height: value.size.height,
            child: VideoPlayer(c),
          ),
        );
      },
    );
  }
}
