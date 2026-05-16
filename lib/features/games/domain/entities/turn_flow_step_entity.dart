import 'package:equatable/equatable.dart';

class TurnFlowStepEntity extends Equatable {
  const TurnFlowStepEntity({
    required this.order,
    required this.name,
    required this.description,
    this.iconKey,
    this.colorKey,
  });

  final int order;
  final String name;
  final String description;
  final String? iconKey;
  final String? colorKey;

  @override
  List<Object?> get props => [order, name, description, iconKey, colorKey];
}
