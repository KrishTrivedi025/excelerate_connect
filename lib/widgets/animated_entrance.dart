import 'package:flutter/material.dart';

/// The staggered fade + slide-up entrance every card list in this app uses —
/// pass the item's position in the list as [index] so later items animate
/// in a beat after earlier ones.
class AnimatedEntrance extends StatelessWidget {
  final int index;
  final Widget child;

  const AnimatedEntrance({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 380 + (index * 90).clamp(0, 450)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}
