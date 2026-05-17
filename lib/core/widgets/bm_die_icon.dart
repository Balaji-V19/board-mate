import 'package:flutter/material.dart';

/// The BoardMate brand mark — a rounded square "die" with five white pip
/// dots in a quincunx (five-face) pattern. Same shape used on the splash
/// screen; here it doubles as the no-image fallback for game thumbnails
/// and hero panels, with the `color` varying by game category.
class BmDieIcon extends StatelessWidget {
  const BmDieIcon({
    super.key,
    required this.color,
    required this.size,
    this.dotColor = Colors.white,
    this.withShadow = true,
  });

  /// Fill colour of the die body.
  final Color color;

  /// Outer width/height of the rounded square in logical pixels.
  final double size;

  /// Colour of the five pip dots. Default white reads well on any tint.
  final Color dotColor;

  /// Whether to drop a soft shadow tinted with [color]. Off for tiny sizes.
  final bool withShadow;

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.24;
    final padding = size * 0.18;
    final dot = size * 0.16;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: withShadow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.32),
                  blurRadius: size * 0.20,
                  offset: Offset(0, size * 0.08),
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.all(padding),
      child: _FiveFaceDots(dotColor: dotColor, dotSize: dot),
    );
  }
}

class _FiveFaceDots extends StatelessWidget {
  const _FiveFaceDots({required this.dotColor, required this.dotSize});
  final Color dotColor;
  final double dotSize;

  @override
  Widget build(BuildContext context) {
    final dot = SizedBox(
      width: dotSize,
      height: dotSize,
      child: DecoratedBox(
        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
      ),
    );
    return Stack(
      children: [
        Align(alignment: Alignment.topLeft, child: dot),
        Align(alignment: Alignment.topRight, child: dot),
        Align(alignment: Alignment.center, child: dot),
        Align(alignment: Alignment.bottomLeft, child: dot),
        Align(alignment: Alignment.bottomRight, child: dot),
      ],
    );
  }
}
