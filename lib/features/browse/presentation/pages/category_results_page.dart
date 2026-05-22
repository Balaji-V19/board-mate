import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../core/widgets/bm_chip.dart';
import '../../../../core/widgets/bm_game_card.dart';
import '../../../games/domain/entities/board_game_entity.dart';
import '../../../games/presentation/providers/games_notifier.dart';
import '../../../saved_games/presentation/providers/saved_games_notifier.dart';

const _difficulties = ['All Levels', 'Easy', 'Medium', 'Hard'];

class CategoryResultsPage extends ConsumerStatefulWidget {
  const CategoryResultsPage({super.key, required this.category});
  final String category;

  @override
  ConsumerState<CategoryResultsPage> createState() =>
      _CategoryResultsPageState();
}

class _CategoryResultsPageState extends ConsumerState<CategoryResultsPage> {
  String _difficulty = 'All Levels';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gamesListNotifierProvider).state;
    final saved = ref.watch(savedGamesNotifierProvider);

    final List<BoardGameEntity> filtered = state.maybeWhen(
      loaded: (games) {
        final inCategory = games
            .where((g) => g.categories.any(
                (c) => c.toLowerCase() == widget.category.toLowerCase()))
            .toList();
        if (_difficulty == 'All Levels') return inCategory;
        return inCategory
            .where((g) =>
                g.difficulty.toLowerCase() == _difficulty.toLowerCase())
            .toList();
      },
      orElse: () => <BoardGameEntity>[],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, 8.h,
                  AppSpacing.screenHorizontal, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(category: widget.category),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Text(
                        '${filtered.length} game${filtered.length == 1 ? '' : 's'}',
                        style: AppTextStyle.helper(),
                      ),
                      const Spacer(),
                      const _SortButton(),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    // Cancel the parent's horizontal padding inside the
                    // scrollable area so the first chip sits flush-left and
                    // the strip can scroll without clipping at the edge.
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Row(
                      children: [
                        for (var i = 0; i < _difficulties.length; i++) ...[
                          BmChip(
                            label: _difficulties[i],
                            selected: _difficulty == _difficulties[i],
                            onTap: () => setState(() {
                              _difficulty = _difficulties[i];
                            }),
                          ),
                          if (i != _difficulties.length - 1)
                            SizedBox(width: 8.w),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: state.maybeWhen(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (m) => Center(
                  child: Text(m,
                      style: AppTextStyle.helper(color: AppColors.error)),
                ),
                orElse: () => filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.w),
                          child: Text(
                            'No ${widget.category.toLowerCase()} games match your filter yet.',
                            style: AppTextStyle.helper(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.fromLTRB(
                            AppSpacing.screenHorizontal,
                            0,
                            AppSpacing.screenHorizontal,
                            AppSpacing.bottomNavSafePadding),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14.h,
                          crossAxisSpacing: 12.w,
                          // Slightly taller than 170/240 so the bottom meta
                          // row sits comfortably below the title block on
                          // every device pixel ratio.
                          childAspectRatio: 170 / 246,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (innerCtx, i) {
                          final g = filtered[i];
                          return BmGameCardGrid(
                            game: g,
                            isSaved: saved.isSaved(g.id),
                            onTap: () => innerCtx.push('/game/${g.id}'),
                            onFavoriteTap: () => ref
                                .read(savedGamesNotifierProvider)
                                .toggle(g.id),
                          );
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

class _Header extends StatelessWidget {
  const _Header({required this.category});
  final String category;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _IconBackButton(
          onTap: () => context.canPop()
              ? context.pop()
              : context.go('/home'),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CATEGORY',
                style: AppTextStyle.label(color: AppColors.primaryGold)
                    .copyWith(letterSpacing: 1.5, fontSize: 11.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                '$category Games',
                style: AppTextStyle.largeTitle().copyWith(
                    fontWeight: FontWeight.w800, fontSize: 28.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconBackButton extends StatelessWidget {
  const _IconBackButton({required this.onTap});
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
          child: Icon(Icons.chevron_left_rounded,
              color: AppColors.secondaryNavy, size: 24.sp),
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceDefault,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.swap_vert_rounded,
              size: 16.sp, color: AppColors.secondaryNavy),
          SizedBox(width: 6.w),
          Text(
            'Popular',
            style: AppTextStyle.bodyStrong().copyWith(fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}
