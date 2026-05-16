import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/constants/app_colors.dart';
import '../../config/constants/app_spacing.dart';
import '../../config/constants/app_textstyle.dart';
import '../../features/games/domain/entities/guide_step_entity.dart';

/// Registry of generic game-concept icons. Game guide JSON can reference these
/// keys to attach a visual aid to a step without needing per-game artwork.
///
/// Keep this list short and high-signal. If a guide step needs something not
/// in the registry, use a Material icon name (the widget falls back when the
/// key isn't found) or provide an external `url`.
class _Concept {
  const _Concept(this.icon, this.tint);
  final IconData icon;
  final Color tint;
}

const _registry = <String, _Concept>{
  // dice / chance
  'dice': _Concept(Icons.casino_rounded, AppColors.primaryGold),
  'dice-pair': _Concept(Icons.casino_rounded, AppColors.primaryGold),
  'spinner': _Concept(Icons.refresh_rounded, AppColors.primaryGold),

  // pieces
  'meeple': _Concept(Icons.person_rounded, AppColors.warning),
  'pawn': _Concept(Icons.emoji_people_rounded, AppColors.secondaryNavy),
  'king': _Concept(Icons.workspace_premium_rounded, AppColors.primaryGold),
  'queen': _Concept(Icons.diamond_rounded, AppColors.primaryGold),
  'rook': _Concept(Icons.fort_rounded, AppColors.secondaryNavy),
  'bishop': _Concept(Icons.church_rounded, AppColors.secondaryNavy),
  'knight': _Concept(Icons.shield_rounded, AppColors.secondaryNavy),

  // cards / hands
  'card': _Concept(Icons.style_rounded, AppColors.info),
  'cards': _Concept(Icons.style_rounded, AppColors.info),
  'deck': _Concept(Icons.layers_rounded, AppColors.info),
  'hand': _Concept(Icons.back_hand_rounded, AppColors.info),

  // tiles / board
  'hex': _Concept(Icons.hexagon_outlined, AppColors.success),
  'tile': _Concept(Icons.dashboard_rounded, AppColors.warning),
  'board': _Concept(Icons.grid_4x4_rounded, AppColors.secondaryNavy),
  'grid': _Concept(Icons.grid_on_rounded, AppColors.secondaryNavy),

  // resources / tokens
  'coin': _Concept(Icons.toll_rounded, AppColors.primaryGold),
  'gem': _Concept(Icons.diamond_outlined, AppColors.info),
  'token': _Concept(Icons.adjust_rounded, AppColors.primaryGold),
  'cube': _Concept(Icons.view_in_ar_rounded, AppColors.error),
  'star': _Concept(Icons.star_rounded, AppColors.primaryGold),
  'heart': _Concept(Icons.favorite_rounded, AppColors.error),
  'point': _Concept(Icons.emoji_events_rounded, AppColors.primaryGold),

  // resources (themed)
  'wheat': _Concept(Icons.grass_rounded, AppColors.warning),
  'wood': _Concept(Icons.park_rounded, AppColors.success),
  'sheep': _Concept(Icons.cloud_rounded, AppColors.success),
  'brick': _Concept(Icons.square_rounded, AppColors.error),
  'ore': _Concept(Icons.terrain_rounded, AppColors.secondaryNavy),
  'fish': _Concept(Icons.set_meal_rounded, AppColors.info),
  'bird': _Concept(Icons.flutter_dash_rounded, AppColors.success),

  // buildings
  'house': _Concept(Icons.home_rounded, AppColors.primaryGold),
  'settlement': _Concept(Icons.home_rounded, AppColors.warning),
  'city': _Concept(Icons.location_city_rounded, AppColors.error),
  'castle': _Concept(Icons.castle_rounded, AppColors.primaryGold),

  // transit / map
  'road': _Concept(Icons.timeline_rounded, AppColors.secondaryNavy),
  'route': _Concept(Icons.route_rounded, AppColors.info),
  'train': _Concept(Icons.train_rounded, AppColors.error),
  'compass': _Concept(Icons.explore_rounded, AppColors.info),
  'map': _Concept(Icons.map_rounded, AppColors.info),

  // people / play
  'players': _Concept(Icons.groups_rounded, AppColors.success),
  'team': _Concept(Icons.diversity_3_rounded, AppColors.success),
  'turn': _Concept(Icons.sync_alt_rounded, AppColors.info),
  'whisper': _Concept(Icons.chat_bubble_rounded, AppColors.warning),
  'eye': _Concept(Icons.visibility_rounded, AppColors.info),
  'speech': _Concept(Icons.record_voice_over_rounded, AppColors.warning),

  // flow / state
  'flag': _Concept(Icons.flag_rounded, AppColors.primaryGold),
  'target': _Concept(Icons.crisis_alert_rounded, AppColors.error),
  'check': _Concept(Icons.check_circle_rounded, AppColors.success),
  'warning': _Concept(Icons.warning_amber_rounded, AppColors.warning),
  'clock': _Concept(Icons.schedule_rounded, AppColors.warning),
  'hourglass': _Concept(Icons.hourglass_top_rounded, AppColors.warning),
  'arrow': _Concept(Icons.arrow_forward_rounded, AppColors.info),
};

class BmConceptImage extends StatelessWidget {
  const BmConceptImage({super.key, required this.image, this.size = 160});

  final StepImage image;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hasUrl = image.url != null && image.url!.isNotEmpty;
    final concept = _registry[image.iconKey?.toLowerCase()] ??
        const _Concept(Icons.casino_rounded, AppColors.primaryGold);

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: size.h,
          decoration: BoxDecoration(
            color: concept.tint.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
            border: Border.all(
              color: concept.tint.withValues(alpha: 0.20),
              width: 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          child: hasUrl
              ? CachedNetworkImage(
                  imageUrl: image.url!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorWidget: (_, __, ___) =>
                      Icon(concept.icon, color: concept.tint, size: 64.sp),
                )
              : Icon(concept.icon, color: concept.tint, size: 64.sp),
        ),
        if (image.caption != null && image.caption!.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            image.caption!,
            style: AppTextStyle.helper(),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Horizontal rail for showing 2+ concept images side-by-side.
class BmConceptImageRow extends StatelessWidget {
  const BmConceptImageRow({super.key, required this.images});
  final List<StepImage> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();
    if (images.length == 1) {
      return BmConceptImage(image: images.first);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < images.length; i++) ...[
          Expanded(
            child: BmConceptImage(image: images[i], size: 120),
          ),
          if (i != images.length - 1) SizedBox(width: 10.w),
        ],
      ],
    );
  }
}
