import 'package:equatable/equatable.dart';

class BoardGameEntity extends Equatable {
  const BoardGameEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.objective,
    required this.categories,
    required this.minPlayers,
    required this.maxPlayers,
    required this.minMinutes,
    required this.maxMinutes,
    required this.difficulty,
    required this.ageRange,
    required this.imageUrl,
    this.rating,
    this.popularity = 0,
  });

  final String id;
  final String name;
  final String description;
  final String objective;
  final List<String> categories;
  final int minPlayers;
  final int maxPlayers;
  final int minMinutes;
  final int maxMinutes;
  final String difficulty;
  final String ageRange;
  final String imageUrl;
  final double? rating;
  final int popularity;

  String get playerRange =>
      minPlayers == maxPlayers ? '$minPlayers' : '$minPlayers-$maxPlayers';
  String get minutesRange =>
      minMinutes == maxMinutes ? '$minMinutes' : '$minMinutes-$maxMinutes';

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        objective,
        categories,
        minPlayers,
        maxPlayers,
        minMinutes,
        maxMinutes,
        difficulty,
        ageRange,
        imageUrl,
        rating,
        popularity,
      ];
}
