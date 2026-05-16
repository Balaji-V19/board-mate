import 'package:equatable/equatable.dart';

class ScoringGuideEntity extends Equatable {
  const ScoringGuideEntity({
    required this.summary,
    this.points = const [],
    this.tieBreaker = '',
    this.gameEnd = '',
  });

  final String summary;
  final List<String> points;
  final String tieBreaker;
  final String gameEnd;

  @override
  List<Object?> get props => [summary, points, tieBreaker, gameEnd];
}
