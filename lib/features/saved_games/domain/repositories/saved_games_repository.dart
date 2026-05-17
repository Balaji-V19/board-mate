import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/saved_game_entity.dart';

abstract class SavedGamesRepository {
  Stream<List<SavedGameEntity>> watchSaved();
  Future<Either<Failure, void>> save(String gameId);
  Future<Either<Failure, void>> unsave(String gameId);
  Future<Either<Failure, void>> setDownloaded(String gameId, bool value);
}
