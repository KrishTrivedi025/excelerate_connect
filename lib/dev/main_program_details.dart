// Dev-only entry point. Lets the Program Details screen owner preview it
// directly without navigating through the rest of the app. This screen
// needs an Opportunity argument (normally passed via Navigator), so this
// harness feeds it the first mock program instead. Never imported by
// lib/main.dart — this is not part of the shipped app.
//
// Run:  flutter run -t lib/dev/main_program_details.dart
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';
import '../screens/program_details/program_details_screen.dart';

void main() {
  runApp(const _DevApp());
}

class _DevApp extends StatelessWidget {
  const _DevApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excelerate Connect — Program Details (dev)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: ProgramDetailsScreen(opportunity: mockOpportunities.first),
    );
  }
}
