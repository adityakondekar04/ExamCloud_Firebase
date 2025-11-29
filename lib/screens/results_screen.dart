
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:examcloud/models/exam.dart';
import 'package:examcloud/models/question.dart';
import 'package:examcloud/database/database_helper.dart';

class ResultsScreen extends StatefulWidget {
  final Exam exam;
  final Map<int, int> answers;

  const ResultsScreen({super.key, required this.exam, required this.answers});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  int _score = 0;
  late List<Question> _questions;

  @override
  void initState() {
    super.initState();
    _questions = [];
    _loadQuestionsAndCalculateScore();
  }

  void _loadQuestionsAndCalculateScore() async {
    final questions = await DatabaseHelper().getQuestions(widget.exam.id!);
    int correctAnswers = 0;
    for (var question in questions) {
      if (widget.answers.containsKey(question.id) &&
          widget.answers[question.id] == question.correctAnswerIndex) {
        correctAnswers++;
      }
    }
    setState(() {
      _questions = questions;
      _score = correctAnswers;
    });
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.exam.title} - Results'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Exam Submitted Successfully!',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (_questions.isNotEmpty)
                Text(
                  'Your Score: $_score / ${_questions.length}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
