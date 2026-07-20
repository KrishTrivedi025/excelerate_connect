// Dev-only entry point. Lets the Home screen owner preview it directly
// without navigating through the rest of the app. Never imported by
// lib/main.dart — this is not part of the shipped app.
//
// Run:  flutter run -t lib/dev/main_home.dart
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../screens/home/home_screen.dart';

void main() {
  runApp(const _DevApp());
}

class _DevApp extends StatelessWidget {
  const _DevApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excelerate Connect — Home (dev)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
