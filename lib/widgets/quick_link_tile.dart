import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Component Library 6.3 — Home screen "Quick Links" grid tile.
class QuickLinkTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickLinkTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<QuickLinkTile> createState() => _QuickLinkTileState();
}

class _QuickLinkTileState extends State<QuickLinkTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: InkWell(
        onTap: widget.onTap,
        onHighlightChanged: (isHighlighted) {
          setState(() => _pressed = isHighlighted);
        },
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFE3F2FD),
                  child: Icon(widget.icon, color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
