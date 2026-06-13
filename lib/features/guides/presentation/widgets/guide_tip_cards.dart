import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_textstyle.dart';

/// Pro tip styled as a soft gold-tinted pill with the lightbulb icon and an
/// inline "Pro tip" label that flows straight into the body text. Used on
/// guide screens to set the helpful asides apart from regular paragraphs
/// without resorting to a louder bordered "info box".
class ProTipCard extends StatelessWidget {
  const ProTipCard({super.key, required this.tip});
  final String tip;

  @override
  Widget build(BuildContext context) {
    final normalizedTip = _normalizeCalloutText(tip);
    if (normalizedTip == null) return const SizedBox.shrink();
    return _InlineCalloutCard(
      label: 'Pro tip',
      body: normalizedTip,
      icon: Icons.tips_and_updates_rounded,
      accent: AppColors.primaryGold,
    );
  }
}

/// "Watch out" callout — same visual shape as [ProTipCard] but in warning
/// amber. Replaces the heavier `BmInfoBox(tone: warning)` on guide screens so
/// the warm-tone vocabulary stays consistent across Pro Tips, warnings, and
/// the rest of the page.
class WatchOutCard extends StatelessWidget {
  const WatchOutCard({super.key, required this.body});
  final String body;

  @override
  Widget build(BuildContext context) {
    final normalizedBody = _normalizeCalloutText(body);
    if (normalizedBody == null) return const SizedBox.shrink();
    return _InlineCalloutCard(
      label: 'Watch out',
      body: normalizedBody,
      icon: Icons.report_problem_rounded,
      accent: AppColors.warning,
    );
  }
}

String? _normalizeCalloutText(String? raw) {
  final text = raw?.trim();
  if (text == null || text.isEmpty) return null;
  final lowered = text.toLowerCase();
  if (lowered == 'null' || lowered == 'n/a' || lowered == 'na') return null;
  return text;
}

class _InlineCalloutCard extends StatelessWidget {
  const _InlineCalloutCard({
    required this.label,
    required this.body,
    required this.icon,
    required this.accent,
  });
  final String label;
  final String body;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final text = AppTextStyle.body().copyWith(
      fontSize: 14.sp,
      height: 20 / 14,
      color: AppColors.textPrimary,
    );
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            // Nudges the icon to align with the cap height of the label.
            padding: EdgeInsets.only(top: 1.h),
            child: Icon(icon, size: 20.sp, color: accent),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: text,
                children: [
                  TextSpan(
                    text: '$label  ',
                    style: text.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  TextSpan(text: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
