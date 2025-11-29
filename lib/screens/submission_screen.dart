
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:examcloud/models/exam.dart';

class SubmissionScreen extends StatefulWidget {
  final Exam exam;
  final Map<int, int> answers;

  const SubmissionScreen({super.key, required this.exam, required this.answers});

  @override
  State<SubmissionScreen> createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends State<SubmissionScreen> {
  bool _isOnline = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _listenToConnectivityChanges();
  }

  void _checkInitialConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = !connectivityResult.contains(ConnectivityResult.none);
    });
  }

  void _listenToConnectivityChanges() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      setState(() {
        _isOnline = !results.contains(ConnectivityResult.none);
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _submit() {
    context.go('/results', extra: {'exam': widget.exam, 'answers': widget.answers});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finish Exam'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'You have finished the exam.',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Text(
                'To submit your exam and view your results, please turn off Airplane Mode and connect to the internet.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (!_isOnline)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Waiting for internet connection...',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ElevatedButton(
                onPressed: _isOnline ? _submit : null,
                child: const Text('Submit Exam'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
