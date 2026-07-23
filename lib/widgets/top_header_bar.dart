import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Shared top bar — logo/wordmark + notification bell + profile avatar.
/// Used by every tab screen (Home, Program Listing, ...) so the chrome is
/// identical across tabs instead of each screen building its own.
class TopHeaderBar extends StatelessWidget {
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final String? avatarUrl;

  const TopHeaderBar({
    super.key,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.onProfileTap,
    this.avatarUrl,
  });

  static const String _defaultAvatarUrl =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo alone — the wordmark is baked into the logo image itself, so
        // no separate "Excelerate" text label is needed next to it.
        const _LogoMark(),
        Row(
          children: [
            GestureDetector(
              onTap: onNotificationTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.divider),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_none_outlined,
                      color: AppColors.textPrimary,
                      size: 22,
                    ),
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            '$notificationCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: 44,
                height: 44,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.divider, width: 1),
                ),
                child: CachedNetworkImage(
                  imageUrl: avatarUrl ?? _defaultAvatarUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: AppColors.divider),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.divider,
                    child: const Icon(
                      Icons.person_outline,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Renders the real logo asset once supplied; falls back to the existing
/// stylized "X" mark (two rotated bars) so the header still looks correct
/// before the asset file exists.
class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    // The logo asset is a wide wordmark (~4:1), not a square icon — sizing
    // the box to match its real aspect ratio instead of a square avoids
    // BoxFit.contain shrinking it down to a tiny sliver.
    return SizedBox(
      width: 190,
      height: 48,
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        errorBuilder: (context, error, stackTrace) => const _FallbackXMark(),
      ),
    );
  }
}

class _FallbackXMark extends StatelessWidget {
  const _FallbackXMark();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.rotate(
          angle: -0.785,
          child: Container(
            width: 10,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Positioned(
          left: 12,
          child: Transform.rotate(
            angle: 0.785,
            child: Container(
              width: 10,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
