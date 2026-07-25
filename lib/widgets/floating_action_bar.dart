import 'dart:ui';

import 'package:flutter/material.dart';

/// Frosted-glass bottom action bar — full width, flush to the physical
/// screen bottom (no gap beneath it), with only the top corners curved.
/// Mirrors [HeroBanner]'s shape upside down (that one curves its bottom
/// corners only; this curves its top corners only) so the two read as the
/// same visual language. Self-positions via an internal [Positioned], so
/// callers just drop this directly into their own body [Stack] — same
/// convention as [BottomNavBar].
class FloatingActionBar extends StatelessWidget {
  /// Optional leading control (e.g. a bookmark toggle). Omit for a bar
  /// that's just the primary action, full width.
  final Widget? leading;
  final Widget child;

  /// Fades the bar out (and stops it from intercepting taps) without
  /// removing it — e.g. Registration hides this once its own success panel
  /// is showing, so the two can never visually overlap. The fade lives
  /// *inside* the self-positioning Positioned below rather than a caller
  /// wrapping this whole widget in AnimatedOpacity: Positioned requires its
  /// immediate parent to be a Stack, and a widget like AnimatedOpacity in
  /// between breaks that.
  final bool visible;

  const FloatingActionBar({
    super.key,
    this.leading,
    required this.child,
    this.visible = true,
  });

  static const double _cornerRadius = 28;

  // Blur strength — raise for a blurrier bar, lower for clearer.
  static const double _blurSigma = 13;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: visible ? 1 : 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(_cornerRadius),
              topRight: Radius.circular(_cornerRadius),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  border: const Border(top: BorderSide(color: Colors.white)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 10),
                    ],
                    Expanded(child: child),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
