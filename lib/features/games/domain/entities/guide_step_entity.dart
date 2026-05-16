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
  const StepImage({this.iconKey, this.url, this.caption});

  /// Concept key from the registry in `BmConceptImage`. The widget falls back
  /// to a generic icon when the key is unknown.
  final String? iconKey;

  /// Optional external image URL (must be CC0 / royalty-free).
  final String? url;

  final String? caption;

  @override
  List<Object?> get props => [iconKey, url, caption];
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
