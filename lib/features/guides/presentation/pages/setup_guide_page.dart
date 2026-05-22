import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../../core/widgets/bm_progress_bar.dart';
import '../../../games/domain/entities/guide_step_entity.dart';
import '../../../games/domain/entities/user_progress_entity.dart';
import '../../../games/presentation/providers/games_notifier.dart';
import '../../../games/presentation/providers/progress_notifier.dart';
import '../../../mascot/domain/entities/mascot_mood.dart';
import '../../../mascot/presentation/widgets/mascot_celebration.dart';
import '../widgets/guide_tip_cards.dart';
import '../widgets/mascot_speech_bubble.dart';
import '../widgets/step_element_card.dart';

class SetupGuidePage extends ConsumerStatefulWidget {
  const SetupGuidePage({super.key, required this.gameId});
  final String gameId;

  @override
  ConsumerState<SetupGuidePage> createState() => _SetupGuidePageState();
}

class _SetupGuidePageState extends ConsumerState<SetupGuidePage> {
  int _step = 0;
  final Set<String> _checked = {};

  /// The element the mascot is currently explaining. Null means the bubble
  /// shows the step's default body text.
  StepElement? _activeElement;
  Timer? _resetTimer;

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

  void _onElementTap(StepElement element) {
    HapticFeedback.lightImpact();
    setState(() => _activeElement = element);
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _activeElement = null);
    });
  }

  void _resetMascot() {
    _resetTimer?.cancel();
    if (_activeElement != null) {
      setState(() => _activeElement = null);
    }
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  static MascotMood _moodFromKey(String? key) {
    switch (key) {
      case 'welcome':
        return MascotMood.welcome;
      case 'thinking':
        return MascotMood.thinking;
      case 'teaching':
        return MascotMood.teaching;
      case 'curious':
        return MascotMood.curious;
      case 'celebrating':
        return MascotMood.celebrating;
      case 'reading':
      default:
        return MascotMood.reading;
    }
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
                    activeElement: _activeElement,
                    bubbleMood: _moodFromKey(
                      _activeElement?.moodKey ?? 'reading',
                    ),
                    onElementTap: _onElementTap,
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
                    if (_step > 0) {
                      _resetMascot();
                      setState(() => _step--);
                    }
                  },
                  onNext: () async {
                    if (_step < steps.length - 1) {
                      _resetMascot();
                      setState(() => _step++);
                    } else {
                      await ref
                          .read(progressNotifierProvider)
                          .markComplete(
                              widget.gameId, GuideSection.setup);
                      if (!context.mounted) return;
                      await showMascotCelebration(
                        context,
                        title: 'Setup complete!',
                        subtitle:
                            'You\'ve got the table ready. Time to dive into the rules.',
                      );
                      if (!context.mounted) return;
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
          // Keeps the title centered now that the mascot has moved into the
          // content area below.
          SizedBox(width: 42.w),
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
    required this.activeElement,
    required this.bubbleMood,
    required this.onElementTap,
    required this.onCheck,
  });

  final GuideStepEntity step;
  final int stepIndex;
  final int totalSteps;
  final Set<String> checked;
  final StepElement? activeElement;
  final MascotMood bubbleMood;
  final ValueChanged<StepElement> onElementTap;
  final void Function(String key, bool checked) onCheck;

  @override
  Widget build(BuildContext context) {
    final overallPct = (stepIndex + 1) / totalSteps;
    final overallPctLabel = '${(overallPct * 100).round()}%';
    final bubbleMessage = activeElement?.message ?? step.body;

    return ListView(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal, 14.h, AppSpacing.screenHorizontal, 24.h),
      children: [
        // ─── Step header: counter + step title + progress ────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'STEP ${stepIndex + 1} OF $totalSteps',
              style: AppTextStyle.label(color: AppColors.primaryGold)
                  .copyWith(letterSpacing: 1.5, fontSize: 11.sp),
            ),
            Text(
              overallPctLabel,
              style: AppTextStyle.bodyStrong(color: AppColors.success)
                  .copyWith(fontSize: 13.sp, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          step.title,
          style: AppTextStyle.largeTitle().copyWith(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            height: 28 / 22,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 12.h),
        BmProgressBar(value: overallPct, height: 6.h),
        SizedBox(height: 18.h),

        // ─── Mascot + speech bubble (typewriter-driven) ──────────────────
        // The bubble is the *only* place the step's body lives now — no
        // duplicate paragraph below. Tapping an element swaps the bubble
        // text to that element's message; the typewriter restarts.
        MascotSpeechBubble(
          mood: bubbleMood,
          message: bubbleMessage,
          mascotSize: 170,
        ),
        SizedBox(height: 16.h),

        // ─── Interactive element strip ───────────────────────────────────
        if (step.elements.isNotEmpty) ...[
          SizedBox(
            height: 124.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: step.elements.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (_, i) {
                final e = step.elements[i];
                return StepElementCard(
                  element: e,
                  selected: identical(activeElement, e),
                  onTap: () => onElementTap(e),
                );
              },
            ),
          ),
          SizedBox(height: 22.h),
        ],

        // ─── Supporting illustration ─────────────────────────────────────
        // The image is taller now (180h) so the natural ~2:1 aspect ratio
        // accommodates typical 3:2 photos without an awkward panoramic
        // crop. Keeps the original photoKey/url so the authored visual is
        // preserved; falls back to the icon tile if the photo can't load.
        if (step.images.isNotEmpty) ...[
          if (step.images.length == 1)
            BmConceptImage(image: step.images.first, size: 180)
          else
            BmConceptImageRow(images: step.images),
          SizedBox(height: 28.h),
        ],

        // ─── Pro tip + Watch out ─ shared inline-callout styling ─────────
        if (step.tip != null) ...[
          ProTipCard(tip: step.tip!),
          SizedBox(height: 18.h),
        ],

        if (step.warning != null) ...[
          WatchOutCard(body: step.warning!),
          SizedBox(height: 18.h),
        ],

        // ─── Checklist for this step ─────────────────────────────────────
        if (step.checklist.isNotEmpty)
          _SetupChecklistCard(
            items: step.checklist,
            checked: checked,
            onCheck: onCheck,
          ),
      ],
    );
  }
}

