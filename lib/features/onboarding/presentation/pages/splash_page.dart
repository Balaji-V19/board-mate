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
    await Future<void>.delayed(const Duration(milliseconds: 1100));
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 104.w,
              height: 104.w,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.14),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGold.withValues(alpha: 0.18),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(Icons.casino_rounded,
                  color: AppColors.primaryGold, size: 56.sp),
            ),
            SizedBox(height: 24.h),
            Text(AppStrings.appName,
                style: AppTextStyle.largeTitle().copyWith(fontSize: 38.sp)),
            SizedBox(height: 6.h),
            Text(AppStrings.tagline,
                style: AppTextStyle.body(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            SizedBox(height: 36.h),
            const _DotsLoader(),
          ],
        ),
      ),
    );
  }
}

class _DotsLoader extends StatefulWidget {
  const _DotsLoader();
  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final p = (_c.value - (i * 0.2)) % 1.0;
            final t = (1 - (p - 0.5).abs() * 2).clamp(0.3, 1.0);
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: t),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
