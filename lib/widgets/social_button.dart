import 'package:flutter/material.dart';

enum SocialProvider {
  google,
  apple,
}

class SocialButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback? onPressed;

  const SocialButton({
    super.key,
    required this.provider,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGoogle = provider == SocialProvider.google;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          isGoogle ? Icons.g_mobiledata : Icons.apple,
          size: 28,
        ),
        label: Text(
          isGoogle
              ? 'Continue with Google'
              : 'Continue with Apple',
        ),
      ),
    );
  }
}