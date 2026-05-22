import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../../dependency_injection.dart';
import '../../domain/entities/mascot_mood.dart';

/// Owns the single [VideoPlayerController] used by the mascot overlay.
///
/// All controller interactions are wrapped in try/catch so any failure
/// (missing asset, codec issue, race during dispose, hot reload) silently
/// hides the mascot rather than crashing the app.
class MascotNotifier extends ChangeNotifier {
  MascotMood? _currentMood;
  VideoPlayerController? _controller;
  bool _isReady = false;
  bool _hasError = false;
  MascotMood? _dismissedMood;
  int _swapToken = 0;

  MascotMood? get currentMood => _currentMood;
  VideoPlayerController? get controller => _controller;
  bool get isReady => _isReady;
  bool get hasError => _hasError;

  /// True only when the current mood matches the one the user dismissed.
  /// A new mood (i.e. a different screen) gets a fresh chance to appear.
  bool get isDismissed =>
      _dismissedMood != null && _dismissedMood == _currentMood;

  Future<void> setMood(MascotMood? mood) async {
    if (mood == null) {
      await _teardown();
      return;
    }
    // If the user dismissed a different mood earlier, this new one is fair
    // game — clear the dismissal flag.
    if (_dismissedMood != null && _dismissedMood != mood) {
      _dismissedMood = null;
    }
    if (_dismissedMood == mood) {
      // Same mood the user already hid on this screen — keep it hidden.
      return;
    }
    if (mood == _currentMood && _isReady && _controller != null) return;

    final token = ++_swapToken;
    _hasError = false;
    // Intentionally do NOT clear _isReady or _controller here — keep the
    // previous mascot visible during the load to avoid a visible flicker.

    VideoPlayerController? next;
    try {
      next = VideoPlayerController.asset(mood.assetPath);
      await next.initialize();
      if (token != _swapToken) {
        await _safeDispose(next);
        return;
      }
      await next.setLooping(true);
      await next.setVolume(0);
      await next.play();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('MascotNotifier: failed to load $mood -> $e\n$st');
      }
      await _safeDispose(next);
      if (token == _swapToken) {
        _hasError = true;
        _isReady = false;
        notifyListeners();
      }
      return;
    }

    final old = _controller;
    _controller = next;
    _currentMood = mood;
    _isReady = true;
    _hasError = false;
    notifyListeners();
    await _safeDispose(old);
  }

  /// Hide the currently visible mascot. The same mood stays hidden until the
  /// route changes to a different mood; then the mascot reappears.
  void dismissCurrent() {
    _dismissedMood = _currentMood;
    _teardown();
  }

  Future<void> _teardown() async {
    _swapToken++;
    final old = _controller;
    _controller = null;
    _currentMood = null;
    _isReady = false;
    _hasError = false;
    notifyListeners();
    await _safeDispose(old);
  }

  Future<void> _safeDispose(VideoPlayerController? c) async {
    if (c == null) return;
    try {
      await c.pause();
    } catch (_) {}
    try {
      await c.dispose();
    } catch (_) {}
  }

  Future<void> onAppLifecycle(AppLifecycleState state) async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    try {
      if (state == AppLifecycleState.resumed) {
        if (_isReady && !isDismissed) {
          await c.play();
        }
      } else {
        await c.pause();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _swapToken++;
    final c = _controller;
    _controller = null;
    _isReady = false;
    if (c != null) {
      c.pause().catchError((_) {});
      c.dispose();
    }
    super.dispose();
  }
}

final mascotNotifierProvider = ChangeNotifierProvider<MascotNotifier>(
  (ref) => sl<MascotNotifier>(),
);
