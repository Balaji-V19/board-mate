import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_strings.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../core/widgets/bm_game_card.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../games/domain/entities/board_game_entity.dart';
import '../../../games/domain/entities/user_progress_entity.dart';
import '../../../games/presentation/providers/games_notifier.dart';
import '../../../games/presentation/providers/games_state.dart';
import '../../../games/presentation/providers/progress_notifier.dart';
import '../../../mascot/domain/entities/mascot_mood.dart';
import '../../../mascot/presentation/widgets/mascot_inline.dart';
import '../widgets/continue_learning_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesState = ref.watch(gamesListNotifierProvider).state;
    final user = ref.watch(authNotifierProvider).user;
    final progress = ref.watch(progressNotifierProvider);

    final continueGame = _resolveContinueGame(gamesState, progress);

    final greeting = _greeting();
    final firstName = user?.displayName.split(' ').first;
    final greetingLine =
        firstName == null ? '$greeting,' : '$greeting, $firstName,';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            8.h,
            AppSpacing.screenHorizontal,
            AppSpacing.bottomNavSafePadding,
          ),
          children: [
            _HomeHeader(greeting: greetingLine),
            SizedBox(height: 16.h),
            _HomeSearchBar(onTap: () => context.go('/browse')),
            if (continueGame != null) ...[
              SizedBox(height: 18.h),
              ContinueLearningCard(
                game: continueGame.$1,
                progress: continueGame.$2,
              ),
            ],
            SizedBox(height: 26.h),
            _SectionHeader(
              title: AppStrings.browseByCategory,
              onSeeAll: () => context.go('/browse'),
            ),
            SizedBox(height: 14.h),
            const _CategoryRow(),
            SizedBox(height: 26.h),
            _SectionHeader(
              title: AppStrings.featuredGames,
              onSeeAll: () => context.go('/browse'),
            ),
            SizedBox(height: 14.h),
            _FeaturedGames(state: gamesState),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return AppStrings.greetingMorning;
    if (h < 18) return AppStrings.greetingAfternoon;
    return AppStrings.greetingEvening;
  }

  static (BoardGameEntity, UserProgressEntity)? _resolveContinueGame(
      GamesListState state, ProgressNotifier progress) {
    final candidate = progress.continueCandidate;
    if (candidate == null) return null;
    return state.maybeWhen(
      loaded: (games) {
        for (final g in games) {
          if (g.id == candidate.gameId) return (g, candidate);
        }
        return null;
      },
      orElse: () => null,
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.greeting});
  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: AppTextStyle.body(color: AppColors.textSecondary),
              ),
              SizedBox(height: 4.h),
              Text(
                AppStrings.homeHeadline,
                style: AppTextStyle.screenTitle().copyWith(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        MascotInline(mood: MascotMood.welcome, size: 96.w),
      ],
    );
  }
}

// ─── Search bar ──────────────────────────────────────────────────────────

class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceDefault,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          height: 52.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded,
                  size: 20.sp, color: AppColors.textSecondary),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Search a board game…',
                  style:
                      AppTextStyle.body(color: AppColors.textSecondary),
                ),
              ),
              Icon(Icons.swap_vert_rounded,
                  size: 20.sp, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section header ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyle.sectionTitle().copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 20.sp,
          ),
        ),
        InkWell(
          onTap: onSeeAll,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            child: Text(
              AppStrings.seeAll,
              style: AppTextStyle.bodyStrong(color: AppColors.primaryGold),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Categories ──────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  const _CategoryRow();

  static const _items = <_CatSpec>[
    _CatSpec(
      label: 'Strategy',
      icon: Icons.workspace_premium_rounded,
      iconColor: AppColors.secondaryNavy,
      tintBg: Color(0xFFF1E4CC),
    ),
    _CatSpec(
      label: 'Family',
      icon: Icons.favorite_rounded,
      iconColor: AppColors.error,
      tintBg: Color(0xFFF4DAD2),
    ),
    _CatSpec(
      label: 'Party',
      icon: Icons.celebration_rounded,
      iconColor: AppColors.categoryParty,
      tintBg: Color(0xFFD7E6D7),
    ),
    _CatSpec(
      label: 'Cards',
      icon: Icons.style_rounded,
      iconColor: AppColors.secondaryNavy,
      tintBg: Color(0xFFD9E2EA),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _items.length; i++) ...[
            Expanded(
              child: _CategoryCard(
                spec: _items[i],
                onTap: () => context.push('/category/${_items[i].label}'),
              ),
            ),
            if (i != _items.length - 1) SizedBox(width: 10.w),
          ],
        ],
      ),
    );
  }
}

class _CatSpec {
  const _CatSpec({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.tintBg,
  });
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color tintBg;
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.spec, required this.onTap});
  final _CatSpec spec;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20.r);
    return DecoratedBox(
      decoration: BoxDecoration(
        // The full card adopts the category's soft pastel tone so each
        // category reads as its own visual identity instead of a generic
        // white tile.
        color: spec.tintBg,
        borderRadius: radius,
        boxShadow: [
          // Shadow tinted with the icon color so each card has a subtle
          // halo matching its accent — gives depth without an outline.
          BoxShadow(
            color: spec.iconColor.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: spec.iconColor.withValues(alpha: 0.12),
          highlightColor: spec.iconColor.withValues(alpha: 0.05),
          child: Padding(
            padding: EdgeInsets.fromLTRB(8.w, 16.h, 8.w, 14.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(spec.icon, color: spec.iconColor, size: 28.sp),
                SizedBox(height: 10.h),
                Text(
                  spec.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.bodyStrong().copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    height: 16 / 13,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Featured games ──────────────────────────────────────────────────────

class _FeaturedGames extends StatelessWidget {
  const _FeaturedGames({required this.state});
  final GamesListState state;

  @override
  Widget build(BuildContext context) {
    return state.when(
      initial: () => const SizedBox.shrink(),
      loading: () => SizedBox(
        height: 220.h,
        child: const Center(child: CircularProgressIndicator()),
      ),
      loaded: (games) {
        if (games.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 32.h),
            child: Text('No games yet. Seed the catalogue from Settings.',
                style: AppTextStyle.helper()),
          );
        }
        return SizedBox(
          height: 240.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: games.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (innerCtx, i) => BmGameCardFeatured(
              game: games[i],
              onTap: () => innerCtx.push('/game/${games[i].id}'),
            ),
          ),
        );
      },
      error: (m) => Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Text(m, style: AppTextStyle.helper(color: AppColors.error)),
      ),
    );
  }
}
