import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_strings.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../core/widgets/bm_button.dart';
import '../../../../core/widgets/bm_checklist_row.dart';
import '../../../../core/widgets/bm_concept_image.dart';
import '../../../../core/widgets/bm_info_box.dart';
import '../../../../core/widgets/bm_progress_bar.dart';
import '../../../games/domain/entities/guide_step_entity.dart';
import '../../../games/domain/entities/user_progress_entity.dart';
import '../../../games/presentation/providers/games_notifier.dart';
import '../../../games/presentation/providers/progress_notifier.dart';

class SetupGuidePage extends ConsumerStatefulWidget {
  const SetupGuidePage({super.key, required this.gameId});
  final String gameId;

  @override
  ConsumerState<SetupGuidePage> createState() => _SetupGuidePageState();
}

class _SetupGuidePageState extends ConsumerState<SetupGuidePage> {
  int _step = 0;
  final Set<String> _checked = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(progressNotifierProvider)
          .touch(widget.gameId, GuideSection.setup);
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
            if (guide.setupSteps.isEmpty) {
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
                        child: Text('No setup steps for this game yet.',
                            style: AppTextStyle.helper(),
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ],
              );
            }
            final steps = guide.setupSteps
              ..sort((a, b) => a.order.compareTo(b.order));
            final current = steps[_step];

            return Column(
              children: [
                _Header(
                  onBack: () => context.canPop()
                      ? context.pop()
                      : context.go('/game/${widget.gameId}'),
                ),
                Expanded(
                  child: _StepView(
                    step: current,
                    stepIndex: _step,
                    totalSteps: steps.length,
                    checked: _checked,
                    onCheck: (key, v) => setState(() {
                      if (v) {
                        _checked.add(key);
                      } else {
                        _checked.remove(key);
                      }
                    }),
                  ),
                ),
                _BottomBar(
                  isFirst: _step == 0,
                  isLast: _step == steps.length - 1,
                  onBack: () {
                    if (_step > 0) setState(() => _step--);
                  },
                  onNext: () async {
                    if (_step < steps.length - 1) {
                      setState(() => _step++);
                    } else {
                      await ref
                          .read(progressNotifierProvider)
                          .markComplete(
                              widget.gameId, GuideSection.setup);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Setup marked complete.')),
                      );
                      context.go('/game/${widget.gameId}/learn');
                    }
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
              child: Text(AppStrings.setupGuide,
                  style: AppTextStyle.cardTitle()
                      .copyWith(fontSize: 17.sp, fontWeight: FontWeight.w700)),
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

// ─── Step body ──────────────────────────────────────────────────────────

class _StepView extends StatelessWidget {
  const _StepView({
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.checked,
    required this.onCheck,
  });

  final GuideStepEntity step;
  final int stepIndex;
  final int totalSteps;
  final Set<String> checked;
  final void Function(String key, bool checked) onCheck;

  @override
  Widget build(BuildContext context) {
    final overallPct = (stepIndex + 1) / totalSteps;
    final overallPctLabel = '${(overallPct * 100).round()}%';

    return ListView(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal, 18.h, AppSpacing.screenHorizontal, 20.h),
      children: [
        // Progress header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SETUP GUIDE',
              style: AppTextStyle.label(color: AppColors.primaryGold)
                  .copyWith(letterSpacing: 1.5, fontSize: 11.sp),
            ),
            Text('Step ${stepIndex + 1} of $totalSteps',
                style: AppTextStyle.helper()),
          ],
        ),
        SizedBox(height: 10.h),
        BmProgressBar(value: overallPct, height: 6.h),
        SizedBox(height: 20.h),
        // Step title
        Text(
          step.title,
          style: AppTextStyle.largeTitle().copyWith(
              fontSize: 26.sp, fontWeight: FontWeight.w800, height: 34 / 26),
        ),
        // Illustration
        if (step.images.isNotEmpty) ...[
          SizedBox(height: 18.h),
          BmConceptImageRow(images: step.images),
        ],
        SizedBox(height: 16.h),
        // Body text
        Text(
          step.body,
          style: AppTextStyle.body(color: AppColors.textSecondary),
        ),
        // Pro tip
        if (step.tip != null) ...[
          SizedBox(height: 18.h),
          BmInfoBox(
            label: AppStrings.proTip,
            body: step.tip!,
            tone: BmInfoTone.tip,
          ),
        ],
        // Warning
        if (step.warning != null) ...[
          SizedBox(height: 14.h),
          BmInfoBox(
            label: AppStrings.warning,
            body: step.warning!,
            tone: BmInfoTone.warning,
          ),
        ],
        // Per-step checklist items (kept when present in data)
        if (step.checklist.isNotEmpty) ...[
          SizedBox(height: 18.h),
          Container(
            padding: EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.surfaceDefault,
              borderRadius:
                  BorderRadius.circular(AppSpacing.smallCardRadius),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('For this step',
                    style: AppTextStyle.cardTitle()
                        .copyWith(fontWeight: FontWeight.w700)),
                SizedBox(height: 4.h),
                for (final item in step.checklist)
                  BmChecklistRow(
                    label: item,
                    checked: checked.contains(item),
                    onChanged: (v) => onCheck(item, v),
                  ),
              ],
            ),
          ),
        ],
        SizedBox(height: 18.h),
        // Overall setup progress card
        _OverallProgressCard(
          completed: stepIndex + 1,
          total: totalSteps,
          percentLabel: overallPctLabel,
          percent: overallPct,
        ),
      ],
    );
  }
}

class _OverallProgressCard extends StatelessWidget {
  const _OverallProgressCard({
    required this.completed,
    required this.total,
    required this.percentLabel,
    required this.percent,
  });
  final int completed;
  final int total;
  final String percentLabel;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceDefault,
        borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHECKLIST',
            style: AppTextStyle.label(color: AppColors.textSecondary)
                .copyWith(letterSpacing: 1.2, fontSize: 11.sp),
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '$completed of $total setup steps complete',
                  style: AppTextStyle.cardTitle()
                      .copyWith(fontWeight: FontWeight.w700, fontSize: 15.sp),
                ),
              ),
              Text(
                percentLabel,
                style: AppTextStyle.bodyStrong(color: AppColors.success)
                    .copyWith(fontSize: 17.sp, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          BmProgressBar(value: percent, color: AppColors.success, height: 6.h),
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
                label:
                    isLast ? 'Finish setup' : '${AppStrings.next} →',
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
