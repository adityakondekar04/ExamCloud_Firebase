
import 'package:flutter/material.dart';

class DisqualificationScreen extends StatelessWidget {
  const DisqualificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('You have been disqualified for accessing the internet.'),
      ),
    );
  }
}
