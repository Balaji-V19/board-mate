import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/board_game_entity.dart';
import '../../domain/entities/game_guide_entity.dart';
import '../../domain/repositories/games_repository.dart';
import '../datasources/games_firestore_datasource.dart';

class GamesRepositoryImpl implements GamesRepository {
  GamesRepositoryImpl(this._remote);
  final GamesFirestoreDataSource _remote;

  @override
  Future<Either<Failure, List<BoardGameEntity>>> getGames({
    String? category,
  }) async {
    try {
      return right(await _remote.getGames(category: category));
    } catch (e) {
      return left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, BoardGameEntity>> getGameById(String id) async {
    try {
      return right(await _remote.getGameById(id));
    } catch (e) {
      return left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, GameGuideEntity>> getGameGuide(String gameId) async {
    try {
      return right(await _remote.getGameGuide(gameId));
    } catch (e) {
      return left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, List<BoardGameEntity>>> searchGames(
      String query) async {
    try {
      return right(await _remote.searchGames(query));
    } catch (e) {
      return left(_mapError(e));
    }
  }

  Failure _mapError(Object e) {
    if (e is NotFoundException) return NotFoundFailure(e.message);
    if (e is ServerException) return ServerFailure(e.message);
    if (e is NetworkException) return NetworkFailure(e.message);
    return UnknownFailure(e.toString());
  }
}
