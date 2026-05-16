import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_strings.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../core/widgets/bm_button.dart';

class _Slide {
  const _Slide(this.icon, this.color, this.title, this.body);
  final IconData icon;
  final Color color;
  final String title;
  final String body;
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  static const _slides = [
    _Slide(Icons.menu_book_rounded, AppColors.primaryGold,
        AppStrings.onboardingTitle1, AppStrings.onboardingBody1),
    _Slide(Icons.checklist_rounded, AppColors.categoryParty,
        AppStrings.onboardingTitle2, AppStrings.onboardingBody2),
    _Slide(Icons.bolt_rounded, AppColors.categoryCards,
        AppStrings.onboardingTitle3, AppStrings.onboardingBody3),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (!mounted) return;
    context.go('/sign-in');
  }

  void _next() {
    if (_index == _slides.length - 1) {
      _finish();
    } else {
      _controller.nextPage(
          duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal, 12.h, AppSpacing.screenHorizontal, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.appName,
                      style: AppTextStyle.cardTitle()),
                  TextButton(
                    onPressed: _finish,
                    child: Text('Skip',
                        style: AppTextStyle.bodyStrong(
                            color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: active ? 22.w : 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primaryGold
                          : AppColors.secondaryNavy.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal),
              child: BmButton(
                label: _index == _slides.length - 1 ? 'Get started' : 'Next',
                onPressed: _next,
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 220.w,
            height: 220.w,
            decoration: BoxDecoration(
              color: slide.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(slide.icon, size: 96.sp, color: slide.color),
          ),
          SizedBox(height: 40.h),
          Text(slide.title,
              style: AppTextStyle.screenTitle(),
              textAlign: TextAlign.center),
          SizedBox(height: 10.h),
          Text(slide.body,
              style: AppTextStyle.body(color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
