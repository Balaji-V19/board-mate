import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_strings.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../core/widgets/bm_badge.dart';
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
      appBar: AppBar(
        title: Text(AppStrings.setupGuide),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go('/game/${widget.gameId}'),
        ),
      ),
      body: state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (m) => Center(
          child:
              Text(m, style: AppTextStyle.helper(color: AppColors.error)),
        ),
        loaded: (guide) {
          if (guide.setupSteps.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(40.w),
                child: Text('No setup steps for this game yet.',
                    style: AppTextStyle.helper(),
                    textAlign: TextAlign.center),
              ),
            );
          }
          final steps = guide.setupSteps..sort((a, b) => a.order.compareTo(b.order));
          final current = steps[_step];
          return _StepView(
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
            onBack: () {
              if (_step > 0) setState(() => _step--);
            },
            onNext: () async {
              if (_step < steps.length - 1) {
                setState(() => _step++);
              } else {
                await ref
                    .read(progressNotifierProvider)
                    .markComplete(widget.gameId, GuideSection.setup);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Setup marked complete.')),
                );
                context.go('/game/${widget.gameId}/how-to-play');
              }
            },
            isLast: _step == steps.length - 1,
          );
        },
      ),
    );
  }
}

class _StepView extends StatelessWidget {
  const _StepView({
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.checked,
    required this.onCheck,
    required this.onBack,
    required this.onNext,
    required this.isLast,
  });

  final GuideStepEntity step;
  final int stepIndex;
  final int totalSteps;
  final Set<String> checked;
  final void Function(String key, bool checked) onCheck;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final completedCount = step.checklist.where(checked.contains).length;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal, 8.h, AppSpacing.screenHorizontal, 24.h),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BmBadge(
                    label: 'SETUP GUIDE',
                    tone: BmBadgeTone.primary,
                  ),
                  Text('Step ${stepIndex + 1} of $totalSteps',
                      style: AppTextStyle.helper()),
                ],
              ),
              SizedBox(height: 14.h),
              BmProgressBar(value: (stepIndex + 1) / totalSteps, height: 8.h),
              SizedBox(height: 22.h),
              Text(step.title, style: AppTextStyle.screenTitle()),
              SizedBox(height: 12.h),
              Text(step.body, style: AppTextStyle.body()),
              if (step.images.isNotEmpty) ...[
                SizedBox(height: 18.h),
                BmConceptImageRow(images: step.images),
              ],
              if (step.tip != null) ...[
                SizedBox(height: 20.h),
                BmInfoBox(
                  label: AppStrings.proTip,
                  body: step.tip!,
                  tone: BmInfoTone.tip,
                ),
              ],
              if (step.warning != null) ...[
                SizedBox(height: 16.h),
                BmInfoBox(
                  label: AppStrings.warning,
                  body: step.warning!,
                  tone: BmInfoTone.warning,
                ),
              ],
              if (step.checklist.isNotEmpty) ...[
                SizedBox(height: 20.h),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Checklist',
                              style: AppTextStyle.cardTitle()),
                          Text(
                            '$completedCount of ${step.checklist.length}',
                            style: AppTextStyle.helper(),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      BmProgressBar(
                        value: completedCount / step.checklist.length,
                      ),
                      SizedBox(height: 6.h),
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
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal, 8.h, AppSpacing.screenHorizontal, 16.h),
            child: Row(
              children: [
                Expanded(
                  child: BmButton(
                    label: AppStrings.back,
                    variant: BmButtonVariant.secondary,
                    onPressed: stepIndex == 0 ? null : onBack,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: BmButton(
                    label: isLast ? 'Finish setup' : AppStrings.next,
                    icon: isLast ? Icons.check_rounded : null,
                    onPressed: onNext,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
