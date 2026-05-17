import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithAppleUseCase {
  SignInWithAppleUseCase(this._repo);
  final AuthRepository _repo;

  Future<Either<Failure, AppUser>> call() => _repo.signInWithApple();
}
