import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSpacing {
  AppSpacing._();

  static double get xxs => 4.w;
  static double get xs => 8.w;
  static double get sm => 12.w;
  static double get md => 16.w;
  static double get lg => 20.w;
  static double get xl => 24.w;
  static double get xxl => 28.w;
  static double get xxxl => 32.w;

  static double get screenHorizontal => 20.w;
  static double get cardPadding => 16.w;
  static double get sectionGap => 28.h;
  static double get cardGap => 14.h;
  static double get titleSubtitleGap => 6.h;

  static double get buttonHeight => 52.h;
  static double get searchBarHeight => 50.h;
  static double get chipHeight => 36.h;
  static double get bottomNavHeight => 76.h;

  static double get cardRadius => 22.r;
  static double get smallCardRadius => 14.r;
  static double get buttonRadius => 16.r;
  static double get chipRadius => 100.r;
  static double get iconButton => 42.w;

  /// Breathing room at the end of scrollable tab screens. Because the docked
  /// bottom nav is a real `bottomNavigationBar` slot in the scaffold, the body
  /// already ends above it — this padding just gives the last content card a
  /// comfortable margin instead of butting up against the nav.
  static double get bottomNavSafePadding => 24.h;
}
