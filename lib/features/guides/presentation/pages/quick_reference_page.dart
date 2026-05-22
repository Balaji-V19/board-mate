import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../core/widgets/bm_accordion.dart';
import '../../../../core/widgets/bm_button.dart';
import '../../../games/domain/entities/game_guide_entity.dart';
import '../../../games/domain/entities/quick_reference_entity.dart';
import '../../../games/domain/entities/scoring_guide_entity.dart';
import '../../../games/domain/entities/user_progress_entity.dart';
import '../../../games/presentation/providers/games_notifier.dart';
import '../../../games/presentation/providers/progress_notifier.dart';
import '../../../mascot/domain/entities/mascot_mood.dart';
import '../../../mascot/presentation/widgets/mascot_celebration.dart';
import '../../../saved_games/presentation/providers/saved_games_notifier.dart';
import '../widgets/mascot_speech_bubble.dart';

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
    final detail = ref.watch(gameDetailNotifierProvider(widget.gameId)).state;
    final progress =
        ref.watch(progressNotifierProvider).forGame(widget.gameId);
    final saved = ref.watch(savedGamesNotifierProvider);
    final isSaved = saved.isSaved(widget.gameId);
    final alreadyComplete =
        progress?.isCompleted(GuideSection.quickReference) ?? false;
    final gameName =
        detail.maybeWhen(loaded: (g) => g.name, orElse: () => '');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go('/game/${widget.gameId}/learn'),
            ),
            Expanded(
              child: state.when(
                initial: () => const SizedBox.shrink(),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (m) => Center(
                    child: Text(m,
                        style:
                            AppTextStyle.helper(color: AppColors.error))),
                loaded: (guide) {
                  final emptyContent = guide.quickReference.sections.isEmpty &&
                      guide.faq.isEmpty &&
                      guide.commonMistakes.isEmpty;
                  if (emptyContent) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.w),
                        child: Text('No quick reference available yet.',
                            style: AppTextStyle.helper(),
                            textAlign: TextAlign.center),
                      ),
                    );
                  }
                  return _Body(
                    gameId: widget.gameId,
                    gameName: gameName,
                    isSaved: isSaved,
                    onToggleSaved: () =>
                        ref.read(savedGamesNotifierProvider).toggle(widget.gameId),
                    guide: guide,
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 8.h,
                    AppSpacing.screenHorizontal, 14.h),
                child: BmButton(
                  label: alreadyComplete ? 'Marked complete' : 'Finish learning',
                  icon: Icons.check_rounded,
                  onPressed: alreadyComplete
                      ? null
                      : () async {
                          await ref
                              .read(progressNotifierProvider)
                              .markComplete(widget.gameId,
                                  GuideSection.quickReference);
                          if (!context.mounted) return;
                          await showMascotCelebration(
                            context,
                            title: 'All sections complete!',
                            subtitle:
                                'You\'re fully prepped to teach this one. Gather the table.',
                          );
                          if (!context.mounted) return;
                          context.go('/game/${widget.gameId}/learn');
                        },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 8.h,
          AppSpacing.screenHorizontal, 0),
      child: Row(
        children: [
          _RoundIconButton(
              icon: Icons.chevron_left_rounded, onTap: onBack),
          Expanded(
            child: Center(
              child: Text('Quick Reference',
                  style: AppTextStyle.cardTitle().copyWith(
                      fontSize: 17.sp, fontWeight: FontWeight.w700)),
            ),
          ),
          // Counter-balance so the title stays centered now that the
          // mascot has moved into the body as a prominent hero.
          SizedBox(width: 42.w),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
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
          child: Icon(icon, color: AppColors.secondaryNavy, size: 22.sp),
        ),
      ),
    );
  }
}

