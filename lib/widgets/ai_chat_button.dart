import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';
import '../core/theme/app_theme.dart';
import 'flexible_asset_image.dart';

/// Floating AI assistant launcher — Home screen only.
///
/// Shows a custom image dropped at assets/images/chatbot_icon.{png,jpg,
/// jpeg,webp} (via FlexibleAssetImage, same convention as every other image
/// in this app — extension doesn't need to match in code). Falls back to a
/// plain icon so the app doesn't crash while that file is still a
/// placeholder.
class AiChatButton extends StatelessWidget {
  // Single source of truth for the launcher's diameter — change this one
  // number to resize the circle (e.g. 72 for smaller, 96 for bigger). The
  // fallback icon inside scales proportionally with it.
  static const double size = 68;

  final bool showHint;
  final VoidCallback onDismissHint;
  final VoidCallback onTap;

  const AiChatButton({
    super.key,
    required this.showHint,
    required this.onDismissHint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 104,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _HintBubble(visible: showHint, onTap: onDismissHint),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Moderate, soft ambient glow — restrained on purpose, not a
              // bright/animated halo.
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.32),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  blurRadius: 36,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  onDismissHint();
                  onTap();
                },
                child: FlexibleAssetImage(
                  baseName: 'assets/images/chatbot_icon',
                  fit: BoxFit.cover,
                  fallback: (context) => Icon(
                    Icons.smart_toy_outlined,
                    color: AppColors.primary,
                    size: size * 0.45,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HintBubble extends StatelessWidget {
  final bool visible;
  final VoidCallback onTap;

  const _HintBubble({required this.visible, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // inverseSurface/onInverseSurface, not textPrimary/white — textPrimary
    // is a BACKGROUND here, and it flips to near-white in dark mode, which
    // would turn this into a near-white bubble with unreadable white text.
    final palette = context.palette;
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 250),
      child: IgnorePointer(
        ignoring: !visible,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: palette.inverseSurface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: palette.shadowStrong,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'Hi! 👋 Click me',
              style: TextStyle(
                color: palette.onInverseSurface,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
