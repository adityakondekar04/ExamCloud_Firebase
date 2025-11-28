
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

import 'package:myapp/models/exam.dart';
import 'package:myapp/models/question.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;
  static Completer<void>? _dbSeedingCompleter;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      if (_dbSeedingCompleter != null) {
        await _dbSeedingCompleter!.future;
      }
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    _dbSeedingCompleter = Completer<void>();
    String path = join(await getDatabasesPath(), 'student_exam.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exams(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE questions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        examId INTEGER,
        questionText TEXT,
        options TEXT,
        correctOption INTEGER,
        FOREIGN KEY (examId) REFERENCES exams (id)
      )
    ''');
    await _seedDatabase(db);
    _dbSeedingCompleter!.complete();
  }

  Future<void> _seedDatabase(Database db) async {
    // Seed Exams
    int exam1Id = await db.insert('exams', {'title': 'Mathematics Exam'});
    int exam2Id = await db.insert('exams', {'title': 'History Exam'});

    // Seed Questions for Mathematics Exam
    await db.insert('questions', {
      'examId': exam1Id,
      'questionText': 'What is 2 + 2?',
      'options': '["3", "4", "5", "6"]',
      'correctOption': 1
    });
    await db.insert('questions', {
      'examId': exam1Id,
      'questionText': 'What is 10 * 5?',
      'options': '["40", "50", "60", "70"]',
      'correctOption': 1
    });
    await db.insert('questions', {
      'examId': exam1Id,
      'questionText': 'What is the square root of 81?',
      'options': '["7", "8", "9", "10"]',
      'correctOption': 2
    });
    await db.insert('questions', {
      'examId': exam1Id,
      'questionText': 'What is 12 / 3?',
      'options': '["2", "3", "4", "5"]',
      'correctOption': 2
    });


    // Seed Questions for History Exam
    await db.insert('questions', {
      'examId': exam2Id,
      'questionText': 'Who was the first president of the United States?',
      'options': '["Abraham Lincoln", "George Washington", "Thomas Jefferson", "John Adams"]',
      'correctOption': 1
    });
    await db.insert('questions', {
      'examId': exam2Id,
      'questionText': 'In which year did World War II end?',
      'options': '["1943", "1944", "1945", "1946"]',
      'correctOption': 2
    });
    await db.insert('questions', {
      'examId': exam2Id,
      'questionText': 'What was the primary cause of the Cold War?',
      'options': '["Economic competition", "Ideological conflict", "Territorial disputes", "All of the above"]',
      'correctOption': 1
    });
     await db.insert('questions', {
      'examId': exam2Id,
      'questionText': 'The ancient city of Rome was built on how many hills?',
      'options': '["5", "6", "7", "8"]',
      'correctOption': 2
    });
  }

  Future<List<Exam>> getExams() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('exams');
    return List.generate(maps.length, (i) {
      return Exam.fromMap(maps[i]);
    });
  }

  Future<List<Question>> getQuestions(int examId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: 'examId = ?',
      whereArgs: [examId],
    );
    return List.generate(maps.length, (i) {
      return Question.fromMap(maps[i]);
    });
  }
}
