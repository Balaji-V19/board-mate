import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../games/domain/entities/turn_flow_step_entity.dart';
import '../../../games/presentation/providers/games_notifier.dart';

class TurnFlowPage extends ConsumerStatefulWidget {
  const TurnFlowPage({super.key, required this.gameId});
  final String gameId;

  @override
  ConsumerState<TurnFlowPage> createState() => _TurnFlowPageState();
}

class _TurnFlowPageState extends ConsumerState<TurnFlowPage> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(gameDetailNotifierProvider(widget.gameId)).state;
    final guide = ref.watch(guideNotifierProvider(widget.gameId)).state;
    final gameName = detail.maybeWhen(loaded: (g) => g.name, orElse: () => '');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: guide.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (m) => Center(
              child:
                  Text(m, style: AppTextStyle.helper(color: AppColors.error))),
          loaded: (g) {
            final phases = [...g.turnFlow]
              ..sort((a, b) => a.order.compareTo(b.order));
            if (phases.isEmpty) {
              return Column(
                children: [
                  _Header(
                      onBack: () => context.canPop()
                          ? context.pop()
                          : context.go('/game/${widget.gameId}')),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.w),
                        child: Text(
                          'Turn flow isn\'t available for this game yet.',
                          style: AppTextStyle.helper(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView(
              padding: EdgeInsets.only(bottom: 24.h),
              children: [
                _Header(
                    onBack: () => context.canPop()
                        ? context.pop()
                        : context.go('/game/${widget.gameId}')),
                SizedBox(height: 18.h),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal),
                  child: _TitleBlock(
                      gameName: gameName, phaseCount: phases.length),
                ),
                SizedBox(height: 22.h),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal),
                  child: Column(
                    children: [
                      for (var i = 0; i < phases.length; i++) ...[
                        _PhaseCard(
                          phase: phases[i],
                          isActive: i == _activeIndex,
                          onTap: () => setState(() => _activeIndex = i),
                        ),
                        if (i != phases.length - 1) const _Connector(),
                      ],
                    ],
                  ),
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
              child: Text('Turn Flow',
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

// ─── Title block ────────────────────────────────────────────────────────

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.gameName, required this.phaseCount});
  final String gameName;
  final int phaseCount;

  @override
  Widget build(BuildContext context) {
    final phaseWord = _numberWord(phaseCount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          gameName.isEmpty
              ? 'A TURN IN THIS GAME'
              : 'A TURN IN ${gameName.toUpperCase()}',
          style: AppTextStyle.label(color: AppColors.primaryGold)
              .copyWith(letterSpacing: 1.5, fontSize: 11.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          'Every turn has\n$phaseWord phase${phaseCount == 1 ? '' : 's'}',
          style: AppTextStyle.largeTitle().copyWith(
              fontSize: 30.sp,
              fontWeight: FontWeight.w800,
              height: 38 / 30),
        ),
        SizedBox(height: 10.h),
        Text(
          'Tap a phase to see what happens.',
          style: AppTextStyle.body(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  String _numberWord(int n) {
    const words = [
      '',
      'one',
      'two',
      'three',
      'four',
      'five',
      'six',
      'seven',
      'eight',
    ];
    return n >= 1 && n < words.length ? words[n] : '$n';
  }
}

// ─── Phase card ────────────────────────────────────────────────────────

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({
    required this.phase,
    required this.isActive,
    required this.onTap,
  });

  final TurnFlowStepEntity phase;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(phase.colorKey);
    final iconData = _iconFor(phase.iconKey);

    return Material(
      color: AppColors.surfaceDefault,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isActive
                  ? AppColors.primaryGold
                  : AppColors.border,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Number circle
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${phase.order}',
                      style: AppTextStyle.cardTitle(color: Colors.white)
                          .copyWith(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w800),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        phase.description,
                        style: AppTextStyle.body(
                                color: AppColors.textSecondary)
                            .copyWith(fontSize: 14.sp, height: 20 / 14),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  // Small icon tile
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    alignment: Alignment.center,
                    child:
                        Icon(iconData, color: accent, size: 18.sp),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      phase.name,
                      style: AppTextStyle.largeTitle().copyWith(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isActive) const _NowPill(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NowPill extends StatelessWidget {
  const _NowPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primaryGold,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        'NOW',
        style: AppTextStyle.label(color: Colors.white)
            .copyWith(letterSpacing: 1.2, fontSize: 11.sp),
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Center(
        child: Container(
          width: 1,
          height: 18.h,
          color: AppColors.secondaryNavy.withValues(alpha: 0.18),
        ),
      ),
    );
  }
}

// ─── Color & icon mapping helpers ────────────────────────────────────────

Color _accentFor(String? colorKey) {
  switch (colorKey?.toLowerCase()) {
    case 'primary':
      return AppColors.primaryGold;
    case 'info':
      return AppColors.info;
    case 'success':
      return AppColors.success;
    case 'warning':
      return AppColors.warning;
    case 'error':
      return AppColors.error;
    default:
      return AppColors.primaryGold;
  }
}

IconData _iconFor(String? iconKey) {
  switch (iconKey?.toLowerCase()) {
    case 'dice':
      return Icons.casino_rounded;
    case 'swap':
      return Icons.swap_horiz_rounded;
    case 'hammer':
      return Icons.build_rounded;
    case 'tile':
      return Icons.dashboard_rounded;
    case 'route':
      return Icons.route_rounded;
    case 'meeple':
      return Icons.person_rounded;
    case 'hand':
      return Icons.back_hand_rounded;
    case 'cards':
      return Icons.style_rounded;
    case 'warning':
      return Icons.warning_amber_rounded;
    case 'board':
      return Icons.grid_4x4_rounded;
    case 'star':
      return Icons.star_rounded;
    case 'check':
      return Icons.check_circle_rounded;
    case 'arrow':
      return Icons.arrow_forward_rounded;
    default:
      return Icons.bolt_rounded;
  }
}
