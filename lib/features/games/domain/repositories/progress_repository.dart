import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_progress_entity.dart';

abstract class ProgressRepository {
  Stream<List<UserProgressEntity>> watchAll();
  Future<Either<Failure, void>> touch(String gameId, GuideSection section);
  Future<Either<Failure, void>> markComplete(String gameId, GuideSection section);
}
