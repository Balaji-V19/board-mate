import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../config/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user_progress_entity.dart';

abstract class ProgressFirestoreDataSource {
  Stream<List<UserProgressEntity>> watchAll();
  Future<void> touch(String gameId, GuideSection section);
  Future<void> markComplete(String gameId, GuideSection section);
}

class ProgressFirestoreDataSourceImpl implements ProgressFirestoreDataSource {
  ProgressFirestoreDataSourceImpl({
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
        .collection(FirestoreCollections.progress);
  }

  @override
  Stream<List<UserProgressEntity>> watchAll() {
    final col = _col();
    if (col == null) return const Stream.empty();
    return col.snapshots().map((snap) {
      return snap.docs
          .map((d) => _fromDoc(d.id, d.data()))
          .toList()
        ..sort((a, b) => b.lastViewedAt.compareTo(a.lastViewedAt));
    }).handleError((Object e) {
      if (kDebugMode) {
        debugPrint('watchProgress stream error: $e');
      }
      return <UserProgressEntity>[];
    });
  }

  UserProgressEntity _fromDoc(String id, Map<String, dynamic> data) {
    final ts = data['lastViewedAt'];
    final lastViewedAt = ts is Timestamp ? ts.toDate() : DateTime.now();
    final completed = ((data['completedSections'] as List?) ?? const [])
        .map((e) => e as String)
        .map(GuideSectionX.fromKey)
        .whereType<GuideSection>()
        .toSet();
    final lastKey = data['lastSection'] as String?;
    return UserProgressEntity(
      gameId: id,
      lastViewedAt: lastViewedAt,
      lastSection: lastKey == null ? null : GuideSectionX.fromKey(lastKey),
      completedSections: completed,
    );
  }

  @override
  Future<void> touch(String gameId, GuideSection section) async {
    final col = _col();
    if (col == null) throw AuthException('Not signed in');
    await col.doc(gameId).set({
      'gameId': gameId,
      'lastViewedAt': FieldValue.serverTimestamp(),
      'lastSection': section.key,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> markComplete(String gameId, GuideSection section) async {
    final col = _col();
    if (col == null) throw AuthException('Not signed in');
    await col.doc(gameId).set({
      'gameId': gameId,
      'lastViewedAt': FieldValue.serverTimestamp(),
      'lastSection': section.key,
      'completedSections': FieldValue.arrayUnion([section.key]),
    }, SetOptions(merge: true));
  }
}
