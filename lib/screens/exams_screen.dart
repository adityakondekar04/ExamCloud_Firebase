
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:examcloud/database/database_helper.dart';
import 'package:examcloud/models/exam.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  late Future<List<Exam>> _examsFuture;
  final Set<int> _registeredExams = {};

  @override
  void initState() {
    super.initState();
    _loadExams();
    _loadRegisteredExams();
  }

  void _loadExams() {
    _examsFuture = DatabaseHelper().getExams();
  }

  void _loadRegisteredExams() async {
    final registered = await DatabaseHelper().getRegisteredExams();
    setState(() {
      _registeredExams.addAll(registered.map((e) => e.id));
    });
  }

  void _registerForExam(Exam exam) async {
    await DatabaseHelper().registerForExam(exam.id);
    setState(() {
      _registeredExams.add(exam.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully registered for ${exam.title}.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Exams'),
      ),
      body: FutureBuilder<List<Exam>>(
        future: _examsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No exams available.'));
          } else {
            final exams = snapshot.data!;
            return ListView.builder(
              itemCount: exams.length,
              itemBuilder: (context, index) {
                final exam = exams[index];
                final isRegistered = _registeredExams.contains(exam.id);
                return ListTile(
                  title: Text(exam.title),
                  subtitle: Text('Duration: ${exam.duration} minutes'),
                  trailing: isRegistered
                      ? ElevatedButton(
                          onPressed: () {
                            context.go('/passkey', extra: exam);
                          },
                          child: const Text('Start Exam'),
                        )
                      : ElevatedButton(
                          onPressed: () => _registerForExam(exam),
                          child: const Text('Register'),
                        ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
