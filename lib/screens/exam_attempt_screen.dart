
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:examcloud/models/exam.dart';
import 'package:examcloud/models/question.dart';
import 'package:examcloud/database/database_helper.dart';

class ExamAttemptScreen extends StatefulWidget {
  final Exam exam;

  const ExamAttemptScreen({super.key, required this.exam});

  @override
  State<ExamAttemptScreen> createState() => _ExamAttemptScreenState();
}

class _ExamAttemptScreenState extends State<ExamAttemptScreen>
    with WidgetsBindingObserver {
  late List<Question> _questions;
  late Map<int, int> _selectedAnswers;
  late Timer _timer;
  int _remainingSeconds = 0;
  bool _isDisqualified = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _questions = [];
    _selectedAnswers = {};
    _remainingSeconds = widget.exam.duration * 60;
    _loadQuestions();
    _startTimer();
    _checkInitialConnectivity();
    _listenToConnectivityChanges();
  }

  void _loadQuestions() async {
    final questions = await DatabaseHelper().getQuestions(widget.exam.id!);
    setState(() {
      _questions = questions;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
        _submitExam();
      }
    });
  }

  void _checkInitialConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (!connectivityResult.contains(ConnectivityResult.none)) {
      _disqualifyUser();
    }
  }

  void _listenToConnectivityChanges() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (!results.contains(ConnectivityResult.none)) {
        _disqualifyUser();
      }
    });
  }

  void _disqualifyUser() {
    if (!_isDisqualified) {
      setState(() {
        _isDisqualified = true;
      });
      _timer.cancel();
      _connectivitySubscription.cancel();
      context.go('/disqualified');
    }
  }

  void _submitExam() {
    _timer.cancel();
    _connectivitySubscription.cancel();
    context.go('/submission',
        extra: {'exam': widget.exam, 'answers': _selectedAnswers});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _disqualifyUser();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    _connectivitySubscription.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam.title),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _formattedTime,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
      body: _questions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      return _buildQuestionCard(_questions[index], index + 1);
                    },
                  ),
                ),
                _buildNavigationControls(),
              ],
            ),
    );
  }

  Widget _buildQuestionCard(Question question, int questionNumber) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question $questionNumber of ${_questions.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                question.questionText,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              ...question.options.asMap().entries.map((entry) {
                final optionIndex = entry.key;
                final optionText = entry.value;
                return RadioListTile<int>(
                  title: Text(optionText),
                  value: optionIndex,
                  groupValue: _selectedAnswers[question.id!],
                  onChanged: (value) {
                    setState(() {
                      _selectedAnswers[question.id!] = value!;
                    });
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationControls() {
    bool isLastQuestion = _currentPage == _questions.length - 1;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _currentPage > 0
                ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            child: const Text('Previous'),
          ),
          if (isLastQuestion)
            ElevatedButton(
              onPressed: _submitExam,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Finish Exam'),
            )
          else
            ElevatedButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('Next'),
            ),
        ],
      ),
    );
  }
}
