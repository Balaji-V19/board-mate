import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/mascot_mood.dart';
import '../providers/mascot_notifier.dart';
import '../providers/mascot_route_mapping.dart';
import 'mascot_bubble.dart';
import 'mascot_hero.dart';

/// Wraps the entire navigator. Looks up the current route on every build to
/// decide the mascot's [MascotPlacement] and [MascotMood], so the overlay
/// painted by the host always matches the active route — no state lag where
/// the previous route's overlay lingers for a frame after navigation.
///
/// For [MascotPlacement.overlayHero] and [MascotPlacement.overlayBubble], the
/// host paints the mascot itself. For [MascotPlacement.inline] the host stays
/// silent and the page renders a `MascotInline` in its own layout.
class MascotHost extends ConsumerStatefulWidget {
  const MascotHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MascotHost> createState() => _MascotHostState();
}

class _MascotHostState extends ConsumerState<MascotHost>
    with WidgetsBindingObserver {
  String? _lastLocation;
  bool _moodRefreshScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(mascotNotifierProvider).onAppLifecycle(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Schedule a single setMood() in the next frame. Coalesces back-to-back
  /// builds (e.g. when the notifier itself causes a rebuild) so we don't
  /// thrash the controller and so the synchronous notifyListeners inside
  /// `setMood` can never fire during the current build pass.
  void _scheduleMoodUpdate(MascotMood? mood) {
    if (_moodRefreshScheduled) return;
    _moodRefreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moodRefreshScheduled = false;
      if (!mounted) return;
      ref.read(mascotNotifierProvider).setMood(mood);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Compute placement + mood from the router state at build time so the
    // overlay always reflects the route being painted right now.
    final router = ref.read(routerProvider);
    final location =
        router.routerDelegate.currentConfiguration.uri.toString();
    final decision = mascotForLocation(location);

    if (location != _lastLocation) {
      _lastLocation = location;
      _scheduleMoodUpdate(decision.mood);
    }

    final notifier = ref.watch(mascotNotifierProvider);
    final hasMascot = notifier.isReady &&
        !notifier.hasError &&
        notifier.currentMood != null &&
        notifier.controller != null;

    // For inline placement the page owns the rendering — host stays silent.
    if (!hasMascot || decision.placement == MascotPlacement.inline) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        if (decision.placement == MascotPlacement.overlayHero)
          Positioned(
            top: MediaQuery.of(context).padding.top + 24.h,
            left: 0,
            right: 0,
            child: Center(
              child: MascotHero(controller: notifier.controller),
            ),
          )
        else
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.h,
            right: 12.w,
            child: MascotBubble(controller: notifier.controller),
          ),
      ],
    );
  }
}
