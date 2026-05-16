import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../config/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/app_user.dart';

abstract class AuthRemoteDataSource {
  Stream<AppUser?> watchUser();
  AppUser? get currentUser;
  Future<AppUser> signInWithGoogle();
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
