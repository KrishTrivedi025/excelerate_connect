import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/routes/app_router.dart';
import '../core/theme/app_theme.dart';
import 'lottie_nav_icon.dart';

/// Which bottom-nav tab a screen represents — drives which icon is
/// highlighted and which tap is a no-op (already on that tab).
enum AppTab { home, explore, learning, profile }

/// Shared floating bottom navigation bar. Used by every tab screen so it
/// stays visible and consistent across the app instead of disappearing on
/// screens that don't happen to build their own copy.
///
/// Shape: flush against the physical bottom edge (no floating gap), with a
/// single smooth arched top edge (via [_NavBarClipper]) that peaks under the
/// center button, and a frosted-glass blur fill instead of a flat surface
/// color. Callers must not wrap this in a bottom-safe-area — it manages its
/// own bottom inset internally (see [MediaQuery.paddingOf] below).
class BottomNavBar extends StatelessWidget {
  final AppTab activeTab;

  const BottomNavBar({super.key, required this.activeTab});

  static const double _cornerRadius = 24;
  static const double _archRise = 25;
  static const double _barBodyHeight = 80;
  static const double _buttonSize = 76;

  // Frosted-glass blur strength — raise for blurrier, lower for clearer.
  static const double _blurSigma = 13;

  void _goToTab(BuildContext context, AppTab tab, String routeName) {
    if (activeTab == tab) return;
    AppRouter.goToTab(context, routeName);
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final totalHeight = _archRise + _barBodyHeight + bottomInset;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: ClipPath(
                clipper: const _NavBarClipper(
                  cornerRadius: _cornerRadius,
                  archRise: _archRise,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.55),
                      border: const Border(
                        top: BorderSide(color: Colors.white, width: 1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              top: _archRise + 8,
              bottom: bottomInset + 6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    lottieName: 'nav_home',
                    motion: _IconMotion.bounce,
                    label: 'Home',
                    isActive: activeTab == AppTab.home,
                    onTap: () => _goToTab(context, AppTab.home, AppRouter.home),
                  ),
                  _NavItem(
                    icon: Icons.explore_outlined,
                    lottieName: 'nav_explore',
                    motion: _IconMotion.spin,
                    label: 'Explore',
                    isActive: activeTab == AppTab.explore,
                    onTap: () => _goToTab(
                      context,
                      AppTab.explore,
                      AppRouter.programListing,
                    ),
                  ),
                  const SizedBox(width: _buttonSize - 20),
                  _NavItem(
                    icon: Icons.play_circle_outline,
                    lottieName: 'nav_learning',
                    motion: _IconMotion.playPause,
                    label: 'Learning',
                    isActive: activeTab == AppTab.learning,
                    onTap: () => _showComingSoon(context, 'Learning'),
                  ),
                  _NavItem(
                    icon: Icons.person_outline,
                    lottieName: 'nav_profile',
                    motion: _IconMotion.bounce,
                    label: 'Profile',
                    isActive: activeTab == AppTab.profile,
                    onTap: () => _showComingSoon(context, 'Profile'),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Transform.translate(
                offset: const Offset(0, -_buttonSize * 0.20),
                child: _CenterButton(
                  onTap: () => _showComingSoon(context, 'Course Syllabus'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Clips the bar's background into one continuous smooth arc across the
/// full top edge — rounded at the far top-left/top-right corners, rising
/// gently to its peak (right where the center button sits) rather than a
/// flat edge or a hard notch.
class _NavBarClipper extends CustomClipper<Path> {
  final double cornerRadius;
  final double archRise;

  const _NavBarClipper({required this.cornerRadius, required this.archRise});

  @override
  Path getClip(Size size) {
    final flatTopY = archRise;
    final centerX = size.width / 2;
    final archSpread = size.width - cornerRadius * 2 - 24;

    return Path()
      ..moveTo(0, flatTopY + cornerRadius)
      ..quadraticBezierTo(0, flatTopY, cornerRadius, flatTopY)
      ..lineTo(centerX - archSpread / 2, flatTopY)
      ..cubicTo(
        centerX - archSpread / 4,
        flatTopY,
        centerX - archSpread / 4,
        0,
        centerX,
        0,
      )
      ..cubicTo(
        centerX + archSpread / 4,
        0,
        centerX + archSpread / 4,
        flatTopY,
        centerX + archSpread / 2,
        flatTopY,
      )
      ..lineTo(size.width - cornerRadius, flatTopY)
      ..quadraticBezierTo(
        size.width,
        flatTopY,
        size.width,
        flatTopY + cornerRadius,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant _NavBarClipper oldClipper) {
    return oldClipper.cornerRadius != cornerRadius ||
        oldClipper.archRise != archRise;
  }
}

/// Which built-in Flutter animation a nav icon's placeholder plays — stands
/// in for the real Lordicon animation until that file is dropped in.
enum _IconMotion { bounce, spin, playPause }

/// Plays [motion] once whenever [trigger] flips. For `playPause` the two
/// ends are visually distinct states (play vs pause) so it tracks direction
/// with forward()/reverse(); bounce/spin just replay forward from 0 since
/// their start and end frames look identical.
class _MotionIcon extends StatefulWidget {
  final IconData icon;
  final _IconMotion motion;
  final bool trigger;
  final Color color;
  final double size;

  const _MotionIcon({
    required this.icon,
    required this.motion,
    required this.trigger,
    required this.color,
    required this.size,
  });

  @override
  State<_MotionIcon> createState() => _MotionIconState();
}

class _MotionIconState extends State<_MotionIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flourish = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  static final Animatable<double> _bounceTween = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 1.28).chain(CurveTween(curve: Curves.easeOut)),
      weight: 40,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.28, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
      weight: 60,
    ),
  ]);

  @override
  void initState() {
    super.initState();
    if (widget.motion == _IconMotion.playPause) {
      _flourish.value = widget.trigger ? 1.0 : 0.0;
    } else if (widget.trigger) {
      _flourish.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(covariant _MotionIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger == widget.trigger) return;
    if (widget.motion == _IconMotion.playPause) {
      widget.trigger ? _flourish.forward() : _flourish.reverse();
    } else {
      _flourish.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _flourish.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.motion) {
      case _IconMotion.spin:
        return RotationTransition(
          turns: CurvedAnimation(parent: _flourish, curve: Curves.easeInOutCubic),
          child: Icon(widget.icon, color: widget.color, size: widget.size),
        );
      case _IconMotion.playPause:
        return AnimatedIcon(
          icon: AnimatedIcons.play_pause,
          progress: CurvedAnimation(parent: _flourish, curve: Curves.easeInOut),
          color: widget.color,
          size: widget.size,
        );
      case _IconMotion.bounce:
        return ScaleTransition(
          scale: _bounceTween.animate(_flourish),
          child: Icon(widget.icon, color: widget.color, size: widget.size),
        );
    }
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String lottieName;
  final _IconMotion motion;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.lottieName,
    required this.motion,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.isActive ? AppColors.primary : AppColors.textSecondary;
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: 58,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LottieNavIcon(
                name: widget.lottieName,
                isActive: widget.isActive,
                size: 35,
                fallback: _MotionIcon(
                  icon: widget.icon,
                  motion: widget.motion,
                  trigger: widget.isActive,
                  color: color,
                  size: 35,
                ),
              ),
              const SizedBox(height: 5),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterButton extends StatefulWidget {
  final VoidCallback onTap;

  const _CenterButton({required this.onTap});

  @override
  State<_CenterButton> createState() => _CenterButtonState();
}

class _CenterButtonState extends State<_CenterButton> {
  bool _pressed = false;
  bool _bounceTrigger = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  void _handleTap() {
    setState(() => _bounceTrigger = !_bounceTrigger);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: BottomNavBar._buttonSize,
          height: BottomNavBar._buttonSize,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: LottieNavIcon(
              name: 'nav_course',
              isActive: true,
              size: 34,
              fallback: _MotionIcon(
                icon: Icons.menu_book_rounded,
                motion: _IconMotion.bounce,
                trigger: _bounceTrigger,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
