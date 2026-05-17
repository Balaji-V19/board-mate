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
  const _Slide({
    required this.title,
    required this.body,
    required this.heroBuilder,
  });
  final String title;
  final String body;
  final WidgetBuilder heroBuilder;
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  late final List<_Slide> _slides = [
    _Slide(
      title: AppStrings.onboardingTitle1,
      body: AppStrings.onboardingBody1,
      heroBuilder: (_) => const _Hero1DiceAndMeeples(),
    ),
    _Slide(
      title: AppStrings.onboardingTitle2,
      body: AppStrings.onboardingBody2,
      heroBuilder: (_) => const _Hero2Rulebook(),
    ),
    _Slide(
      title: AppStrings.onboardingTitle3,
      body: AppStrings.onboardingBody3,
      heroBuilder: (_) => const _Hero3GameCards(),
    ),
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
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _slides.length - 1;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with Skip
            Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 8.h,
                  AppSpacing.screenHorizontal, 4.h),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    AppStrings.onboardingSkip,
                    style: AppTextStyle.body(
                            color: AppColors.textSecondary)
                        .copyWith(fontSize: 16.sp),
                  ),
                ),
              ),
            ),
            // Slides
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: _slides.length,
                itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
              ),
            ),
            // Dots
            _Dots(count: _slides.length, active: _index),
            SizedBox(height: 24.h),
            // Primary CTA + secondary skip link
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal),
              child: BmButton(
                label: isLast
                    ? AppStrings.onboardingGetStarted
                    : AppStrings.onboardingContinue,
                onPressed: _next,
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 36.h,
              child: isLast
                  ? const SizedBox.shrink()
                  : TextButton(
                      onPressed: _finish,
                      child: Text(
                        AppStrings.onboardingSkip,
                        style: AppTextStyle.bodyStrong(
                            color: AppColors.textSecondary),
                      ),
                    ),
            ),
            SizedBox(height: 8.h),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero illustration card
          AspectRatio(
            aspectRatio: 353 / 320,
            child: _HeroFrame(child: slide.heroBuilder(context)),
          ),
          SizedBox(height: 22.h),
          // Gold accent bar
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.primaryGold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            slide.title,
            style: AppTextStyle.largeTitle().copyWith(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              height: 34 / 28,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            slide.body,
            style: AppTextStyle.body(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});
  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: isActive ? 28.w : 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryGold
                : AppColors.primaryGold.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero illustrations — built with Flutter primitives so we ship no asset files.
// ─────────────────────────────────────────────────────────────────────────────

class _HeroFrame extends StatelessWidget {
  const _HeroFrame({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(color: const Color(0xFFEFE6D0)),
          ),
          // Soft blob shapes behind illustration
          Positioned(
            right: -30,
            top: -20,
            child: _blob(160, AppColors.primaryGold.withValues(alpha: 0.18)),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: _blob(140, AppColors.categoryFamily.withValues(alpha: 0.14)),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ── Hero 1: dice + meeples ──
class _Hero1DiceAndMeeples extends StatelessWidget {
  const _Hero1DiceAndMeeples();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dice pair
          SizedBox(
            height: 110.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // White die (left, slight tilt)
                Transform.translate(
                  offset: Offset(-32.w, 0),
                  child: _WhiteDie(),
                ),
                // Gold die (right, rotated)
                Transform.translate(
                  offset: Offset(40.w, 14.h),
                  child: Transform.rotate(
                    angle: 0.32,
                    child: _GoldDie(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          // Meeple row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _Meeple(color: AppColors.secondaryNavy),
              _Meeple(color: AppColors.categoryFamily),
              _Meeple(color: AppColors.primaryGold),
              _Meeple(color: AppColors.categoryCards),
            ],
          ),
        ],
      ),
    );
  }
}

class _WhiteDie extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96.w,
      height: 96.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryNavy.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: _DieFaceFive(dotColor: AppColors.secondaryNavy),
      ),
    );
  }
}

class _GoldDie extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78.w,
      height: 78.w,
      decoration: BoxDecoration(
        color: AppColors.primaryGold,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: _DieFaceThree(dotColor: Colors.white),
      ),
    );
  }
}

class _DieFaceFive extends StatelessWidget {
  const _DieFaceFive({required this.dotColor});
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    Widget dot() => LayoutBuilder(
          builder: (_, c) => SizedBox(
            width: c.maxWidth * 0.20,
            height: c.maxWidth * 0.20,
            child: DecoratedBox(
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
          ),
        );
    return Stack(
      children: [
        Align(alignment: Alignment.topLeft, child: dot()),
        Align(alignment: Alignment.topRight, child: dot()),
        Align(alignment: Alignment.center, child: dot()),
        Align(alignment: Alignment.bottomLeft, child: dot()),
        Align(alignment: Alignment.bottomRight, child: dot()),
      ],
    );
  }
}

