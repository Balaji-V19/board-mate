import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../config/constants/api_constants.dart';

/// One-shot Firestore seeder for the sample games shipped in
/// `assets/seed/games.json`. Triggered from the debug-only settings entry.
class SeedService {
  SeedService._();
  static final SeedService instance = SeedService._();

  Future<int> seedGames() async {
    final raw = await rootBundle.loadString('assets/seed/games.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    final firestore = FirebaseFirestore.instance;
    int count = 0;
    for (final entry in list) {
      final id = entry['id'] as String;
      final game = entry['game'] as Map<String, dynamic>;
      final guide = entry['guide'] as Map<String, dynamic>;

      final batch = firestore.batch();
      final gameRef =
          firestore.collection(FirestoreCollections.games).doc(id);
      batch.set(
        gameRef,
        {
          ...game,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      final guideRef = gameRef
          .collection(FirestoreCollections.gameGuideSubcollection)
          .doc(FirestoreCollections.gameGuideDoc);
      batch.set(guideRef, guide, SetOptions(merge: true));
      await batch.commit();
      count++;
    }
    return count;
  }
}
