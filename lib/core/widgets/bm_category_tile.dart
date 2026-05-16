import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/constants/app_colors.dart';
import '../../config/constants/app_spacing.dart';
import '../../config/constants/app_textstyle.dart';

class BmCategoryTile extends StatelessWidget {
  const BmCategoryTile({
    super.key,
    required this.label,
    required this.emoji,
    required this.color,
    this.onTap,
  });

  final String label;
  final String emoji;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
        child: Column(
          children: [
            Container(
              height: 64.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: TextStyle(fontSize: 28.sp)),
            ),
            SizedBox(height: 8.h),
            Text(label, style: AppTextStyle.helper(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
