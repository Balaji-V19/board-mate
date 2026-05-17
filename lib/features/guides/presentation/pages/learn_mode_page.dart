import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../games/domain/entities/user_progress_entity.dart';
import '../../../games/presentation/providers/games_notifier.dart';
import '../../../games/presentation/providers/progress_notifier.dart';

class LearnModePage extends ConsumerWidget {
  const LearnModePage({super.key, required this.gameId});
  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(gameDetailNotifierProvider(gameId)).state;
    final guide = ref.watch(guideNotifierProvider(gameId)).state;
    final gameName = detail.maybeWhen(
      loaded: (g) => g.name,
      orElse: () => '',
    );
    final hasTurnFlow = guide.maybeWhen(
      loaded: (g) => g.turnFlow.isNotEmpty,
      orElse: () => false,
    );
    final progress = ref.watch(progressNotifierProvider).forGame(gameId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal, 8.h, AppSpacing.screenHorizontal, 32.h),
          children: [
            _Header(gameName: gameName),
            SizedBox(height: 20.h),
            Text(
              'CHOOSE YOUR PATH',
              style: AppTextStyle.label(color: AppColors.primaryGold)
                  .copyWith(letterSpacing: 1.5, fontSize: 11.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'How would you like\nto learn?',
              style: AppTextStyle.largeTitle().copyWith(
                fontSize: 30.sp,
                fontWeight: FontWeight.w800,
                height: 38 / 30,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Pick a learning mode. You can switch any time.',
              style: AppTextStyle.body(color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),
            _ModeCard(
              icon: Icons.settings_rounded,
              iconColor: AppColors.secondaryNavy,
              tint: const Color(0xFFF1E4CC),
              title: 'Setup Guide',
              subtitle: 'Set up the board and player areas',
              duration: '5 min',
              completed:
                  progress?.isCompleted(GuideSection.setup) ?? false,
              onTap: () => context.push('/game/$gameId/setup'),
            ),
            SizedBox(height: 12.h),
            _ModeCard(
              icon: Icons.menu_rounded,
              iconColor: AppColors.info,
              tint: const Color(0xFFD9E2EA),
              title: 'How to Play',
              subtitle: 'Step-by-step rules walkthrough',
              duration: '12 min',
              completed:
                  progress?.isCompleted(GuideSection.howToPlay) ?? false,
              onTap: () => context.push('/game/$gameId/how-to-play'),
            ),
            if (hasTurnFlow) ...[
              SizedBox(height: 12.h),
              _ModeCard(
                icon: Icons.loop_rounded,
                iconColor: AppColors.success,
                tint: const Color(0xFFD7E6D7),
                title: 'Turn Flow',
                subtitle: 'The rhythm of each turn',
                duration: '6 min',
                completed: false,
                onTap: () => context.push('/game/$gameId/turn-flow'),
              ),
            ],
            SizedBox(height: 12.h),
            _ModeCard(
              icon: Icons.auto_awesome_rounded,
              iconColor: AppColors.primaryGold,
              tint: const Color(0xFFF1E4CC),
              title: 'Quick Reference',
              subtitle: 'Cheat sheet for gameplay',
              duration: '2 min',
              completed:
                  progress?.isCompleted(GuideSection.quickReference) ?? false,
              onTap: () => context.push('/game/$gameId/quick-reference'),
            ),
            SizedBox(height: 22.h),
            const _TipBox(),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.gameName});
  final String gameName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconButton(
          icon: Icons.chevron_left_rounded,
          onTap: () => context.canPop()
              ? context.pop()
              : context.go('/home'),
        ),
        Expanded(
          child: Center(
            child: Text(
              gameName,
              style: AppTextStyle.cardTitle().copyWith(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        _IconButton(
          icon: Icons.more_horiz_rounded,
          onTap: () {},
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});
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

// ─── Mode card ───────────────────────────────────────────────────────────

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.iconColor,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.completed,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color tint;
  final String title;
  final String subtitle;
  final String duration;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceDefault,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 26.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyle.cardTitle().copyWith(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: AppTextStyle.helper(
                          color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (completed) ...[
                          Icon(Icons.check_rounded,
                              size: 12.sp,
                              color: AppColors.primaryGold),
                          SizedBox(width: 4.w),
                        ],
                        Text(
                          duration,
                          style: AppTextStyle.label(
                                  color: AppColors.primaryGold)
                              .copyWith(letterSpacing: 0, fontSize: 11.sp),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Icon(Icons.chevron_right_rounded,
                      size: 22.sp, color: AppColors.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tip box ─────────────────────────────────────────────────────────────

class _TipBox extends StatelessWidget {
  const _TipBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.wb_sunny_rounded,
              color: AppColors.primaryGold, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'New here? Start with the Setup Guide for the smoothest learning curve.',
              style: AppTextStyle.helper(color: AppColors.textPrimary)
                  .copyWith(fontSize: 13.sp, height: 18 / 13),
            ),
          ),
        ],
      ),
    );
  }
}
