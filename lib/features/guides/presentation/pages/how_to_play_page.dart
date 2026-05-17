import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_strings.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../core/widgets/bm_button.dart';
import '../../../../core/widgets/bm_concept_image.dart';
import '../../../../core/widgets/bm_info_box.dart';
import '../../../../core/widgets/bm_progress_bar.dart';
import '../../../games/domain/entities/guide_step_entity.dart';
import '../../../games/domain/entities/user_progress_entity.dart';
import '../../../games/presentation/providers/games_notifier.dart';
import '../../../games/presentation/providers/progress_notifier.dart';

class HowToPlayPage extends ConsumerStatefulWidget {
  const HowToPlayPage({super.key, required this.gameId});
  final String gameId;

  @override
  ConsumerState<HowToPlayPage> createState() => _HowToPlayPageState();
}

class _HowToPlayPageState extends ConsumerState<HowToPlayPage> {
  int _chapter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(progressNotifierProvider)
          .touch(widget.gameId, GuideSection.howToPlay);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(guideNotifierProvider(widget.gameId)).state;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (m) => Center(
            child: Text(m,
                style: AppTextStyle.helper(color: AppColors.error)),
          ),
          loaded: (guide) {
            if (guide.howToPlaySteps.isEmpty) {
              return Column(
                children: [
                  _Header(
                    onBack: () => context.canPop()
                        ? context.pop()
                        : context.go('/game/${widget.gameId}'),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.w),
                        child: Text('No play steps yet for this game.',
                            style: AppTextStyle.helper(),
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ],
              );
            }
            final chapters = guide.howToPlaySteps
              ..sort((a, b) => a.order.compareTo(b.order));
            final current = chapters[_chapter];

            return Column(
              children: [
                _Header(
                  onBack: () => context.canPop()
                      ? context.pop()
                      : context.go('/game/${widget.gameId}'),
                ),
                Expanded(
                  child: _ChapterView(
                    chapter: current,
                    chapterIndex: _chapter,
                    totalChapters: chapters.length,
                  ),
                ),
                _BottomBar(
                  isFirst: _chapter == 0,
                  isLast: _chapter == chapters.length - 1,
                  onBack: () {
                    if (_chapter > 0) setState(() => _chapter--);
                  },
                  onNext: () async {
                    if (_chapter < chapters.length - 1) {
                      setState(() => _chapter++);
                      return;
                    }
                    await ref
                        .read(progressNotifierProvider)
                        .markComplete(
                            widget.gameId, GuideSection.howToPlay);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('How to play marked complete.')),
                    );
                    context.go('/game/${widget.gameId}/learn');
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────

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
          _RoundIconButton(
              icon: Icons.chevron_left_rounded, onTap: onBack),
          Expanded(
            child: Center(
              child: Text(AppStrings.howToPlay,
                  style: AppTextStyle.cardTitle().copyWith(
                      fontSize: 17.sp, fontWeight: FontWeight.w700)),
            ),
          ),
          _RoundIconButton(
              icon: Icons.more_horiz_rounded, onTap: () {}),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceDefault,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.secondaryNavy, size: 22.sp),
        ),
      ),
    );
  }
}

// ─── Chapter body ────────────────────────────────────────────────────────

class _ChapterView extends StatelessWidget {
  const _ChapterView({
    required this.chapter,
    required this.chapterIndex,
    required this.totalChapters,
  });

  final GuideStepEntity chapter;
  final int chapterIndex;
  final int totalChapters;

  @override
  Widget build(BuildContext context) {
    final pct = (chapterIndex + 1) / totalChapters;
    final readMinutes = _estimateReadMinutes(chapter);

    return ListView(
      padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 18.h,
          AppSpacing.screenHorizontal, 20.h),
      children: [
        // Progress header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CHAPTER ${chapterIndex + 1} OF $totalChapters',
              style: AppTextStyle.label(color: AppColors.primaryGold)
                  .copyWith(letterSpacing: 1.5, fontSize: 11.sp),
            ),
            Text('$readMinutes min read', style: AppTextStyle.helper()),
          ],
        ),
        SizedBox(height: 10.h),
        BmProgressBar(value: pct, height: 6.h),
        SizedBox(height: 20.h),
        // Chapter title
        Text(
          chapter.title,
          style: AppTextStyle.largeTitle().copyWith(
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
              height: 34 / 26),
        ),
        SizedBox(height: 12.h),
        // Intro paragraph
        Text(
          chapter.body,
          style: AppTextStyle.body(color: AppColors.textSecondary),
        ),
        // Illustration
        if (chapter.images.isNotEmpty) ...[
          SizedBox(height: 18.h),
          BmConceptImageRow(images: chapter.images),
        ],
        // Rules
        if (chapter.rules.isNotEmpty) ...[
          SizedBox(height: 22.h),
          Text(
            'Rules of ${chapter.title.toLowerCase()}',
            style: AppTextStyle.sectionTitle()
                .copyWith(fontWeight: FontWeight.w800, fontSize: 20.sp),
          ),
          SizedBox(height: 12.h),
          for (final rule in chapter.rules) _RuleCard(rule: rule),
        ],
        // Warning
        if (chapter.warning != null) ...[
          SizedBox(height: 14.h),
          BmInfoBox(
            label: AppStrings.warning,
            body: chapter.warning!,
            tone: BmInfoTone.warning,
          ),
        ],
      ],
    );
  }

  /// Rough reading-time estimate based on word count of body + rule text.
  /// ~50 words per minute (slow, attentive read for rules). Clamped to 1-30.
  int _estimateReadMinutes(GuideStepEntity c) {
    int words = c.body.split(RegExp(r'\s+')).length;
    for (final r in c.rules) {
      words += r.title.split(RegExp(r'\s+')).length;
      words += r.body.split(RegExp(r'\s+')).length;
    }
    return (words / 50).ceil().clamp(1, 30);
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({required this.rule});
  final NumberedRuleEntity rule;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceDefault,
        borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${rule.number}',
              style: AppTextStyle.bodyStrong(color: AppColors.primaryGold)
                  .copyWith(fontSize: 13.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rule.title,
                    style: AppTextStyle.bodyStrong()
                        .copyWith(fontSize: 15.sp)),
                SizedBox(height: 2.h),
                Text(rule.body,
                    style: AppTextStyle.helper(
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom CTA bar ──────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isFirst,
    required this.isLast,
    required this.onBack,
    required this.onNext,
  });
  final bool isFirst;
  final bool isLast;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 8.h,
            AppSpacing.screenHorizontal, 14.h),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: BmButton(
                label: '‹ ${AppStrings.back}',
                variant: BmButtonVariant.secondary,
                onPressed: isFirst ? null : onBack,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              flex: 7,
              child: BmButton(
                label: isLast ? 'Finish chapters' : 'Next Chapter →',
                icon: isLast ? Icons.check_rounded : null,
                onPressed: onNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
