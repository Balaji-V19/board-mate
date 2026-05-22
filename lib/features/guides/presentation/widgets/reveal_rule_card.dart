import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../games/domain/entities/guide_step_entity.dart';

/// Rule card that starts collapsed ("?" + Tap to reveal) and animates open to
/// show the rule's title and body on tap. Reveal state is owned by the page so
/// it can also drive the mascot speech bubble.
class RevealRuleCard extends StatelessWidget {
  const RevealRuleCard({
    super.key,
    required this.rule,
    required this.revealed,
    required this.onTap,
  });

  final NumberedRuleEntity rule;
  final bool revealed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: AppColors.surfaceDefault,
        borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
        child: InkWell(
          onTap: revealed ? null : onTap,
          borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(AppSpacing.smallCardRadius),
              border: Border.all(
                color: revealed
                    ? AppColors.primaryGold.withValues(alpha: 0.45)
                    : AppColors.border,
                width: revealed ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NumberBadge(number: rule.number, revealed: revealed),
                SizedBox(width: 12.w),
                Expanded(
                  child: AnimatedCrossFade(
                    duration: const Duration(milliseconds: 180),
                    firstChild: _Collapsed(),
                    secondChild: _Revealed(rule: rule),
                    crossFadeState: revealed
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({required this.number, required this.revealed});
  final int number;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: revealed
            ? AppColors.primaryGold
            : AppColors.primaryGold.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: AppTextStyle.bodyStrong(
          color: revealed ? Colors.white : AppColors.primaryGold,
        ).copyWith(fontSize: 13.sp),
      ),
    );
  }
}

class _Collapsed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: AppColors.secondaryNavy.withValues(alpha: 0.06),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '?',
            style: AppTextStyle.bodyStrong(
              color: AppColors.textSecondary,
            ).copyWith(fontSize: 14.sp),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            'Tap to reveal',
            style: AppTextStyle.bodyStrong(color: AppColors.textSecondary)
                .copyWith(fontSize: 14.sp),
          ),
        ),
      ],
    );
  }
}

class _Revealed extends StatelessWidget {
  const _Revealed({required this.rule});
  final NumberedRuleEntity rule;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          rule.title,
          style: AppTextStyle.bodyStrong().copyWith(fontSize: 15.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          rule.body,
          style: AppTextStyle.helper(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
