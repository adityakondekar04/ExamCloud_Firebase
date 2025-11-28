
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Student Name'),
            ),
            ListTile(
              title: const Text('Exams'),
              onTap: () {
                context.go('/exams');
              },
            ),
            ListTile(
              title: const Text('Attempt Exam'),
              onTap: () {
                context.go('/attempt-exam');
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Welcome to your dashboard!'),
      ),
    );
  }
}