class _DieFaceThree extends StatelessWidget {
  const _DieFaceThree({required this.dotColor});
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    Widget dot() => LayoutBuilder(
          builder: (_, c) => SizedBox(
            width: c.maxWidth * 0.22,
            height: c.maxWidth * 0.22,
            child: DecoratedBox(
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
          ),
        );
    return Stack(
      children: [
        Align(alignment: Alignment.topLeft, child: dot()),
        Align(alignment: Alignment.center, child: dot()),
        Align(alignment: Alignment.bottomRight, child: dot()),
      ],
    );
  }
}

class _Meeple extends StatelessWidget {
  const _Meeple({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 56.h,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Body — taller rounded rect with shoulders
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: 14.h,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                  bottomLeft: Radius.circular(4.r),
                  bottomRight: Radius.circular(4.r),
                ),
              ),
            ),
          ),
          // Head
          Container(
            width: 26.w,
            height: 26.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero 2: open rulebook + check badge + Step chips ──
class _Hero2Rulebook extends StatelessWidget {
  const _Hero2Rulebook();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Open book
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    _BookPage(left: true),
                    SizedBox(width: 4),
                    _BookPage(left: false),
                  ],
                ),
                // Check badge top-right
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGold
                              .withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.check_rounded,
                        color: Colors.white, size: 22.sp),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Step chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepChip(label: 'Step 1', active: false),
              SizedBox(width: 8.w),
              _StepChip(label: 'Step 2', active: true),
              SizedBox(width: 8.w),
              _StepChip(label: 'Step 3', active: false),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookPage extends StatelessWidget {
  const _BookPage({required this.left});
  final bool left;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(left ? 10 : 4),
            bottomLeft: Radius.circular(left ? 10 : 4),
            topRight: Radius.circular(left ? 4 : 10),
            bottomRight: Radius.circular(left ? 4 : 10),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryNavy.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 18.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            5,
            (i) => Container(
              height: 6.h,
              margin: EdgeInsets.only(right: i.isEven ? 0 : 18.w),
              decoration: BoxDecoration(
                color: AppColors.secondaryNavy.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({required this.label, required this.active});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: active ? AppColors.primaryGold : Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryNavy.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        style: AppTextStyle.label(
                color: active ? Colors.white : AppColors.secondaryNavy)
            .copyWith(letterSpacing: 0.2, fontSize: 12.sp),
      ),
    );
  }
}

// ── Hero 3: two game cards + "Downloaded" pill ──
class _Hero3GameCards extends StatelessWidget {
  const _Hero3GameCards();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Left card (tilted slightly left)
        Transform.translate(
          offset: Offset(-46.w, 6.h),
          child: Transform.rotate(
            angle: -0.10,
            child: const _MiniGameCard(
              accent: AppColors.categoryFamily,
              hasStar: false,
              hasTag: true,
            ),
          ),
        ),
        // Right card (tilted slightly right, on top)
        Transform.translate(
          offset: Offset(46.w, -6.h),
          child: Transform.rotate(
            angle: 0.10,
            child: const _MiniGameCard(
              accent: AppColors.categoryParty,
              hasStar: true,
              hasTag: false,
            ),
          ),
        ),
        // Downloaded pill
        Positioned(
          right: 28,
          bottom: 24,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.download_done_rounded,
                    color: Colors.white, size: 14.sp),
                SizedBox(width: 6.w),
                Text(
                  'Downloaded',
                  style: AppTextStyle.label(color: Colors.white)
                      .copyWith(letterSpacing: 0.2, fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniGameCard extends StatelessWidget {
  const _MiniGameCard({
    required this.accent,
    required this.hasStar,
    required this.hasTag,
  });
  final Color accent;
  final bool hasStar;
  final bool hasTag;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.w,
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryNavy.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top image area with abstract shapes
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                // Yellow circle
                Positioned(
                  left: 14,
                  top: 14,
                  child: _shape(18, AppColors.primaryGold, BoxShape.circle),
                ),
                // Navy circle
                Positioned(
                  left: 36,
                  top: 22,
                  child: _shape(14, AppColors.secondaryNavy, BoxShape.circle),
                ),
                // Red/peach square
                Positioned(
                  left: 24,
                  top: 40,
                  child: _shape(14, AppColors.error.withValues(alpha: 0.85),
                      BoxShape.rectangle, radius: 3),
                ),
                if (hasStar)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.star_rounded,
                          color: Colors.white, size: 14.sp),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          // Title-ish line
          Container(
            height: 6.h,
            width: 80.w,
            decoration: BoxDecoration(
              color: AppColors.secondaryNavy.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          SizedBox(height: 6.h),
          if (hasTag)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primaryGold,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: SizedBox(width: 20.w, height: 4.h),
            )
          else
            Container(
              height: 4.h,
              width: 60.w,
              decoration: BoxDecoration(
                color: AppColors.secondaryNavy.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
        ],
      ),
    );
  }

  Widget _shape(double size, Color color, BoxShape shape, {double radius = 0}) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: color,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(radius)
            : null,
      ),
    );
  }
}
