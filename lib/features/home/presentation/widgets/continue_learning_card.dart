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
    final accent = AppColors.categoryFor(
      game.categories.isEmpty ? '' : game.categories.first,
    );
    final completed = progress.completedSections.length;
    final nextSection = _nextSection();
    final cta = nextSection == null ? 'Review again' : 'Resume ${nextSection.label.toLowerCase()}';
    final route = nextSection == null
        ? '/game/${game.id}'
        : '/game/${game.id}/${nextSection.routeSegment}';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: AppColors.secondaryNavy,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CONTINUE LEARNING',
                    style: AppTextStyle.label(color: Colors.white70)
                        .copyWith(letterSpacing: 1.2, fontSize: 11.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(game.name,
                      style: AppTextStyle.sectionTitle(color: Colors.white)),
                  SizedBox(height: 4.h),
                  Text(
                    progress.isComplete
                        ? 'All 3 sections complete'
                        : '$completed of 3 sections complete',
                    style: AppTextStyle.helper(color: Colors.white70),
                  ),
                  SizedBox(height: 14.h),
                  BmProgressBar(
                    value: progress.percent,
                    color: accent,
                    background: Colors.white.withValues(alpha: 0.12),
                    height: 8.h,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Text(cta,
                          style: AppTextStyle.bodyStrong(color: Colors.white)),
                      SizedBox(width: 6.w),
                      Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 18.sp),
                    ],
                  ),
                ],
              ),
            ],
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
