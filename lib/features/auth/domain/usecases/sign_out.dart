import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  SignOutUseCase(this._repo);
  final AuthRepository _repo;

  Future<Either<Failure, void>> call() => _repo.signOut();
}
