import 'package:equatable/equatable.dart';

class SavedGameEntity extends Equatable {
  const SavedGameEntity({
    required this.gameId,
    required this.savedAt,
    this.downloaded = false,
  });

  final String gameId;
  final DateTime savedAt;
  final bool downloaded;

  @override
  List<Object?> get props => [gameId, savedAt, downloaded];
}
