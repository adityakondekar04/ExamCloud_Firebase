
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:myapp/models/exam.dart';

class SubmissionScreen extends StatefulWidget {
  final Map<String, dynamic> extra;
  const SubmissionScreen({super.key, required this.extra});

  @override
  State<SubmissionScreen> createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends State<SubmissionScreen> {
  bool _isConnected = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      _updateConnectionStatus(result);
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    if (!mounted) return;
    setState(() {
      _isConnected = result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi);
    });
  }

  void _submitExam() {
    if (_isConnected) {
      // Here you would typically send the data to your server.
      // For this example, we'll just simulate a delay.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submitting your answers...')),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Exam submitted successfully!'),
              backgroundColor: Colors.green),
        );
        // Navigate to the dashboard after submission
        context.go('/dashboard');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Exam exam = widget.extra['exam'];
    final List<int?> answers = widget.extra['answers'];
    final int totalQuestions = answers.length;
    final int answeredQuestions = answers.where((a) => a != null).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Submit ${exam.title}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        automaticallyImplyLeading: false, // Prevents going back
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Exam Finished!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'You answered $answeredQuestions out of $totalQuestions questions.',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (!_isConnected)
                const Card(
                  color: Colors.amber,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Please turn on your internet connection to submit the exam.',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isConnected ? _submitExam : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: _isConnected ? Colors.green : Colors.grey,
                ),
                child: const Text('Submit Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
