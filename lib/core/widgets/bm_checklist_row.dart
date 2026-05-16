import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/constants/app_colors.dart';
import '../../config/constants/app_textstyle.dart';

class BmChecklistRow extends StatelessWidget {
  const BmChecklistRow({
    super.key,
    required this.label,
    required this.checked,
    this.onChanged,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!checked),
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: checked ? AppColors.success : Colors.transparent,
                borderRadius: BorderRadius.circular(7.r),
                border: Border.all(
                  color: checked ? AppColors.success : AppColors.border,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: checked
                  ? Icon(Icons.check_rounded, color: Colors.white, size: 14.sp)
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: AppTextStyle.body().copyWith(
                  decoration: checked ? TextDecoration.lineThrough : null,
                  color:
                      checked ? AppColors.textSecondary : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
