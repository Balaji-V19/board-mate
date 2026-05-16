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
      appBar: AppBar(
        title: Text(AppStrings.howToPlay),
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
            child: Text(m,
                style: AppTextStyle.helper(color: AppColors.error))),
        loaded: (guide) {
          if (guide.howToPlaySteps.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(40.w),
                child: Text('No play steps yet for this game.',
                    style: AppTextStyle.helper(),
                    textAlign: TextAlign.center),
              ),
            );
          }
          final chapters = guide.howToPlaySteps
            ..sort((a, b) => a.order.compareTo(b.order));
          final current = chapters[_chapter];

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontal,
                      8.h,
                      AppSpacing.screenHorizontal,
                      24.h),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BmBadge(
                          label:
                              'CHAPTER ${_chapter + 1} OF ${chapters.length}',
                          tone: BmBadgeTone.info,
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    BmProgressBar(
                        value: (_chapter + 1) / chapters.length, height: 8.h),
                    SizedBox(height: 22.h),
                    Text(current.title, style: AppTextStyle.screenTitle()),
                    SizedBox(height: 12.h),
                    Text(current.body, style: AppTextStyle.body()),
                    if (current.images.isNotEmpty) ...[
                      SizedBox(height: 18.h),
                      BmConceptImageRow(images: current.images),
                    ],
                    if (current.rules.isNotEmpty) ...[
                      SizedBox(height: 20.h),
                      for (final rule in current.rules)
                        _NumberedRuleCard(rule: rule),
                    ],
                    if (current.warning != null) ...[
                      SizedBox(height: 14.h),
                      BmInfoBox(
                        label: AppStrings.warning,
                        body: current.warning!,
                        tone: BmInfoTone.warning,
                      ),
                    ],
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontal,
                      8.h,
                      AppSpacing.screenHorizontal,
                      16.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: BmButton(
                          label: AppStrings.back,
                          variant: BmButtonVariant.secondary,
                          onPressed: _chapter == 0
                              ? null
                              : () => setState(() => _chapter--),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: BmButton(
                          label: _chapter == chapters.length - 1
                              ? AppStrings.finish
                              : AppStrings.next,
                          icon: _chapter == chapters.length - 1
                              ? Icons.check_rounded
                              : null,
                          onPressed: () async {
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
                                  content:
                                      Text('How to play marked complete.')),
                            );
                            context.go(
                                '/game/${widget.gameId}/quick-reference');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NumberedRuleCard extends StatelessWidget {
  const _NumberedRuleCard({required this.rule});
  final NumberedRuleEntity rule;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceDefault,
        borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text('${rule.number}',
                style:
                    AppTextStyle.bodyStrong(color: AppColors.primaryGold)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rule.title, style: AppTextStyle.cardTitle()),
                SizedBox(height: 4.h),
                Text(rule.body, style: AppTextStyle.body()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
