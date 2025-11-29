
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:examcloud/providers/user_provider.dart';
import 'package:examcloud/screens/login_screen.dart';
import 'package:examcloud/screens/dashboard_screen.dart';
import 'package:examcloud/screens/exams_screen.dart';
import 'package:examcloud/screens/profile_screen.dart';
import 'package:examcloud/screens/exam_attempt_screen.dart';
import 'package:examcloud/screens/rules_screen.dart';
import 'package:examcloud/screens/submission_screen.dart';
import 'package:examcloud/screens/disqualified_screen.dart';
import 'package:examcloud/screens/results_screen.dart';
import 'package:examcloud/screens/passkey_screen.dart'; // Import the new passkey screen
import 'package:examcloud/models/exam.dart';
import 'package:examcloud/main.dart'; // Import main.dart to access routeObserver

class AppRouter {
  final UserProvider userProvider;
  late final GoRouter router;

  AppRouter(this.userProvider) {
    final _rootNavigatorKey = GlobalKey<NavigatorState>();
    final _shellNavigatorKey = GlobalKey<NavigatorState>();

    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      refreshListenable: userProvider,
      redirect: (BuildContext context, GoRouterState state) {
        final bool isLoggedIn = userProvider.isLoggedIn;
        final bool isLoggingIn = state.matchedLocation == '/';

        if (!isLoggedIn && !isLoggingIn) {
          return '/';
        }
        if (isLoggedIn && isLoggingIn) {
          return '/dashboard';
        }
        return null;
      },
      observers: [routeObserver], // Add the observer here
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (context, state) => const LoginScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return Scaffold(
              body: child,
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _calculateSelectedIndex(state.matchedLocation),
                onTap: (index) => _onItemTapped(index, context),
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.school),
                    label: 'All Exams',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            );
          },
          routes: <RouteBase>[
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/exams',
              builder: (context, state) => const ExamsScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/passkey',
          builder: (context, state) {
            final exam = state.extra as Exam;
            return PasskeyScreen(exam: exam);
          },
        ),
        GoRoute(
          path: '/rules',
          builder: (context, state) {
            final exam = state.extra as Exam;
            return RulesScreen(exam: exam);
          },
        ),
        GoRoute(
          path: '/exam',
          builder: (context, state) {
            final exam = state.extra as Exam;
            return ExamAttemptScreen(exam: exam);
          },
        ),
        GoRoute(
          path: '/submission',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>;
            final exam = args['exam'] as Exam;
            final answers = args['answers'] as Map<int, int>;
            return SubmissionScreen(
              exam: exam,
              answers: answers,
            );
          },
        ),
        GoRoute(
          path: '/results',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>;
            final exam = args['exam'] as Exam;
            final answers = args['answers'] as Map<int, int>;
            return ResultsScreen(
              exam: exam,
              answers: answers,
            );
          },
        ),
        GoRoute(
          path: '/disqualified',
          builder: (context, state) => const DisqualifiedScreen(),
        ),
      ],
    );
  }

  static int _calculateSelectedIndex(String location) {
    if (location.startsWith('/dashboard')) {
      return 0;
    } else if (location.startsWith('/exams')) {
      return 1;
    } else if (location.startsWith('/profile')) {
      return 2;
    }
    return 0;
  }

  static void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/dashboard');
        break;
      case 1:
        GoRouter.of(context).go('/exams');
        break;
      case 2:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}
