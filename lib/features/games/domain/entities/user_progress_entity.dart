import 'package:equatable/equatable.dart';

/// All sections a user can complete for a single game.
enum GuideSection { setup, howToPlay, quickReference }

extension GuideSectionX on GuideSection {
  String get key => switch (this) {
        GuideSection.setup => 'setup',
        GuideSection.howToPlay => 'howToPlay',
        GuideSection.quickReference => 'quickReference',
      };

  String get label => switch (this) {
        GuideSection.setup => 'Setup',
        GuideSection.howToPlay => 'How to play',
        GuideSection.quickReference => 'Quick reference',
      };

  String get routeSegment => switch (this) {
        GuideSection.setup => 'setup',
        GuideSection.howToPlay => 'how-to-play',
        GuideSection.quickReference => 'quick-reference',
      };

  static GuideSection? fromKey(String key) {
    return switch (key) {
      'setup' => GuideSection.setup,
      'howToPlay' => GuideSection.howToPlay,
      'quickReference' => GuideSection.quickReference,
      _ => null,
    };
  }
}

class UserProgressEntity extends Equatable {
  const UserProgressEntity({
    required this.gameId,
    required this.lastViewedAt,
    this.lastSection,
    this.completedSections = const {},
  });

  final String gameId;
  final DateTime lastViewedAt;
  final GuideSection? lastSection;
  final Set<GuideSection> completedSections;

  /// 0.0 → 1.0 across the three sections.
  double get percent => completedSections.length / 3.0;

  bool get isComplete => completedSections.length >= 3;

  bool isCompleted(GuideSection s) => completedSections.contains(s);

  UserProgressEntity copyWith({
    DateTime? lastViewedAt,
    GuideSection? lastSection,
    Set<GuideSection>? completedSections,
  }) =>
      UserProgressEntity(
        gameId: gameId,
        lastViewedAt: lastViewedAt ?? this.lastViewedAt,
        lastSection: lastSection ?? this.lastSection,
        completedSections: completedSections ?? this.completedSections,
      );

  @override
  List<Object?> get props =>
      [gameId, lastViewedAt, lastSection, completedSections];
}
