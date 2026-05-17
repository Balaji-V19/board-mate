import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/app_spacing.dart';
import '../../../../config/constants/app_strings.dart';
import '../../../../config/constants/app_textstyle.dart';
import '../../../../core/widgets/bm_die_icon.dart';
import '../../../games/domain/entities/board_game_entity.dart';
import '../../../games/presentation/providers/games_notifier.dart';
import '../providers/saved_games_notifier.dart';

enum _Tab { all, downloaded, collections }

class SavedGamesPage extends ConsumerStatefulWidget {
  const SavedGamesPage({super.key});
  @override
  ConsumerState<SavedGamesPage> createState() => _SavedGamesPageState();
}

class _SavedGamesPageState extends ConsumerState<SavedGamesPage> {
  _Tab _tab = _Tab.all;
  bool _editMode = false;

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(savedGamesNotifierProvider);
    final gamesState = ref.watch(gamesListNotifierProvider).state;

    final allGames = gamesState.maybeWhen(
      loaded: (g) => g,
      orElse: () => const <BoardGameEntity>[],
    );
    final savedIds = saved.items.map((s) => s.gameId).toSet();
    final savedGames =
        allGames.where((g) => savedIds.contains(g.id)).toList();

    final filtered = switch (_tab) {
      _Tab.all => savedGames,
      _Tab.downloaded =>
        savedGames.where((g) => saved.isDownloaded(g.id)).toList(),
      _Tab.collections => const <BoardGameEntity>[],
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal, 8.h, AppSpacing.screenHorizontal, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.savedTitle,
                          style: AppTextStyle.largeTitle().copyWith(
                              fontSize: 32.sp, fontWeight: FontWeight.w800),
                        ),
                      ),
                      _EditButton(
                        active: _editMode,
                        onTap: () => setState(() => _editMode = !_editMode),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${savedGames.length} game${savedGames.length == 1 ? '' : 's'} bookmarked',
                    style: AppTextStyle.helper(),
                  ),
                  SizedBox(height: 16.h),
                  _TabStrip(
                    current: _tab,
                    onChanged: (t) => setState(() => _tab = t),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: _Content(
                tab: _tab,
                games: filtered,
                editMode: _editMode,
                isDownloaded: saved.isDownloaded,
                onTap: (g) => context.push('/game/${g.id}'),
                onToggleDownloaded: (id) => ref
                    .read(savedGamesNotifierProvider)
                    .toggleDownloaded(id),
                onUnsave: (id) =>
                    ref.read(savedGamesNotifierProvider).toggle(id),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Edit button ─────────────────────────────────────────────────────────

class _EditButton extends StatelessWidget {
  const _EditButton({required this.active, required this.onTap});
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.primaryGold : AppColors.surfaceDefault,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: active
                ? null
                : Border.all(color: AppColors.border, width: 1),
          ),
          child: Text(
            active ? 'Done' : 'Edit',
            style: AppTextStyle.bodyStrong(
                color: active ? Colors.white : AppColors.secondaryNavy)
                .copyWith(fontSize: 14.sp),
          ),
        ),
      ),
    );
  }
}

// ─── Tab strip ───────────────────────────────────────────────────────────

