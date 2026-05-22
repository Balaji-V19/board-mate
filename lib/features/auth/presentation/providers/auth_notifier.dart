import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../dependency_injection.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/sign_in_with_apple.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/watch_auth_state.dart';
import 'auth_state.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier({
    required WatchAuthStateUseCase watchAuthState,
    required SignInWithGoogleUseCase signInWithGoogle,
    required SignInWithAppleUseCase signInWithApple,
    required SignOutUseCase signOut,
    required DeleteAccountUseCase deleteAccount,
  })  : _watchAuthState = watchAuthState,
        _signInWithGoogle = signInWithGoogle,
        _signInWithApple = signInWithApple,
        _signOut = signOut,
        _deleteAccount = deleteAccount {
    _sub = _watchAuthState().listen(_onAuthChanged);
  }

  final WatchAuthStateUseCase _watchAuthState;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignInWithAppleUseCase _signInWithApple;
  final SignOutUseCase _signOut;
  final DeleteAccountUseCase _deleteAccount;
  StreamSubscription<AppUser?>? _sub;

  AuthState _state = const AuthState.initial();
  AuthState get state => _state;

  bool get isAuthenticated => _state.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );

  AppUser? get user => _state.maybeWhen(
        authenticated: (u) => u,
        orElse: () => null,
      );

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void _onAuthChanged(AppUser? user) {
    final isAuthenticating =
        _state.maybeWhen(authenticating: () => true, orElse: () => false);

    // During OAuth handoff (Google/Apple sheet + app switch), Firebase can
    // briefly emit `null` before the final signed-in user arrives.
    // Keep the loading state until sign-in resolves to avoid showing idle
    // login buttons mid-flow.
    if (isAuthenticating && user == null) return;

    if (user == null) {
      _setState(const AuthState.unauthenticated());
    } else {
      _setState(AuthState.authenticated(user));
    }
  }

  Future<void> signInWithGoogle() async {
    _setState(const AuthState.authenticating());
    final result = await _signInWithGoogle();
    result.fold(
      (failure) => _setState(AuthState.error(failure.message)),
      (user) => _setState(AuthState.authenticated(user)),
    );
  }

  Future<void> signInWithApple() async {
    _setState(const AuthState.authenticating());
    final result = await _signInWithApple();
    result.fold(
      (failure) => _setState(AuthState.error(failure.message)),
      (user) => _setState(AuthState.authenticated(user)),
    );
  }

  Future<void> signOut() async {
    final result = await _signOut();
    result.fold(
      (failure) => _setState(AuthState.error(failure.message)),
      (_) => _setState(const AuthState.unauthenticated()),
    );
  }

  /// Permanently removes the current user. Returns the underlying [Either]
  /// so the UI can surface a specific error message (e.g. when the user
  /// cancels the re-auth picker) without conflating it with the normal
  /// authentication state.
  Future<Either<Failure, void>> deleteAccount() async {
    final result = await _deleteAccount();
    result.fold(
      (failure) {
        // Surface the failure to listeners but leave the user signed in
        // so they can decide what to do next.
        _setState(AuthState.error(failure.message));
      },
      (_) {
        // Firebase's authStateChanges listener also fires after a
        // successful delete, but pushing the state explicitly here makes
        // navigation deterministic for the caller.
        _setState(const AuthState.unauthenticated());
      },
    );
    return result;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  return sl<AuthNotifier>();
});
