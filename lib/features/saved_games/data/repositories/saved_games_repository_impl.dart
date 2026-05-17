import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/saved_game_entity.dart';
import '../../domain/repositories/saved_games_repository.dart';
import '../datasources/saved_games_firestore_datasource.dart';

class SavedGamesRepositoryImpl implements SavedGamesRepository {
  SavedGamesRepositoryImpl(this._remote);
  final SavedGamesFirestoreDataSource _remote;

  @override
  Stream<List<SavedGameEntity>> watchSaved() => _remote.watchSaved();

  @override
  Future<Either<Failure, void>> save(String gameId) async {
    try {
      await _remote.save(gameId);
      return right(null);
    } on AuthException catch (e) {
      return left(AuthFailure(e.message));
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unsave(String gameId) async {
    try {
      await _remote.unsave(gameId);
      return right(null);
    } on AuthException catch (e) {
      return left(AuthFailure(e.message));
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setDownloaded(
      String gameId, bool value) async {
    try {
      await _remote.setDownloaded(gameId, value);
      return right(null);
    } on AuthException catch (e) {
      return left(AuthFailure(e.message));
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }
}
