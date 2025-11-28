
class Exam {
  final int id;
  final String title;

  Exam({required this.id, required this.title});

  factory Exam.fromMap(Map<String, dynamic> map) {
    return Exam(
      id: map['id'],
      title: map['title'],
    );
  }
}
