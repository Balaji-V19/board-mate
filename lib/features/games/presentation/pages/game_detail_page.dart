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
    final accent = AppColors.categoryFor(
        game.categories.isEmpty ? '' : game.categories.first);

    final saved = ref.watch(savedGamesNotifierProvider);
    final isSaved = saved.isSaved(game.id);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: false,
          backgroundColor: accent.withValues(alpha: 0.18),
          expandedHeight: 360.h,
          leading: _FrostedIcon(
            icon: Icons.arrow_back_rounded,
            onTap: () =>
                context.canPop() ? context.pop() : context.go('/home'),
          ),
          actions: [
            _FrostedIcon(
              icon: isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              tint: isSaved ? AppColors.primaryGold : null,
              onTap: () => ref
                  .read(savedGamesNotifierProvider)
                  .toggle(game.id),
            ),
            SizedBox(width: 8.w),
            _FrostedIcon(
                icon: Icons.ios_share_rounded, onTap: () {}),
            SizedBox(width: AppSpacing.screenHorizontal),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: accent.withValues(alpha: 0.16),
              alignment: Alignment.center,
              child: game.imageUrl.isEmpty
                  ? Icon(Icons.casino_rounded,
                      color: accent, size: 160.sp)
                  : CachedNetworkImage(
                      imageUrl: game.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorWidget: (_, __, ___) => Icon(Icons.casino_rounded,
                          color: accent, size: 160.sp),
                    ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: Offset(0, -20.h),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28.r),
                  topRight: Radius.circular(28.r),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal, 24.h, AppSpacing.screenHorizontal, 140.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryNavy.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  if (game.categories.isNotEmpty)
                    BmBadge(
                      label: game.categories.first,
                      tone: BmBadgeTone.primary,
                    ),
                  SizedBox(height: 12.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(game.name,
                            style: AppTextStyle.largeTitle()),
                      ),
                      if (game.rating != null)
                        Row(children: [
                          Icon(Icons.star_rounded,
                              color: AppColors.primaryGold, size: 20.sp),
                          SizedBox(width: 4.w),
                          Text(game.rating!.toStringAsFixed(1),
                              style: AppTextStyle.bodyStrong()),
                        ]),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _MetaGrid(game: game),
                  SizedBox(height: 28.h),
                  Text(AppStrings.aboutThisGame,
                      style: AppTextStyle.sectionTitle()),
                  SizedBox(height: 10.h),
                  Text(
                    game.description.isEmpty ? game.objective : game.description,
                    style: AppTextStyle.body(),
                  ),
                  SizedBox(height: 28.h),
                  Text(AppStrings.whatYoullLearn,
                      style: AppTextStyle.sectionTitle()),
                  SizedBox(height: 10.h),
                  _LearnList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaGrid extends StatelessWidget {
  const _MetaGrid({required this.game});
  final BoardGameEntity game;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MetaCell(icon: Icons.people_rounded, label: AppStrings.players, value: game.playerRange)),
        SizedBox(width: 10.w),
        Expanded(child: _MetaCell(icon: Icons.schedule_rounded, label: AppStrings.duration, value: '${game.minutesRange} min')),
        SizedBox(width: 10.w),
        Expanded(child: _MetaCell(icon: Icons.diamond_outlined, label: AppStrings.difficulty, value: game.difficulty)),
      ],
    );
  }
}

class _MetaCell extends StatelessWidget {
  const _MetaCell({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceDefault,
        borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 22.sp),
          SizedBox(height: 8.h),
          Text(value, style: AppTextStyle.bodyStrong(), maxLines: 1),
          SizedBox(height: 2.h),
          Text(label, style: AppTextStyle.helper()),
        ],
      ),
    );
  }
}

class _LearnList extends StatelessWidget {
  static const _items = [
    ('1', 'Game setup', '5 min'),
    ('2', 'How to play', '8 min'),
    ('3', 'Turn flow', '4 min'),
    ('4', 'Quick reference', 'On demand'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (n, title, time) in _items) ...[
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceDefault,
              borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(n,
                      style: AppTextStyle.bodyStrong(
                          color: AppColors.primaryGold)),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(title, style: AppTextStyle.cardTitle()),
                ),
                Text(time, style: AppTextStyle.helper()),
              ],
            ),
          ),
          SizedBox(height: 10.h),
        ],
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Material(
        color: Colors.white.withValues(alpha: 0.85),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 40.w,
            height: 40.w,
            alignment: Alignment.center,
            child: Icon(icon,
                color: tint ?? AppColors.secondaryNavy, size: 20.sp),
          ),
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
        padding: EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal, 8.h, AppSpacing.screenHorizontal, 16.h),
        child: BmButton(
          label: AppStrings.startLearning,
          icon: Icons.arrow_forward_rounded,
          onPressed: () => context.push('/game/$gameId/setup'),
        ),
      ),
    );
  }
}
