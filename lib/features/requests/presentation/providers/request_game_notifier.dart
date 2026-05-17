import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../dependency_injection.dart';
import '../../domain/entities/game_request_entity.dart';
import '../../domain/repositories/game_requests_repository.dart';

enum SubmitStatus { idle, submitting, success, error }

class RequestGameNotifier extends ChangeNotifier {
  RequestGameNotifier({required GameRequestsRepository repository})
      : _repo = repository;

  final GameRequestsRepository _repo;

  SubmitStatus _status = SubmitStatus.idle;
  String? _errorMessage;

  SubmitStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _status == SubmitStatus.submitting;

  void resetIfNotSubmitting() {
    if (_status == SubmitStatus.submitting) return;
    if (_status == SubmitStatus.idle && _errorMessage == null) return;
    _status = SubmitStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> submit(GameRequestEntity request) async {
    _status = SubmitStatus.submitting;
    _errorMessage = null;
    notifyListeners();
    final result = await _repo.submit(request);
    return result.fold(
      (failure) {
        _status = SubmitStatus.error;
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _status = SubmitStatus.success;
        notifyListeners();
        return true;
      },
    );
  }
}

final requestGameNotifierProvider =
    ChangeNotifierProvider<RequestGameNotifier>((ref) {
  return sl<RequestGameNotifier>();
});
