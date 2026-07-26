import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Bottom-nav icon loaded from a Lordicon-exported Lottie animation at
/// `assets/icons/{name}.json`. Plays once when the tab becomes active (per
/// Lordicon's own guidance against constantly-looping icons) and otherwise
/// sits still. Active/inactive state is shown via opacity + scale rather
/// than recoloring, so each icon keeps whatever color it was exported with.
/// Falls back to [fallback] so the bar still renders correctly (and stays
/// genuinely animated, not just a static glyph) before the real files are
/// dropped in.
class LottieNavIcon extends StatelessWidget {
  final String name;
  final Widget fallback;
  final bool isActive;
  final double size;

  const LottieNavIcon({
    super.key,
    required this.name,
    required this.fallback,
    required this.isActive,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isActive ? 1.0 : 0.86,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.55,
        duration: const Duration(milliseconds: 200),
        child: SizedBox(
          width: size,
          height: size,
          child: Lottie.asset(
            'assets/icons/$name.json',
            width: size,
            height: size,
            fit: BoxFit.contain,
            repeat: false,
            animate: isActive,
            errorBuilder: (context, error, stackTrace) => fallback,
          ),
        ),
      ),
    );
  }
}
