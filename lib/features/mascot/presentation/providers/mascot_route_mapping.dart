import '../../domain/entities/mascot_mood.dart';

final _gameRoute = RegExp(
  r'^/game/[^/]+(?:/(learn|setup|how-to-play|turn-flow|quick-reference))?$',
);

MascotRouteDecision mascotForLocation(String location) {
  final path = location.split('?').first;

  if (path == '/splash') {
    // The splash page owns its own dedicated mascot (SplashMascot) so the
    // global host should stay silent here.
    return const MascotRouteDecision(
      mood: null,
      placement: MascotPlacement.overlayBubble,
    );
  }
  if (path == '/onboarding') {
    // Onboarding owns its mascot per-slide so the global host stays silent.
    return const MascotRouteDecision(
      mood: MascotMood.welcome,
      placement: MascotPlacement.inline,
    );
  }
  if (path == '/sign-in') {
    return const MascotRouteDecision(
      mood: MascotMood.welcome,
      placement: MascotPlacement.overlayBubble,
    );
  }

  if (path == '/home') {
    return const MascotRouteDecision(
      mood: MascotMood.welcome,
      placement: MascotPlacement.inline,
    );
  }
  if (path == '/browse') {
    return const MascotRouteDecision(
      mood: MascotMood.curious,
      placement: MascotPlacement.overlayBubble,
    );
  }
  if (path == '/saved') {
    return const MascotRouteDecision(
      mood: MascotMood.reading,
      placement: MascotPlacement.inline,
    );
  }
  if (path == '/settings') {
    return const MascotRouteDecision(
      mood: null,
      placement: MascotPlacement.overlayBubble,
    );
  }

  if (path.startsWith('/category/')) {
    return const MascotRouteDecision(
      mood: MascotMood.curious,
      placement: MascotPlacement.overlayBubble,
    );
  }
  if (path == '/request-game') {
    return const MascotRouteDecision(
      mood: MascotMood.thinking,
      placement: MascotPlacement.overlayBubble,
    );
  }
  if (path == '/credits') {
    return const MascotRouteDecision(
      mood: null,
      placement: MascotPlacement.overlayBubble,
    );
  }

  final match = _gameRoute.firstMatch(path);
  if (match != null) {
    final sub = match.group(1);
    switch (sub) {
      case 'learn':
        return const MascotRouteDecision(
          mood: MascotMood.teaching,
          placement: MascotPlacement.inline,
        );
      case 'setup':
        return const MascotRouteDecision(
          mood: MascotMood.reading,
          placement: MascotPlacement.inline,
        );
      case 'how-to-play':
        return const MascotRouteDecision(
          mood: MascotMood.teaching,
          placement: MascotPlacement.inline,
        );
      case 'turn-flow':
        return const MascotRouteDecision(
          mood: MascotMood.thinking,
          placement: MascotPlacement.inline,
        );
      case 'quick-reference':
        return const MascotRouteDecision(
          mood: MascotMood.curious,
          placement: MascotPlacement.inline,
        );
      default:
        return const MascotRouteDecision(
          mood: MascotMood.thinking,
          placement: MascotPlacement.overlayBubble,
        );
    }
  }

  return const MascotRouteDecision(
    mood: null,
    placement: MascotPlacement.overlayBubble,
  );
}
