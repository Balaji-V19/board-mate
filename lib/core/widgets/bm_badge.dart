import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/constants/app_colors.dart';
import '../../config/constants/app_textstyle.dart';

enum BmBadgeTone { success, info, warning, neutral, primary }

class BmBadge extends StatelessWidget {
  const BmBadge({
    super.key,
    required this.label,
    this.tone = BmBadgeTone.neutral,
    this.icon,
  });

  final String label;
  final BmBadgeTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      BmBadgeTone.success => (
          AppColors.success.withValues(alpha: 0.12),
          AppColors.success,
        ),
      BmBadgeTone.info => (
          AppColors.info.withValues(alpha: 0.12),
          AppColors.info,
        ),
      BmBadgeTone.warning => (
          AppColors.warning.withValues(alpha: 0.14),
          AppColors.warning,
        ),
      BmBadgeTone.primary => (
          AppColors.primaryGold.withValues(alpha: 0.14),
          AppColors.primaryGold,
        ),
      BmBadgeTone.neutral => (
          AppColors.secondaryNavy.withValues(alpha: 0.08),
          AppColors.secondaryNavy,
        ),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14.sp, color: fg),
            SizedBox(width: 6.w),
          ],
          Text(
            label.toUpperCase(),
            style: AppTextStyle.label(color: fg).copyWith(letterSpacing: 0.6, fontSize: 11.sp),
          ),
        ],
      ),
    );
  }
}
