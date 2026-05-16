import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../dependency_injection.dart';
import '../../domain/usecases/get_game_by_id.dart';
import '../../domain/usecases/get_game_guide.dart';
import '../../domain/usecases/get_games.dart';
import '../../domain/usecases/search_games.dart';
import 'games_state.dart';

class GamesListNotifier extends ChangeNotifier {
  GamesListNotifier({required GetGamesUseCase getGames}) : _getGames = getGames {
    load();
  }
  final GetGamesUseCase _getGames;

  GamesListState _state = const GamesListState.initial();
  GamesListState get state => _state;
  String? _category;

  void _set(GamesListState s) {
    _state = s;
    notifyListeners();
  }

  Future<void> load({String? category}) async {
    _category = category;
    _set(const GamesListState.loading());
    final r = await _getGames(category: category);
    r.fold(
      (f) => _set(GamesListState.error(f.message)),
      (games) => _set(GamesListState.loaded(games)),
    );
  }

  Future<void> refresh() => load(category: _category);
}

final gamesListNotifierProvider =
    ChangeNotifierProvider<GamesListNotifier>((ref) {
  return sl<GamesListNotifier>();
});

class GameDetailNotifier extends ChangeNotifier {
  GameDetailNotifier({required GetGameByIdUseCase getById}) : _getById = getById;
  final GetGameByIdUseCase _getById;

  GameDetailState _state = const GameDetailState.initial();
  GameDetailState get state => _state;

  void _set(GameDetailState s) {
    _state = s;
    notifyListeners();
  }

  Future<void> load(String id) async {
    _set(const GameDetailState.loading());
    final r = await _getById(id);
    r.fold(
      (f) => _set(GameDetailState.error(f.message)),
      (g) => _set(GameDetailState.loaded(g)),
    );
  }
}

final gameDetailNotifierProvider =
    ChangeNotifierProvider.family<GameDetailNotifier, String>((ref, id) {
  final n = sl<GameDetailNotifier>();
  n.load(id);
  return n;
});

class GuideNotifier extends ChangeNotifier {
  GuideNotifier({required GetGameGuideUseCase getGuide}) : _getGuide = getGuide;
  final GetGameGuideUseCase _getGuide;

  GuideState _state = const GuideState.initial();
  GuideState get state => _state;

  void _set(GuideState s) {
    _state = s;
    notifyListeners();
  }

  Future<void> load(String gameId) async {
    _set(const GuideState.loading());
    final r = await _getGuide(gameId);
    r.fold(
      (f) => _set(GuideState.error(f.message)),
      (g) => _set(GuideState.loaded(g)),
    );
  }
}

final guideNotifierProvider =
    ChangeNotifierProvider.family<GuideNotifier, String>((ref, gameId) {
  final n = sl<GuideNotifier>();
  n.load(gameId);
  return n;
});

class BrowseNotifier extends ChangeNotifier {
  BrowseNotifier({
    required GetGamesUseCase getGames,
    required SearchGamesUseCase searchGames,
  })  : _getGames = getGames,
        _searchGames = searchGames {
    load();
  }
  final GetGamesUseCase _getGames;
  final SearchGamesUseCase _searchGames;

  GamesListState _state = const GamesListState.initial();
  GamesListState get state => _state;

  String _query = '';
  String? _category;
  String get query => _query;
  String? get category => _category;

  void _set(GamesListState s) {
    _state = s;
    notifyListeners();
  }

  Future<void> load() async {
    _set(const GamesListState.loading());
    final r = _query.isEmpty
        ? await _getGames(category: _category)
        : await _searchGames(_query);
    r.fold(
      (f) => _set(GamesListState.error(f.message)),
      (games) {
        final filtered = _category == null || _query.isNotEmpty
            ? games
            : games.where((g) => g.categories.contains(_category)).toList();
        _set(GamesListState.loaded(filtered));
      },
    );
  }

  Future<void> setQuery(String q) {
    _query = q;
    return load();
  }

  Future<void> setCategory(String? c) {
    _category = c;
    return load();
  }
}

final browseNotifierProvider = ChangeNotifierProvider<BrowseNotifier>((ref) {
  return sl<BrowseNotifier>();
});
