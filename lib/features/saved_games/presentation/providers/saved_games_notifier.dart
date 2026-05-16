import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../dependency_injection.dart';
import '../../domain/entities/saved_game_entity.dart';
import '../../domain/repositories/saved_games_repository.dart';

class SavedGamesNotifier extends ChangeNotifier {
  SavedGamesNotifier({required SavedGamesRepository repository})
      : _repo = repository {
    _sub = _repo.watchSaved().listen((list) {
      _items = list;
      notifyListeners();
    });
  }

  final SavedGamesRepository _repo;
  StreamSubscription? _sub;

  List<SavedGameEntity> _items = const [];
  List<SavedGameEntity> get items => _items;

  bool isSaved(String gameId) => _items.any((s) => s.gameId == gameId);

  Future<void> toggle(String gameId) async {
    if (isSaved(gameId)) {
      await _repo.unsave(gameId);
    } else {
      await _repo.save(gameId);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final savedGamesNotifierProvider =
    ChangeNotifierProvider<SavedGamesNotifier>((ref) {
  return sl<SavedGamesNotifier>();
});
