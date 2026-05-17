import '../../domain/entities/board_game_entity.dart';
import '../../domain/entities/component_entity.dart';
import '../../domain/entities/faq_entity.dart';
import '../../domain/entities/game_guide_entity.dart';
import '../../domain/entities/guide_step_entity.dart';
import '../../domain/entities/quick_reference_entity.dart';
import '../../domain/entities/scoring_guide_entity.dart';
import '../../domain/entities/turn_flow_step_entity.dart';

/// JSON mappers for games and guides. Plain Dart — no codegen so the seed
/// JSON files map cleanly without needing build_runner for the data layer.

BoardGameEntity boardGameFromJson(String id, Map<String, dynamic> j) {
  return BoardGameEntity(
    id: id,
    name: (j['name'] ?? '') as String,
    description: (j['description'] ?? '') as String,
    objective: (j['objective'] ?? '') as String,
    categories: ((j['categories'] as List?) ?? const [])
        .map((e) => e as String)
        .toList(),
    minPlayers: (j['minPlayers'] ?? 1) as int,
    maxPlayers: (j['maxPlayers'] ?? 1) as int,
    minMinutes: (j['minMinutes'] ?? 0) as int,
    maxMinutes: (j['maxMinutes'] ?? 0) as int,
    difficulty: (j['difficulty'] ?? 'Medium') as String,
    ageRange: (j['ageRange'] ?? '') as String,
    imageUrl: (j['imageUrl'] ?? '') as String,
    rating: (j['rating'] as num?)?.toDouble(),
    popularity: (j['popularity'] ?? 0) as int,
  );
}

Map<String, dynamic> boardGameToJson(BoardGameEntity g) => {
      'name': g.name,
      'description': g.description,
      'objective': g.objective,
      'categories': g.categories,
      'minPlayers': g.minPlayers,
      'maxPlayers': g.maxPlayers,
      'minMinutes': g.minMinutes,
      'maxMinutes': g.maxMinutes,
      'difficulty': g.difficulty,
      'ageRange': g.ageRange,
      'imageUrl': g.imageUrl,
      'rating': g.rating,
      'popularity': g.popularity,
    };

ComponentEntity _componentFromJson(Map<String, dynamic> j) => ComponentEntity(
      name: (j['name'] ?? '') as String,
      count: (j['count'] ?? 1) as int,
      description: (j['description'] ?? '') as String,
      iconKey: j['iconKey'] as String?,
    );

GuideStepEntity _stepFromJson(Map<String, dynamic> j) => GuideStepEntity(
      order: (j['order'] ?? 0) as int,
      title: (j['title'] ?? '') as String,
      body: (j['body'] ?? '') as String,
      tip: j['tip'] as String?,
      warning: j['warning'] as String?,
      illustrationKey: j['illustrationKey'] as String?,
      checklist: ((j['checklist'] as List?) ?? const [])
          .map((e) => e as String)
          .toList(),
      rules: ((j['rules'] as List?) ?? const [])
          .map((r) => NumberedRuleEntity(
                number: (r['number'] ?? 0) as int,
                title: (r['title'] ?? '') as String,
                body: (r['body'] ?? '') as String,
              ))
          .toList(),
      images: ((j['images'] as List?) ?? const [])
          .map((e) => StepImage(
                iconKey: (e as Map<String, dynamic>)['iconKey'] as String?,
                photoKey: e['photoKey'] as String?,
                url: e['url'] as String?,
                caption: e['caption'] as String?,
              ))
          .toList(),
    );

TurnFlowStepEntity _turnStepFromJson(Map<String, dynamic> j) =>
    TurnFlowStepEntity(
      order: (j['order'] ?? 0) as int,
      name: (j['name'] ?? '') as String,
      description: (j['description'] ?? '') as String,
      iconKey: j['iconKey'] as String?,
      colorKey: j['colorKey'] as String?,
    );

ScoringGuideEntity _scoringFromJson(Map<String, dynamic> j) =>
    ScoringGuideEntity(
      summary: (j['summary'] ?? '') as String,
      points: ((j['points'] as List?) ?? const [])
          .map((e) => e as String)
          .toList(),
      tieBreaker: (j['tieBreaker'] ?? '') as String,
      gameEnd: (j['gameEnd'] ?? '') as String,
      targetScore: (j['targetScore'] as num?)?.toInt(),
      targetUnit: j['targetUnit'] as String?,
    );

