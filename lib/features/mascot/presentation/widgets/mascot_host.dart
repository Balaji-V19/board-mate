import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/mascot_mood.dart';
import '../providers/mascot_notifier.dart';
import '../providers/mascot_route_mapping.dart';
import 'mascot_bubble.dart';
import 'mascot_hero.dart';

/// Top-level mascot coordinator. Wraps the entire navigator and is composed
/// of two cleanly separated pieces:
///
///   1. [MascotHost] itself — only forwards app-lifecycle events (pause/
///      resume on background/foreground) to the [MascotNotifier]. It never
///      reacts to route changes itself, so its widget can never be dirtied
///      mid-build by a router notification (which previously produced the
///      `!_dirty` assertion).
///   2. [_MascotOverlay] — a sibling layer inside a [Stack] that owns the
///      router-delegate listener, schedules mood updates, and paints the
///      overlay mascot for `overlayBubble` / `overlayHero` routes. It
///      rebuilds via its own `setState`, but only the overlay subtree is
///      affected; `widget.child` (the navigator subtree) is preserved.
///
/// Routes with `MascotPlacement.inline` render their own `MascotInline`
/// inside the page tree; the overlay layer stays silent on those routes so
/// there's never a duplicate mascot.
class MascotHost extends ConsumerStatefulWidget {
  const MascotHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MascotHost> createState() => _MascotHostState();
}

class _MascotHostState extends ConsumerState<MascotHost>
    with WidgetsBindingObserver {
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        const _MascotOverlay(),
      ],
    );
  }
}

// ─── Overlay layer ──────────────────────────────────────────────────────

class _MascotOverlay extends ConsumerStatefulWidget {
  const _MascotOverlay();

  @override
  ConsumerState<_MascotOverlay> createState() => _MascotOverlayState();
}

class _MascotOverlayState extends ConsumerState<_MascotOverlay> {
  GoRouter? _router;
  String? _lastLocation;
  bool _scheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _attach());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-attach defensively — `_attach` is idempotent for the same router
    // instance, but if something ever does cause the GoRouter singleton to
    // be replaced (auth flow tweaks, hot reload, etc.) this ensures we
    // re-subscribe immediately instead of going deaf to route changes,
    // which is what would manifest as "the revealed page has no mascot
    // after going back".
    _attach();
  }

  void _attach() {
    if (!mounted) return;
    final router = ref.read(routerProvider);
    if (identical(router, _router)) return;
    _router?.routerDelegate.removeListener(_onRouterChanged);
    _router = router;
    _router!.routerDelegate.addListener(_onRouterChanged);
    // Sync initial route → mood.
    _onRouterChanged();
  }

  /// Router listener. Never mutates state synchronously — defers everything
  /// (setMood + setState) to a post-frame so we can't dirty this widget
  /// during a parent's build pass. Coalesces back-to-back notifications.
  void _onRouterChanged() {
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted || _router == null) return;
      final location =
          _router!.routerDelegate.currentConfiguration.uri.toString();
      final changed = location != _lastLocation;
      if (changed) {
        _lastLocation = location;
        final decision = mascotForLocation(location);
        ref.read(mascotNotifierProvider).setMood(decision.mood);
        // Trigger a rebuild so the overlay reflects the new route. (Inline
        // routes will collapse to SizedBox.shrink; overlay routes will
        // paint MascotBubble / MascotHero.)
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _router?.routerDelegate.removeListener(_onRouterChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = _router;
    if (router == null) return const SizedBox.shrink();
    final location =
        router.routerDelegate.currentConfiguration.uri.toString();
    final decision = mascotForLocation(location);

    // Inline placement: the page owns the rendering, stay completely silent.
    if (decision.placement == MascotPlacement.inline) {
      return const SizedBox.shrink();
    }

    final notifier = ref.watch(mascotNotifierProvider);
    final hasMascot = notifier.isReady &&
        !notifier.hasError &&
        notifier.currentMood != null &&
        notifier.controller != null;
    if (!hasMascot) return const SizedBox.shrink();

    if (decision.placement == MascotPlacement.overlayHero) {
      return Positioned(
        top: MediaQuery.of(context).padding.top + 24.h,
        left: 0,
        right: 0,
        child: Center(
          child: MascotHero(controller: notifier.controller),
        ),
      );
    }
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8.h,
      right: 12.w,
      child: MascotBubble(controller: notifier.controller),
    );
  }
}
