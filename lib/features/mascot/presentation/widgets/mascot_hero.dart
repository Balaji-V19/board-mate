import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import 'mascot_video_view.dart';

/// Larger mascot used on welcome moments (e.g. onboarding) painted by
/// [MascotHost]. Decorative only — taps pass through to whatever is behind it.
class MascotHero extends StatelessWidget {
  const MascotHero({super.key, required this.controller});

  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    final size = 220.w;
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: MascotVideoView(controller: controller),
      ),
    );
  }
}
