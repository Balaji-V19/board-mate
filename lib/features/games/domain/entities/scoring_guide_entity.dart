import 'package:equatable/equatable.dart';

class ScoringGuideEntity extends Equatable {
  const ScoringGuideEntity({
    required this.summary,
    this.points = const [],
    this.tieBreaker = '',
    this.gameEnd = '',
    this.targetScore,
    this.targetUnit,
  });

  final String summary;
  final List<String> points;
  final String tieBreaker;
  final String gameEnd;

  /// Numeric win threshold (e.g. 10 for Catan, 15 for Splendor). When set
  /// together with [targetUnit], the Quick Reference page surfaces a
  /// "Victory points" highlight card. Leave null for games without a fixed
  /// numeric target (cooperative wins, most-points-wins games, binary wins).
  final int? targetScore;

  /// Label that pairs with [targetScore], e.g. "victory points", "prestige
  /// points". Combined into "First to {score} {unit} wins the game".
  final String? targetUnit;

  bool get hasFixedTarget =>
      targetScore != null && (targetUnit ?? '').isNotEmpty;

  @override
  List<Object?> get props =>
      [summary, points, tieBreaker, gameEnd, targetScore, targetUnit];
}
