import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../config/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/app_user.dart';

abstract class AuthRemoteDataSource {
  Stream<AppUser?> watchUser();
  AppUser? get currentUser;
  Future<AppUser> signInWithGoogle();
  Future<AppUser> signInWithApple();
  Future<void> signOut();

  /// Permanently delete the signed-in account:
  /// 1. Snapshot `users/{uid}` and copy it into `deleted_users/{uid}` with
  ///    deletion metadata (provider, deletedAt).
  /// 2. Remove the `users/{uid}` document.
  /// 3. Delete the Firebase Auth user (re-authenticates first if the
  ///    Firebase session is too old).
  /// 4. Sign out local OAuth providers (Google) so the device session is
  ///    cleared.
  Future<void> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  @override
  Stream<AppUser?> watchUser() {
    return _auth.authStateChanges().map(_mapUser);
  }

  @override
  AppUser? get currentUser => _mapUser(_auth.currentUser);

  AppUser? _mapUser(User? u) {
    if (u == null) return null;
    return AppUser(
      uid: u.uid,
      email: u.email ?? '',
      displayName: u.displayName ?? '',
      photoUrl: u.photoURL ?? '',
    );
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw AuthException('Sign-in cancelled');
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    final user = result.user;
    if (user == null) throw AuthException('No user returned');

    await _ensureUserDoc(user);

    return _mapUser(user)!;
  }

  @override
  Future<AppUser> signInWithApple() async {
    // Nonce prevents replay of an intercepted Apple identity token. The
    // value sent to Apple is the SHA-256 of `rawNonce`; Firebase verifies it
    // matches the hash inside the returned id token.
    final rawNonce = _generateNonce();
    final hashedNonce = _sha256ofString(rawNonce);

    final AuthorizationCredentialAppleID appleCredential;
    try {
      appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw AuthException('Sign-in cancelled');
      }
      throw AuthException(e.message);
    }

    final idToken = appleCredential.identityToken;
    if (idToken == null) {
      throw AuthException('Apple did not return an identity token');
    }

