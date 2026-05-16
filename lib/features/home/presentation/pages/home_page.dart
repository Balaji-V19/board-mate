import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_strings.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../core/widgets/bm_category_tile.dart';
import '../../../../core/widgets/bm_game_card.dart';
import '../../../../core/widgets/bm_search_bar.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../games/domain/entities/board_game_entity.dart';
import '../../../games/domain/entities/user_progress_entity.dart';
import '../../../games/presentation/providers/games_notifier.dart';
import '../../../games/presentation/providers/games_state.dart';
import '../../../games/presentation/providers/progress_notifier.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 12.h,
              AppSpacing.screenHorizontal, AppSpacing.bottomNavSafePadding),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstName == null ? greeting : '$greeting, $firstName',
                      style: AppTextStyle.helper(color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 4.h),
                    Text(AppStrings.homeHeadline,
                        style: AppTextStyle.screenTitle()),
                  ],
                ),
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDefault,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.notifications_none_rounded,
                      color: AppColors.secondaryNavy, size: 20.sp),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            BmSearchBar(
              hint: AppStrings.searchHint,
              readOnly: true,
              onTap: () => context.go('/browse'),
              trailing: BmIconFilterButton(onTap: () => context.go('/browse')),
            ),
            if (continueGame != null) ...[
              SizedBox(height: AppSpacing.sectionGap),
              Text(AppStrings.continueLearning,
                  style: AppTextStyle.sectionTitle()),
              SizedBox(height: 12.h),
              ContinueLearningCard(
                game: continueGame.$1,
                progress: continueGame.$2,
              ),
            ],
            SizedBox(height: AppSpacing.sectionGap),
            Text(AppStrings.browseByCategory, style: AppTextStyle.sectionTitle()),
            SizedBox(height: 14.h),
            const _CategoryGrid(),
            SizedBox(height: AppSpacing.sectionGap),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.featuredGames, style: AppTextStyle.sectionTitle()),
                TextButton(
                  onPressed: () => context.go('/browse'),
                  child: Text(AppStrings.seeAll,
                      style: AppTextStyle.bodyStrong(
                          color: AppColors.primaryGold)),
                ),
              ],
            ),
            SizedBox(height: 4.h),
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

  /// Pair the most-recent progress entry with its full game record. Returns
  /// null when no progress exists or the matching game isn't loaded yet.
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

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid();

  static const _cats = [
    ('Strategy', '♟', AppColors.categoryStrategy),
    ('Family', '🎲', AppColors.categoryFamily),
    ('Party', '🎉', AppColors.categoryParty),
    ('Cards', '🃏', AppColors.categoryCards),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (label, emoji, color) in _cats) ...[
          Expanded(
            child: BmCategoryTile(
              label: label,
              emoji: emoji,
              color: color,
              onTap: () => context.go('/browse?category=$label'),
            ),
          ),
          if (label != 'Cards') SizedBox(width: 12.w),
        ],
      ],
    );
  }
}

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
          height: 230.h,
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
