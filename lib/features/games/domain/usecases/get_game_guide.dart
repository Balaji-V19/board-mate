import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/game_guide_entity.dart';
import '../repositories/games_repository.dart';

class GetGameGuideUseCase {
  GetGameGuideUseCase(this._repo);
  final GamesRepository _repo;

  Future<Either<Failure, GameGuideEntity>> call(String gameId) =>
      _repo.getGameGuide(gameId);
}