    final authorizationCode = appleCredential.authorizationCode;
    if (authorizationCode.isEmpty) {
      throw AuthException('Apple did not return an authorization code');
    }

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: idToken,
      rawNonce: rawNonce,
      accessToken: authorizationCode,
    );

    final result = await _auth.signInWithCredential(oauthCredential);
    final user = result.user;
    if (user == null) throw AuthException('No user returned');

    // Apple only returns the user's name on the *first* sign-in. Persist it
    // on the Firebase user the first time so subsequent sign-ins still have
    // a display name.
    final composedName = [
      appleCredential.givenName,
      appleCredential.familyName,
    ]
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(' ');
    if (composedName.isNotEmpty && (user.displayName ?? '').isEmpty) {
      try {
        await user.updateDisplayName(composedName);
        await user.reload();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('updateDisplayName failed: $e');
        }
      }
    }

    final live = _auth.currentUser ?? user;
    await _ensureUserDoc(live);
    return _mapUser(live)!;
  }

  // Best-effort write — Firebase Auth's session is the source of truth. If
  // Firestore rules block this (e.g. before rules are deployed), we log and
  // move on rather than failing the whole sign-in.
  Future<void> _ensureUserDoc(User user) async {
    try {
      final ref =
          _firestore.collection(FirestoreCollections.users).doc(user.uid);
      await ref.set({
        'displayName': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'lastSeenAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ensureUserDoc skipped: $e');
      }
    }
  }

  @override
  Future<void> signOut() async {
    // Drop this device's FCM token first so the account stops receiving
    // pushes on this device. Best-effort — never block sign-out on it.
    try {
      await NotificationService.instance.removeCurrentDeviceToken();
    } catch (_) {}
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException('Not signed in.');
    }

    final providerId = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : null;

    // 1. Snapshot the user's profile doc. Read failure is tolerated — the
    //    archive will still capture the Firebase Auth fields below.
    final userRef =
        _firestore.collection(FirestoreCollections.users).doc(user.uid);
    Map<String, dynamic> snapshot = const {};
    try {
      final snap = await userRef.get();
      if (snap.exists) snapshot = snap.data() ?? const {};
    } catch (e) {
      if (kDebugMode) debugPrint('deleteAccount: snapshot read skipped: $e');
    }

    // 2. Archive to deleted_users/{uid}. This is the *source of truth* for
    //    the deletion record — if it fails (typically Firestore rules not
    //    yet deployed), we abort with a clear, actionable error rather
    //    than silently destroying the account without a tombstone.
    try {
      await _firestore
          .collection(FirestoreCollections.deletedUsers)
          .doc(user.uid)
          .set(<String, dynamic>{
        ...snapshot,
        'uid': user.uid,
        'email': user.email ?? snapshot['email'] ?? '',
        'displayName': user.displayName ?? snapshot['displayName'] ?? '',
        'photoUrl': user.photoURL ?? snapshot['photoUrl'] ?? '',
        'providerId': providerId,
        'deletedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw AuthException(
          "Couldn't archive your account. Deploy the latest "
          'firestore.rules so writes to deleted_users/{uid} are '
          'allowed for the authenticated user, then try again.',
        );
      }
      throw AuthException('Failed to archive account: ${e.message ?? e.code}');
    }

    // 3. Cascade-delete subcollections under users/{uid}. Firestore won't
    //    do this for us when we delete the parent doc, so we walk each
    //    known subcollection and batch-delete its contents while the user
    //    is still authenticated (rules: /users/{uid}/{path=**}).
    for (final sub in const [
      FirestoreCollections.saved,
      FirestoreCollections.progress,
      FirestoreCollections.recents,
      'fcmTokens',
    ]) {
      try {
        await _purgeUserSubcollection(user.uid, sub);
      } on FirebaseException catch (e) {
        throw AuthException(
          "Couldn't clear $sub data: ${e.message ?? e.code}",
        );
      }
    }

    // 4. Remove the live user doc itself.
    try {
      await userRef.delete();
    } on FirebaseException catch (e) {
      if (e.code != 'not-found') {
        throw AuthException(
          "Couldn't delete profile doc: ${e.message ?? e.code}",
        );
      }
    }

    // 5. Delete the Firebase Auth user. If the session is older than a few
    //    minutes Firebase requires a fresh re-auth before destructive ops.
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        await _reauthenticate(user, providerId);
        await user.delete();
      } else {
        throw AuthException(e.message ?? 'Failed to delete account.');
      }
    }

    // 6. Clear the OAuth session on this device so the next "Sign in with
    //    Google" actually opens the picker instead of silently re-using
    //    the disconnected account. Best-effort — local cleanup only.
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  /// Page through `users/{uid}/{name}/*` in 500-doc batches and delete each
  /// document. Returns when the subcollection is empty.
  ///
  /// Firestore's recommended client-side cascade pattern: list, batch
  /// delete, repeat. Per-batch limit is 500 writes. Saved/progress data is
  /// small in practice (handful of docs), so this usually completes in
  /// one round-trip.
  Future<void> _purgeUserSubcollection(String uid, String name) async {
    final col = _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .collection(name);
    while (true) {
      final snap = await col.limit(500).get();
      if (snap.docs.isEmpty) return;
      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      if (snap.docs.length < 500) return;
    }
  }

  /// Re-runs the OAuth flow for [providerId] and re-authenticates [user]
  /// with the resulting credential, satisfying Firebase's "recent login"
  /// requirement for destructive operations.
  Future<void> _reauthenticate(User user, String? providerId) async {
    switch (providerId) {
      case 'google.com':
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          throw AuthException('Re-authentication cancelled.');
        }
        final googleAuth = await googleUser.authentication;
        final cred = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(cred);
        return;
      case 'apple.com':
        final rawNonce = _generateNonce();
        final hashedNonce = _sha256ofString(rawNonce);
        final AuthorizationCredentialAppleID appleCredential;
        try {
          appleCredential = await SignInWithApple.getAppleIDCredential(
            scopes: const [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
            nonce: hashedNonce,
          );
        } on SignInWithAppleAuthorizationException catch (e) {
          if (e.code == AuthorizationErrorCode.canceled) {
            throw AuthException('Re-authentication cancelled.');
          }
          throw AuthException(e.message);
        }
        final idToken = appleCredential.identityToken;
        if (idToken == null) {
          throw AuthException('Apple did not return an identity token.');
        }
        final cred = OAuthProvider('apple.com').credential(
          idToken: idToken,
          rawNonce: rawNonce,
          accessToken: appleCredential.authorizationCode,
        );
        await user.reauthenticateWithCredential(cred);
        return;
      default:
        throw AuthException(
          'Please sign out and back in, then try deleting again.',
        );
    }
  }
}

String _generateNonce([int length = 32]) {
  const charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(
    length,
    (_) => charset[random.nextInt(charset.length)],
  ).join();
}

String _sha256ofString(String input) {
  final bytes = utf8.encode(input);
  return sha256.convert(bytes).toString();
}
