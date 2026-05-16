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
import '../../../../core/widgets/bm_search_bar.dart';
import '../../../games/presentation/providers/games_notifier.dart';
import '../../../saved_games/presentation/providers/saved_games_notifier.dart';

const _categories = ['All', 'Strategy', 'Family', 'Cards', 'Party', 'Co-op'];

class BrowsePage extends ConsumerStatefulWidget {
  const BrowsePage({super.key, this.initialCategory});
  final String? initialCategory;

  @override
  ConsumerState<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends ConsumerState<BrowsePage> {
  final _searchCtrl = TextEditingController();
  String? _appliedCategory;

  @override
  void initState() {
    super.initState();
    _appliedCategory = widget.initialCategory;
    if (_appliedCategory != null) {
      // Defer until first frame so the notifier is fully wired.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(browseNotifierProvider).setCategory(_appliedCategory);
      });
    }
  }

  @override
  void didUpdateWidget(covariant BrowsePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategory != widget.initialCategory &&
        widget.initialCategory != _appliedCategory) {
      _appliedCategory = widget.initialCategory;
      ref.read(browseNotifierProvider).setCategory(_appliedCategory);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(browseNotifierProvider);
    final state = notifier.state;
    final saved = ref.watch(savedGamesNotifierProvider);

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
                  Text(AppStrings.browseTitle,
                      style: AppTextStyle.screenTitle()),
                  SizedBox(height: 2.h),
                  Text(
                    state.maybeWhen(
                      loaded: (g) =>
                          '${g.length} game${g.length == 1 ? '' : 's'} to learn',
                      orElse: () => 'Loading games…',
                    ),
                    style: AppTextStyle.helper(),
                  ),
                  SizedBox(height: 14.h),
                  BmSearchBar(
                    controller: _searchCtrl,
                    hint: AppStrings.searchHint,
                    onChanged: ref.read(browseNotifierProvider).setQuery,
                    trailing: BmIconFilterButton(onTap: () {}),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: AppSpacing.chipHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, i) {
                  final c = _categories[i];
                  final selected = (c == 'All' && notifier.category == null) ||
                      notifier.category == c;
                  return BmChip(
                    label: c,
                    selected: selected,
                    onTap: () => ref
                        .read(browseNotifierProvider)
                        .setCategory(c == 'All' ? null : c),
                  );
                },
              ),
            ),
            SizedBox(height: 14.h),
            Expanded(
              child: state.when(
                initial: () => const SizedBox.shrink(),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                loaded: (games) => games.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.w),
                          child: Text(AppStrings.browseEmpty,
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
                        itemCount: games.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (innerCtx, i) {
                          final g = games[i];
                          return BmGameCardRow(
                            game: g,
                            isSaved: saved.isSaved(g.id),
                            onTap: () => innerCtx.push('/game/${g.id}'),
                            onFavoriteTap: () =>
                                ref.read(savedGamesNotifierProvider).toggle(g.id),
                          );
                        },
                      ),
                error: (m) => Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Text(m,
                        style:
                            AppTextStyle.helper(color: AppColors.error)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
