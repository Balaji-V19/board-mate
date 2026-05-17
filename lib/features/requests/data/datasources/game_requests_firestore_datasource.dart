import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../config/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/game_request_entity.dart';

abstract class GameRequestsFirestoreDataSource {
  Future<void> submit(GameRequestEntity request);
}

class GameRequestsFirestoreDataSourceImpl
    implements GameRequestsFirestoreDataSource {
  GameRequestsFirestoreDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<void> submit(GameRequestEntity request) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw AuthException('Not signed in');
    await _firestore.collection(FirestoreCollections.requests).add({
      'uid': uid,
      'gameName': request.gameName,
      'category': request.category,
      'notes': request.notes,
      'submittedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }
}
