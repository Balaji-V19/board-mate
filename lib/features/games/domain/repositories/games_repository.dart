import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/board_game_entity.dart';
import '../entities/game_guide_entity.dart';

abstract class GamesRepository {
  Future<Either<Failure, List<BoardGameEntity>>> getGames({String? category});
  Future<Either<Failure, BoardGameEntity>> getGameById(String id);
  Future<Either<Failure, GameGuideEntity>> getGameGuide(String gameId);
  Future<Either<Failure, List<BoardGameEntity>>> searchGames(String query);
}
