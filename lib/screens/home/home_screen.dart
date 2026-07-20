import 'package:flutter/material.dart';

/// Temporary placeholder Home Screen.
/// The actual Home UI will be developed by another team member.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(
        child: Text('Home Screen - Developed by another team member'),
      ),
    );
  }
}