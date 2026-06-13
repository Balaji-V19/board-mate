import 'package:flutter/material.dart';

import '../../config/constants/app_colors.dart';
import '../utils/device_layout.dart';

/// Centers a fixed phone viewport on tablet-class screens (iPad).
///
/// The child is laid out at [DeviceLayout.phoneWidth]×[DeviceLayout.phoneHeight]
/// and scaled uniformly with [FittedBox] so [ScreenUtil] never sees the full
/// iPad width (which caused text and cards to blow up and overflow).
class TabletPhoneShell extends StatelessWidget {
  const TabletPhoneShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!DeviceLayout.isTablet(context)) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final widthScale = constraints.maxWidth / DeviceLayout.phoneWidth;
        final heightScale = constraints.maxHeight / DeviceLayout.phoneHeight;
        final scale = widthScale < heightScale ? widthScale : heightScale;

        final shellWidth = DeviceLayout.phoneWidth * scale;
        final shellHeight = DeviceLayout.phoneHeight * scale;
        final radius = 24 * scale;

        return ColoredBox(
          color: AppColors.background,
          child: Center(
            child: SizedBox(
              width: shellWidth,
              height: shellHeight,
              child: MediaQuery(
                data: DeviceLayout.phoneMediaQuery(MediaQuery.of(context)),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(
                      color: AppColors.secondaryNavy.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondaryNavy.withValues(alpha: 0.06),
                        blurRadius: 24 * scale,
                        offset: Offset(0, 8 * scale),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
