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
