import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_strings.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../core/widgets/bm_button.dart';
import '../providers/auth_notifier.dart';

class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(authNotifierProvider);
    final state = notifier.state;
    final loading =
        state.maybeWhen(authenticating: () => true, orElse: () => false);
    final errorMessage =
        state.maybeWhen(error: (m) => m, orElse: () => null);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40.h),
              _Logo(),
              SizedBox(height: 28.h),
              Text(AppStrings.signInTitle,
                  style: AppTextStyle.screenTitle(),
                  textAlign: TextAlign.center),
              SizedBox(height: 10.h),
              Text(AppStrings.signInSubtitle,
                  style: AppTextStyle.body(color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
              const Spacer(),
              if (errorMessage != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    errorMessage,
                    style: AppTextStyle.helper(color: AppColors.error),
                  ),
                ),
                SizedBox(height: 14.h),
              ],
              BmButton(
                label: AppStrings.continueWithGoogle,
                icon: Icons.login_rounded,
                loading: loading,
                onPressed: () => ref.read(authNotifierProvider).signInWithGoogle(),
              ),
              SizedBox(height: 14.h),
              Text(
                'By continuing, you agree to our terms and privacy policy.',
                style: AppTextStyle.helper(),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 104.w,
        height: 104.w,
        decoration: BoxDecoration(
          color: AppColors.primaryGold.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.casino_rounded,
          color: AppColors.primaryGold,
          size: 54.sp,
        ),
      ),
    );
  }
}
