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

  CollectionReference<Map<String, dynamic>>? _col() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .collection(FirestoreCollections.saved);
  }

  @override
  Stream<List<SavedGameEntity>> watchSaved() {
    final col = _col();
    if (col == null) return const Stream.empty();
    return col.snapshots().map((snap) => snap.docs.map((d) {
          final data = d.data();
          final ts = data['savedAt'];
          final savedAt = ts is Timestamp ? ts.toDate() : DateTime.now();
          return SavedGameEntity(
            gameId: d.id,
            savedAt: savedAt,
            downloaded: (data['downloaded'] ?? false) as bool,
          );
        }).toList()).handleError((Object e) {
      if (kDebugMode) {
        debugPrint('watchSaved stream error (likely rules): $e');
      }
      return <SavedGameEntity>[];
    });
  }

  @override
  Future<void> save(String gameId) async {
    final col = _col();
    if (col == null) throw AuthException('Not signed in');
    await col.doc(gameId).set({
      'savedAt': FieldValue.serverTimestamp(),
      'downloaded': false,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> unsave(String gameId) async {
    final col = _col();
    if (col == null) throw AuthException('Not signed in');
    await col.doc(gameId).delete();
  }

  @override
  Future<void> setDownloaded(String gameId, bool value) async {
    final col = _col();
    if (col == null) throw AuthException('Not signed in');
    await col.doc(gameId).set({
      'gameId': gameId,
      'downloaded': value,
      'savedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
