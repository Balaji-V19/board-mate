import 'package:equatable/equatable.dart';

class ComponentEntity extends Equatable {
  const ComponentEntity({
    required this.name,
    required this.count,
    this.description = '',
    this.iconKey,
  });

  final String name;
  final int count;
  final String description;
  final String? iconKey;

  @override
  List<Object?> get props => [name, count, description, iconKey];
}
