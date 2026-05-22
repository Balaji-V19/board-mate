import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../core/widgets/bm_button.dart';
import '../../../guides/presentation/widgets/mascot_speech_bubble.dart';
import '../../../mascot/domain/entities/mascot_mood.dart';
import '../../../mascot/presentation/providers/mascot_notifier.dart';

/// A single onboarding slide. Carries the mascot's mood for the slide so the
/// mascot visibly reacts to the feature being introduced (welcome → curious →
/// reading → teaching → thinking).
class _Slide {
  const _Slide({
    required this.title,
    required this.body,
    required this.mood,
    required this.hints,
    this.mascotOnRight = false,
  });
  final String title;
  final String body;
  final MascotMood mood;

  /// Optional feature chips shown under the bubble — small, glance-able
  /// hints that preview the actual UI vocabulary inside the app.
  final List<_HintChip> hints;

  /// Flip the mascot to the right side (and the bubble to the left) — used
  /// on the "Learn how to play" slide so the visual flips and the teaching
  /// motif reads naturally.
  final bool mascotOnRight;
}

class _HintChip {
  const _HintChip(this.icon, this.label, this.color);
  final IconData icon;
  final String label;
  final Color color;
}

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});
  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  late final List<_Slide> _slides = [
    _Slide(
      title: 'Your board game teacher',
      body:
          "Hi! I'm here to help you learn real board games — no rulebook "
          'hunting, just clear, friendly steps.',
      mood: MascotMood.welcome,
      hints: const [],
    ),
    _Slide(
      title: 'Find your next game',
      body:
          'Browse dozens of games by category and filter by players, time, '
          'or difficulty in seconds.',
      mood: MascotMood.curious,
      hints: const [
        _HintChip(
          Icons.workspace_premium_rounded,
          'Strategy',
          AppColors.secondaryNavy,
        ),
        _HintChip(Icons.favorite_rounded, 'Family', AppColors.error),
        _HintChip(
          Icons.celebration_rounded,
          'Party',
          AppColors.categoryParty,
        ),
        _HintChip(Icons.style_rounded, 'Cards', AppColors.info),
      ],
    ),
    _Slide(
      title: 'Set up the table',
      body:
          "Step-by-step setup with tappable pieces. I'll explain each one "
          'as you tap, and tick off the table as you go.',
      mood: MascotMood.reading,
      // textSecondary is a runtime-computed color so this list can't be const.
      hints: [
        const _HintChip(
          Icons.check_circle_rounded,
          'Hex tiles',
          AppColors.success,
        ),
        const _HintChip(
          Icons.check_circle_rounded,
          'Tokens',
          AppColors.success,
        ),
        _HintChip(
          Icons.radio_button_unchecked_rounded,
          'Robber',
          AppColors.textSecondary,
        ),
      ],
    ),
    _Slide(
      title: 'Learn how to play',
      body:
          'Tap-to-reveal rules, a visual turn-flow, and a quick reference '
          'for table-side lookups when you forget a thing.',
      mood: MascotMood.teaching,
      mascotOnRight: true,
      hints: const [
        _HintChip(Icons.casino_rounded, '1. Roll', AppColors.primaryGold),
        _HintChip(Icons.swap_horiz_rounded, '2. Trade', AppColors.info),
        _HintChip(Icons.build_rounded, '3. Build', AppColors.success),
      ],
    ),
    _Slide(
      title: 'Always at the table',
      body:
          'Save games for offline use. Pull up the cheat sheet whenever '
          "you need it — even when the wifi doesn't show up.",
      mood: MascotMood.thinking,
      hints: const [
        _HintChip(
          Icons.download_done_rounded,
          'Saved offline',
          AppColors.success,
        ),
        _HintChip(
          Icons.auto_awesome_rounded,
          'Cheat sheet',
          AppColors.primaryGold,
        ),
      ],
    ),
  ];

  Future<void> _finish() async {
    HapticFeedback.lightImpact();
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
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onSlideChanged(int i) {
    HapticFeedback.lightImpact();
    setState(() => _index = i);
    // Explicitly update the mascot mood when the slide changes. Slides are
    // built lazily by PageView, so we can't rely on each slide's own
    // MascotInline to fire setMood when navigating back to a slide that
    // was already built — push it here instead.
    ref.read(mascotNotifierProvider).setMood(_slides[i].mood);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _slides.length - 1;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar — progress hint on the left, Skip on the right.
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                8.h,
                AppSpacing.screenHorizontal,
                4.h,
              ),
              child: Row(
                children: [
                  Text(
                    '${_index + 1} of ${_slides.length}',
                    style: AppTextStyle.helper(
                      color: AppColors.textSecondary,
                    ).copyWith(fontSize: 13.sp, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Skip',
                      style: AppTextStyle.body(
                        color: AppColors.textSecondary,
                      ).copyWith(fontSize: 15.sp),
                    ),
                  ),
                ],
              ),
            ),
            // Slides
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: _onSlideChanged,
                itemCount: _slides.length,
                itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
              ),
            ),
            // Page dots
            _Dots(count: _slides.length, active: _index),
            SizedBox(height: 18.h),
            // Primary CTA — label morphs on the final slide.
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: BmButton(
                label: isLast ? "Let's play" : 'Continue',
                icon: isLast ? Icons.arrow_forward_rounded : null,
                onPressed: _next,
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 32.h,
              child: isLast
                  ? const SizedBox.shrink()
                  : TextButton(
                      onPressed: _finish,
                      child: Text(
                        'Skip for now',
                        style: AppTextStyle.bodyStrong(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }
}

// ─── Slide content ──────────────────────────────────────────────────────

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    // Use a LayoutBuilder + ConstrainedBox so the slide content vertically
    // *centers* within whatever height PageView gives it. Otherwise the
    // content piled up at the top and left a big blank below.
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            8.h,
            AppSpacing.screenHorizontal,
            16.h,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Brand badge
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'BOARDMATE',
                    style: AppTextStyle.label(color: AppColors.primaryGold)
                        .copyWith(
                      letterSpacing: 1.5,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                // Title
                Text(
                  slide.title,
                  style: AppTextStyle.largeTitle().copyWith(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    height: 34 / 28,
                  ),
                ),
                SizedBox(height: 20.h),
                // Mascot + speech bubble — typewriter narrates `slide.body`
                // and the mascot's mood reflects the feature being
                // introduced. Mascot footprint (170) leaves enough row
                // width so the bubble doesn't wrap to 2-3 words a line.
                MascotSpeechBubble(
                  mood: slide.mood,
                  message: slide.body,
                  mascotSize: 170,
                  mascotOnRight: slide.mascotOnRight,
                ),
                if (slide.hints.isNotEmpty) ...[
                  SizedBox(height: 24.h),
                  _FeatureChips(items: slide.hints),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Compact pill chips showing concrete UI elements the user will see inside
/// the app — gives the onboarding a "glimpse of the product" feel.
class _FeatureChips extends StatelessWidget {
  const _FeatureChips({required this.items});
  final List<_HintChip> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: items
          .map(
            (h) => Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: h.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: h.color.withValues(alpha: 0.30),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(h.icon, size: 14.sp, color: h.color),
                  SizedBox(width: 6.w),
                  Text(
                    h.label,
                    style: AppTextStyle.bodyStrong(color: h.color)
                        .copyWith(fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─── Dots ───────────────────────────────────────────────────────────────

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
