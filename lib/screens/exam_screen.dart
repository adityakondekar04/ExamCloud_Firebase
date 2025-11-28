
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:myapp/database/database_helper.dart';
import 'package:myapp/models/exam.dart';
import 'package:myapp/models/question.dart';
import 'package:myapp/widgets/custom_radio_tile.dart';

class ExamScreen extends StatefulWidget {
  final Exam exam;
  const ExamScreen({super.key, required this.exam});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late Future<List<Question>> _questions;
  final PageController _pageController = PageController();
  late List<int?> _selectedAnswers;
  bool _isFinished = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _questions = DatabaseHelper().getQuestions(widget.exam.id);
    _questions.then((questions) {
      if (mounted) {
        setState(() {
          _selectedAnswers = List.filled(questions.length, null);
        });
      }
    });

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (!result.contains(ConnectivityResult.none) || result.length > 1) {
        if (mounted) {
          context.go('/disqualified');
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _finishExam() {
    if (!mounted) return;
    setState(() {
      _isFinished = true;
    });
    _connectivitySubscription.cancel(); // Stop listening for connectivity changes
    context.go('/submission', extra: {
      'exam': widget.exam,
      'answers': _selectedAnswers,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam.title),
        automaticallyImplyLeading: false, // Prevents going back
      ),
      body: FutureBuilder<List<Question>>(
        future: _questions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No questions available for this exam.'));
          } else {
            final questions = snapshot.data!;
            if (_selectedAnswers.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: questions.length + 1, // +1 for the finish button
              itemBuilder: (context, index) {
                if (index == questions.length) {
                  return _buildFinishPage(questions.length);
                }
                final question = questions[index];
                return _buildQuestionPage(question, index, questions.length);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildQuestionPage(Question question, int index, int totalQuestions) {
    return PopScope(
      canPop: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${index + 1} of $totalQuestions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              question.questionText,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ...question.options.asMap().entries.map((entry) {
              int optionIndex = entry.key;
              String optionText = entry.value;
              return CustomRadioTile<int>(
                title: Text(optionText),
                value: optionIndex,
                groupValue: _selectedAnswers[index],
                onChanged: (value) {
                  if (!_isFinished) {
                    setState(() {
                      _selectedAnswers[index] = value;
                    });
                  }
                },
              );
            }),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (index > 0)
                  ElevatedButton.icon(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  ),
                ElevatedButton.icon(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishPage(int totalQuestions) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'You have reached the end of the exam.',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'You have answered ${_selectedAnswers.where((a) => a != null).length} out of $totalQuestions questions.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _finishExam,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Finish Exam'),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
