import 'package:cached_network_image/cached_network_image.dart';
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
import '../../../../core/widgets/bm_die_icon.dart';
import '../../../saved_games/presentation/providers/saved_games_notifier.dart';
import '../../domain/entities/board_game_entity.dart';
import '../providers/games_notifier.dart';

class GameDetailPage extends ConsumerWidget {
  const GameDetailPage({super.key, required this.gameId});
  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameDetailNotifierProvider(gameId)).state;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (g) => _Loaded(game: g),
        error: (msg) => _ErrorView(message: msg),
      ),
      bottomNavigationBar: state.maybeWhen(
        loaded: (_) => GameDetailBottomBar(gameId: gameId),
        orElse: () => null,
      ),
    );
  }
}

class _Loaded extends ConsumerWidget {
  const _Loaded({required this.game});
  final BoardGameEntity game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedGamesNotifierProvider);
    final isSaved = saved.isSaved(game.id);

    return Stack(
      children: [
        // Scrolling content (hero + sheet)
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Hero(game: game, heightFactor: 0.50)),
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: Offset(0, -24.h),
                child: _ContentSheet(game: game),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 120.h)),
          ],
        ),
        // Top action bar — over the hero
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal, vertical: 8.h),
            child: Row(
              children: [
                _FrostedIcon(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => context.canPop()
                      ? context.pop()
                      : context.go('/home'),
                ),
                const Spacer(),
                _FrostedIcon(
                  icon: Icons.ios_share_rounded,
                  onTap: () {},
                ),
                SizedBox(width: 10.w),
                _FrostedIcon(
                  icon: isSaved
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  tint: isSaved ? AppColors.primaryGold : null,
                  onTap: () =>
                      ref.read(savedGamesNotifierProvider).toggle(game.id),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Hero ────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.game, required this.heightFactor});
  final BoardGameEntity game;
  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final accent = AppColors.categoryFor(
        game.categories.isEmpty ? '' : game.categories.first);
    final hasImage = game.imageUrl.isNotEmpty;

    return SizedBox(
      height: size.height * heightFactor,
      width: double.infinity,
      child: hasImage
          ? _PhotoHero(game: game, accent: accent)
          : _IconHero(game: game, accent: accent),
    );
  }
}

/// Full-bleed cover photo with the accent colour as a placeholder/background.
class _PhotoHero extends StatelessWidget {
  const _PhotoHero({required this.game, required this.accent});
  final BoardGameEntity game;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: accent.withValues(alpha: 0.16),
      child: CachedNetworkImage(
        imageUrl: game.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, __) => const SizedBox.shrink(),
        errorWidget: (_, __, ___) => _IconHero(game: game, accent: accent),
      ),
    );
  }
}

