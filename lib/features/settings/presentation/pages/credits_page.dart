import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../core/data/image_credits.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
                onBack: () => context.canPop()
                    ? context.pop()
                    : context.go('/settings')),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal,
                    18.h, AppSpacing.screenHorizontal, 24.h),
                children: [
                  Text('Image credits',
                      style: AppTextStyle.largeTitle().copyWith(
                          fontSize: 28.sp, fontWeight: FontWeight.w800)),
                  SizedBox(height: 8.h),
                  Text(
                    'Game photos used in BoardMate are licensed under '
                    'Creative Commons or the Unsplash licence. Tap a source '
                    'to view the original file and its licence terms.',
                    style: AppTextStyle.body(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 18.h),
                  for (final c in imageCredits) _CreditCard(credit: c),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 8.h,
          AppSpacing.screenHorizontal, 0),
      child: Row(
        children: [
          Material(
            color: AppColors.surfaceDefault,
            borderRadius: BorderRadius.circular(12.r),
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.chevron_left_rounded,
                    color: AppColors.secondaryNavy, size: 22.sp),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text('Credits',
                  style: AppTextStyle.cardTitle().copyWith(
                      fontSize: 17.sp, fontWeight: FontWeight.w700)),
            ),
          ),
          SizedBox(width: 42.w),
        ],
      ),
    );
  }
}

class _CreditCard extends StatelessWidget {
  const _CreditCard({required this.credit});
  final ImageCredit credit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceDefault,
        borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(credit.label,
              style: AppTextStyle.cardTitle()
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 15.sp)),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.person_outline_rounded,
                  size: 14.sp, color: AppColors.textSecondary),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(credit.author,
                    style: AppTextStyle.helper()),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.shield_outlined,
                  size: 14.sp, color: AppColors.textSecondary),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(credit.license,
                    style: AppTextStyle.helper()),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Builder(
            builder: (rowContext) => InkWell(
              onTap: () async {
                await Clipboard.setData(
                    ClipboardData(text: credit.sourcePage));
                if (!rowContext.mounted) return;
                ScaffoldMessenger.of(rowContext).showSnackBar(
                  const SnackBar(content: Text('Source link copied.')),
                );
              },
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  children: [
                    Icon(Icons.link_rounded,
                        size: 14.sp, color: AppColors.primaryGold),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        credit.sourcePage,
                        style: AppTextStyle.helper(
                            color: AppColors.primaryGold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(Icons.copy_rounded,
                        size: 14.sp, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
