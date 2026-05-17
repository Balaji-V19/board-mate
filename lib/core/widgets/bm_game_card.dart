import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/constants/app_colors.dart';
import '../../config/constants/app_spacing.dart';
import '../../config/constants/app_textstyle.dart';
import '../../features/games/domain/entities/board_game_entity.dart';
import 'bm_die_icon.dart';

Color _gameAccent(BoardGameEntity g) => AppColors.categoryFor(
      g.categories.isEmpty ? '' : g.categories.first,
    );

Color _difficultyColor(String difficulty) {
  switch (difficulty.toLowerCase()) {
    case 'easy':
      return AppColors.success;
    case 'medium':
      return AppColors.primaryGold;
    case 'hard':
      return AppColors.error;
    default:
      return AppColors.textSecondary;
  }
}

String _duration(BoardGameEntity g) {
  if (g.minMinutes == g.maxMinutes) return '${g.minMinutes} min';
  return '${g.minMinutes}-${g.maxMinutes} min';
}

/// Thumbnail used in all card variants. Shows `game.imageUrl` when present
/// (with the category icon as a load/error fallback) and falls back to a
/// tinted-icon tile when the game has no image. Passing `double.infinity`
/// for `size` makes the thumbnail expand to its parent's constraints (used
/// inside `AspectRatio` for the featured-card variant).
class _Thumb extends StatelessWidget {
  const _Thumb({required this.game, required this.size, this.radius = 14});
  final BoardGameEntity game;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final accent = _gameAccent(game);
    final hasImage = game.imageUrl.isNotEmpty;
    return Container(
      width: size.isFinite ? size : null,
      height: size.isFinite ? size : null,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: game.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (_, __) => _ThumbIcon(game: game, size: size),
              errorWidget: (_, __, ___) =>
                  _ThumbIcon(game: game, size: size),
            )
          : _ThumbIcon(game: game, size: size),
    );
  }
}

class _ThumbIcon extends StatelessWidget {
  const _ThumbIcon({required this.game, required this.size});
  final BoardGameEntity game;
  final double size;

  @override
  Widget build(BuildContext context) {
    final accent = _gameAccent(game);
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth.isFinite
            ? c.maxWidth
            : (size.isFinite ? size : 80.0);
        final h = c.maxHeight.isFinite
            ? c.maxHeight
            : (size.isFinite ? size : 80.0);
        final dim = w < h ? w : h;
        return Center(
          child: BmDieIcon(
            color: accent,
            size: dim * 0.58,
            withShadow: dim > 70,
          ),
        );
      },
    );
  }
}

// ─── Row card — used in Browse + Saved ───────────────────────────────────

class BmGameCardRow extends StatelessWidget {
  const BmGameCardRow({
    super.key,
    required this.game,
    this.onTap,
    this.onFavoriteTap,
    this.isSaved = false,
  });

  final BoardGameEntity game;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceDefault,
      borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(AppSpacing.smallCardRadius),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Thumb(game: game, size: 78.w),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      game.name,
                      style: AppTextStyle.cardTitle().copyWith(
                          fontWeight: FontWeight.w700, fontSize: 17.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${game.categories.isEmpty ? '' : game.categories.first} · ${game.playerRange} players',
                      style: AppTextStyle.helper(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _difficultyColor(game.difficulty),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          game.difficulty,
                          style: AppTextStyle.helper(
                              color: _difficultyColor(game.difficulty)),
                        ),
                        SizedBox(width: 12.w),
                        Icon(Icons.schedule_rounded,
                            size: 14.sp, color: AppColors.textSecondary),
                        SizedBox(width: 4.w),
                        Text(_duration(game),
                            style: AppTextStyle.helper()),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: onFavoriteTap,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Icon(
                        isSaved
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 20.sp,
                        color: isSaved
                            ? AppColors.primaryGold
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Icon(Icons.chevron_right_rounded,
                        size: 22.sp, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Featured card — used in Home carousel ───────────────────────────────

class BmGameCardFeatured extends StatelessWidget {
  const BmGameCardFeatured({
    super.key,
    required this.game,
    this.onTap,
    this.width = 220,
  });

  final BoardGameEntity game;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width.w,
      child: Material(
        color: AppColors.surfaceDefault,
        borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(AppSpacing.smallCardRadius),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 220 / 130,
                  child: _Thumb(
                    game: game,
                    size: double.infinity,
                    radius: 0,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(game.name,
                          style: AppTextStyle.cardTitle().copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 17.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      SizedBox(height: 2.h),
                      Text(
                        '${game.categories.isEmpty ? '' : game.categories.first} · ${game.playerRange} players',
                        style: AppTextStyle.helper(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Grid card — used in Category Results 2-column grid ──────────────────

class BmGameCardGrid extends StatelessWidget {
  const BmGameCardGrid({
    super.key,
    required this.game,
    this.onTap,
    this.onFavoriteTap,
    this.isSaved = false,
  });

  final BoardGameEntity game;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isSaved;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceDefault,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 170 / 120,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: game.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: game.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  _GridIconBackground(game: game),
                              errorWidget: (_, __, ___) =>
                                  _GridIconBackground(game: game),
                            )
                          : _GridIconBackground(game: game),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _HeartButton(
                        isSaved: isSaved,
                        onTap: onFavoriteTap,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      style: AppTextStyle.cardTitle().copyWith(
                          fontWeight: FontWeight.w700, fontSize: 17.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text('${game.playerRange} players',
                        style: AppTextStyle.helper()),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _difficultyColor(game.difficulty),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          game.difficulty,
                          style: AppTextStyle.helper(
                              color: _difficultyColor(game.difficulty)),
                        ),
                        SizedBox(width: 12.w),
                        Icon(Icons.schedule_rounded,
                            size: 14.sp, color: AppColors.textSecondary),
                        SizedBox(width: 4.w),
                        Text(_duration(game),
                            style: AppTextStyle.helper()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridIconBackground extends StatelessWidget {
  const _GridIconBackground({required this.game});
  final BoardGameEntity game;

  @override
  Widget build(BuildContext context) {
    final accent = _gameAccent(game);
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(color: accent.withValues(alpha: 0.18)),
        ),
        Positioned(
          right: -20,
          bottom: -20,
          child: Container(
            width: 90.w,
            height: 90.w,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Center(
          child: BmDieIcon(color: accent, size: 60.sp),
        ),
      ],
    );
  }
}

class _HeartButton extends StatelessWidget {
  const _HeartButton({required this.isSaved, required this.onTap});
  final bool isSaved;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceDefault,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 32.w,
          height: 32.w,
          child: Icon(
            isSaved
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color:
                isSaved ? AppColors.primaryGold : AppColors.textSecondary,
            size: 16.sp,
          ),
        ),
      ),
    );
  }
}
