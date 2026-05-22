import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_strings.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../core/widgets/bm_button.dart';
import '../../../../core/widgets/bm_concept_image.dart';
import '../../../../core/widgets/bm_progress_bar.dart';
import '../../../games/domain/entities/guide_step_entity.dart';
import '../../../games/domain/entities/user_progress_entity.dart';
import '../../../games/presentation/providers/games_notifier.dart';
import '../../../games/presentation/providers/progress_notifier.dart';
import '../../../mascot/domain/entities/mascot_mood.dart';
import '../../../mascot/presentation/widgets/mascot_celebration.dart';
import '../widgets/guide_tip_cards.dart';
import '../widgets/mascot_speech_bubble.dart';
import '../widgets/reveal_rule_card.dart';

class HowToPlayPage extends ConsumerStatefulWidget {
  const HowToPlayPage({super.key, required this.gameId});
  final String gameId;

  @override
  ConsumerState<HowToPlayPage> createState() => _HowToPlayPageState();
}

class _HowToPlayPageState extends ConsumerState<HowToPlayPage> {
  int _chapter = 0;

  /// Per-chapter set of rule numbers that have been revealed. Reset when the
  /// user navigates between chapters so re-visits feel fresh.
  final Map<int, Set<int>> _revealed = {};

  /// Transient mascot message shown after a rule is revealed; null falls back
  /// to the chapter's default prompt.
  String? _bubbleMessage;
  Timer? _bubbleTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(progressNotifierProvider)
          .touch(widget.gameId, GuideSection.howToPlay);
    });
  }

  void _revealRule(NumberedRuleEntity rule) {
    HapticFeedback.lightImpact();
    setState(() {
      _revealed.putIfAbsent(_chapter, () => <int>{}).add(rule.number);
      _bubbleMessage = 'Rule ${rule.number} — got it. Keep going!';
    });
    _bubbleTimer?.cancel();
    _bubbleTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _bubbleMessage = null);
    });
  }

  void _resetBubble() {
    _bubbleTimer?.cancel();
    if (_bubbleMessage != null) {
      setState(() => _bubbleMessage = null);
    }
  }

  @override
  void dispose() {
    _bubbleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(guideNotifierProvider(widget.gameId)).state;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (m) => Center(
            child: Text(m,
                style: AppTextStyle.helper(color: AppColors.error)),
          ),
          loaded: (guide) {
            if (guide.howToPlaySteps.isEmpty) {
              return Column(
                children: [
                  _Header(
                    onBack: () => context.canPop()
                        ? context.pop()
                        : context.go('/game/${widget.gameId}'),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.w),
                        child: Text('No play steps yet for this game.',
                            style: AppTextStyle.helper(),
                            textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ],
              );
            }
            final chapters = guide.howToPlaySteps
              ..sort((a, b) => a.order.compareTo(b.order));
            final current = chapters[_chapter];
            final revealedHere = _revealed[_chapter] ?? const <int>{};
            final allRevealed = current.rules.isNotEmpty &&
                revealedHere.length >= current.rules.length;

            return Column(
              children: [
                _Header(
                  onBack: () => context.canPop()
                      ? context.pop()
                      : context.go('/game/${widget.gameId}'),
                ),
                Expanded(
                  child: _ChapterView(
                    chapter: current,
                    chapterIndex: _chapter,
                    totalChapters: chapters.length,
                    revealed: revealedHere,
                    bubbleMessage: _bubbleMessage,
                    onRevealRule: _revealRule,
                  ),
                ),
                _BottomBar(
                  isFirst: _chapter == 0,
                  isLast: _chapter == chapters.length - 1,
                  finishedAll: allRevealed,
                  onBack: () {
                    if (_chapter > 0) {
                      _resetBubble();
                      setState(() => _chapter--);
                    }
                  },
                  onNext: () async {
                    if (_chapter < chapters.length - 1) {
                      _resetBubble();
                      setState(() => _chapter++);
                      return;
                    }
                    await ref
                        .read(progressNotifierProvider)
                        .markComplete(
                            widget.gameId, GuideSection.howToPlay);
                    if (!context.mounted) return;
                    await showMascotCelebration(
                      context,
                      title: 'How to play — done!',
                      subtitle:
                          'You know the rules. Practice makes legends.',
                    );
                    if (!context.mounted) return;
                    context.go('/game/${widget.gameId}/learn');
                  },
                ),
              ],
            );
          },
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
              child: Text(AppStrings.howToPlay,
                  style: AppTextStyle.cardTitle().copyWith(
                      fontSize: 17.sp, fontWeight: FontWeight.w700)),
            ),
          ),
          // Keeps the title centered now that the mascot has moved into the
          // content area below.
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

// ─── Chapter body ────────────────────────────────────────────────────────

