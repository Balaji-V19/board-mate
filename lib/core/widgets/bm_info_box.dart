import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/constants/app_colors.dart';
import '../../config/constants/app_spacing.dart';
import '../../config/constants/app_textstyle.dart';

enum BmInfoTone { tip, warning, info, success }

class BmInfoBox extends StatelessWidget {
  const BmInfoBox({
    super.key,
    required this.label,
    required this.body,
    this.tone = BmInfoTone.info,
    this.icon,
  });

  final String label;
  final String body;
  final BmInfoTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final accent = switch (tone) {
      BmInfoTone.tip => AppColors.info,
      BmInfoTone.info => AppColors.info,
      BmInfoTone.warning => AppColors.warning,
      BmInfoTone.success => AppColors.success,
    };
    final defaultIcon = switch (tone) {
      BmInfoTone.tip => Icons.lightbulb_outline_rounded,
      BmInfoTone.info => Icons.info_outline_rounded,
      BmInfoTone.warning => Icons.warning_amber_rounded,
      BmInfoTone.success => Icons.check_circle_outline_rounded,
    };
    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
        border: Border(left: BorderSide(color: accent, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defaultIcon, color: accent, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppTextStyle.label(color: accent)
                      .copyWith(letterSpacing: 0.6, fontSize: 11.sp),
                ),
                SizedBox(height: 4.h),
                Text(body, style: AppTextStyle.body()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
