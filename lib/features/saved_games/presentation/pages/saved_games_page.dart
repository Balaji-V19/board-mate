import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_strings.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../core/widgets/bm_chip.dart';
import '../../../../core/widgets/bm_game_card.dart';
import '../../../games/domain/entities/board_game_entity.dart';
import '../../../games/presentation/providers/games_notifier.dart';
import '../providers/saved_games_notifier.dart';

class SavedGamesPage extends ConsumerStatefulWidget {
  const SavedGamesPage({super.key});
  @override
  ConsumerState<SavedGamesPage> createState() => _SavedGamesPageState();
}

class _SavedGamesPageState extends ConsumerState<SavedGamesPage> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(savedGamesNotifierProvider);
    final gamesState = ref.watch(gamesListNotifierProvider).state;

    // Resolve saved game IDs against the in-memory games list. For an MVP this
    // avoids a separate per-game Firestore fetch loop and works fine while the
    // catalogue is small.
    final List<BoardGameEntity> allGames = gamesState.maybeWhen(
      loaded: (g) => g,
      orElse: () => const [],
    );
    final savedIds = saved.items.map((s) => s.gameId).toSet();
    final resolved =
        allGames.where((g) => savedIds.contains(g.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal, 12.h, AppSpacing.screenHorizontal, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.savedTitle,
                      style: AppTextStyle.screenTitle()),
                  SizedBox(height: 2.h),
                  Text(
                    '${resolved.length} game${resolved.length == 1 ? '' : 's'} bookmarked',
                    style: AppTextStyle.helper(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal),
              child: Row(
                children: [
                  for (final (i, label) in [
                    (0, 'All'),
                    (1, 'Downloaded'),
                    (2, 'Collections'),
                  ]) ...[
                    Expanded(
                      child: BmChip(
                        label: label,
                        selected: i == _segment,
                        onTap: () => setState(() => _segment = i),
                      ),
                    ),
                    if (i != 2) SizedBox(width: 8.w),
                  ],
                ],
              ),
            ),
            SizedBox(height: 14.h),
            Expanded(
              child: resolved.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.w),
                        child: Text(AppStrings.savedEmpty,
                            style: AppTextStyle.helper(),
                            textAlign: TextAlign.center),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                          AppSpacing.screenHorizontal,
                          0,
                          AppSpacing.screenHorizontal,
                          AppSpacing.bottomNavSafePadding),
                      itemCount: resolved.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (innerCtx, i) {
                        final g = resolved[i];
                        return BmGameCardRow(
                          game: g,
                          isSaved: true,
                          onTap: () => innerCtx.push('/game/${g.id}'),
                          onFavoriteTap: () => ref
                              .read(savedGamesNotifierProvider)
                              .toggle(g.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
