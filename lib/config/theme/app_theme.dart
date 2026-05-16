import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryGold,
      onPrimary: Colors.white,
      secondary: AppColors.secondaryNavy,
      onSecondary: Colors.white,
      surface: AppColors.surfaceDefault,
      onSurface: AppColors.secondaryNavy,
      error: AppColors.error,
      onError: Colors.white,
    ),
    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: AppColors.secondaryNavy,
      displayColor: AppColors.secondaryNavy,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.secondaryNavy,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.inter(
        color: AppColors.secondaryNavy,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
    splashFactory: InkSparkle.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
    }),
  );
}