class _TabStrip extends StatelessWidget {
  const _TabStrip({required this.current, required this.onChanged});
  final _Tab current;
  final ValueChanged<_Tab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceDefault,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          _TabButton(
              label: 'All',
              active: current == _Tab.all,
              onTap: () => onChanged(_Tab.all)),
          _TabButton(
              label: 'Downloaded',
              active: current == _Tab.downloaded,
              onTap: () => onChanged(_Tab.downloaded)),
          _TabButton(
              label: 'Collections',
              active: current == _Tab.collections,
              onTap: () => onChanged(_Tab.collections)),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryGold : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(100),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              alignment: Alignment.center,
              child: Text(
                label,
                style: AppTextStyle.bodyStrong(
                  color: active ? Colors.white : AppColors.textSecondary,
                ).copyWith(fontSize: 14.sp),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Content ─────────────────────────────────────────────────────────────

class _Content extends StatelessWidget {
  const _Content({
    required this.tab,
    required this.games,
    required this.editMode,
    required this.isDownloaded,
    required this.onTap,
    required this.onToggleDownloaded,
    required this.onUnsave,
  });

  final _Tab tab;
  final List<BoardGameEntity> games;
  final bool editMode;
  final bool Function(String) isDownloaded;
  final void Function(BoardGameEntity) onTap;
  final void Function(String gameId) onToggleDownloaded;
  final void Function(String gameId) onUnsave;

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: _EmptyMessage(tab: tab),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          0,
          AppSpacing.screenHorizontal,
          AppSpacing.bottomNavSafePadding),
      itemCount: games.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (innerCtx, i) {
        final g = games[i];
        final downloaded = isDownloaded(g.id);
        return _SavedCard(
          game: g,
          downloaded: downloaded,
          editMode: editMode,
          onTap: () => onTap(g),
          onToggleDownloaded: () => onToggleDownloaded(g.id),
          onUnsave: () => onUnsave(g.id),
        );
      },
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.tab});
  final _Tab tab;

  @override
  Widget build(BuildContext context) {
    final (icon, text) = switch (tab) {
      _Tab.all => (
          Icons.favorite_border_rounded,
          AppStrings.savedEmpty,
        ),
      _Tab.downloaded => (
          Icons.download_for_offline_outlined,
          'Tap "Download" on a saved game to keep it here for offline use.',
        ),
      _Tab.collections => (
          Icons.collections_bookmark_outlined,
          'Collections are coming soon — organize your saved games into themed lists.',
        ),
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 40.sp, color: AppColors.textSecondary),
        SizedBox(height: 14.h),
        Text(text,
            style: AppTextStyle.helper(),
            textAlign: TextAlign.center),
      ],
    );
  }
}

// ─── Saved card ──────────────────────────────────────────────────────────

class _SavedCard extends StatelessWidget {
  const _SavedCard({
    required this.game,
    required this.downloaded,
    required this.editMode,
    required this.onTap,
    required this.onToggleDownloaded,
    required this.onUnsave,
  });

  final BoardGameEntity game;
  final bool downloaded;
  final bool editMode;
  final VoidCallback onTap;
  final VoidCallback onToggleDownloaded;
  final VoidCallback onUnsave;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.categoryFor(
        game.categories.isEmpty ? '' : game.categories.first);
    return Material(
      color: AppColors.surfaceDefault,
      borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.smallCardRadius),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(AppSpacing.smallCardRadius),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ThumbBox(game: game, accent: accent),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(game.name,
                        style: AppTextStyle.cardTitle().copyWith(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700)),
                    SizedBox(height: 2.h),
                    Text(
                      '${game.categories.isEmpty ? '' : game.categories.first} · ${game.playerRange} players',
                      style: AppTextStyle.helper(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10.h),
                    _DownloadStatusPill(
                      downloaded: downloaded,
                      onTap: onToggleDownloaded,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              InkWell(
                onTap: editMode ? onUnsave : null,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Icon(
                    editMode
                        ? Icons.close_rounded
                        : Icons.favorite_rounded,
                    color: editMode
                        ? AppColors.error
                        : AppColors.primaryGold,
                    size: 22.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThumbBox extends StatelessWidget {
  const _ThumbBox({required this.game, required this.accent});
  final BoardGameEntity game;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final hasImage = game.imageUrl.isNotEmpty;
    return Container(
      width: 84.w,
      height: 84.w,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              game.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _ThumbIcon(accent: accent),
            )
          : _ThumbIcon(accent: accent),
    );
  }
}

/// Icon variant of the thumbnail — a decorative blob in the top-left corner
/// (≈70% visible, the remaining 30% bleeds off the clipped corner) with the
/// BoardMate brand die centred in the game's category accent colour.
class _ThumbIcon extends StatelessWidget {
  const _ThumbIcon({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: -22.w,
          top: -22.w,
          child: Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Center(
          child: BmDieIcon(
            color: accent,
            size: 38.w,
            withShadow: false,
          ),
        ),
      ],
    );
  }
}

class _DownloadStatusPill extends StatelessWidget {
  const _DownloadStatusPill({
    required this.downloaded,
    required this.onTap,
  });
  final bool downloaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = downloaded
        ? AppColors.success.withValues(alpha: 0.12)
        : AppColors.secondaryNavy.withValues(alpha: 0.06);
    final fg = downloaded ? AppColors.success : AppColors.textSecondary;
    final icon = downloaded
        ? Icons.check_circle_rounded
        : Icons.download_rounded;
    final label = downloaded ? 'Downloaded' : 'Download';

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14.sp, color: fg),
              SizedBox(width: 6.w),
              Text(
                label,
                style: AppTextStyle.bodyStrong(color: fg)
                    .copyWith(fontSize: 13.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
