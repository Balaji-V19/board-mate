import 'package:equatable/equatable.dart';

class GuideStepEntity extends Equatable {
  const GuideStepEntity({
    required this.order,
    required this.title,
    required this.body,
    this.tip,
    this.warning,
    this.illustrationKey,
    this.checklist = const [],
    this.rules = const [],
    this.images = const [],
    this.elements = const [],
  });

  final int order;
  final String title;
  final String body;
  final String? tip;
  final String? warning;
  final String? illustrationKey;
  final List<String> checklist;
  final List<NumberedRuleEntity> rules;
  final List<StepImage> images;

  /// Optional tappable game pieces tied to this step. Each one carries a
  /// short mascot explanation that's shown in the on-page speech bubble.
  /// Absent for legacy games — the screen renders without an element strip.
  final List<StepElement> elements;

  @override
  List<Object?> get props => [
        order,
        title,
        body,
        tip,
        warning,
        illustrationKey,
        checklist,
        rules,
        images,
        elements,
      ];
}

class StepImage extends Equatable {
  const StepImage({this.iconKey, this.photoKey, this.url, this.caption});

  /// Concept key from the icon registry in `BmConceptImage`. Renders as a
  /// tinted Material icon. Used as a fallback when no photo loads.
  final String? iconKey;

  /// Concept key from the photo registry in `BmConceptImage`. Resolves to a
  /// verified royalty-free Unsplash URL.
  final String? photoKey;

  /// Optional explicit image URL (overrides `photoKey`). Must be CC0 /
  /// royalty-free.
  final String? url;

  final String? caption;

  @override
  List<Object?> get props => [iconKey, photoKey, url, caption];
}

/// A tappable game piece / component highlighted on a setup step. When the
/// user taps the element card, the mascot's speech bubble switches to
/// [message] and the mascot can briefly change mood (via [moodKey]).
class StepElement extends Equatable {
  const StepElement({
    required this.name,
    this.iconKey,
    this.photoKey,
    required this.message,
    this.moodKey,
  });

  /// Short label shown on the card itself (e.g. "Dice").
  final String name;

  /// Concept key from the icon registry in `BmConceptImage`. Used when no
  /// photo is provided.
  final String? iconKey;

  /// Concept key from the photo registry in `BmConceptImage`.
  final String? photoKey;

  /// What the mascot says when this element is tapped.
  final String message;

  /// One of: `welcome | thinking | teaching | reading | curious | celebrating`.
  /// Null falls back to `thinking` (default "explaining a piece" mood).
  final String? moodKey;

  @override
  List<Object?> get props => [name, iconKey, photoKey, message, moodKey];
}

class NumberedRuleEntity extends Equatable {
  const NumberedRuleEntity({
    required this.number,
    required this.title,
    required this.body,
  });

  final int number;
  final String title;
  final String body;

  @override
  List<Object?> get props => [number, title, body];
}