class _ChapterView extends StatelessWidget {
  const _ChapterView({
    required this.chapter,
    required this.chapterIndex,
    required this.totalChapters,
    required this.revealed,
    required this.bubbleMessage,
    required this.onRevealRule,
  });

  final GuideStepEntity chapter;
  final int chapterIndex;
  final int totalChapters;

  /// Rule numbers already revealed in this chapter.
  final Set<int> revealed;

  /// Transient mascot prompt (e.g. after a reveal). When null, a default
  /// prompt is shown based on the chapter's rule count.
  final String? bubbleMessage;

  final ValueChanged<NumberedRuleEntity> onRevealRule;

  @override
  Widget build(BuildContext context) {
    final pct = (chapterIndex + 1) / totalChapters;
    final readMinutes = _estimateReadMinutes(chapter);
    final ruleCount = chapter.rules.length;
    final defaultPrompt = ruleCount > 0
        ? '$ruleCount rule${ruleCount == 1 ? '' : 's'} in this chapter — '
            'tap each card to learn it.'
        : chapter.body;
    final message = bubbleMessage ?? defaultPrompt;

    return ListView(
      padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 12.h,
          AppSpacing.screenHorizontal, 20.h),
      children: [
        // Progress header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CHAPTER ${chapterIndex + 1} OF $totalChapters',
              style: AppTextStyle.label(color: AppColors.primaryGold)
                  .copyWith(letterSpacing: 1.5, fontSize: 11.sp),
            ),
            Text('$readMinutes min read', style: AppTextStyle.helper()),
          ],
        ),
        SizedBox(height: 10.h),
        BmProgressBar(value: pct, height: 6.h),
        SizedBox(height: 18.h),
        // Mascot teaches "from the right" on this screen — bubble on the
        // left, mascot on the right — so the reading order flows naturally
        // into the rules below.
        MascotSpeechBubble(
          mood: MascotMood.teaching,
          message: message,
          mascotSize: 140,
          mascotOnRight: true,
        ),
        SizedBox(height: 22.h),
        // Chapter title
        Text(
          chapter.title,
          style: AppTextStyle.largeTitle().copyWith(
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
              height: 34 / 26),
        ),
        // Intro paragraph — suppressed when the bubble is already saying
        // exactly this text (happens on chapters with no numbered rules,
        // where the default bubble prompt falls back to chapter.body).
        if (chapter.body.isNotEmpty && message != chapter.body) ...[
          SizedBox(height: 12.h),
          Text(
            chapter.body,
            style: AppTextStyle.body(color: AppColors.textSecondary),
          ),
        ],
        // Illustration
        if (chapter.images.isNotEmpty) ...[
          SizedBox(height: 18.h),
          BmConceptImageRow(images: chapter.images),
        ],
        // Rules — each one revealed on tap.
        if (chapter.rules.isNotEmpty) ...[
          SizedBox(height: 22.h),
          Text(
            'Rules of ${chapter.title.toLowerCase()}',
            style: AppTextStyle.sectionTitle()
                .copyWith(fontWeight: FontWeight.w800, fontSize: 20.sp),
          ),
          SizedBox(height: 12.h),
          for (final rule in chapter.rules)
            RevealRuleCard(
              rule: rule,
              revealed: revealed.contains(rule.number),
              onTap: () => onRevealRule(rule),
            ),
        ],
        // Warning — same inline-callout style as the setup-guide Pro Tip
        if (chapter.warning != null) ...[
          SizedBox(height: 14.h),
          WatchOutCard(body: chapter.warning!),
        ],
      ],
    );
  }

  /// Rough reading-time estimate based on word count of body + rule text.
  /// ~50 words per minute (slow, attentive read for rules). Clamped to 1-30.
  int _estimateReadMinutes(GuideStepEntity c) {
    int words = c.body.split(RegExp(r'\s+')).length;
    for (final r in c.rules) {
      words += r.title.split(RegExp(r'\s+')).length;
      words += r.body.split(RegExp(r'\s+')).length;
    }
    return (words / 50).ceil().clamp(1, 30);
  }
}

// ─── Bottom CTA bar ──────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isFirst,
    required this.isLast,
    required this.finishedAll,
    required this.onBack,
    required this.onNext,
  });
  final bool isFirst;
  final bool isLast;

  /// True once every rule in the current chapter has been revealed.
  final bool finishedAll;

  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final primaryLabel = isLast
        ? (finishedAll ? 'Finish learning ✨' : 'Finish chapters')
        : 'Next Chapter →';

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 8.h,
            AppSpacing.screenHorizontal, 14.h),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: BmButton(
                label: '‹ ${AppStrings.back}',
                variant: BmButtonVariant.secondary,
                onPressed: isFirst ? null : onBack,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              flex: 7,
              child: BmButton(
                label: primaryLabel,
                icon: isLast ? Icons.check_rounded : null,
                onPressed: onNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
