import 'package:equatable/equatable.dart';

class GameRequestEntity extends Equatable {
  const GameRequestEntity({
    required this.gameName,
    required this.category,
    required this.notes,
  });

  final String gameName;
  final String category;
  final String notes;

  @override
  List<Object?> get props => [gameName, category, notes];
}
