import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../core/widgets/bm_concept_image.dart';
import '../../../games/domain/entities/guide_step_entity.dart';

/// A small tappable card representing a game piece in the current setup step.
/// Tap fires [onTap]; [selected] paints a gold ring to mark which element the
/// mascot is currently explaining. Designed to sit in a horizontal scroll
/// strip above the [MascotSpeechBubble].
class StepElementCard extends StatelessWidget {
  const StepElementCard({
    super.key,
    required this.element,
    required this.selected,
    required this.onTap,
  });

  final StepElement element;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageStub = StepImage(
      iconKey: element.iconKey,
      photoKey: element.photoKey,
      url: element.url,
    );
    final ringColor = selected
        ? AppColors.primaryGold
        : AppColors.border;
    final ringWidth = selected ? 2.0 : 1.0;
    final bg = selected
        ? AppColors.primaryGold.withValues(alpha: 0.10)
        : AppColors.surfaceDefault;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: 96.w,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: ringColor, width: ringWidth),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 56.w,
                width: 56.w,
                child: BmConceptImage(image: imageStub, size: 56),
              ),
              SizedBox(height: 8.h),
              Text(
                element.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.bodyStrong().copyWith(
                  fontSize: 12.sp,
                  height: 14 / 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
