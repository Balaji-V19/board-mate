import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/board_game_entity.dart';
import '../repositories/games_repository.dart';

class GetGamesUseCase {
  GetGamesUseCase(this._repo);
  final GamesRepository _repo;

  Future<Either<Failure, List<BoardGameEntity>>> call({String? category}) =>
      _repo.getGames(category: category);
}
