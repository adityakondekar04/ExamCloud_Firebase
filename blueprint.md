
# Student Exam App Blueprint

## Overview

The Student Exam App is a mobile application built with Flutter that allows students to take exams in a secure environment. The app features a login screen, a dashboard, a list of available exams, and an exam-taking interface. To ensure a cheat-free environment, the app requires users to turn on airplane mode and disconnect from all networks before starting an exam. The app also prevents users from leaving the app during the exam and from going back to change their answers after finishing.

## Features

*   **Login Screen**: A simple login screen to authenticate users.
*   **Dashboard**: A central hub where students can see their registered exams and other relevant information.
*   **Available Exams**: A screen that lists all the available exams for the student to take.
*   **Exam Rules**: A screen that displays the rules of the exam, including the requirement to turn on airplane mode.
*   **Secure Exam Environment**: The app checks for network connectivity and disqualifies the user if any connection is detected during the exam.
*   **Question Navigation**: Users can navigate between questions during the exam.
*   **Submission**: After finishing the exam, users must reconnect to the internet to submit their answers.
*   **Modern UI**: The app uses a modern and visually appealing theme with custom fonts and colors.

## Project Structure

```
lib/
|-- database/
|   |-- database_helper.dart
|-- models/
|   |-- exam.dart
|   |-- question.dart
|-- screens/
|   |-- dashboard_screen.dart
|   |-- disqualification_screen.dart
|   |-- exam_screen.dart
|   |-- exams_screen.dart
|   |-- login_screen.dart
|   |-- rules_screen.dart
|   |-- submission_screen.dart
|-- main.dart
|-- router.dart
```

## Dependencies

*   `flutter/material.dart`
*   `go_router`
*   `sqflite`
*   `path_provider`
*   `connectivity_plus`
*   `google_fonts`
