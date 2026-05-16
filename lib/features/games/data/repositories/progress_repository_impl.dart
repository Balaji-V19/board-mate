import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_progress_entity.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_firestore_datasource.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl(this._remote);
  final ProgressFirestoreDataSource _remote;

  @override
  Stream<List<UserProgressEntity>> watchAll() => _remote.watchAll();

  @override
  Future<Either<Failure, void>> touch(String gameId, GuideSection section) =>
      _wrap(() => _remote.touch(gameId, section));

  @override
  Future<Either<Failure, void>> markComplete(
          String gameId, GuideSection section) =>
      _wrap(() => _remote.markComplete(gameId, section));

  Future<Either<Failure, void>> _wrap(Future<void> Function() action) async {
    try {
      await action();
      return right(null);
    } on AuthException catch (e) {
      return left(AuthFailure(e.message));
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }
}
