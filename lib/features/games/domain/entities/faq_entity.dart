import 'package:equatable/equatable.dart';

class FaqEntity extends Equatable {
  const FaqEntity({required this.question, required this.answer});
  final String question;
  final String answer;

  @override
  List<Object?> get props => [question, answer];
}

class CommonMistakeEntity extends Equatable {
  const CommonMistakeEntity({required this.title, required this.body});
  final String title;
  final String body;

  @override
  List<Object?> get props => [title, body];
}
