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
import '../../../games/domain/entities/component_entity.dart';
import '../../../games/domain/entities/guide_step_entity.dart';
import '../../../games/presentation/providers/games_notifier.dart';
import '../../../mascot/domain/entities/mascot_mood.dart';
import '../widgets/mascot_speech_bubble.dart';

/// "What's in the box" — a paginated walk-through of every component. Each
/// page shows one box item with a mascot-led explanation. Mirrors the chrome
/// of `SetupGuidePage` (header + body + bottom CTA) so authors and users
/// experience a consistent step-flow across the guide screens.
class GameElementsPage extends ConsumerStatefulWidget {
  const GameElementsPage({super.key, required this.gameId});
  final String gameId;

  @override
  ConsumerState<GameElementsPage> createState() => _GameElementsPageState();
}

class _GameElementsPageState extends ConsumerState<GameElementsPage> {
  int _page = 0;

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
            child: Text(
              m,
              style: AppTextStyle.helper(color: AppColors.error),
            ),
          ),
          loaded: (guide) {
            final components = guide.components;
            void onBack() {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/game/${widget.gameId}');
              }
            }

            if (components.isEmpty) {
              return Column(
                children: [
                  _Header(onBack: onBack),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.w),
                        child: Text(
                          "This game doesn't list any components yet.",
                          style: AppTextStyle.helper(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            // Clamp the page index if the guide changes underneath us (e.g.
            // hot reload mid-development with a different component count).
            final safePage = _page.clamp(0, components.length - 1);
            final current = components[safePage];

            return Column(
              children: [
                _Header(onBack: onBack),
                Expanded(
                  child: _ComponentPage(
                    component: current,
                    index: safePage,
                    total: components.length,
                  ),
                ),
                _BottomBar(
                  isFirst: safePage == 0,
                  isLast: safePage == components.length - 1,
                  onBack: () {
                    if (safePage > 0) setState(() => _page = safePage - 1);
                  },
                  onNext: () {
                    if (safePage < components.length - 1) {
                      setState(() => _page = safePage + 1);
                    } else {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/game/${widget.gameId}/learn');
                      }
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
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        8.h,
        AppSpacing.screenHorizontal,
        0,
      ),
      child: Row(
        children: [
          _RoundIconButton(
            icon: Icons.chevron_left_rounded,
            onTap: onBack,
          ),
          Expanded(
            child: Center(
              child: Text(
                "What's in the box",
                style: AppTextStyle.cardTitle().copyWith(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
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

// ─── Single-component page body ──────────────────────────────────────────

class _ComponentPage extends StatelessWidget {
  const _ComponentPage({
    required this.component,
    required this.index,
    required this.total,
  });

  final ComponentEntity component;
  final int index;
  final int total;

  String get _bubbleMessage {
    if (component.description.isNotEmpty) {
      return component.description;
    }
    final count = component.count;
    return count == 1
        ? "There's $count ${component.name} in the box."
        : 'There are $count ${component.name} in the box.';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        14.h,
        AppSpacing.screenHorizontal,
        24.h,
      ),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ITEM ${index + 1} OF $total',
              style: AppTextStyle.label(color: AppColors.primaryGold)
                  .copyWith(letterSpacing: 1.5, fontSize: 11.sp),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '×${component.count}',
                style: AppTextStyle.label(color: AppColors.primaryGold)
                    .copyWith(letterSpacing: 0, fontSize: 11.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          component.name,
          style: AppTextStyle.largeTitle().copyWith(
            fontSize: 26.sp,
            fontWeight: FontWeight.w800,
            height: 32 / 26,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 18.h),

        // Mascot on the right, speech bubble on the left.
        MascotSpeechBubble(
          mood: MascotMood.teaching,
          message: _bubbleMessage,
          mascotSize: 160,
          mascotOnRight: true,
        ),

        if (component.hasVisual) ...[
          SizedBox(height: 22.h),
          BmConceptImage(
            image: StepImage(
              iconKey: component.iconKey,
              photoKey: component.photoKey,
              url: component.url,
            ),
            size: 200,
          ),
        ],
      ],
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
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          8.h,
          AppSpacing.screenHorizontal,
          14.h,
        ),
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
                label: isLast ? 'Done' : '${AppStrings.next} →',
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
