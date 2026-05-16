import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/constants/app_colors.dart';
import '../../config/constants/app_spacing.dart';
import '../../config/constants/app_textstyle.dart';
import '../../features/games/domain/entities/board_game_entity.dart';

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.game,
    required this.width,
    required this.height,
  });

  final BoardGameEntity game;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.categoryFor(
      game.categories.isEmpty ? '' : game.categories.first,
    );
    // Icon size must be finite; the featured card passes width: infinity, so
    // anchor on height (always finite from our call sites) and clamp.
    final iconSize = (height.isFinite ? height : 80) * 0.45;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: game.imageUrl.isEmpty
          ? Center(
              child:
                  Icon(Icons.casino_rounded, color: accent, size: iconSize),
            )
          : CachedNetworkImage(
              imageUrl: game.imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Center(
                child:
                    Icon(Icons.casino_rounded, color: accent, size: iconSize),
              ),
            ),
    );
  }
}

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
            borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              _Thumbnail(game: game, width: 78.w, height: 88.h),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(game.name,
                        style: AppTextStyle.cardTitle(), maxLines: 1),
                    SizedBox(height: 2.h),
                    Text(
                      '${game.categories.isEmpty ? '' : game.categories.first} · ${game.minPlayers}-${game.maxPlayers} players',
                      style: AppTextStyle.helper(),
                      maxLines: 1,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        _difficultyDot(game.difficulty),
                        SizedBox(width: 6.w),
                        Text(game.difficulty,
                            style: AppTextStyle.helper()),
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
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onFavoriteTap,
                icon: Icon(
                  isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isSaved ? AppColors.primaryGold : AppColors.textSecondary,
                  size: 22.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumbnail(game: game, width: double.infinity, height: 130.h),
                SizedBox(height: 12.h),
                Text(game.name, style: AppTextStyle.cardTitle(), maxLines: 1),
                SizedBox(height: 2.h),
                Text(
                  '${game.minPlayers}-${game.maxPlayers} players · ${_duration(game)}',
                  style: AppTextStyle.helper(),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _difficultyDot(String difficulty) {
  final color = switch (difficulty.toLowerCase()) {
    'easy' => AppColors.success,
    'medium' => AppColors.warning,
    'hard' => AppColors.error,
    _ => AppColors.textSecondary,
  };
  return Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

String _duration(BoardGameEntity g) {
  if (g.minMinutes == g.maxMinutes) return '${g.minMinutes} min';
  return '${g.minMinutes}-${g.maxMinutes} min';
}
