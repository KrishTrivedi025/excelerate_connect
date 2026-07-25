import 'dart:ui';

import 'package:flutter/material.dart';

/// Frosted-glass floating action bar — a rounded pill that floats above the
/// physical screen bottom (margin on every side, not edge-to-edge), using
/// the same blur treatment as [BottomNavBar] so both read as one consistent
/// "floating bottom surface" language instead of each screen inventing its
/// own bottom bar. Self-positions via an internal [Positioned], so callers
/// just drop this directly into their own body [Stack] — same convention as
/// [BottomNavBar].
class FloatingActionBar extends StatelessWidget {
  /// Optional leading control (e.g. a bookmark toggle). Omit for a bar
  /// that's just the primary action, full width.
  final Widget? leading;
  final Widget child;

  const FloatingActionBar({super.key, this.leading, required this.child});

  static const double _cornerRadius = 24;
  static const double _blurSigma = 13;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Positioned(
      left: 20,
      right: 20,
      bottom: bottomInset + 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cornerRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 16, 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(_cornerRadius),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 8)],
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
