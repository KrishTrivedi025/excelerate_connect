import 'package:flutter/material.dart';

/// Decorative peach wave used at the bottom of Login and Sign-Up.
/// Callers should place this in a [Positioned] anchored to the physical
/// bottom of the screen (and wrap in [IgnorePointer]) so it stays put when
/// the keyboard opens instead of riding up with the shrinking layout.
class BottomWave extends StatelessWidget {
  // Single source of truth for the wave's height, so callers that need to
  // reserve space above it (e.g. Positioned(bottom: BottomWave.height)) can
  // never drift out of sync with the wave's actual rendered size.
  static const double height = 90;

  final Color color;

  const BottomWave({
    super.key,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _WavePainter(color: color)),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;

  _WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    path.moveTo(0, size.height * 0.55);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.05,
      size.width * 0.5,
      size.height * 0.35,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.65,
      size.width,
      size.height * 0.15,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
