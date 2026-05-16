import 'package:equatable/equatable.dart';

class QuickReferenceEntity extends Equatable {
  const QuickReferenceEntity({this.sections = const []});
  final List<QuickReferenceSection> sections;

  @override
  List<Object?> get props => [sections];
}

class QuickReferenceSection extends Equatable {
  const QuickReferenceSection({
    required this.title,
    required this.items,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<String> items;

  @override
  List<Object?> get props => [title, subtitle, items];
}
