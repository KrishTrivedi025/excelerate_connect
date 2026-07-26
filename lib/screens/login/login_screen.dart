import 'package:flutter/material.dart';

import '../../core/routes/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/bottom_wave.dart';
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
  static final RegExp _emailRegex =
      RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

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

      Navigator.pushReplacementNamed(context, AppRouter.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
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
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Scaffold(
      backgroundColor: AppColors.background,
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            child: SizedBox(
                              width: 220,
                              height: 66,
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
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
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Excelerate Connect',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Learn • Grow • Excel',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
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
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Sign in to continue your learning journey.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                PrimaryTextField(
                                  controller: _emailController,
                                  labelText: 'Email Address',
                                  hintText: 'Enter your email address',
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  prefixIcon: Icons.mail_outline,
                                  validator: _validateEmail,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                PasswordField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  hintText: 'Enter your password',
                                  textInputAction: TextInputAction.done,
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
                                      foregroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: AppSpacing.xs,
                                      ),
                                    ),
                                    child: const Text(
                                      'Forgot Password?',
                                      style:
                                          TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                PrimaryButton(
                                  label: 'Login',
                                  isLoading: _isLoading,
                                  onPressed: _isLoading ? null : _handleLogin,
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
                                : () => _showComingSoon('Google sign-in'),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SocialButton(
                            provider: SocialProvider.apple,
                            onPressed: _isLoading
                                ? null
                                : () => _showComingSoon('Apple sign-in'),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          // Wrap prevents overflow on narrow screens: falls
                          // to a second line before it clips.
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                              GestureDetector(
                                onTap: _isLoading ? null : _navigateToSignup,
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
              child: BottomWave(color: AppColors.wave),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: AppColors.divider, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            'OR',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Expanded(
          child: Divider(color: AppColors.divider, thickness: 1),
        ),
      ],
    );
  }
}
