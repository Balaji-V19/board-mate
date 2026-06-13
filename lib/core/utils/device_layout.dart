import 'package:flutter/widgets.dart';

/// Device-size helpers that read the **physical window**, not the layout
/// [MediaQuery] (which we clamp to phone dimensions on iPad).
class DeviceLayout {
  DeviceLayout._();

  static const tabletBreakpoint = 600.0;
  static const phoneWidth = 393.0;
  static const phoneHeight = 852.0;

  static Size windowSize(BuildContext context) {
    final view = View.of(context);
    return view.physicalSize / view.devicePixelRatio;
  }

  static bool isTablet(BuildContext context) =>
      windowSize(context).shortestSide >= tabletBreakpoint;

  static MediaQueryData phoneMediaQuery(MediaQueryData data) =>
      data.copyWith(size: const Size(phoneWidth, phoneHeight));
}
