import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_strings.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});
  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decide());
  }

  Future<void> _decide() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
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
            const Spacer(flex: 4),
            const _SplashLogo(),
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

/// Concentric soft-gold glow rings with a die in the center.
class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300.w,
      height: 300.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _ring(300, 0.05),
          _ring(240, 0.07),
          _ring(180, 0.10),
          const _DieIcon(),
        ],
      ),
    );
  }

  Widget _ring(double size, double alpha) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryGold.withValues(alpha: alpha),
      ),
    );
  }
}

class _DieIcon extends StatelessWidget {
  const _DieIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108.w,
      height: 108.w,
      decoration: BoxDecoration(
        color: AppColors.primaryGold,
        borderRadius: BorderRadius.circular(26.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.35),
            blurRadius: 28,
            spreadRadius: 0,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: const _FiveFaceDots(),
      ),
    );
  }
}

/// The classic five-spot die face: dots at four corners + one in the center.
class _FiveFaceDots extends StatelessWidget {
  const _FiveFaceDots();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final dot = SizedBox(
          width: c.maxWidth * 0.18,
          height: c.maxWidth * 0.18,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        );
        return Stack(
          children: [
            Align(alignment: Alignment.topLeft, child: dot),
            Align(alignment: Alignment.topRight, child: dot),
            Align(alignment: Alignment.center, child: dot),
            Align(alignment: Alignment.bottomLeft, child: dot),
            Align(alignment: Alignment.bottomRight, child: dot),
          ],
        );
      },
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