QuickReferenceEntity _quickRefFromJson(Map<String, dynamic> j) =>
    QuickReferenceEntity(
      sections: ((j['sections'] as List?) ?? const [])
          .map((s) => QuickReferenceSection(
                title: (s['title'] ?? '') as String,
                subtitle: s['subtitle'] as String?,
                items: ((s['items'] as List?) ?? const [])
                    .map((e) => e as String)
                    .toList(),
              ))
          .toList(),
    );

GameGuideEntity gameGuideFromJson(String gameId, Map<String, dynamic> j) {
  return GameGuideEntity(
    gameId: gameId,
    components: ((j['components'] as List?) ?? const [])
        .map((e) => _componentFromJson(e as Map<String, dynamic>))
        .toList(),
    setupSteps: ((j['setupSteps'] as List?) ?? const [])
        .map((e) => _stepFromJson(e as Map<String, dynamic>))
        .toList(),
    howToPlaySteps: ((j['howToPlaySteps'] as List?) ?? const [])
        .map((e) => _stepFromJson(e as Map<String, dynamic>))
        .toList(),
    turnFlow: ((j['turnFlow'] as List?) ?? const [])
        .map((e) => _turnStepFromJson(e as Map<String, dynamic>))
        .toList(),
    scoring: j['scoring'] == null
        ? const ScoringGuideEntity(summary: '')
        : _scoringFromJson(j['scoring'] as Map<String, dynamic>),
    faq: ((j['faq'] as List?) ?? const [])
        .map((e) => FaqEntity(
              question: (e['question'] ?? '') as String,
              answer: (e['answer'] ?? '') as String,
            ))
        .toList(),
    commonMistakes: ((j['commonMistakes'] as List?) ?? const [])
        .map((e) => CommonMistakeEntity(
              title: (e['title'] ?? '') as String,
              body: (e['body'] ?? '') as String,
            ))
        .toList(),
    quickReference: j['quickReference'] == null
        ? const QuickReferenceEntity()
        : _quickRefFromJson(j['quickReference'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> gameGuideToJson(GameGuideEntity g) => {
      'components': g.components
          .map((c) => {
                'name': c.name,
                'count': c.count,
                'description': c.description,
                'iconKey': c.iconKey,
              })
          .toList(),
      'setupSteps': g.setupSteps.map(_stepToJson).toList(),
      'howToPlaySteps': g.howToPlaySteps.map(_stepToJson).toList(),
      'turnFlow': g.turnFlow
          .map((t) => {
                'order': t.order,
                'name': t.name,
                'description': t.description,
                'iconKey': t.iconKey,
                'colorKey': t.colorKey,
              })
          .toList(),
      'scoring': {
        'summary': g.scoring.summary,
        'points': g.scoring.points,
        'tieBreaker': g.scoring.tieBreaker,
        'gameEnd': g.scoring.gameEnd,
        'targetScore': g.scoring.targetScore,
        'targetUnit': g.scoring.targetUnit,
      },
      'faq': g.faq.map((f) => {'question': f.question, 'answer': f.answer}).toList(),
      'commonMistakes': g.commonMistakes
          .map((m) => {'title': m.title, 'body': m.body})
          .toList(),
      'quickReference': {
        'sections': g.quickReference.sections
            .map((s) => {
                  'title': s.title,
                  'subtitle': s.subtitle,
                  'items': s.items,
                })
            .toList(),
      },
    };

Map<String, dynamic> _stepToJson(GuideStepEntity s) => {
      'order': s.order,
      'title': s.title,
      'body': s.body,
      'tip': s.tip,
      'warning': s.warning,
      'illustrationKey': s.illustrationKey,
      'checklist': s.checklist,
      'rules': s.rules
          .map((r) =>
              {'number': r.number, 'title': r.title, 'body': r.body})
          .toList(),
      'images': s.images
          .map((i) => {
                'iconKey': i.iconKey,
                'photoKey': i.photoKey,
                'url': i.url,
                'caption': i.caption,
              })
          .toList(),
    };
