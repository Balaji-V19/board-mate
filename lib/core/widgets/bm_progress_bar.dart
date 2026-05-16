import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/constants/app_colors.dart';

class BmProgressBar extends StatelessWidget {
  const BmProgressBar({
    super.key,
    required this.value,
    this.color,
    this.background,
    this.height,
  });

  final double value;
  final Color? color;
  final Color? background;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    final h = height ?? 6.h;
    return ClipRRect(
      borderRadius: BorderRadius.circular(h),
      child: Stack(
        children: [
          Container(
            height: h,
            color: background ?? AppColors.secondaryNavy.withValues(alpha: 0.08),
          ),
          FractionallySizedBox(
            widthFactor: v,
            child: Container(
              height: h,
              color: color ?? AppColors.primaryGold,
            ),
          ),
        ],
      ),
    );
  }
}
