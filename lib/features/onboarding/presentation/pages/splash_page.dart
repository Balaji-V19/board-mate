import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_strings.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../mascot/presentation/widgets/splash_mascot.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});
  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _navigated = false;

  Future<void> _onGreetingDone() async {
    if (_navigated || !mounted) return;
    _navigated = true;

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final seen = prefs.getBool('seenOnboarding') ?? false;
    final auth = ref.read(authNotifierProvider);
    if (!mounted) return;

    if (!seen) {
      context.go('/onboarding');
    } else if (auth.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            SplashMascot(
              size: 280.w,
              onGreetingDone: _onGreetingDone,
            ),
            SizedBox(height: 26.h),
            Text(
              AppStrings.appName,
              style: AppTextStyle.largeTitle().copyWith(
                fontSize: 38.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              AppStrings.tagline,
              textAlign: TextAlign.center,
              style: AppTextStyle.body(color: AppColors.textSecondary),
            ),
            const Spacer(flex: 4),
            const _DotIndicator(),
            const Spacer(flex: 2),
            Text(
              AppStrings.splashFooter,
              style: AppTextStyle.helper().copyWith(
                color: AppColors.textSecondary,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(false),
        SizedBox(width: 10.w),
        _dot(true),
        SizedBox(width: 10.w),
        _dot(false),
      ],
    );
  }

  Widget _dot(bool active) {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? AppColors.primaryGold
            : AppColors.primaryGold.withValues(alpha: 0.25),
      ),
    );
  }
}
