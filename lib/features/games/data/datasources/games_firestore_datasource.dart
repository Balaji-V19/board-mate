import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../config/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/board_game_entity.dart';
import '../../domain/entities/game_guide_entity.dart';
import '../models/game_models.dart';

abstract class GamesFirestoreDataSource {
  Future<List<BoardGameEntity>> getGames({String? category});
  Future<BoardGameEntity> getGameById(String id);
  Future<GameGuideEntity> getGameGuide(String gameId);
  Future<List<BoardGameEntity>> searchGames(String query);
}

class GamesFirestoreDataSourceImpl implements GamesFirestoreDataSource {
  GamesFirestoreDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _games =>
      _firestore.collection(FirestoreCollections.games);

  @override
  Future<List<BoardGameEntity>> getGames({String? category}) async {
    // Filter+order on different fields would need a composite index. Keep the
    // query simple (one of: order OR filter) and sort the small result set
    // client-side.
    Query<Map<String, dynamic>> q = _games;
    if (category != null && category.isNotEmpty) {
      q = q.where('categories', arrayContains: category);
    } else {
      q = q.orderBy('popularity', descending: true);
    }
    final snap = await q.limit(60).get();
    final games =
        snap.docs.map((d) => boardGameFromJson(d.id, d.data())).toList();
    games.sort((a, b) => b.popularity.compareTo(a.popularity));
    return games;
  }

  @override
  Future<BoardGameEntity> getGameById(String id) async {
    final doc = await _games.doc(id).get();
    if (!doc.exists) throw NotFoundException('Game not found');
    return boardGameFromJson(doc.id, doc.data()!);
  }

  @override
  Future<GameGuideEntity> getGameGuide(String gameId) async {
    final doc = await _games
        .doc(gameId)
        .collection(FirestoreCollections.gameGuideSubcollection)
        .doc(FirestoreCollections.gameGuideDoc)
        .get();
    if (!doc.exists) throw NotFoundException('Guide not found');
    return gameGuideFromJson(gameId, doc.data()!);
  }

  @override
  Future<List<BoardGameEntity>> searchGames(String query) async {
    final lower = query.trim().toLowerCase();
    if (lower.isEmpty) return getGames();
    final snap = await _games.orderBy('popularity', descending: true).limit(120).get();
    return snap.docs
        .map((d) => boardGameFromJson(d.id, d.data()))
        .where((g) =>
            g.name.toLowerCase().contains(lower) ||
            g.categories.any((c) => c.toLowerCase().contains(lower)))
        .toList()
      ..sort((a, b) => b.popularity.compareTo(a.popularity));
  }
}
