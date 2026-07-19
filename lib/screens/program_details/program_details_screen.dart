import 'package:flutter/material.dart';
import '../../data/mock_data.dart';

class ProgramDetailsScreen extends StatelessWidget {
  final Opportunity opportunity;

  const ProgramDetailsScreen({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(opportunity.name)),
      body: const Center(child: Text('Program Details Screen')),
    );
  }
}
