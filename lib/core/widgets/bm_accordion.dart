import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/constants/app_colors.dart';
import '../../config/constants/app_spacing.dart';
import '../../config/constants/app_textstyle.dart';

class BmAccordion extends StatefulWidget {
  const BmAccordion({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.initiallyExpanded = false,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final bool initiallyExpanded;
  final Widget? leading;

  @override
  State<BmAccordion> createState() => _BmAccordionState();
}

class _BmAccordionState extends State<BmAccordion> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDefault,
        borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.cardPadding,
                vertical: 14.h,
              ),
              child: Row(
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    SizedBox(width: 12.w),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: AppTextStyle.cardTitle()),
                        if (widget.subtitle != null) ...[
                          SizedBox(height: 2.h),
                          Text(widget.subtitle!,
                              style: AppTextStyle.helper()),
                        ],
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary, size: 24.sp),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState:
                _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(height: 0, width: double.infinity),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.cardPadding,
                0,
                AppSpacing.cardPadding,
                16.h,
              ),
              child: SizedBox(width: double.infinity, child: widget.child),
            ),
          ),
        ],
      ),
    );
  }
}
