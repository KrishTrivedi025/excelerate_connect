import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Component Library 6.5 — Home screen hero banner (top section only).
/// [image] source (asset vs. network) is the caller's decision — see spec
/// Section 2.6 for how the team should source the Excelerate hero image.
class HeroBanner extends StatelessWidget {
  final ImageProvider image;
  final String title;
  final String subtitle;
  final VoidCallback onCtaTap;
  final String ctaLabel;

  const HeroBanner({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.onCtaTap,
    this.ctaLabel = 'Explore Programs',
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(AppRadius.hero),
        bottomRight: Radius.circular(AppRadius.hero),
      ),
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              image: image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const ColoredBox(
                color: AppColors.primary,
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // rgba(0,0,0,0.35) -> rgba(0,0,0,0.05), spec Section 4.3.
                  colors: [Color(0x59000000), Color(0x0D000000)],
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: AppSpacing.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: textTheme.displayLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PillCta(label: ctaLabel, onTap: onCtaTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillCta extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PillCta({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.xs,
        ),
        shape: const StadiumBorder(),
        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
            ),
      ),
      child: Text(label),
    );
  }
}
