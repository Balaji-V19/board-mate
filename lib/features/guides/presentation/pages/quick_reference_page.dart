import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_strings.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../core/widgets/bm_accordion.dart';
import '../../../../core/widgets/bm_button.dart';
import '../../../games/domain/entities/user_progress_entity.dart';
import '../../../games/presentation/providers/games_notifier.dart';
import '../../../games/presentation/providers/progress_notifier.dart';

class QuickReferencePage extends ConsumerStatefulWidget {
  const QuickReferencePage({super.key, required this.gameId});
  final String gameId;

  @override
  ConsumerState<QuickReferencePage> createState() => _QuickReferencePageState();
}

class _QuickReferencePageState extends ConsumerState<QuickReferencePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(progressNotifierProvider)
          .touch(widget.gameId, GuideSection.quickReference);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(guideNotifierProvider(widget.gameId)).state;
    final progress = ref.watch(progressNotifierProvider).forGame(widget.gameId);
    final alreadyComplete =
        progress?.isCompleted(GuideSection.quickReference) ?? false;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.quickReference),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go('/game/${widget.gameId}'),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 8.h,
              AppSpacing.screenHorizontal, 12.h),
          child: BmButton(
            label: alreadyComplete ? 'Marked complete' : 'Finish learning',
            icon: Icons.check_rounded,
            onPressed: alreadyComplete
                ? null
                : () async {
                    await ref.read(progressNotifierProvider).markComplete(
                        widget.gameId, GuideSection.quickReference);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All sections complete!')),
                    );
                    context.go('/home');
                  },
          ),
        ),
      ),
      body: state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (m) => Center(
            child: Text(m,
                style: AppTextStyle.helper(color: AppColors.error))),
        loaded: (guide) {
          final sections = guide.quickReference.sections;
          if (sections.isEmpty &&
              guide.faq.isEmpty &&
              guide.commonMistakes.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(40.w),
                child: Text('No quick reference available yet.',
                    style: AppTextStyle.helper(),
                    textAlign: TextAlign.center),
              ),
            );
          }
          return ListView(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                12.h,
                AppSpacing.screenHorizontal,
                32.h),
            children: [
              for (final section in sections) ...[
                BmAccordion(
                  title: section.title,
                  subtitle: section.subtitle,
                  initiallyExpanded: section == sections.first,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final item in section.items) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 8.h),
                                width: 6.w,
                                height: 6.w,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGold,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                  child: Text(item,
                                      style: AppTextStyle.body())),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
              ],
              if (guide.commonMistakes.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text('Common mistakes', style: AppTextStyle.sectionTitle()),
                SizedBox(height: 10.h),
                for (final m in guide.commonMistakes) ...[
                  Container(
                    margin: EdgeInsets.only(bottom: 10.h),
                    padding: EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.08),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.smallCardRadius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.title, style: AppTextStyle.cardTitle()),
                        SizedBox(height: 4.h),
                        Text(m.body, style: AppTextStyle.body()),
                      ],
                    ),
                  ),
                ],
              ],
              if (guide.faq.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text('FAQ', style: AppTextStyle.sectionTitle()),
                SizedBox(height: 10.h),
                for (final f in guide.faq)
                  Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: BmAccordion(
                      title: f.question,
                      child: Text(f.answer, style: AppTextStyle.body()),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
