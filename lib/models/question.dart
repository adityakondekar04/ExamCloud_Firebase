
class Question {
  final int id;
  final int examId;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.id,
    required this.examId,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'examId': examId,
      'questionText': questionText,
      'options': options.join('||'), // Store options as a delimited string
      'correctAnswerIndex': correctAnswerIndex,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      examId: map['examId'],
      questionText: map['questionText'],
      options: (map['options'] as String).split('||'),
      correctAnswerIndex: map['correctAnswerIndex'],
    );
  }
}
