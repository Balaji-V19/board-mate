import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../config/constants/app_colors.dart';
import '../../config/constants/app_spacing.dart';
import '../../config/constants/app_textstyle.dart';

/// Full-screen image viewer. Pure static layout — just the app background, a
/// back button, and the image rendered at its full natural aspect ratio via
/// `BoxFit.contain` (no crop, no zoom-to-fill). Wrapped in an
/// [InteractiveViewer] so the user can pinch-zoom if they want a closer look.
class ImageViewerPage extends StatelessWidget {
  const ImageViewerPage({super.key, required this.url});

  /// Absolute image URL. Must be non-empty — the router falls through to the
  /// empty-state when it's not.
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: url.isEmpty
                  ? Center(
                      child: Text(
                        'No image to show.',
                        style: AppTextStyle.helper(),
                      ),
                    )
                  : InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.contain,
                          placeholder: (_, __) => const SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (_, __, ___) => Padding(
                            padding: EdgeInsets.all(24.w),
                            child: Text(
                              "Couldn't load this image.",
                              style: AppTextStyle.helper(
                                  color: AppColors.error),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            Positioned(
              top: 8.h,
              left: AppSpacing.screenHorizontal,
              child: _BackButton(
                onTap: () => context.canPop()
                    ? context.pop()
                    : context.go('/home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
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
          child: Icon(
            Icons.chevron_left_rounded,
            color: AppColors.secondaryNavy,
            size: 22.sp,
          ),
        ),
      ),
    );
  }
}
