import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../config/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/saved_game_entity.dart';

abstract class SavedGamesFirestoreDataSource {
  Stream<List<SavedGameEntity>> watchSaved();
  Future<void> save(String gameId);
  Future<void> unsave(String gameId);
  Future<void> setDownloaded(String gameId, bool value);
}

class SavedGamesFirestoreDataSourceImpl implements SavedGamesFirestoreDataSource {
  SavedGamesFirestoreDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>>? _colForUid(String? uid) {
    if (uid == null) return null;
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .collection(FirestoreCollections.saved);
  }

  @override
  Stream<List<SavedGameEntity>> watchSaved() {
    return Stream.multi((controller) {
      StreamSubscription<List<SavedGameEntity>>? savedSub;

      void bindForUid(String? uid) {
        savedSub?.cancel();
        final col = _colForUid(uid);
        if (col == null) {
          controller.add(const <SavedGameEntity>[]);
          return;
        }
        savedSub = col.snapshots().map((snap) => snap.docs.map((d) {
              final data = d.data();
              final ts = data['savedAt'];
              final savedAt = ts is Timestamp ? ts.toDate() : DateTime.now();
              return SavedGameEntity(
                gameId: d.id,
                savedAt: savedAt,
                downloaded: (data['downloaded'] ?? false) as bool,
              );
            }).toList()).listen(
          controller.add,
          onError: (Object e) {
            if (kDebugMode) {
              debugPrint('watchSaved stream error (likely rules): $e');
            }
            controller.add(const <SavedGameEntity>[]);
          },
        );
      }

      // Bind immediately for app restarts where user is already signed in.
      bindForUid(_auth.currentUser?.uid);

      final authSub = _auth.authStateChanges().listen(
        (user) => bindForUid(user?.uid),
        onError: (Object e) {
          if (kDebugMode) {
            debugPrint('authStateChanges error (saved): $e');
          }
          controller.add(const <SavedGameEntity>[]);
        },
      );

      controller.onCancel = () async {
        await savedSub?.cancel();
        await authSub.cancel();
      };
    });
  }

  @override
  Future<void> save(String gameId) async {
    final col = _colForUid(_auth.currentUser?.uid);
    if (col == null) throw AuthException('Not signed in');
    await col.doc(gameId).set({
      'savedAt': FieldValue.serverTimestamp(),
      'downloaded': false,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> unsave(String gameId) async {
    final col = _colForUid(_auth.currentUser?.uid);
    if (col == null) throw AuthException('Not signed in');
    await col.doc(gameId).delete();
  }

  @override
  Future<void> setDownloaded(String gameId, bool value) async {
    final col = _colForUid(_auth.currentUser?.uid);
    if (col == null) throw AuthException('Not signed in');
    await col.doc(gameId).set({
      'gameId': gameId,
      'downloaded': value,
      'savedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
