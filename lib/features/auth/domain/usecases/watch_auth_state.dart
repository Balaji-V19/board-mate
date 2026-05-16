import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class WatchAuthStateUseCase {
  WatchAuthStateUseCase(this._repo);
  final AuthRepository _repo;

  Stream<AppUser?> call() => _repo.watchUser();
}
