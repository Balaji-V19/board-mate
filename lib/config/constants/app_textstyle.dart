import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyle {
  AppTextStyle._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    required double height,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: size.sp,
      fontWeight: weight,
      height: height / size,
      color: color ?? AppColors.textPrimary,
    );
  }

  static TextStyle largeTitle({Color? color}) => _base(
        size: 30,
        weight: FontWeight.w700,
        height: 38,
        color: color,
      );

  static TextStyle screenTitle({Color? color}) => _base(
        size: 26,
        weight: FontWeight.w700,
        height: 34,
        color: color,
      );

  static TextStyle sectionTitle({Color? color}) => _base(
        size: 20,
        weight: FontWeight.w600,
        height: 28,
        color: color,
      );

  static TextStyle cardTitle({Color? color}) => _base(
        size: 17,
        weight: FontWeight.w600,
        height: 24,
        color: color,
      );

  static TextStyle body({Color? color}) => _base(
        size: 15,
        weight: FontWeight.w400,
        height: 23,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle bodyStrong({Color? color}) => _base(
        size: 15,
        weight: FontWeight.w600,
        height: 23,
        color: color,
      );

  static TextStyle helper({Color? color}) => _base(
        size: 13,
        weight: FontWeight.w400,
        height: 18,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle label({Color? color}) => _base(
        size: 12,
        weight: FontWeight.w600,
        height: 16,
        color: color ?? AppColors.textSecondary,
      ).copyWith(letterSpacing: 0.6);

  static TextStyle button({Color? color}) => _base(
        size: 16,
        weight: FontWeight.w600,
        height: 22,
        color: color ?? Colors.white,
      );
}