// ─── Body ───────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({
    required this.gameId,
    required this.gameName,
    required this.isSaved,
    required this.onToggleSaved,
    required this.guide,
  });

  final String gameId;
  final String gameName;
  final bool isSaved;
  final VoidCallback onToggleSaved;
  final GameGuideEntity guide;

  @override
  Widget build(BuildContext context) {
    final bubbleMessage = gameName.isEmpty
        ? 'All the rules, scoring, and gotchas — one screen for the table.'
        : 'Your $gameName cheat sheet — rules, scoring, and gotchas, '
            'all in one screen. Bookmark for game night.';
    return ListView(
      padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 14.h,
          AppSpacing.screenHorizontal, 24.h),
      children: [
        _TitleBlock(
          gameName: gameName,
          isSaved: isSaved,
          onToggleSaved: onToggleSaved,
        ),
        SizedBox(height: 18.h),
        // Hero mascot + speech bubble — prominent at the top of the body so
        // the page feels like the mascot is presenting the cheat sheet.
        MascotSpeechBubble(
          mood: MascotMood.curious,
          message: bubbleMessage,
          mascotSize: 170,
        ),
        SizedBox(height: 26.h),
        for (final section in guide.quickReference.sections) ...[
          _RefSection(section: section),
          SizedBox(height: 20.h),
        ],
        if (guide.scoring.hasFixedTarget) ...[
          Text(
            'Victory points',
            style: AppTextStyle.sectionTitle()
                .copyWith(fontWeight: FontWeight.w800, fontSize: 20.sp),
          ),
          SizedBox(height: 12.h),
          _VictoryPointsCard(scoring: guide.scoring),
          SizedBox(height: 22.h),
        ],
        if (guide.commonMistakes.isNotEmpty) ...[
          Text(
            'Common mistakes',
            style: AppTextStyle.sectionTitle()
                .copyWith(fontWeight: FontWeight.w800, fontSize: 20.sp),
          ),
          SizedBox(height: 12.h),
          for (final m in guide.commonMistakes)
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
                  Text(m.title,
                      style: AppTextStyle.cardTitle()
                          .copyWith(fontWeight: FontWeight.w700)),
                  SizedBox(height: 4.h),
                  Text(m.body,
                      style: AppTextStyle.body(
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
          SizedBox(height: 12.h),
        ],
        if (guide.faq.isNotEmpty) ...[
          Text(
            'FAQ',
            style: AppTextStyle.sectionTitle()
                .copyWith(fontWeight: FontWeight.w800, fontSize: 20.sp),
          ),
          SizedBox(height: 12.h),
          for (final f in guide.faq)
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: BmAccordion(
                title: f.question,
                child: Text(f.answer, style: AppTextStyle.body()),
              ),
            ),
          SizedBox(height: 12.h),
        ],
        const _TipBox(),
      ],
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({
    required this.gameName,
    required this.isSaved,
    required this.onToggleSaved,
  });
  final String gameName;
  final bool isSaved;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                gameName.isEmpty ? 'THIS GAME' : gameName.toUpperCase(),
                style: AppTextStyle.label(color: AppColors.primaryGold)
                    .copyWith(letterSpacing: 1.5, fontSize: 11.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                'Cheat sheet',
                style: AppTextStyle.largeTitle().copyWith(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w800,
                    height: 36 / 30),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        _SavedPill(isSaved: isSaved, onTap: onToggleSaved),
      ],
    );
  }
}

class _SavedPill extends StatelessWidget {
  const _SavedPill({required this.isSaved, required this.onTap});
  final bool isSaved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isSaved ? AppColors.success : AppColors.surfaceDefault;
    final fg = isSaved ? Colors.white : AppColors.secondaryNavy;
    final icon =
        isSaved ? Icons.download_done_rounded : Icons.bookmark_border_rounded;
    final label = isSaved ? 'Saved' : 'Save';

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: isSaved
                ? null
                : Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.sp, color: fg),
              SizedBox(width: 6.w),
              Text(
                label,
                style: AppTextStyle.bodyStrong(color: fg)
                    .copyWith(fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section ────────────────────────────────────────────────────────────

class _RefSection extends StatelessWidget {
  const _RefSection({required this.section});
  final QuickReferenceSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: AppTextStyle.sectionTitle()
              .copyWith(fontWeight: FontWeight.w800, fontSize: 20.sp),
        ),
        if (section.subtitle != null && section.subtitle!.isNotEmpty) ...[
          SizedBox(height: 2.h),
          Text(section.subtitle!, style: AppTextStyle.helper()),
        ],
        SizedBox(height: 12.h),
        // Two-column grid of item cards
        _GridOfItems(items: section.items),
      ],
    );
  }
}