/// Splash-style fallback for games without an image: soft ivory background,
/// concentric circles in the category accent, and a saturated category-tinted
/// BoardMate die in the centre. So each game shows the same brand mark in a
/// different colour.
class _IconHero extends StatelessWidget {
  const _IconHero({required this.game, required this.accent});
  final BoardGameEntity game;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  accent.withValues(alpha: 0.16),
                  accent.withValues(alpha: 0.08),
                  AppColors.background,
                ],
                stops: const [0, 0.4, 1],
              ),
            ),
          ),
        ),
        // Overlapping circle rings
        Positioned(
          top: -40.h,
          right: -40.w,
          child: _ring(240.w, accent.withValues(alpha: 0.20)),
        ),
        Positioned(
          top: 40.h,
          right: -100.w,
          child: _ring(200.w, accent.withValues(alpha: 0.14)),
        ),
        Positioned(
          top: 80.h,
          left: -70.w,
          child: _ring(220.w, accent.withValues(alpha: 0.18)),
        ),
        Positioned(
          bottom: -50.h,
          left: 60.w,
          child: _ring(160.w, accent.withValues(alpha: 0.12)),
        ),
        // Centered die in the category colour
        Padding(
          padding: EdgeInsets.only(top: 30.h),
          child: BmDieIcon(
            color: accent,
            size: 160.sp,
            withShadow: true,
          ),
        ),
      ],
    );
  }

  Widget _ring(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ── Content sheet ────────────────────────────────────────────────────────

class _ContentSheet extends StatelessWidget {
  const _ContentSheet({required this.game});
  final BoardGameEntity game;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal, 14.h, AppSpacing.screenHorizontal, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.secondaryNavy.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          SizedBox(height: 18.h),
          if (game.categories.isNotEmpty)
            BmBadge(
                label: game.categories.first, tone: BmBadgeTone.primary),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  game.name,
                  style: AppTextStyle.largeTitle().copyWith(
                      fontSize: 32.sp, fontWeight: FontWeight.w800),
                  maxLines: 2,
                ),
              ),
              if (game.rating != null)
                Row(children: [
                  Icon(Icons.star_rounded,
                      color: AppColors.primaryGold, size: 22.sp),
                  SizedBox(width: 4.w),
                  Text(game.rating!.toStringAsFixed(1),
                      style: AppTextStyle.bodyStrong()
                          .copyWith(fontSize: 17.sp)),
                ]),
            ],
          ),
          SizedBox(height: 18.h),
          _MetaRow(game: game),
          SizedBox(height: 24.h),
          Text(AppStrings.aboutThisGame,
              style: AppTextStyle.sectionTitle()
                  .copyWith(fontWeight: FontWeight.w800)),
          SizedBox(height: 10.h),
          Text(
            game.description.isEmpty ? game.objective : game.description,
            style: AppTextStyle.body(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.game});
  final BoardGameEntity game;

  @override
  Widget build(BuildContext context) {
    final duration = game.minMinutes == game.maxMinutes
        ? '${game.minMinutes} min'
        : '${game.minMinutes}-${game.maxMinutes} min';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceDefault,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _MetaCell(
                icon: Icons.groups_rounded,
                iconColor: AppColors.primaryGold,
                value: game.playerRange,
                label: AppStrings.players,
              ),
            ),
            _Divider(),
            Expanded(
              child: _MetaCell(
                icon: Icons.timer_outlined,
                iconColor: AppColors.secondaryNavy,
                value: duration,
                label: AppStrings.duration,
              ),
            ),
            _Divider(),
            Expanded(
              child: _MetaCell(
                icon: Icons.diamond_rounded,
                iconColor: AppColors.primaryGold,
                value: game.difficulty,
                label: AppStrings.difficulty,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      color: AppColors.primaryGold.withValues(alpha: 0.18),
    );
  }
}

class _MetaCell extends StatelessWidget {
  const _MetaCell({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 20.sp),
        SizedBox(height: 6.h),
        Text(
          value,
          style: AppTextStyle.bodyStrong().copyWith(fontSize: 17.sp),
          maxLines: 1,
        ),
        SizedBox(height: 2.h),
        Text(
          label.toUpperCase(),
          style: AppTextStyle.label(color: AppColors.textSecondary)
              .copyWith(letterSpacing: 0.8, fontSize: 11.sp),
        ),
      ],
    );
  }
}

class _FrostedIcon extends StatelessWidget {
  const _FrostedIcon({required this.icon, required this.onTap, this.tint});
  final IconData icon;
  final VoidCallback onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 42.w,
          height: 42.w,
          alignment: Alignment.center,
          child: Icon(icon,
              color: tint ?? AppColors.secondaryNavy, size: 22.sp),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Center(child: Text(message, style: AppTextStyle.body())),
    );
  }
}

class GameDetailBottomBar extends ConsumerWidget {
  const GameDetailBottomBar({super.key, required this.gameId});
  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 8.h,
            AppSpacing.screenHorizontal, 16.h),
        child: BmButton(
          label: AppStrings.startLearning,
          icon: Icons.arrow_forward_rounded,
          onPressed: () => context.push('/game/$gameId/learn'),
        ),
      ),
    );
  }
}
