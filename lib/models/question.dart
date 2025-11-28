
import 'dart:convert';

class Question {
  final int id;
  final int examId;
  final String questionText;
  final List<String> options;
  final int correctOption;

  Question({
    required this.id,
    required this.examId,
    required this.questionText,
    required this.options,
    required this.correctOption,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      examId: map['examId'],
      questionText: map['questionText'],
      options: List<String>.from(json.decode(map['options'])),
      correctOption: map['correctOption'],
    );
  }
}
