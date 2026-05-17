import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/game_request_entity.dart';

abstract class GameRequestsRepository {
  Future<Either<Failure, void>> submit(GameRequestEntity request);
}
