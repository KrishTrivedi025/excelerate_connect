import 'package:flutter/material.dart';

/// Placeholder — spec Section 4.2. Replace with the real Sign-Up UI
/// (Full Name / Email / Password / Confirm Password / University dropdown /
/// Terms checkbox / Create Account button). Route: /signup.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Sign-Up Screen')),
    );
  }
}
