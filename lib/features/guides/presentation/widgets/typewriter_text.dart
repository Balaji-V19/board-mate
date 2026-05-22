import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reveals [text] one character at a time, then stops. Whenever [text]
/// changes, the animation restarts from the beginning.
///
/// When [hapticOnWords] is true, a light `selectionClick` haptic fires on
/// every word boundary (space char) and on the final character, so the user
/// physically feels the mascot's reading rhythm.
///
/// Pair this with an `AnimatedSize` parent so the surrounding container can
/// grow smoothly while characters are revealed.
class TypewriterText extends StatefulWidget {
  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    this.charDuration = const Duration(milliseconds: 24),
    this.maxLines,
    this.overflow,
    this.hapticOnWords = false,
  });

  final String text;
  final TextStyle style;

  /// Time between each new character. Keep small (15-45ms) for a natural
  /// typing feel; anything slower starts to feel laggy.
  final Duration charDuration;

  final int? maxLines;
  final TextOverflow? overflow;

  /// Fire a `HapticFeedback.selectionClick()` every time a word boundary
  /// (space) is revealed, plus once on the final character. Off by default
  /// so non-mascot uses of this widget stay silent.
  final bool hapticOnWords;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  Timer? _timer;
  int _shown = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _timer?.cancel();
      _shown = 0;
      _start();
    } else if (oldWidget.charDuration != widget.charDuration) {
      _timer?.cancel();
      _start();
    }
  }

  void _start() {
    if (widget.text.isEmpty) {
      _shown = 0;
      return;
    }
    _timer = Timer.periodic(widget.charDuration, (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_shown >= widget.text.length) {
        t.cancel();
        return;
      }
      final next = _shown + 1;
      if (widget.hapticOnWords) {
        final lastChar = widget.text[next - 1];
        final isWordBreak = lastChar == ' ' || lastChar == '\n';
        final isFinal = next == widget.text.length;
        if (isWordBreak || isFinal) {
          HapticFeedback.selectionClick();
        }
      }
      setState(() => _shown = next);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shown = widget.text.substring(
      0,
      _shown.clamp(0, widget.text.length),
    );
    return Text(
      shown,
      style: widget.style,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}
