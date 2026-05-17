import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Stream<AppUser?> watchUser() => _remote.watchUser();

  @override
  AppUser? get currentUser => _remote.currentUser;

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try {
      final user = await _remote.signInWithGoogle();
      return right(user);
    } on AuthException catch (e) {
      return left(AuthFailure(e.message));
    } on fb.FirebaseAuthException catch (e) {
      return left(AuthFailure(e.message ?? 'Sign-in failed'));
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithApple() async {
    try {
      final user = await _remote.signInWithApple();
      return right(user);
    } on AuthException catch (e) {
      return left(AuthFailure(e.message));
    } on fb.FirebaseAuthException catch (e) {
      return left(AuthFailure(e.message ?? 'Sign-in failed'));
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remote.signOut();
      return right(null);
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }
}
