import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/bottom_wave.dart';
import '../../widgets/branded_loader.dart';
import '../../widgets/password_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/primary_text_field.dart';
import '../../widgets/social_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Class-level so we don't rebuild these on every validator call.
  static final RegExp _emailRegex = RegExp(
    r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$',
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // Shown full-screen once auth succeeds, while the app "fetches" the
  // learner's Home data — bridges the gap instead of an instant cut.
  bool _isFetchingData = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO(auth): Replace with actual authentication call.
      await Future<void>.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isFetchingData = true;
      });

      // Simulated fetch of the learner's Home data (announcements, featured
      // programs, etc.) — a fixed delay for now, matching the branded
      // loading screen this app shows for every async fetch.
      await Future<void>.delayed(const Duration(milliseconds: 2500));

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRouter.home);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isFetchingData = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          // Explicit white text — the theme's snackBarTheme.contentTextStyle
          // is tuned for the default inverseSurface background (dark text on
          // a light chip in dark mode), which would be unreadable on this
          // red fill.
          content: Text(
            'Login failed. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — coming soon'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        margin: const EdgeInsets.only(
          bottom: BottomWave.height + AppSpacing.md,
          left: AppSpacing.lg,
          right: AppSpacing.lg,
        ),
      ),
    );
  }

  void _navigateToSignup() {
    Navigator.pushNamed(context, AppRouter.signup);
  }

  @override
  Widget build(BuildContext context) {
    // Login always renders in light mode, regardless of the app-wide theme
    // toggle — auth screens are an intentional exemption (same treatment
    // in signup_screen.dart), the same way AiChatScreen is always dark.
    // This Theme override is what makes every Material widget below
    // (fields, buttons) render light too, no matter ThemeController's
    // current global mode.
    return Theme(
      data: AppTheme.light,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    // Referenced directly (not context.palette) — this method is still
    // handed the pre-override context from build() above, since the Theme
    // override wraps around its return value rather than sitting above it.
    const palette = AppPalette.light;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _isFetchingData
          ? Scaffold(
              key: const ValueKey('loading'),
              backgroundColor: palette.background,
              body: Center(child: BrandedLoader(width: 110)),
            )
          : Scaffold(
              key: const ValueKey('form'),
              backgroundColor: palette.background,
              // Keep the wave pinned to the physical screen bottom when the keyboard
              // opens instead of letting the layout shrink and drag it upward.
              resizeToAvoidBottomInset: false,
              body: Stack(
                children: [
                  // Content — scrolls, respects the keyboard via bottom padding on the
                  // outer wrapper so focused fields still auto-scroll into view.
                  // bottom: BottomWave.height reserves the wave's strip so the
                  // scrollable viewport can never render content behind it, at any
                  // scroll position — not just when scrolled all the way down.
                  // Once the keyboard is open it already covers that whole strip
                  // (and more), so the reservation would just become a dead gap
                  // sitting above the keyboard — drop it while the keyboard is up.
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: viewInsets.bottom > 0 ? 0 : BottomWave.height,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: viewInsets.bottom),
                        // LayoutBuilder must wrap the ScrollView, not sit inside it —
                        // a vertical SingleChildScrollView gives its child unbounded
                        // height (that's what lets it scroll), so a LayoutBuilder
                        // placed inside would read maxHeight as infinite. Measuring
                        // here, above the scroll view, captures the real bounded
                        // viewport height instead.
                        child: LayoutBuilder(
                          builder: (context, outerConstraints) => SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: outerConstraints.maxHeight,
                                  maxWidth: 440,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  // Centers content vertically within the box instead
                                  // of packing it at the top — the box is already
                                  // forced to full viewport height (see minHeight
                                  // above), so without this the extra space just
                                  // collects below the content instead of the whole
                                  // block sitting in the middle of the screen.
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: AppSpacing.xxl),
                                    Center(
                                      // Sized to the logo's real ~4:1 wide-wordmark
                                      // aspect ratio (not a square) so it renders at a
                                      // legible size instead of BoxFit.contain
                                      // shrinking it to fit a square box.
                                      //
                                      // logo.png has no alpha channel — opaque art on
                                      // a near-white #F7F7F5 plate. This Container is
                                      // a no-op in light mode (transparent) and frames
                                      // it as a deliberate badge in dark mode instead
                                      // of showing a stark white rectangle.
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: palette.logoPlate,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: SizedBox(
                                          width: 220,
                                          height: 66,
                                          child: Image.asset(
                                            'assets/images/logo.png',
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => const Center(
                                                  child: Text(
                                                    'X',
                                                    style: TextStyle(
                                                      fontSize: 48,
                                                      fontWeight: FontWeight.w900,
                                                      height: 1,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      'Excelerate Connect',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: palette.textPrimary,
                                          ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'Learn • Grow • Excel',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: palette.textSecondary,
                                          ),
                                    ),
                                    const SizedBox(height: AppSpacing.xl),
                                    Text(
                                      'Welcome Back 👋',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: palette.textPrimary,
                                          ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'Sign in to continue your learning journey.',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: palette.textSecondary,
                                          ),
                                    ),
                                    const SizedBox(height: AppSpacing.xl),
                                    Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          PrimaryTextField(
                                            controller: _emailController,
                                            labelText: 'Email Address',
                                            hintText:
                                                'Enter your email address',
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            textInputAction:
                                                TextInputAction.next,
                                            prefixIcon: Icons.mail_outline,
                                            validator: _validateEmail,
                                          ),
                                          const SizedBox(height: AppSpacing.md),
                                          PasswordField(
                                            controller: _passwordController,
                                            label: 'Password',
                                            hintText: 'Enter your password',
                                            textInputAction:
                                                TextInputAction.done,
                                            validator: _validatePassword,
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                              onPressed: _isLoading
                                                  ? null
                                                  : () => _showComingSoon(
                                                      'Forgot password',
                                                    ),
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                    AppColors.primary,
                                                overlayColor:
                                                    Colors.transparent,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: AppSpacing.xs,
                                                    ),
                                              ),
                                              child: const Text(
                                                'Forgot Password?',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.sm),
                                          PrimaryButton(
                                            label: 'Login',
                                            isLoading: _isLoading,
                                            onPressed: _isLoading
                                                ? null
                                                : _handleLogin,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xl),
                                    const _OrDivider(),
                                    const SizedBox(height: AppSpacing.lg),
                                    SocialButton(
                                      provider: SocialProvider.google,
                                      onPressed: _isLoading
                                          ? null
                                          : () => _showComingSoon(
                                              'Google sign-in',
                                            ),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    SocialButton(
                                      provider: SocialProvider.apple,
                                      onPressed: _isLoading
                                          ? null
                                          : () => _showComingSoon(
                                              'Apple sign-in',
                                            ),
                                    ),
                                    const SizedBox(height: AppSpacing.xl),
                                    // Wrap prevents overflow on narrow screens: falls
                                    // to a second line before it clips.
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          "Don't have an account? ",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: palette.textSecondary,
                                              ),
                                        ),
                                        GestureDetector(
                                          onTap: _isLoading
                                              ? null
                                              : _navigateToSignup,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Create Account',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Icon(
                                                Icons.arrow_forward,
                                                size: 16,
                                                color: AppColors.primary,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.xl),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Wave anchored to the physical screen bottom; ignored by hit-testing
                  // so it never intercepts taps on content that scrolls over it.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: BottomWave(color: palette.wave),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Expanded(child: Divider(color: palette.divider, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            'OR',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: palette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: palette.divider, thickness: 1)),
      ],
    );
  }
}
