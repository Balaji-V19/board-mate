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
import '../../domain/entities/app_user.dart';

abstract class AuthRemoteDataSource {
  Stream<AppUser?> watchUser();
  AppUser? get currentUser;
  Future<AppUser> signInWithGoogle();
  Future<AppUser> signInWithApple();
  Future<void> signOut();
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
    await _googleSignIn.signOut();
    await _auth.signOut();
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
