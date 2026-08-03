import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';
import '../core/theme/app_theme.dart';
import 'theme_toggle_button.dart';

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
    final palette = context.palette;
    return Row(
      children: [
        // Expanded (not a fixed-width sibling in a spaceBetween Row) — a
        // third 44px control plus its gap pushes the old fixed layout past
        // 360dp and overflows on budget Android devices. Expanded lets the
        // logo shrink instead.
        const Expanded(child: _LogoMark()),
        Row(
          mainAxisSize: MainAxisSize.min,
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
                      color: palette.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: palette.divider),
                      boxShadow: [
                        BoxShadow(
                          color: palette.shadowSoft,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.notifications_none_outlined,
                      color: palette.textPrimary,
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
                          border: Border.all(color: palette.background, width: 1.5),
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
            const ThemeToggleButton(),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: 44,
                height: 44,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: palette.divider, width: 1),
                ),
                child: CachedNetworkImage(
                  imageUrl: avatarUrl ?? _defaultAvatarUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: palette.divider),
                  errorWidget: (context, url, error) => Container(
                    color: palette.divider,
                    child: Icon(
                      Icons.person_outline,
                      color: palette.textSecondary,
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
    // width: double.infinity (not a fixed 190) so this shrinks gracefully
    // under the Expanded wrapper on narrow screens instead of overflowing
    // once the header gained a third trailing control.
    final logo = SizedBox(
      width: double.infinity,
      height: 48,
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        errorBuilder: (context, error, stackTrace) => const _FallbackXMark(),
      ),
    );

    // logo.png has no alpha channel — it's opaque art on a near-white
    // #F7F7F5 plate. In light mode that's invisible against the page; in
    // dark mode it would render as a stark white rectangle. This container
    // is a no-op in light (transparent) and frames the logo as a
    // deliberate badge in dark, matching its own baked-in ground exactly
    // so there's no visible seam.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.palette.logoPlate,
        borderRadius: BorderRadius.circular(10),
      ),
      child: logo,
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
