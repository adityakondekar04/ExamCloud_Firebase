
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:examcloud/models/exam.dart';

class PasskeyScreen extends StatefulWidget {
  final Exam exam;
  const PasskeyScreen({super.key, required this.exam});

  @override
  State<PasskeyScreen> createState() => _PasskeyScreenState();
}

class _PasskeyScreenState extends State<PasskeyScreen> {
  final _passkeyController = TextEditingController();
  String? _errorMessage;

  void _verifyPasskey() {
    if (_passkeyController.text == widget.exam.passkey) {
      context.go('/rules', extra: widget.exam);
    } else {
      setState(() {
        _errorMessage = 'Incorrect passkey. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter Exam Passkey',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _passkeyController,
              decoration: InputDecoration(
                labelText: 'Passkey',
                errorText: _errorMessage,
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _verifyPasskey,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
