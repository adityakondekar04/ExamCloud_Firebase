
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/exam.dart';
import 'package:myapp/screens/dashboard_screen.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/exams_screen.dart';
import 'package:myapp/screens/rules_screen.dart';
import 'package:myapp/screens/exam_screen.dart';
import 'package:myapp/screens/disqualified_screen.dart';
import 'package:myapp/screens/submission_screen.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'dashboard',
          builder: (BuildContext context, GoRouterState state) {
            return const DashboardScreen();
          },
        ),
        GoRoute(
          path: 'exams',
          builder: (BuildContext context, GoRouterState state) {
            return const ExamsScreen();
          },
        ),
        GoRoute(
            path: 'rules',
            builder: (BuildContext context, GoRouterState state) {
              final exam = state.extra as Exam?;
              if (exam != null) {
                return RulesScreen(exam: exam);
              } else {
                // Handle the case where exam is null, maybe redirect or show an error
                return const ExamsScreen(); // Redirecting to exams screen for safety
              }
            }),
        GoRoute(
            path: 'exam',
            builder: (BuildContext context, GoRouterState state) {
              final exam = state.extra as Exam?;
              if (exam != null) {
                return ExamScreen(exam: exam);
              } else {
                return const ExamsScreen();
              }
            }),
        GoRoute(
          path: 'disqualified',
          builder: (BuildContext context, GoRouterState state) {
            return const DisqualifiedScreen();
          },
        ),
        GoRoute(
            path: 'submission',
            builder: (BuildContext context, GoRouterState state) {
              final extra = state.extra as Map<String, dynamic>?;
              if (extra != null) {
                return SubmissionScreen(extra: extra);
              } else {
                return const ExamsScreen();
              }
            }),
      ],
    ),
  ],
);
