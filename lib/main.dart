
import 'package:flutter/material.dart';
import 'package:myapp/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6200EE);
    const secondaryColor = Color(0xFF03DAC6);

    final textTheme = Theme.of(context).textTheme.apply(
          fontFamily: 'Lato',
        );

    return MaterialApp.router(
      routerConfig: router,
      title: 'Student Exam App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
          surface: Colors.grey[100],
          onSurface: Colors.black,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onError: Colors.white,
        ),
        textTheme: textTheme.copyWith(
          displayLarge: const TextStyle(fontSize: 57, fontWeight: FontWeight.bold, fontFamily: 'Oswald'),
          titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
          bodyMedium: const TextStyle(fontSize: 14, fontFamily: 'Lato'),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(fontFamily: 'Oswald', fontSize: 24, fontWeight: FontWeight.bold)
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
          ),
        ),
        useMaterial3: true,
      ),
    );
  }
}
