
class Exam {
  final int id;
  final String title;
  final DateTime startTime;
  final int duration; // in minutes
  final String passkey;
  bool selected;

  Exam({
    required this.id,
    required this.title,
    required this.startTime,
    required this.duration,
    required this.passkey,
    this.selected = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'duration': duration,
      'passkey': passkey,
    };
  }

  factory Exam.fromMap(Map<String, dynamic> map) {
    return Exam(
      id: map['id'],
      title: map['title'],
      startTime: DateTime.parse(map['startTime']),
      duration: map['duration'],
      passkey: map['passkey'],
    );
  }
}
