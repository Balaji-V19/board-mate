import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/board_game_entity.dart';
import '../repositories/games_repository.dart';

class GetGameByIdUseCase {
  GetGameByIdUseCase(this._repo);
  final GamesRepository _repo;

  Future<Either<Failure, BoardGameEntity>> call(String id) =>
      _repo.getGameById(id);
}
