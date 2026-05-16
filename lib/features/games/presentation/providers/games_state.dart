import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/board_game_entity.dart';
import '../../domain/entities/game_guide_entity.dart';

part 'games_state.freezed.dart';

@freezed
class GamesListState with _$GamesListState {
  const factory GamesListState.initial() = _GLInitial;
  const factory GamesListState.loading() = _GLLoading;
  const factory GamesListState.loaded(List<BoardGameEntity> games) = _GLLoaded;
  const factory GamesListState.error(String message) = _GLError;
}

@freezed
class GameDetailState with _$GameDetailState {
  const factory GameDetailState.initial() = _GDInitial;
  const factory GameDetailState.loading() = _GDLoading;
  const factory GameDetailState.loaded(BoardGameEntity game) = _GDLoaded;
  const factory GameDetailState.error(String message) = _GDError;
}

@freezed
class GuideState with _$GuideState {
  const factory GuideState.initial() = _GuInitial;
  const factory GuideState.loading() = _GuLoading;
  const factory GuideState.loaded(GameGuideEntity guide) = _GuLoaded;
  const factory GuideState.error(String message) = _GuError;
}
