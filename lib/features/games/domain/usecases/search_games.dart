import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/board_game_entity.dart';
import '../repositories/games_repository.dart';

class SearchGamesUseCase {
  SearchGamesUseCase(this._repo);
  final GamesRepository _repo;

  Future<Either<Failure, List<BoardGameEntity>>> call(String query) =>
      _repo.searchGames(query);
}
