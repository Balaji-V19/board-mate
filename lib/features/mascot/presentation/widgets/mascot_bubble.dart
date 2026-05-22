import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import 'mascot_video_view.dart';

/// Small floating mascot painted in the corner of a screen by [MascotHost].
/// Decorative only — taps pass through to whatever is behind it so the
/// underlying page receives them normally.
class MascotBubble extends StatelessWidget {
  const MascotBubble({super.key, required this.controller});

  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    final size = 88.w;
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: MascotVideoView(controller: controller),
      ),
    );
  }
}
