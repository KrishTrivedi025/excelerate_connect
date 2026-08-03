import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_palette.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';

/// Light/dark toggle in TopHeaderBar, between the notification bell and the
/// profile avatar. Reads its state from Theme.of(context).brightness (not
/// from ThemeController directly) so it's correct even inside the lib/dev/
/// harnesses, which never touch the controller, and so it rebuilds via the
/// normal inherited-widget dependency rather than a second listener.
class ThemeToggleButton extends StatefulWidget {
  const ThemeToggleButton({super.key});

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  void _handleTap(Brightness current) {
    HapticFeedback.selectionClick();
    ThemeController.instance.toggleFrom(current);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDarkTheme;

    return Semantics(
      button: true,
      label: isDark ? 'Switch to light theme' : 'Switch to dark theme',
      child: Tooltip(
        message: isDark ? 'Switch to light theme' : 'Switch to dark theme',
        child: GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: () => _handleTap(Theme.of(context).brightness),
          child: AnimatedScale(
            // 100ms, matching _NavItem/_CenterButton in bottom_nav_bar.dart
            // so the press feedback feels native to the rest of the app.
            scale: _pressed ? 0.88 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
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
                  // Warm ambient glow, dark mode only — fades in with the
                  // theme itself via the outer TweenAnimationBuilder below.
                ],
              ),
              child: Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: isDark ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder: (context, haloT, child) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: haloT > 0
                            ? [
                                BoxShadow(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.22 * haloT,
                                  ),
                                  blurRadius: 14 * haloT,
                                ),
                              ]
                            : null,
                      ),
                      child: child,
                    );
                  },
                  child: TweenAnimationBuilder<Color?>(
                    tween: ColorTween(
                      begin: AppColors.accent,
                      end: isDark ? const Color(0xFFB9C4D8) : AppColors.accent,
                    ),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    builder: (context, tint, child) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: RotationTransition(
                                turns: Tween<double>(
                                  begin: 0.6,
                                  end: 1.0,
                                ).animate(animation),
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: Icon(
                          isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                          key: ValueKey(isDark),
                          color: tint,
                          size: 20,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
