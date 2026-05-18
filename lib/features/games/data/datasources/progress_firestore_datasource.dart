import 'dart:async';

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

  CollectionReference<Map<String, dynamic>>? _colForUid(String? uid) {
    if (uid == null) return null;
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .collection(FirestoreCollections.progress);
  }

  @override
  Stream<List<UserProgressEntity>> watchAll() {
    return Stream.multi((controller) {
      StreamSubscription<List<UserProgressEntity>>? progressSub;

      void bindForUid(String? uid) {
        progressSub?.cancel();
        final col = _colForUid(uid);
        if (col == null) {
          controller.add(const <UserProgressEntity>[]);
          return;
        }
        progressSub = col.snapshots().map((snap) {
          return snap.docs
              .map((d) => _fromDoc(d.id, d.data()))
              .toList()
            ..sort((a, b) => b.lastViewedAt.compareTo(a.lastViewedAt));
        }).listen(
          controller.add,
          onError: (Object e) {
            if (kDebugMode) {
              debugPrint('watchProgress stream error: $e');
            }
            controller.add(const <UserProgressEntity>[]);
          },
        );
      }

      // Bind immediately for app restarts where user is already signed in.
      bindForUid(_auth.currentUser?.uid);

      final authSub = _auth.authStateChanges().listen(
        (user) => bindForUid(user?.uid),
        onError: (Object e) {
          if (kDebugMode) {
            debugPrint('authStateChanges error (progress): $e');
          }
          controller.add(const <UserProgressEntity>[]);
        },
      );

      controller.onCancel = () async {
        await progressSub?.cancel();
        await authSub.cancel();
      };
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
    final col = _colForUid(_auth.currentUser?.uid);
    if (col == null) throw AuthException('Not signed in');
    await col.doc(gameId).set({
      'gameId': gameId,
      'lastViewedAt': FieldValue.serverTimestamp(),
      'lastSection': section.key,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> markComplete(String gameId, GuideSection section) async {
    final col = _colForUid(_auth.currentUser?.uid);
    if (col == null) throw AuthException('Not signed in');
    await col.doc(gameId).set({
      'gameId': gameId,
      'lastViewedAt': FieldValue.serverTimestamp(),
      'lastSection': section.key,
      'completedSections': FieldValue.arrayUnion([section.key]),
    }, SetOptions(merge: true));
  }
}
