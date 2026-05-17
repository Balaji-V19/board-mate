import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../core/widgets/bm_progress_bar.dart';
import '../../../games/domain/entities/board_game_entity.dart';
import '../../../games/domain/entities/user_progress_entity.dart';

class ContinueLearningCard extends StatelessWidget {
  const ContinueLearningCard({
    super.key,
    required this.game,
    required this.progress,
  });

  final BoardGameEntity game;
  final UserProgressEntity progress;

  @override
  Widget build(BuildContext context) {
    final completed = progress.completedSections.length;
    final nextSection = _nextSection();
    final subtitle = nextSection == null
        ? 'All sections complete'
        : '${nextSection.label} · $completed of 3 sections';
    final route = nextSection == null
        ? '/game/${game.id}'
        : '/game/${game.id}/${nextSection.routeSegment}';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          child: SizedBox(
            height: 138.h,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryNavy,
                    ),
                  ),
                ),
                // Gold half-circle decoration on the right
                Positioned(
                  right: -36.w,
                  top: -22.h,
                  child: Container(
                    width: 150.w,
                    height: 150.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.32),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CONTINUE LEARNING',
                        style: AppTextStyle.label(color: AppColors.primaryGold)
                            .copyWith(letterSpacing: 1.5, fontSize: 11.sp),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.name,
                            style: AppTextStyle.sectionTitle(
                                    color: Colors.white)
                                .copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22.sp),
                            maxLines: 1,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            subtitle,
                            style: AppTextStyle.helper(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 70.w),
                        child: BmProgressBar(
                          value: progress.percent,
                          color: AppColors.primaryGold,
                          background:
                              Colors.white.withValues(alpha: 0.18),
                          height: 6.h,
                        ),
                      ),
                    ],
                  ),
                ),
                // Gold round CTA button
                Positioned(
                  right: 22.w,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 52.w,
                      height: 52.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondaryNavy
                                .withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 26.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  GuideSection? _nextSection() {
    for (final s in GuideSection.values) {
      if (!progress.isCompleted(s)) return s;
    }
    return null;
  }
}
