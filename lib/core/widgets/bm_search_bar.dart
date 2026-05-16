import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/constants/app_colors.dart';
import '../../config/constants/app_spacing.dart';
import '../../config/constants/app_textstyle.dart';

class BmSearchBar extends StatelessWidget {
  const BmSearchBar({
    super.key,
    this.controller,
    this.hint = 'Search…',
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
    this.trailing,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: AppSpacing.searchBarHeight,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceDefault,
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded,
                    size: 20.sp, color: AppColors.textSecondary),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    onTap: onTap,
                    readOnly: readOnly,
                    autofocus: autofocus,
                    style: AppTextStyle.body(),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: AppTextStyle.body(
                          color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: 10.w),
          trailing!,
        ],
      ],
    );
  }
}

class BmIconFilterButton extends StatelessWidget {
  const BmIconFilterButton({super.key, this.onTap, this.icon});
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceDefault,
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        child: Container(
          width: AppSpacing.searchBarHeight,
          height: AppSpacing.searchBarHeight,
          decoration: BoxDecoration(
            color: AppColors.surfaceDefault,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon ?? Icons.tune_rounded,
            size: 20.sp,
            color: AppColors.secondaryNavy,
          ),
        ),
      ),
    );
  }
}
