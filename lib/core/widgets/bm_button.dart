import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/constants/app_colors.dart';
import '../../config/constants/app_spacing.dart';
import '../../config/constants/app_textstyle.dart';

enum BmButtonVariant { primary, secondary, ghost, destructive }

class BmButton extends StatelessWidget {
  const BmButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = BmButtonVariant.primary,
    this.icon,
    this.leading,
    this.expand = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final BmButtonVariant variant;
  final IconData? icon;

  /// Optional widget rendered to the left of the label instead of [icon].
  /// Useful for brand glyphs that aren't part of the Material icon set
  /// (e.g. the Google "G" logo as an SVG).
  final Widget? leading;

  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final bg = switch (variant) {
      BmButtonVariant.primary => AppColors.primaryGold,
      BmButtonVariant.secondary => AppColors.surfaceDefault,
      BmButtonVariant.ghost => Colors.transparent,
      BmButtonVariant.destructive => AppColors.error.withValues(alpha: 0.08),
    };
    final fg = switch (variant) {
      BmButtonVariant.primary => Colors.white,
      BmButtonVariant.secondary => AppColors.secondaryNavy,
      BmButtonVariant.ghost => AppColors.secondaryNavy,
      BmButtonVariant.destructive => AppColors.error,
    };
    final border = variant == BmButtonVariant.secondary
        ? Border.all(color: AppColors.border, width: 1)
        : null;

    final disabled = onPressed == null || loading;

    final child = Container(
      height: AppSpacing.buttonHeight,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: disabled ? bg.withValues(alpha: 0.55) : bg,
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        border: border,
        boxShadow: variant == BmButtonVariant.primary
            ? [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: loading
          ? SizedBox(
              width: 22.w,
              height: 22.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation(fg),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (leading != null) ...[
                  leading!,
                  SizedBox(width: 10.w),
                ] else if (icon != null) ...[
                  Icon(icon, color: fg, size: 18.sp),
                  SizedBox(width: 8.w),
                ],
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    label,
                    style: AppTextStyle.button(color: fg),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        child: child,
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