/// Renders items as a 2-column grid where every pair of cards is wrapped in
/// `IntrinsicHeight` so both cards share the height of the taller one. That
/// keeps each row visually balanced even when item text wraps to different
/// numbers of lines.
class _GridOfItems extends StatelessWidget {
  const _GridOfItems({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      final left = items[i];
      final right = i + 1 < items.length ? items[i + 1] : null;
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _ItemCard(text: left)),
              SizedBox(width: 10.w),
              Expanded(
                child: right != null
                    ? _ItemCard(text: right)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
      if (i + 2 < items.length) {
        rows.add(SizedBox(height: 10.h));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    // Try to split "Name: detail" so the name renders bold above the detail.
    final colonIdx = text.indexOf(':');
    final hasSplit = colonIdx > 0 && colonIdx < text.length - 1;
    final name = hasSplit ? text.substring(0, colonIdx).trim() : text;
    final detail = hasSplit ? text.substring(colonIdx + 1).trim() : '';

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceDefault,
        borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: AppTextStyle.cardTitle()
                .copyWith(fontWeight: FontWeight.w700, fontSize: 15.sp),
          ),
          if (detail.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              detail,
              style:
                  AppTextStyle.helper(color: AppColors.textSecondary)
                      .copyWith(fontSize: 13.sp, height: 18 / 13),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Tip box ────────────────────────────────────────────────────────────

class _TipBox extends StatelessWidget {
  const _TipBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.wb_sunny_rounded,
              color: AppColors.primaryGold, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Save this guide for offline access during gameplay.',
              style: AppTextStyle.helper(color: AppColors.textPrimary)
                  .copyWith(fontSize: 13.sp, height: 18 / 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Victory Points highlight ───────────────────────────────────────────

/// Dark navy stat card surfacing the win threshold and per-source point
/// values. Only shown when `scoring.hasFixedTarget` is true.
class _VictoryPointsCard extends StatelessWidget {
  const _VictoryPointsCard({required this.scoring});
  final ScoringGuideEntity scoring;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Container(
        decoration: const BoxDecoration(color: AppColors.secondaryNavy),
        child: Stack(
          children: [
            Positioned(
              right: -50,
              top: -40,
              child: Container(
                width: 200.w,
                height: 200.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.32),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FIRST TO',
                    style: AppTextStyle.label(color: AppColors.primaryGold)
                        .copyWith(letterSpacing: 1.5, fontSize: 11.sp),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${scoring.targetScore}',
                        style: AppTextStyle.largeTitle(color: Colors.white)
                            .copyWith(
                                fontSize: 56.sp,
                                fontWeight: FontWeight.w800,
                                height: 1),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Text(
                            '${scoring.targetUnit}\nwins the game',
                            style: AppTextStyle.body(color: Colors.white)
                                .copyWith(height: 20 / 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (scoring.points.isNotEmpty) ...[
                    SizedBox(height: 18.h),
                    _PointsGrid(items: scoring.points),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointsGrid extends StatelessWidget {
  const _PointsGrid({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      final left = items[i];
      final right = i + 1 < items.length ? items[i + 1] : null;
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _PointEntry(text: left)),
              SizedBox(width: 14.w),
              Expanded(
                child: right == null
                    ? const SizedBox.shrink()
                    : _PointEntry(text: right),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

class _PointEntry extends StatelessWidget {
  const _PointEntry({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final colon = text.indexOf(':');
    final hasSplit = colon > 0 && colon < text.length - 1;
    final name = hasSplit ? text.substring(0, colon).trim() : text;
    final value = hasSplit ? text.substring(colon + 1).trim() : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            name,
            style: AppTextStyle.helper(color: Colors.white)
                .copyWith(fontSize: 13.sp),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (value.isNotEmpty) ...[
          SizedBox(width: 6.w),
          Text(
            value,
            style: AppTextStyle.bodyStrong(color: AppColors.primaryGold)
                .copyWith(fontSize: 13.sp),
          ),
        ],
      ],
    );
  }
}
