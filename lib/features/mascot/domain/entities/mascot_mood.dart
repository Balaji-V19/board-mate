/// The emotional state of the BoardMate mascot, used to pick which short
/// looping video to display as a learning companion.
enum MascotMood {
  welcome,
  thinking,
  teaching,
  reading,
  curious,
  celebrating,
}

extension MascotMoodAsset on MascotMood {
  String get assetPath {
    switch (this) {
      case MascotMood.welcome:
        return 'assets/videos/welcome.mov';
      case MascotMood.thinking:
        return 'assets/videos/thinking.mov';
      case MascotMood.teaching:
        return 'assets/videos/teaching.mov';
      case MascotMood.reading:
        return 'assets/videos/reading.mov';
      case MascotMood.curious:
        return 'assets/videos/magnifying-glass.mov';
      case MascotMood.celebrating:
        return 'assets/videos/celebrating.mov';
    }
  }
}

/// Where the mascot is rendered on a given route.
/// - [overlayHero] / [overlayBubble]: the [MascotHost] paints it as a floating
///   overlay on top of the screen.
/// - [inline]: the host stays out of the way and the page itself drops a
///   [MascotInline] widget into its layout, so the mascot scrolls with content.
enum MascotPlacement { overlayHero, overlayBubble, inline }

class MascotRouteDecision {
  const MascotRouteDecision({required this.mood, required this.placement});
  final MascotMood? mood;
  final MascotPlacement placement;
}
