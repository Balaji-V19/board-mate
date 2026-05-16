import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../dependency_injection.dart';
import '../../domain/entities/user_progress_entity.dart';
import '../../domain/repositories/progress_repository.dart';

class ProgressNotifier extends ChangeNotifier {
  ProgressNotifier({required ProgressRepository repository})
      : _repo = repository {
    _sub = _repo.watchAll().listen(
      (list) {
        _items = list;
        notifyListeners();
      },
      onError: (Object e) {
        if (kDebugMode) {
          debugPrint('progress watchAll error: $e');
        }
      },
    );
  }

  final ProgressRepository _repo;
  StreamSubscription? _sub;

  List<UserProgressEntity> _items = const [];
  List<UserProgressEntity> get items => _items;

  UserProgressEntity? forGame(String gameId) {
    for (final p in _items) {
      if (p.gameId == gameId) return p;
    }
    return null;
  }

  /// The most-recently-touched game that still has at least one unfinished
  /// section. Used by the Home "Continue learning" card.
  UserProgressEntity? get continueCandidate {
    for (final p in _items) {
      if (!p.isComplete) return p; // list is pre-sorted by lastViewedAt desc
    }
    return _items.isEmpty ? null : _items.first;
  }

  Future<void> touch(String gameId, GuideSection section) =>
      _repo.touch(gameId, section);

  Future<void> markComplete(String gameId, GuideSection section) =>
      _repo.markComplete(gameId, section);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final progressNotifierProvider =
    ChangeNotifierProvider<ProgressNotifier>((ref) {
  return sl<ProgressNotifier>();
});
