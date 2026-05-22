import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_strings.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../core/widgets/bm_button.dart';
import '../providers/auth_notifier.dart';

enum _SignInMethod { google, apple }

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  _SignInMethod? _activeMethod;

  @override
  Widget build(BuildContext context) {
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
                leading: const _GoogleGlyph(),
                loading: loading && _activeMethod == _SignInMethod.google,
                onPressed: loading
                    ? null
                    : () async {
                        setState(() => _activeMethod = _SignInMethod.google);
                        await ref.read(authNotifierProvider).signInWithGoogle();
                        if (!mounted) return;
                        setState(() => _activeMethod = null);
                      },
              ),
              if (!kIsWeb && Platform.isIOS) ...[
                SizedBox(height: 10.h),
                BmButton(
                  label: AppStrings.continueWithApple,
                  icon: Icons.apple,
                  variant: BmButtonVariant.secondary,
                  loading: loading && _activeMethod == _SignInMethod.apple,
                  onPressed: loading
                      ? null
                      : () async {
                          setState(() => _activeMethod = _SignInMethod.apple);
                          await ref.read(authNotifierProvider).signInWithApple();
                          if (!mounted) return;
                          setState(() => _activeMethod = null);
                        },
                ),
              ],
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

/// The official 4-color Google "G" rendered from an SVG asset and wrapped
/// in a white pill so it stays legible on the gold primary button.
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26.w,
      height: 26.w,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        'assets/icons/google_g.svg',
        width: 16.w,
        height: 16.w,
      ),
    );
  }
}
