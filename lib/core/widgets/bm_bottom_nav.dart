import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/constants/app_colors.dart';
import '../../config/constants/app_spacing.dart';
import '../../config/constants/app_textstyle.dart';

class BmBottomNavItem {
  const BmBottomNavItem({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

class BmBottomNav extends StatelessWidget {
  const BmBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<BmBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceDefault,
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceDefault,
          border: Border(
            top: BorderSide(
              color: AppColors.secondaryNavy.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: AppSpacing.bottomNavHeight,
            child: Row(
              children: List.generate(items.length, (i) {
                final selected = i == currentIndex;
                final item = items[i];
                return Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primaryGold.withValues(alpha: 0.14)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Icon(
                            item.icon,
                            color: selected
                                ? AppColors.primaryGold
                                : AppColors.textSecondary,
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          item.label,
                          style: AppTextStyle.helper(
                            color: selected
                                ? AppColors.primaryGold
                                : AppColors.textSecondary,
                          ).copyWith(
                              fontSize: 11.sp, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
