import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../mascot/domain/entities/mascot_mood.dart';
import '../../../mascot/presentation/widgets/mascot_inline.dart';
import 'typewriter_text.dart';

/// A composable "mascot with a speech bubble" used to make the guide screens
/// feel like the mascot is teaching the user.
///
/// - Mascot sits at [mascotSize] on the left by default; pass
///   `mascotOnRight: true` to flip the layout (used by How To Play so the
///   mascot reads "to" the user instead of "from" them).
/// - The bubble's text reveals one character at a time via [TypewriterText]
///   and the bubble height grows with content (`AnimatedSize`, 180ms).
class MascotSpeechBubble extends StatelessWidget {
  const MascotSpeechBubble({
    super.key,
    required this.mood,
    required this.message,
    this.mascotSize = 180,
    // ~24 chars/sec — close to natural read-aloud pace so the mascot
    // feels like it's reading the line, not racing through it.
    this.charDuration = const Duration(milliseconds: 42),
    this.mascotOnRight = false,
  });

  final MascotMood mood;
  final String message;
  final double mascotSize;
  final Duration charDuration;
  final bool mascotOnRight;

  @override
  Widget build(BuildContext context) {
    final mascot = MascotInline(mood: mood, size: mascotSize.w);
    final spacer = SizedBox(width: 4.w);
    final bubble = Expanded(
      child: _Bubble(
        message: message,
        charDuration: charDuration,
        pointRight: mascotOnRight,
      ),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: mascotOnRight
          ? [bubble, spacer, mascot]
          : [mascot, spacer, bubble],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    required this.charDuration,
    required this.pointRight,
  });

  final String message;
  final Duration charDuration;

  /// When true, the tail is on the right edge and the inner container's
  /// margin shifts to the right side so the tail visually points at the
  /// mascot sitting to the right.
  final bool pointRight;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      alignment: pointRight ? Alignment.topRight : Alignment.topLeft,
      curve: Curves.easeOut,
      child: CustomPaint(
        painter: _BubbleTailPainter(
          color: AppColors.surfaceDefault,
          shadowColor: AppColors.secondaryNavy.withValues(alpha: 0.10),
          pointRight: pointRight,
        ),
        child: Container(
          margin: pointRight
              ? EdgeInsets.only(right: 10.w)
              : EdgeInsets.only(left: 10.w),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceDefault,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryNavy.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: TypewriterText(
            // ValueKey forces a fresh TypewriterText state when the message
            // changes — guarantees the new line starts at char 0 even if the
            // surrounding tree decides to recycle the widget.
            key: ValueKey(message),
            text: message,
            charDuration: charDuration,
            // Subtle selection-click on each word boundary so the user
            // physically feels the mascot reading at a natural rhythm.
            hapticOnWords: true,
            style: AppTextStyle.body().copyWith(
              fontSize: 14.sp,
              height: 20 / 14,
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws a small triangular "tail" on the edge of the bubble pointing toward
/// the mascot. The tail is at the left edge by default, or the right edge
/// when [pointRight] is true. Tail recenters as the bubble grows.
class _BubbleTailPainter extends CustomPainter {
  _BubbleTailPainter({
    required this.color,
    required this.shadowColor,
    required this.pointRight,
  });
  final Color color;
  final Color shadowColor;
  final bool pointRight;

  @override
  void paint(Canvas canvas, Size size) {
    final tailCenterY = size.height / 2;
    final path = Path();
    if (pointRight) {
      final right = size.width;
      path
        ..moveTo(right, tailCenterY)
        ..lineTo(right - 14, tailCenterY - 10)
        ..lineTo(right - 14, tailCenterY + 10)
        ..close();
    } else {
      path
        ..moveTo(0, tailCenterY)
        ..lineTo(14, tailCenterY - 10)
        ..lineTo(14, tailCenterY + 10)
        ..close();
    }
    canvas.drawShadow(path, shadowColor, 4, true);
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter old) =>
      old.color != color ||
      old.shadowColor != shadowColor ||
      old.pointRight != pointRight;
}
