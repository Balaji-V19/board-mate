import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/game_request_entity.dart';
import '../../domain/repositories/game_requests_repository.dart';
import '../datasources/game_requests_firestore_datasource.dart';

class GameRequestsRepositoryImpl implements GameRequestsRepository {
  GameRequestsRepositoryImpl(this._remote);
  final GameRequestsFirestoreDataSource _remote;

  @override
  Future<Either<Failure, void>> submit(GameRequestEntity request) async {
    try {
      await _remote.submit(request);
      return right(null);
    } on AuthException catch (e) {
      return left(AuthFailure(e.message));
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }
}
