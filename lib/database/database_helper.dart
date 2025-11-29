
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:examcloud/models/exam.dart';
import 'package:examcloud/models/question.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'exam_database.db');

    // For development, you might want to delete the database to re-seed it
    await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exams(
        id INTEGER PRIMARY KEY,
        title TEXT,
        startTime TEXT,
        duration INTEGER,
        passkey TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE questions(
        id INTEGER PRIMARY KEY,
        examId INTEGER,
        questionText TEXT,
        options TEXT,
        correctAnswerIndex INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE user_exams(
        examId INTEGER PRIMARY KEY,
        FOREIGN KEY (examId) REFERENCES exams (id)
      )
    ''');

    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    // Seed Exams
    await db.insert('exams', {
      'id': 1,
      'title': 'Mathematics Exam',
      'startTime': DateTime.now().add(const Duration(minutes: 1)).toIso8601String(),
      'duration': 60,
      'passkey': 'math123',
    });
    await db.insert('exams', {
      'id': 2,
      'title': 'History Exam',
      'startTime': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
      'duration': 45,
      'passkey': 'hist123',
    });

    // Seed Questions for Math Exam (id: 1)
    await db.insert('questions', {
      'id': 1,
      'examId': 1,
      'questionText': 'What is 2 + 2?',
      'options': '3||4||5||6',
      'correctAnswerIndex': 1,
    });
    await db.insert('questions', {
      'id': 2,
      'examId': 1,
      'questionText': 'What is 10 * 5?',
      'options': '45||55||50||60',
      'correctAnswerIndex': 2,
    });

    // Seed Questions for History Exam (id: 2)
    await db.insert('questions', {
      'id': 3,
      'examId': 2,
      'questionText': 'Who was the first president of the United States?',
      'options': 'Thomas Jefferson||Abraham Lincoln||George Washington||John Adams',
      'correctAnswerIndex': 2,
    });
  }

  Future<List<Exam>> getExams() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('exams');
    return List.generate(maps.length, (i) => Exam.fromMap(maps[i]));
  }

  Future<List<Question>> getQuestions(int examId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: 'examId = ?',
      whereArgs: [examId],
    );
    return List.generate(maps.length, (i) => Question.fromMap(maps[i]));
  }

  Future<void> registerForExam(int examId) async {
    final db = await database;
    await db.insert(
      'user_exams',
      {'examId': examId},
      conflictAlgorithm: ConflictAlgorithm.ignore, // Ignore if already registered
    );
  }

  Future<List<Exam>> getRegisteredExams() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT e.* FROM exams e
      INNER JOIN user_exams ue ON e.id = ue.examId
    ''');
    return List.generate(maps.length, (i) => Exam.fromMap(maps[i]));
  }

  Future<List<Exam>> getSelectedExams() async {
    return getRegisteredExams(); // Keep for compatibility if used elsewhere
  }

  Future<void> addExamToUser(int examId) async {
    await registerForExam(examId); // Keep for compatibility
  }
}