/// Self-explanatory checklist card. Replaces the bland "For this step" label
/// with an explicit header (icon + title + one-liner subtitle) so the user
/// immediately knows what the items are for and how to interact with them.
class _SetupChecklistCard extends StatelessWidget {
  const _SetupChecklistCard({
    required this.items,
    required this.checked,
    required this.onCheck,
  });

  final List<String> items;
  final Set<String> checked;
  final void Function(String key, bool checked) onCheck;

  @override
  Widget build(BuildContext context) {
    final doneCount = items.where(checked.contains).length;
    final allDone = doneCount == items.length;
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceDefault,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: allDone
              ? AppColors.success.withValues(alpha: 0.40)
              : AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryNavy.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: icon · title + helper · progress badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  allDone
                      ? Icons.task_alt_rounded
                      : Icons.checklist_rounded,
                  size: 18.sp,
                  color: AppColors.success,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      allDone ? 'Nice — all set!' : 'Quick check',
                      style: AppTextStyle.cardTitle().copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      allDone
                          ? 'You\'ve placed everything for this step.'
                          : 'Tap each box once it\'s on the table.',
                      style: AppTextStyle.helper(
                        color: AppColors.textSecondary,
                      ).copyWith(fontSize: 12.sp, height: 16 / 12),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$doneCount/${items.length}',
                  style: AppTextStyle.label(color: AppColors.success)
                      .copyWith(
                    letterSpacing: 0.2,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          for (final item in items)
            BmChecklistRow(
              label: item,
              checked: checked.contains(item),
              onChanged: (v) => onCheck(item, v),
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
