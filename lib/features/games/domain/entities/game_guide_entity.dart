import 'package:equatable/equatable.dart';

import 'component_entity.dart';
import 'faq_entity.dart';
import 'guide_step_entity.dart';
import 'quick_reference_entity.dart';
import 'scoring_guide_entity.dart';
import 'turn_flow_step_entity.dart';

class GameGuideEntity extends Equatable {
  const GameGuideEntity({
    required this.gameId,
    this.components = const [],
    this.setupSteps = const [],
    this.howToPlaySteps = const [],
    this.turnFlow = const [],
    this.scoring = const ScoringGuideEntity(summary: ''),
    this.faq = const [],
    this.commonMistakes = const [],
    this.quickReference = const QuickReferenceEntity(),
  });

  final String gameId;
  final List<ComponentEntity> components;
  final List<GuideStepEntity> setupSteps;
  final List<GuideStepEntity> howToPlaySteps;
  final List<TurnFlowStepEntity> turnFlow;
  final ScoringGuideEntity scoring;
  final List<FaqEntity> faq;
  final List<CommonMistakeEntity> commonMistakes;
  final QuickReferenceEntity quickReference;

  @override
  List<Object?> get props => [
        gameId,
        components,
        setupSteps,
        howToPlaySteps,
        turnFlow,
        scoring,
        faq,
        commonMistakes,
        quickReference,
      ];
}
