import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../core/widgets/bm_button.dart';
import '../../../games/domain/entities/turn_flow_step_entity.dart';
import '../../../games/presentation/providers/games_notifier.dart';
import '../../../mascot/domain/entities/mascot_mood.dart';
import '../../../mascot/presentation/widgets/mascot_celebration.dart';
import '../widgets/mascot_speech_bubble.dart';

class TurnFlowPage extends ConsumerStatefulWidget {
  const TurnFlowPage({super.key, required this.gameId});
  final String gameId;

  @override
  ConsumerState<TurnFlowPage> createState() => _TurnFlowPageState();
}

class _TurnFlowPageState extends ConsumerState<TurnFlowPage> {
  int _activeIndex = 0;

  void _setActive(int i) {
    if (i == _activeIndex) return;
    HapticFeedback.lightImpact();
    setState(() => _activeIndex = i);
  }

  Future<void> _onFinish() async {
    await showMascotCelebration(
      context,
      title: 'Turn flow — got it!',
      subtitle:
          'You know how each turn unfolds. Now you\'re ready to play it out.',
    );
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/game/${widget.gameId}/learn');
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail =
        ref.watch(gameDetailNotifierProvider(widget.gameId)).state;
    final guide = ref.watch(guideNotifierProvider(widget.gameId)).state;
    final gameName =
        detail.maybeWhen(loaded: (g) => g.name, orElse: () => '');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: guide.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (m) => Center(
            child: Text(m,
                style: AppTextStyle.helper(color: AppColors.error)),
          ),
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
                          "Turn flow isn't available for this game yet.",
                          style: AppTextStyle.helper(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            final active = _activeIndex.clamp(0, phases.length - 1);
            final phase = phases[active];
            final accent = _accentFor(phase.colorKey);
            final bubble =
                'Phase ${phase.order} — ${phase.name}. ${phase.description}';
            final upNext = active == phases.length - 1
                ? null
                : phases[active + 1];

            return Column(
              children: [
                _Header(
                  onBack: () => context.canPop()
                      ? context.pop()
                      : context.go('/game/${widget.gameId}'),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontal,
                      14.h,
                      AppSpacing.screenHorizontal,
                      28.h,
                    ),
                    children: [
                      // Section badge
                      Text(
                        gameName.isEmpty
                            ? 'A TURN IN THIS GAME'
                            : 'A TURN IN ${gameName.toUpperCase()}',
                        style: AppTextStyle.label(
                                color: AppColors.primaryGold)
                            .copyWith(
                                letterSpacing: 1.5, fontSize: 11.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Every turn flows in ${phases.length} step${phases.length == 1 ? '' : 's'}.',
                        style: AppTextStyle.largeTitle().copyWith(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          height: 30 / 24,
                        ),
                      ),
                      SizedBox(height: 18.h),
                      // Mascot + speech bubble narrates the active phase.
                      MascotSpeechBubble(
                        mood: MascotMood.thinking,
                        message: bubble,
                        mascotSize: 170,
                      ),
                      SizedBox(height: 22.h),
                      // Stepper — all phases as compact chips
                      _PhaseStepper(
                        phases: phases,
                        activeIndex: active,
                        onTap: _setActive,
                      ),
                      SizedBox(height: 22.h),
                      // Featured showcase for the active phase
                      _PhaseShowcase(
                        phase: phase,
                        total: phases.length,
                        accent: accent,
                        upNext: upNext,
                        onTapUpNext: upNext == null
                            ? null
                            : () => _setActive(active + 1),
                      ),
                      SizedBox(height: 22.h),
                      // Prev / Next controls
                      _PhaseNav(
                        activeIndex: active,
                        total: phases.length,
                        onPrev: () => _setActive(active - 1),
                        onNext: () => _setActive(active + 1),
                        onFinish: _onFinish,
                      ),
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
          // Counter-balance so the title stays centered.
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

// ─── Phase stepper ───────────────────────────────────────────────────────

/// Horizontal row of compact phase chips with thin connectors between them.
/// Active chip swells slightly and adopts its phase accent color.
class _PhaseStepper extends StatelessWidget {
  const _PhaseStepper({
    required this.phases,
    required this.activeIndex,
    required this.onTap,
  });

  final List<TurnFlowStepEntity> phases;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < phases.length; i++) ...[
            Expanded(
              child: _PhaseChip(
                phase: phases[i],
                isActive: i == activeIndex,
                isComplete: i < activeIndex,
                onTap: () => onTap(i),
              ),
            ),
            if (i != phases.length - 1)
              SizedBox(
                width: 12.w,
                child: Center(
                  child: SizedBox(
                    width: 12.w,
                    height: 2.h,
                    child: ColoredBox(
                      color: i < activeIndex
                          ? AppColors.primaryGold
                              .withValues(alpha: 0.55)
                          : AppColors.secondaryNavy
                              .withValues(alpha: 0.16),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({
    required this.phase,
    required this.isActive,
    required this.isComplete,
    required this.onTap,
  });

  final TurnFlowStepEntity phase;
  final bool isActive;
  final bool isComplete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(phase.colorKey);
    final iconData = _iconFor(phase.iconKey);
    final bg = isActive
        ? accent.withValues(alpha: 0.12)
        : AppColors.surfaceDefault;
    final borderColor = isActive
        ? accent
        : (isComplete
            ? accent.withValues(alpha: 0.40)
            : AppColors.border);
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: borderColor,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: isActive
                          ? accent
                          : accent.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      iconData,
                      color: isActive ? Colors.white : accent,
                      size: 18.sp,
                    ),
                  ),
                  if (isComplete && !isActive)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 14.w,
                        height: 14.w,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surfaceDefault,
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child:
                            Icon(Icons.check, color: Colors.white, size: 8.sp),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                phase.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodyStrong(
                  color: isActive ? accent : AppColors.textPrimary,
                ).copyWith(
                  fontSize: 11.sp,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Phase showcase ──────────────────────────────────────────────────────

/// Large card highlighting the currently-active phase: accent-tinted blob,
/// big icon, phase label, name, and a small "Up next" pointer that links to
/// the following phase (or "End of turn" for the last one).
class _PhaseShowcase extends StatelessWidget {
  const _PhaseShowcase({
    required this.phase,
    required this.total,
    required this.accent,
    required this.upNext,
    required this.onTapUpNext,
  });

  final TurnFlowStepEntity phase;
  final int total;
  final Color accent;
  final TurnFlowStepEntity? upNext;
  final VoidCallback? onTapUpNext;

  @override
  Widget build(BuildContext context) {
    final iconData = _iconFor(phase.iconKey);
    return ClipRRect(
      borderRadius: BorderRadius.circular(22.r),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDefault,
          borderRadius: BorderRadius.circular(22.r),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative tinted blob bleeding from top-right corner.
            Positioned(
              top: -40.h,
              right: -40.w,
              child: Container(
                width: 150.w,
                height: 150.w,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PHASE ${phase.order} OF $total',
                    style: AppTextStyle.label(color: accent).copyWith(
                      letterSpacing: 1.5,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Container(
                    width: 76.w,
                    height: 76.w,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(22.r),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(iconData, color: Colors.white, size: 38.sp),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    phase.name,
                    style: AppTextStyle.largeTitle().copyWith(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      height: 32 / 26,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _UpNextRow(
                    upNext: upNext,
                    accent: accent,
                    onTap: onTapUpNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpNextRow extends StatelessWidget {
  const _UpNextRow({
    required this.upNext,
    required this.accent,
    required this.onTap,
  });

  final TurnFlowStepEntity? upNext;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = upNext == null
        ? 'End of turn — next player goes.'
        : 'Up next  ·  ${upNext!.name}';
    final iconData = upNext == null
        ? Icons.flag_rounded
        : _iconFor(upNext!.iconKey);
    final color = upNext == null ? AppColors.success : accent;

    final content = Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: color, size: 16.sp),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              label,
              style: AppTextStyle.bodyStrong(color: color).copyWith(
                fontSize: 13.sp,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onTap != null) ...[
            SizedBox(width: 6.w),
            Icon(Icons.arrow_forward_rounded, color: color, size: 14.sp),
          ],
        ],
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: content,
      ),
    );
  }
}

// ─── Prev / Next nav ─────────────────────────────────────────────────────

class _PhaseNav extends StatelessWidget {
  const _PhaseNav({
    required this.activeIndex,
    required this.total,
    required this.onPrev,
    required this.onNext,
    required this.onFinish,
  });

  final int activeIndex;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  /// Called when the user finishes the last phase ("Done →").
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final isFirst = activeIndex == 0;
    final isLast = activeIndex == total - 1;
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: BmButton(
            label: '‹ Previous',
            variant: BmButtonVariant.secondary,
            onPressed: isFirst ? null : onPrev,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          flex: 7,
          child: BmButton(
            label: isLast ? 'Done' : 'Next phase →',
            icon: isLast ? Icons.check_rounded : null,
            onPressed: isLast ? onFinish : onNext,
          ),
        ),
      ],
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
