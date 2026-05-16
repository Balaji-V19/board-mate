import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/constants/app_colors.dart';
import '../../config/constants/app_spacing.dart';
import '../../config/constants/app_textstyle.dart';

class BmChip extends StatelessWidget {
  const BmChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primaryGold;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        child: Container(
          height: AppSpacing.chipHeight,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: selected ? accent : AppColors.surfaceDefault,
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            border: Border.all(
              color: selected ? accent : AppColors.border,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyle.label(
              color: selected ? Colors.white : AppColors.textPrimary,
            ).copyWith(letterSpacing: 0.2, fontSize: 13.sp),
          ),
        ),
      ),
    );
  }
}
